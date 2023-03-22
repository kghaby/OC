local fillLimit=1e18 --arbitrary limit of wireless energy network before rs turns off energy stream
local EU_mod={1000000000,"G"}

local component = require("component")
local computer = require("computer")
local os = require("os")
local Serial = require("serialization")
local math = require("math")
local gpu = component.gpu

local lsc = component.proxy("b1bab203-04ed-4be0-842b-239f0a181c1b")

local redstone = component.proxy("6b7f615c-6f5b-4419-903c-74318403c647")
--autoreboot with comparator next to comp >not gate>signal back into comp
RScard=component.proxy("13648e2b-d641-4030-a84a-8a138018474b")
RScard.setWakeThreshold(10)

--local w,h=160,50
--gpu.setResolution(44,8)
gpu.setResolution(50,15)
--gpu.setResolution(160,50)
local w, h = gpu.getResolution()
local halfW=w/2
local vertBarr=h-4
local updateInterval = 6000 --in ticks
local enableFraction = 0.4 -- [0,1]
local disableFraction = 0.6 -- [0,1]


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

local function formatEU(n,EU_mod) 
    local amp_string=string.format("%." .. (1) .. "f", n/EU_mod[1])..EU_mod[2]
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
    (math.floor(number * 1000) / 10) .. "%" 
end




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
        local status = {
            address=lsc.address,
            wirelessEU = parser.getInteger(sensorInformation[12] or 0)
        }
        return status
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
local maxEU=fillLimit
local percentage=0
local prevEU=0

local function updateEnergyData(powerStatus)
    powerStatus=get_LSC_info(lsc)
    currentEU = powerStatus.wirelessEU
    if currentEU==nil then
        return "skipIter"
    end
    percentage = math.min(currentEU/maxEU, 1.0)
    if percentage >0.999 then
        percentage=1.0
    end
    energyRate = (currentEU-prevEU)/updateInterval
    prevEU=currentEU
    return
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
    percentEU=string.format("%." .. (6) .. "f", percentage*100)..'%'
    gpu.set((halfW)-(#percentEU/2),2,percentEU)
    
    --2nd bot row
    gpu.setForeground(xcolors.maroon) 
    rateColor=spectrumRedGreen2(energyRate,-1,1)
    gpu.setForeground(rateColor)
    EUrate=formatEU(energyRate,EU_mod)
    if energyRate>0 then
        EUrate='+'..EUrate
    end
    gpu.fill((halfW)-6, h-1, 12, 1, " ") -- reset rate space to white 
    gpu.set((halfW)-(#EUrate/2),h-1,EUrate)

    
    
    --time until full
    gpu.setForeground(xcolors.gray)
    if energyRate > 0 then
        if percentage>0.999 then
            fillTime = 0
        else
            fillTime = math.floor((maxEU-currentEU)/(energyRate*20))
        end  
        fillTimeString = "Full: " .. time.format(math.abs(fillTime))
    elseif energyRate < 0 then
        if percentage>0.999 then
            fillTime = 0
        else
            fillTime = math.floor((currentEU)/(energyRate*20))
        end  
        fillTimeString = "Empty: " .. time.format(math.abs(fillTime))
    else
        fillTimeString = ""
    end
    gpu.fill(1, 1, w, 1, " ")
    gpu.set((halfW)-(#fillTimeString/2),1,fillTimeString)
    
end

--redstone power control

local function disengage()
    redstone.setOutput({0, 0, 0, 0, 0, 0})
end
local function engage()
    redstone.setOutput({15, 15, 15, 15, 15, 15})
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



while true do
    starttime=computer.uptime()
    iter=updateEnergyData(powerStatus,enableFraction,disableFraction)
    if iter=="skipIter" then
        goto skipIter
    end
    drawEnergyScreen()

    checkPower(percentage,enableFraction,disableFraction)

    ::skipIter::
    endtime=computer.uptime()
    --    print((endtime-starttime))
    os.sleep(updateInterval/20)
    --[[
    if endtime-starttime<0.01 then
        os.sleep(0.01)
    else
        os.sleep()
    end
    ]]--
    if round(computer.uptime()) % 36000 == 0 then
        os.execute("reboot")
    end
end

