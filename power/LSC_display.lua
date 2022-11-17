local component = require("component")
local computer = require("computer")
local os = require("os")
local Serial = require("serialization")
local math = require("math")
local gpu = component.gpu
local glasses=component.glasses

local lsc = component.proxy("83d81a1c-55e4-4a46-a63b-70a5997f142a")
local inputHatch = component.proxy("b5c1d2d9-0254-4b47-9582-eab46c49778f") 
local outputHatch = component.proxy("37293af0-80a7-4160-9bdc-91f66348a62f")

--local w,h=160,50
--gpu.setResolution(32,6)
gpu.setResolution(80,15)
local w, h = gpu.getResolution()
local halfW=w/2
local vertBarr=h-4
local sleepTime=0.05 --s
local updateInterval = 80/(sleepTime/0.05) --4s

local xcolors = {           --NIDAS colors
    red = 0xFF0000,
    lime = 0x00FF00,
    blue = 0x0000FF,
    magenta = 0xFF00FF,
    yellow = 0xFFFF00,
    cyan = 0x00FFFF,
    greenYellow = 0xADFF2F,
    green = 0x008000,
    darkOliveGreen = 0x556B2F,
    indigo = 0x4B0082,
    purple = 0x800080,
    electricBlue = 0x00A6FF,
    dodgerBlue = 0x1E90FF,
    steelBlue = 0x4682B4,
    darkSlateBlue = 0x483D8B,
    midnightBlue = 0x191970,
    darkBlue = 0x000080,
    darkOrange = 0xFFA500,
    rosyBrown = 0xBC8F8F,
    golden = 0xDAA520,
    maroon = 0x800000,
    black = 0x000000,
    white = 0xFFFFFF,
    gray = 0x3C5B72,
    lightGray = 0xA9A9A9,
    darkGray = 0x181828,
    darkSlateGrey = 0x2F4F4F,
    orange = 0xFF6600,
    darkGreen= 0x008000
}

local function hex2RGB(hex)
    local r = ((hex >> 16) & 0xFF) / 255.0
    local g = ((hex >> 8) & 0xFF) / 255.0
    local b = ((hex) & 0xFF) / 255.0
    return r, g, b
end

local function round(num) return math.floor(num+.5) end

local function sciNot(n) 
    return string.format("%." .. (2) .. "E", n)
end


local time = {}
function time.format(number)
    if number == 0 then
        return 0
    else
        local hours = math.floor(number / 3600)
        local minutes = math.floor((number - math.floor(number / 3600) * 3600) / 60)
        local seconds = (number % 60)
        if hours > 17000 then
            local years = math.floor(hours / (24 * 365))
            local days = math.floor((hours - (years * 24 * 365)) / 24)
            return (years .. " Years " .. days .. " Days")
        elseif hours > 48 then
            local days = math.floor(hours / 24)
            hours = math.floor(hours - days * 24)
            return (days .. "d " .. hours .. "h " .. minutes .. "m")
        else
            return (hours .. "h " .. minutes .. "m " .. seconds .. "s")
        end
    end
end

local parser = {}

-- Returns given number formatted as XXX,XXX,XXX
function parser.splitNumber(number, delim)
    delim = delim or ","
    if delim == "" then return tostring(number) end
    local formattedNumber = {}
    local string = tostring(math.abs(number))
    local sign = number / math.abs(number)
    for i = 1, #string do
        local n = string:sub(i, i)
        formattedNumber[i] = n
        if ((#string - i) % 3 == 0) and (#string - i > 0) then
            formattedNumber[i] = formattedNumber[i] .. delim
        end
    end
    if (sign < 0) then table.insert(formattedNumber, 1, "-") end
    return table.concat(formattedNumber, "")
end

function parser.metricNumber(number, format)
    format = format or "%.1f"
    if math.abs(number) < 1000 then return tostring(math.floor(number)) end
    local suffixes = {"k", "M", "G", "T", "P", "E", "Z", "Y"}
    local power = 1
    while math.abs((number / 1000 ^ power)) > 1000 do power = power + 1 end
    return tostring(string.format(format, (number / 1000 ^ power)))..suffixes[power]
end

function parser.getInteger(string)
    if type(string) == "string" then
        local numberString = string.gsub(string, "([^0-9]+)", "")
        if tonumber(numberString) then
            return round(tonumber(numberString))
        end
        return 0
    else
        return 0
    end
end

function parser.split(string, sep)
    if sep == nil then sep = "%s" end
    local words = {}
    for str in string.gmatch(string, "([^"..sep.."]+)") do
        table.insert(words, str)
    end
    return words
end

function parser.percentage(number) return
    (math.floor(number * 1000) / 10) .. "%" end

local states = {
    ON = {name = "ON"},
    IDLE = {name = "IDLE"},
    OFF = {name = "OFF"},
    BROKEN = {name = "BROKEN"},
    MISSING = {name = "NOT FOUND"}
}



local function getNewTable(size, value)
    local array = {}
    for i = 1, size, 1 do
        array[i] = value
    end
    return array
end

local function getAverage(array)
    local sum = 0
    for i = 1, #array, 1 do
        sum = sum + array[i]
    end
    return sum / #array
end

local energyData = {
    intervalCounter = 1,
    animationCounter = 1,
    readings = {},
    startTime = 0,
    endTime = 0,
    updateInterval = updateInterval,
    energyPerTick = 0,
    offset = 0,
    highestInput = 1,
    highestOutput= -1,
    energyIn = getNewTable(updateInterval, 0),
    energyOut = getNewTable(updateInterval, 0),
    input = 0,
    output = 0,
}






local function getProbs(problemsString)
    local problems = string.match(problemsString or "", "Has Problems") and "1" or "0"
    pcall(function()
        problems =
            string.sub(problemsString, string.find(problemsString, "c%d"))
    end)
    return tonumber((string.gsub(problems, "c", "")))
end

local function get_LSC_info(lsc)
    --get status and sensor info
    local sensorInformation = lsc.getSensorInformation()
    if sensorInformation ~= nil then
        local problems = getProbs(sensorInformation[9])
        local state = nil
        if lsc:isWorkAllowed() then
            if lsc:hasWork() then
                state = states.ON
            else
                state = states.IDLE
            end
        else
            state = states.OFF
        end

        if problems > 0 then
            state = states.BROKEN
        end
        local status = {
            address=lsc.address,
            name = "LSC",
            state = state,
            storedEU = parser.getInteger(sensorInformation[2]),--+inputHatch.getStoredEU(), 
            EUCapacity = parser.getInteger(sensorInformation[3]),--+inputHatch.getEUMaxStored(),
            problems = problems,
            passiveLoss = parser.getInteger(sensorInformation[4] or 0),
            location = lsc.getCoordinates,
            EUIn = inputHatch.getEUInputAverage(), --parser.getInteger(sensorInformation[5] or 0), 
            EUOut = outputHatch.getEUOutputAverage(), --parser.getInteger(sensorInformation[6] or 0), 
            wirelessEU = parser.getInteger(sensorInformation[12] or 0)
        }
        return status
    else
        return {state = states.MISSING}
    end
end

local powerStatus={}
local function initialize(lsc)
    gpu.setBackground(xcolors.white)
    gpu.fill(1, 1, w, h, " ") -- clears the screen

    powerStatus=get_LSC_info(lsc)
end

--local ticks=0
local currentEU=0
local maxEU=0
local percentage=0

local function updateEnergyData(powerStatus)
    powerStatus=get_LSC_info(lsc)
    currentEU = powerStatus.storedEU
    maxEU = powerStatus.EUCapacity
    percentage = math.min(currentEU/maxEU, 1.0)
    
    energyData.energyIn[energyData.intervalCounter] = powerStatus.EUIn
    energyData.energyOut[energyData.intervalCounter] = -1*powerStatus.EUOut
    
    if energyData.intervalCounter < energyData.updateInterval then
        --if energyData.intervalCounter == 1 then  
            --energyData.startTime = computer.uptime()
            --energyData.readings[1] = currentEU
        --end
        energyData.intervalCounter = energyData.intervalCounter + 1
        
    elseif energyData.intervalCounter == energyData.updateInterval then
        --energyData.endTime = computer.uptime()
        --energyData.readings[2] = currentEU
        --ticks = round((energyData.endTime - energyData.startTime) * 20)
        --energyData.energyPerTick = round((energyData.readings[2] - energyData.readings[1])/ticks)
        
        energyData.input = round(getAverage(energyData.energyIn))
        energyData.output = round(getAverage(energyData.energyOut))-powerStatus.passiveLoss
        energyData.energyPerTick = energyData.input+energyData.output
        if energyData.energyPerTick >= 0 then
            if energyData.energyPerTick > energyData.highestInput then
                energyData.highestInput = energyData.energyPerTick
            end
        else
            if energyData.energyPerTick < energyData.highestOutput then
                energyData.highestOutput = energyData.energyPerTick
            end
        end      
        energyData.intervalCounter = 1
    end
end

local function spectrumRedGreen(num,lowBound,highBound)
    local frac=math.abs(num/(highBound-lowBound))
    if frac > 0.8 then
        gpu.setForeground(xcolors.green)
    elseif frac > 0.6 then
        gpu.setForeground(xcolors.greenYellow)
    elseif frac > 0.4 then
        gpu.setForeground(xcolors.yellow)
    elseif frac > 0.2 then
        gpu.setForeground(xcolors.orange)
    else
        gpu.setForeground(xcolors.red)
    end
end

local function drawEnergyScreen() 
    
    gpu.setBackground(xcolors.white)
    --gpu.fill(1, 1, w, 2, " ")
    --gpu.fill(1, h-1, w, 2, " ")
    
    gpu.setBackground(xcolors.electricBlue)
    local fillLength=math.ceil(percentage*w)
    gpu.fill(1, 3, fillLength, vertBarr, " ")
    gpu.setBackground(xcolors.midnightBlue)
    gpu.fill(fillLength+1, 3, w, vertBarr, " ")
    gpu.setBackground(xcolors.white)
    
    --2nd top row
    gpu.setForeground(xcolors.electricBlue)
    gpu.set(1,2,sciNot(currentEU))
    gpu.setForeground(xcolors.darkSlateBlue)
    local EUcap=sciNot(maxEU)
    gpu.set(w-#(EUcap),2,EUcap)
    spectrumRedGreen(percentage,0,1)
    local percentEU=string.format("%." .. (2) .. "f", percentage*100)..'%'
    gpu.set((halfW)-(#percentEU/2),2,percentEU)
    
    --2nd bot row
    gpu.setForeground(xcolors.maroon)
    gpu.set(1,h-1,sciNot(energyData.output))
    gpu.setForeground(xcolors.darkGreen)
    local EUinp=sciNot(energyData.input)
    gpu.set(w-#(EUinp),h-1,EUinp)
    spectrumRedGreen(energyData.energyPerTick,energyData.highestOutput,energyData.highestInput)
    local EUrate=sciNot(energyData.energyPerTick)
    gpu.set((halfW)-(#EUrate/2),h-1,EUrate)

    
    
    --time until full
    gpu.setForeground(xcolors.gray)
    if energyData.energyPerTick > 0 then
        fillTime = math.floor((maxEU-currentEU)/(energyData.energyPerTick*20))
        fillTimeString = "Full: " .. time.format(math.abs(fillTime))
    elseif energyData.energyPerTick < 0 then
        fillTime = math.floor((currentEU)/(energyData.energyPerTick*20))
        fillTimeString = "Empty: " .. time.format(math.abs(fillTime))
    else
        fillTimeString = ""
    end
    gpu.fill(1, 1, w, 1, " ")
    gpu.set((halfW)-(#fillTimeString/2),1,fillTimeString)
    
    --alert maint
    if powerStatus.problems>0 then
        gpu.setForeground(xcolors.red)
        problemMessage="MAINT REQUIRED"
        gpu.set((halfW)-(#problemMessage/2),h,problemMessage)
    else
        gpu.fill(1, h, w, 1, " ")
    end
end

--AR stuff
local terminal = {x = -474, y = 57, z = 300}
--local terminal = {x = 0, y = 0, z = 0}
local resolution={1920,1080}
local x=1920/3
local y=1080/3
local scale=3
local screen = {}
-- Small = 1, Normal = 2, Large = 3, Auto = 4x to 10x (Even)
function screen.size(resolution, scale)
    scale = scale or 3
    return {resolution[1] / scale, resolution[2] / scale}
end

local AR = {}

function AR.cube(glasses, x, y, z, color, alpha, scale)
    scale = scale or 1
    alpha = alpha or 1
    local cube = glasses.addCube3D()
    cube.set3DPos(x - terminal.x, y - terminal.y, z - terminal.z)
    cube.setColor(hex2RGB(color))
    cube.setAlpha(alpha)
    cube.setScale(scale)
    return cube
end

function AR.line(glasses, source, dest, color, alpha, scale)
    scale = scale or 1
    alpha = alpha or 1
    local line = glasses.addLine3D()
    line.setVertex(1, source.x - terminal.x + 0.5, source.y - terminal.y + 0.5, source.z - terminal.z + 0.5)
    line.setVertex(2, dest.x - terminal.x + 0.5, dest.y - terminal.y + 0.5, dest.z - terminal.z + 0.5)
    line.setColor(hex2RGB(color))
    line.setAlpha(alpha)
    line.setScale(scale)
    return line
end

function AR.worldText(glasses, name, x, y, z, color, alpha, scale)
    scale = scale or 0.04
    alpha = alpha or 1
    local text = glasses.addFloatingText()
    text.set3DPos(x - terminal.x, y - terminal.y, z - terminal.z)
    text.setColor(hex2RGB(color))
    text.setAlpha(alpha)
    text.setScale(scale)
    text.setText(name)
    return text
end

function AR.hudTriangle(glasses, a, b, c, color, alpha)
    alpha = alpha or 1.0
    local triangle = glasses.addTriangle()
    triangle.setColor(hex2RGB(color))
    triangle.setAlpha(alpha)
    triangle.setVertex(1, a[1], a[2])
    triangle.setVertex(2, b[1], b[2])
    triangle.setVertex(3, c[1], c[2])
    return triangle
end

function AR.hudQuad(glasses, a, b, c, d, color, alpha)
    alpha = alpha or 1.0
    local quad = glasses.addQuad()
    quad.setColor(hex2RGB(color))
    quad.setAlpha(alpha)
    quad.setVertex(1, a[1], a[2])
    quad.setVertex(2, b[1], b[2])
    quad.setVertex(3, c[1], c[2])
    quad.setVertex(4, d[1], d[2])
    return quad
end

function AR.hudRectangle(glasses, x, y, w, h, color, alpha)
    alpha = alpha or 1.0
    local rect = glasses.addRect()
    rect.setPosition(x, y)
    rect.setSize(h, w)
    rect.setColor(hex2RGB(color))
    rect.setAlpha(alpha)
    return rect
end

function AR.textSize(textObject, scale)
    local oldX, oldY = textObject.getPosition()
    oldX = oldX * textObject.getScale()
    oldY = oldY * textObject.getScale()
    textObject.setScale(scale)
    textObject.setPosition(oldX / (scale + 1), oldY / (scale + 1))
end

function AR.hudText(glasses, displayText, x, y, color, scale)
    scale = scale or 1
    local text = glasses.addTextLabel()
    text.setText(displayText)
    text.setPosition(x, y)
    text.setColor(hex2RGB(color))
    AR.textSize(text, scale)
    return text
end

function AR.remove(glasses, objects)
    for i = 1, #objects do
        glasses.removeObject(objects[i].getID())
    end
end

function AR.rectangle(glasses, v1, width, height, color, alpha)
    alpha = alpha or 1.0
    local rect = glasses.addQuad()
    rect.setColor(hex2RGB(color))
    rect.setAlpha(alpha)
    rect.setVertex(1, v1[1], v1[2])
    rect.setVertex(2, v1[1], v1[2] + height)
    rect.setVertex(3, v1[1] + width, v1[2] + height)
    rect.setVertex(4, v1[1] + width, v1[2])
    return rect
end

function AR.testGrid(glasses, resolution, scale)
    scale = scale or 3
    local glassResolution = screen.size(resolution, scale)
    AR.rectangle(glasses, {glassResolution[1]/2, 0}, 1, glassResolution[2], xcolors.electricBlue)
    AR.rectangle(glasses, {0, glassResolution[2]/2}, glassResolution[1], 1, xcolors.electricBlue)
end

function AR.clear(glasses)
    glasses.removeAll()
end



local function drawEnergyHUD()
    AR.hudRectangle(glasses, 0.04*x, 0.92*y, 0.2*x, 0.04*y, xcolors.midnightBlue, 0.4)
end
    
initialize(lsc)
AR.clear(glasses)
--local oldtime=0

--stats_fh = io.open("stats.dat","w")
 while true do
    
    updateEnergyData(powerStatus)
    
    drawEnergyScreen()
    drawEnergyHUD()
    
    --gpu.fill(1, 1, w, h, " ")
    --gpu.set(40,1,tostring(energyData.energyPerTick))
    --gpu.set(40,2,tostring(energyData.intervalCounter))
    --gpu.set(40,3,tostring(energyData.input))
    --gpu.set(40,4,tostring(energyData.output))
  --  if energyData.energyIn[energyData.intervalCounter] > 0 then
  --      stats_fh:write(energyData.intervalCounter,'     ',round((computer.uptime()-oldtime)*20),'     ',energyData.energyIn[energyData.intervalCounter],'\n')
  --      oldtime=computer.uptime()
  --  end
    
    --for k,v in pairs(energyData.energyIn) do stats_fh:write(tostring(k)..'  '..tostring(v)..'\n') end
    --stats_fh:close()
    os.sleep(sleepTime)
 end
