local component = require("component")
local computer = require("computer")
local event = require("event")
local os = require("os")
local gpu = component.gpu
local tp = component.telepad
local io = require("io")
local Serial = require("serialization")
local term=require("term")
local thread = require("thread")

gpu.setResolution(56,30)
w,h=gpu.getResolution()

local function logTeleport(infoMsg)
    local logFile = io.open("teleport_log.txt", "a")
    logFile:write(infoMsg)
    logFile:flush()
    logFile:close()
end

local function displayTeleportLog()
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ") -- clears the screen
    local logFile = io.open("teleport_log.txt", "r")
    if logFile == nil then
        return
    end
    local logText = logFile:read("*all")
    logFile:close()
    print(logText)
end

local function getRowText(y,w)
    local rowText=""
    for x=1,w,1 do 
        local char=gpu.get(x,y)
        rowText=rowText..char
    end
    return rowText
end

local function highlightRow(color,y,rowText)
    --needs color as hex eg 0x000000
    gpu.setBackground(color)
    gpu.set(1,y,rowText)
    gpu.setBackground(0x000000)
end

local function changeBackground(color,w,h)
    --needs color as hex eg 0x000000
    gpu.setBackground(color)
    for row=1,h,1 do
        local rowText=getRowText(row,w)
        gpu.set(1,row,rowText)
    end
end


local function extractCoords(infoMsg)
    local startIndex, endIndex = string.find(infoMsg, "%b{}")
    local coords = string.sub(infoMsg, startIndex, endIndex)
    return coords
end
    
local function extractDimension(infoMsg)
    local _, endIndex = string.find(infoMsg, "Dim")
    local dim = string.sub(infoMsg, endIndex + 2)
    return tonumber(dim)
end
    
local touchThread=thread.create(function()
    while true do 
        local _, _, x, y = event.pull("touch")
        -- code to handle screen touch
        if x and y then
            changeBackground(0x000000,w,h)
            local rowText = getRowText(y,w)
            if string.find(rowText,"TP to") then
                highlightRow(0x3C5B72,y,rowText)
                local coords = Serial.unserialize(extractCoords(rowText))
                local dim = extractDimension(rowText)
                tp.setCoords(coords[1],coords[2],coords[3])
                tp.setDimension(dim)
            end
        end 
        os.sleep()
    end
end)


displayTeleportLog()
while true do
    if tp.getProgress() > 0 then
        changeBackground(0x000000,w,h)
        local coords = Serial.serialize({tp.getCoords()})
        local dim = tostring(tp.getDimension())
        local infoMsg = os.date()..": TP to "..coords.." in Dim "..dim
        print(infoMsg)
        logTeleport(infoMsg.."\n")
    end
    os.sleep()
end


