local component = require("component")
local os = require("os")
local gpu = component.gpu


local cableList = {
    {label="64A LuV",cable=component.proxy("d2462d54-0473-4adb-b315-3f1926a4b473")},
    {label="128A ZPM",cable=component.proxy("7ccd36dc-b662-45bc-b988-1d6ff6109666")},
    {label="128A UV",cable=component.proxy("b3c4421b-8cd1-434e-9168-a54bbbcb41f5")},
    {label="192A UHV",cable=component.proxy("0d656629-be5b-4ea1-a498-128322415537")},
    {label="64A UEV",cable=component.proxy("c237e6ce-18c0-4a89-bf9f-29d978835de6")}
    
} 

function split(string, sep)
    if sep == nil then sep = "%s" end
    local words = {}
    for str in string.gmatch(string, "([^"..sep.."]+)") do
        table.insert(words, str)
    end
    return words
end

local function getEnergyInfo(cable)
    local sensorInformation=cable.getSensorInformation()
    local ampStrings = split(sensorInformation[3], "/")
    local currentA = ampStrings[1]:gsub("([^0-9]+)", "")
    if #currentA==1 then
        currentA="0"..currentA
    end
    local maxA = ampStrings[2]:gsub("([^0-9]+)", "")
    return {currentA,maxA}
end


--initialize table
local highestTable={}
for i=1,#cableList,1 do
    highestTable[cableList[i].label]=0
end


--initialize screen
w,h=gpu.getResolution()
gpu.fill(1, 1, w, h, " ")
gpu.setResolution(18,2+#cableList)
--gpu.setResolution(160,50) --debugging
gpu.set(1,1, "CABLE CAPACITY")
for i=1,#cableList,1 do
    gpu.set(1,2+i,cableList[i].label..": 00/00")
end



while true do
    for i=1,#cableList,1 do
        ampInfo=getEnergyInfo(cableList[i].cable)
        if highestTable[cableList[i].label] <= tonumber(ampInfo[1]) then
            highestTable[cableList[i].label]=tonumber(ampInfo[1])
            gpu.set(1,2+i,cableList[i].label..": "..ampInfo[1]) --.."/"..ampInfo[2])
        end
    end
    os.sleep()
end
