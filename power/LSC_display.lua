--personal resolutions for AR display
local scale=3 -- gui size
local RES_G={1920/scale,1015/scale}
local RES_Z={1920/scale,1016/scale}
local RES_K={1920/scale,1080/scale}

local RES_l={RES_G,RES_Z,RES_K}

local V={131072,"ZPM"}

local component = require("component")
local computer = require("computer")
local os = require("os")
local Serial = require("serialization")
local math = require("math")
local gpu = component.gpu


local glasses_G=component.proxy("b172fc79-86eb-4675-9079-270214f8a324")
local glasses_Z=component.proxy("1aac0142-80bf-4a59-846f-fa579551322e")
local glasses_K=component.proxy("662a8ec2-fdde-44f2-a973-21a401acf053")
local glasses_l={glasses_G,glasses_Z,glasses_K}

local lsc = component.proxy("e8cd0c39-095a-43d1-b728-cf316ebb0fc4")
local inputHatchList = {
    component.proxy("b5c1d2d9-0254-4b47-9582-eab46c49778f")
} 
local outputHatchList = {
    component.proxy("37293af0-80a7-4160-9bdc-91f66348a62f")
}

local redstone = component.proxy("de72557c-8939-43b4-bf5d-215ad845c170")
--autoreboot with comparator next to comp >not gate>signal back into comp
RScard=component.proxy("02e29142-f3bf-4ddf-a71b-30dc578a7541")
RScard.setWakeThreshold(10)

--local w,h=160,50
gpu.setResolution(44,8)
--gpu.setResolution(80,15)
local w, h = gpu.getResolution()
local halfW=w/2
local vertBarr=h-4
local sleepTime=0.05 --s
local updateInterval = 80/(sleepTime/0.05) --4s
local enableFraction = 0.3 -- [0,1]
local disableFraction = 0.9 -- [0,1]


local xcolors = {           --mostly NIDAS colors
    red = 0xFF0000,
    lime = 0x00FF00,
    blue = 0x0000FF,
    magenta = 0xFF00FF,
    yellow = 0xFFFF00,
    cyan = 0x00FFFF,
    greenYellow = 0xADFF2F,
    green = 0x00B000,
    darkOliveGreen = 0x556B2F,
    indigo = 0x4B0082,
    purple = 0x800080,
    electricBlue = 0x00A6FF,
    dodgerBlue = 0x1E90FF,
    steelBlue = 0x4682B4,
    darkSlateBlue = 0x483D8B,
    midnightBlue = 0x00014C,
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
    darkGreen= 0x007000,
    darkYellow=0x9F9F00,
    darkElectricBlue=0x477B98
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

local function tierAmps(n,V) 
    local amp_string=string.format("%." .. (1) .. "f", n/V[1])..'A '..V[2]
    return amp_string
end

local time = {}
function time.format(number)
    if number == 0 then
        return ("00h " .."00m " .."00s")
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
    output = 0
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

        local totEUIn=0
        for i=1,#inputHatchList,1 do
            totEUIn=totEUIn+inputHatch[i].getEUInputAverage()
        end

        local totEUOut=0
        for i=1,#outputHatchList,1 do
            totEUOut=totEUOut+outputHatch[i].getEUOutputAverage()
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
            EUIn = totEUIn, --parser.getInteger(sensorInformation[5] or 0), 
            EUOut = totEUOut, --parser.getInteger(sensorInformation[6] or 0), 
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
    if percentage >0.999 then
        percentage=1.0
    end
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
        return xcolors.green
    elseif frac > 0.6 then
        return xcolors.greenYellow
    elseif frac > 0.4 then
        return xcolors.darkYellow
    elseif frac > 0.2 then
        return xcolors.orange
    else
        return xcolors.red
    end
end

local function spectrumRedGreen2(num,lowBound,highBound)
    local frac=num/(highBound-lowBound)
    if frac > 0.6 then
        return xcolors.green
    elseif frac > 0.2 then
        return xcolors.greenYellow
    elseif frac > -0.2 then
        return xcolors.darkYellow
    elseif frac > -0.6 then
        return xcolors.orange
    else
        return xcolors.red
    end
end

local function drawRedstone(enableFraction,disableFraction)
    gpu.setBackground(xcolors.maroon)
    gpu.fill(disableFraction*w+1, 3, 1, vertBarr, " ")
    gpu.setBackground(xcolors.red)
    gpu.fill(enableFraction*w+1, 3, 1, vertBarr, " ")
end

local percentColor=""
local rateColor=""
local EUout=""
local EUinp=""
local EUrate=""
local EUcap=""
local EUstor=""
local percentEU=""


local function drawEnergyScreen() 
    
    gpu.setBackground(xcolors.white)
    --gpu.fill(1, 1, w, 2, " ")
    --gpu.fill(1, h-1, w, 2, " ")
    
    gpu.setBackground(xcolors.electricBlue)
    local fillLength=math.ceil(percentage*w)
    gpu.fill(1, 3, fillLength, vertBarr, " ")
    gpu.setBackground(xcolors.darkElectricBlue)
    gpu.fill(fillLength+1, 3, w, vertBarr, " ")
    drawRedstone(enableFraction,disableFraction)
    gpu.setBackground(xcolors.white)
    
    --2nd top row
    gpu.setForeground(xcolors.electricBlue)
    EUstor=sciNot(currentEU)
    gpu.set(1,2,EUstor)
    gpu.setForeground(xcolors.darkElectricBlue)
    EUcap=sciNot(maxEU)
    gpu.set(w-#(EUcap),2,EUcap)
    percentColor=spectrumRedGreen(percentage,0,1)
    gpu.fill((halfW)-6, 2, 12, 1, " ") -- reset % space to white 
    gpu.setForeground(percentColor)
    percentEU=string.format("%." .. (1) .. "f", percentage*100)..'%'
    gpu.set((halfW)-(#percentEU/2),2,percentEU)
    
    --2nd bot row
    gpu.setForeground(xcolors.maroon)
    EUout=tierAmps(energyData.output,V)
    gpu.fill(1, h-1, 12, 1, " ") -- reset rate space to white 
    gpu.set(1,h-1,EUout)
    gpu.setForeground(xcolors.darkGreen)
    EUinp=tierAmps(energyData.input,V)
    gpu.fill(w-12, h-1, 12, 1, " ") -- reset rate space to white 
    gpu.set(w-#(EUinp),h-1,EUinp)
    rateColor=spectrumRedGreen2(energyData.energyPerTick,energyData.output,energyData.input)
    gpu.setForeground(rateColor)
    EUrate=tierAmps(energyData.energyPerTick,V)
    if energyData.energyPerTick>0 then
        EUrate='+'..EUrate
    end
    gpu.fill((halfW)-6, h-1, 12, 1, " ") -- reset rate space to white 
    gpu.set((halfW)-(#EUrate/2),h-1,EUrate)

    
    
    --time until full
    gpu.setForeground(xcolors.gray)
    if energyData.energyPerTick > 0 then
        if percentage>0.999 then
            fillTime = 0
        else
            fillTime = math.floor((maxEU-currentEU)/(energyData.energyPerTick*20))
        end  
        fillTimeString = "Full: " .. time.format(math.abs(fillTime))
    elseif energyData.energyPerTick < 0 then
        if percentage>0.999 then
            fillTime = 0
        else
            fillTime = math.floor((currentEU)/(energyData.energyPerTick*20))
        end  
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

function AR.hudNewRectangle(glasses, x, y, w, h, color, alpha)
    alpha = alpha or 1.0
    local rect = glasses.addRect()
    rect.setPosition(x, y)
    rect.setSize(h, w)
    rect.setColor(hex2RGB(color))
    rect.setAlpha(alpha)
    return rect
end

function AR.hudRectangle(rect, x, y, w, h, color, alpha)
    alpha = alpha or 1.0
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

function AR.hudNewText(glasses, displayText, x, y, color, scale)
    scale = scale or 1
    local text = glasses.addTextLabel()
    text.setScale(scale)
    text.setText(displayText)
    text.setPosition(x, y)
    text.setColor(hex2RGB(color))
    
    --AR.textSize(text, scale)
    return text
end

function AR.hudText(text, displayText, x, y, color, scale)
    scale = scale or 1
    text.setScale(scale)
    text.setText(displayText)
    text.setPosition(x, y)
    text.setColor(hex2RGB(color))
    --AR.textSize(text, scale)
    return text
end

function AR.remove(glasses, objects)
    for k,v in pairs(objects) do
        glasses.removeObject(objects[k].getID())
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

local function checkRes()
    for i=1,x,20 do 
        AR.hudNewText(glasses, tostring(i), i, 1, xcolors.black, 1)
    end
    for j=1,y,20 do
        AR.hudNewText(glasses, tostring(j), 1, j, xcolors.black, 1)
    end
end


local function initializeHUD(glasses,x,y)
    AR.clear(glasses)
    glasses.hudObjects={}
    glasses.hudObjects.static={}
    --glasses.hudObjects.static.outerRect={}
    glasses.hudObjects.static = {
        outerRecttop=AR.hudNewRectangle(glasses, 0, y-27, 217, 9, xcolors.darkGray, 0.80),
        outerRectbot=AR.hudNewRectangle(glasses, 0, y-9, 217, 9, xcolors.darkGray, 0.80),
        outerRectleft=AR.hudNewRectangle(glasses, 0, y-18, 3, 9, xcolors.darkGray, 0.80),
        outerRectright=AR.hudNewRectangle(glasses, 214, y-18, 3, 9, xcolors.darkGray, 0.80),
        backRect=AR.hudNewRectangle(glasses, 3, y-18, 211, 9, xcolors.darkElectricBlue, 0.5)
    }
    
    glasses.hudObjects.dynamic = {
        energyBar = glasses.addRect(), 
        maxEU = glasses.addTextLabel(),  
        currentEU = glasses.addTextLabel(),
        rate = glasses.addTextLabel(),
        ouput = glasses.addTextLabel(),
        input = glasses.addTextLabel(),
        percent = glasses.addTextLabel(),
        time = glasses.addTextLabel(),
        RSenable = glasses.addRect(),
        RSdisable = glasses.addRect()
    }
end
--checkRes()

local energyBarLength=0
local function drawEnergyHUD(hudObjects,x,y)
    energyBarLength=math.ceil(percentage*211)

    AR.hudRectangle(hudObjects.energyBar, 3, y-18, energyBarLength, 9, xcolors.electricBlue, 1)
    AR.hudText(hudObjects.maxEU, EUcap, 214-3.5*#EUcap, y-24, xcolors.darkElectricBlue, 0.6) 
    AR.hudText(hudObjects.currentEU, EUstor, 3, y-24, xcolors.electricBlue, 0.6)
    AR.hudText(hudObjects.rate, EUrate, 107-3.5*(#EUrate/2), y-7, rateColor, 0.6)
    AR.hudText(hudObjects.ouput, EUout, 3, y-7, xcolors.maroon, 0.6)
    AR.hudText(hudObjects.input, EUinp, 214-3.5*#EUinp, y-7, xcolors.darkGreen, 0.6)
    AR.hudText(hudObjects.percent, percentEU, 107-3.5*(#percentEU/2), y-24, percentColor, 0.6)
    if powerStatus.problems>0 then
        AR.hudText(hudObjects.time, problemMessage, 107-3.5*(#problemMessage/2), y-16, xcolors.red, 0.6)
    else
        AR.hudText(hudObjects.time, fillTimeString, 107-3.5*(#fillTimeString/2), y-16, xcolors.black, 0.6)
    end
end




--redstone power control

local function disengage()
    redstone.setOutput({0, 0, 0, 0, 0, 0})
end
local function engage()
    redstone.setOutput({15, 15, 15, 15, 15, 15})
end

--local checkingInterval = 1500
--local counter = checkingInterval

local function drawRedstoneHUD(hudObjects,x,y,enableRect,enableFraction,disableRect,disableFraction)
    AR.hudRectangle(hudObjects.RSenable, math.ceil(enableFraction*211)+3, y-18, 1, 9, xcolors.red, 1)
    AR.hudRectangle(hudObjects.RSdisable, math.ceil(disableFraction*211)+3, y-18, 1, 9, xcolors.maroon, 1)
end

local function checkPower(fillFraction,enableFraction,disableFraction)
    --if counter == checkingInterval then
    if fillFraction < enableFraction then
        engage()
    elseif fillFraction > disableFraction then
        disengage()
    end
        --counter = 1
    --else
        --counter = counter + 1
    --end  
end

initialize(lsc)

for i=1,#glasses_l,1 do
    initializeHUD(glasses_l[i],RES_l[i][1],RES_l[i][2])
end

 while true do
    updateEnergyData(powerStatus,enableFraction,disableFraction)
    drawEnergyScreen()

    for i=1,#glasses_l,1 do
        drawEnergyHUD(glasses_l[i].hudObjects.dynamic,RES_l[i][1],RES_l[i][2])
        drawRedstoneHUD(glasses_l[i].hudObjects.dynamic,RES_l[i][1],RES_l[i][2],enableRect,enableFraction,disableRect,disableFraction)
    end
    
    checkPower(percentage,enableFraction,disableFraction)
    
    os.sleep(sleepTime)
    
    if round(computer.uptime()) % 36000 == 0 then
        os.execute("reboot")
    end
 end
