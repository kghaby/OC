local component = require("component")
local computer = require("computer")
local event = require("event")
local os = require("os")
local redstone = component.redstone
local sides = require("sides")

--autoreboot with comparator next to comp >not gate>signal back into comp
redstone.setWakeThreshold(10)

local function checkChatMessage()
    local _, _, _, message = event.pull("chat_message")
    if message and string.find(message, "rebooting") and os.time() - computer.uptime() < 60 then
        return false
    end
    return true
end

while true do
    if checkChatMessage() and redstone.getInput("left") == 0 then
        redstone.setOutput("right", 15)
    else
        redstone.setOutput("right", 0)
    end
    os.sleep()
end