

local component = require("component")
local transforms = require("transforms")
local computer = require("computer")
local os = require("os")
local Serial = require("serialization")
local math = require("math")
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
    darkSlateGrey = 0x2F4F4F
}

local function round(num) return math.floor(num+.5) end

local function sciNot(n) 
    return string.format("%." .. (2) .. "E", n)
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

local gpu = component.gpu
local lsc = component.gt_machine --["83d81a1c-55e4-4a46-a63b-70a5997f142a"]

--local w,h=160,50
local w, h = gpu.getResolution()
local sleepTime=0.05 --s
local updateInterval = 80/(sleepTime/0.05) --4s

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
            storedEU = parser.getInteger(sensorInformation[2]),
            EUCapacity = parser.getInteger(sensorInformation[3]),
            problems = problems,
            passiveLoss = parser.getInteger(sensorInformation[4] or 0),
            location = lsc.getCoordinates,
            EUIn = parser.getInteger(sensorInformation[5] or 0),
            EUOut = parser.getInteger(sensorInformation[6] or 0),
            wirelessEU = parser.getInteger(sensorInformation[12] or 0)
        }
        gpu.set(60,5,tostring(status.EUIn))
        return status
    else
        return {state = states.MISSING}
    end
end

local powerStatus={}
local function initialize(lsc)
    gpu.setBackground(xcolors.black)
    gpu.fill(1, 1, w, h, " ") -- clears the screen
    gpu.setResolution(80,15)
    powerStatus=get_LSC_info(lsc)
end

local ticks=0
local function updateEnergyData(powerStatus)
    prevPowerStatus=powerStatus
    powerStatus=get_LSC_info(lsc)
    local currentEU = powerStatus.storedEU
    local maxEU = powerStatus.EUCapacity
    local percentage = math.min(currentEU/maxEU, 1.0)
    
    if energyData.intervalCounter == 1 then
        energyData.startTime = computer.uptime()
        energyData.readings[1] = currentEU
        energyData.energyIn[energyData.intervalCounter] = powerStatus.EUIn
        energyData.energyOut[energyData.intervalCounter] = powerStatus.EUOut
        energyData.intervalCounter = energyData.intervalCounter + 1
    
    elseif energyData.intervalCounter < energyData.updateInterval then
        energyData.energyIn[energyData.intervalCounter] = powerStatus.EUIn
        energyData.energyOut[energyData.intervalCounter] = powerStatus.EUOut
        energyData.intervalCounter = energyData.intervalCounter + 1
        
    elseif energyData.intervalCounter == energyData.updateInterval then
        energyData.endTime = computer.uptime()
        energyData.readings[2] = currentEU

        energyData.input = getAverage(energyData.energyIn)
        energyData.output = getAverage(energyData.energyOut)

        ticks = round((energyData.endTime - energyData.startTime) * 20)
        energyData.energyPerTick = round((energyData.readings[2] - energyData.readings[1])/ticks)
        
      
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
    energyData.offset = energyData.offset + 2
    if energyData.energyPerTick >= 0 then
        energyData.offset = energyData.offset + 10*(energyData.energyPerTick / energyData.highestInput)
    else
        energyData.offset = energyData.offset + 10*(energyData.energyPerTick / energyData.highestOutput)
    end
end



initialize(lsc)
local oldtime=0
local didalready=true
--stats_fh = io.open("stats.dat","w")
 while true do
    --gpu.fill(1, 1, w, h, " ")
    updateEnergyData(powerStatus)
    
    gpu.set(40,1,tostring(energyData.energyPerTick))
    gpu.set(40,2,tostring(energyData.intervalCounter))
    gpu.set(40,3,tostring(energyData.input))
    gpu.set(40,4,tostring(energyData.output))
    if energyData.energyIn[energyData.intervalCounter] > 0 then
        if not didalready then
            print(tostring(round((computer.uptime()-oldtime)*20)),energyData.energyIn[energyData.intervalCounter])
            oldtime=computer.uptime()
            didalready=true
        else
            didalready=false
        end
    end
    
    --for k,v in pairs(energyData.energyIn) do stats_fh:write(tostring(k)..'  '..tostring(v)..'\n') end
    --stats_fh:close()
    os.sleep(sleepTime)
 end
