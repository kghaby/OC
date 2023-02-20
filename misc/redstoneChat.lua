local component = require("component")
local computer = require("computer")
local event = require("event")
local os = require("os")
local redstone = component.redstone
local sides = require("sides")
local chatbox=component.chat_box
local thread=require("thread")


--autoreboot with reboot IC gate
redstone.setOutput(sides.back,15)
redstone.setWakeThreshold(15)


local isRebooting=thread.create(function()
    while true do
        local _, _, _, message = event.pull("chat_message")
        if message and string.find(message, "reboot in 1 minute") then
            chatbox.say("Scheduled reboot detected. Sleeping redstone for 120 seconds")
            redstone.setOutput(sides.right, 0)
            os.sleep(120)
            redstone.setOutput(sides.right, 15)
        end
    end
end)


local function isNetworkOn()
    if redstone.getInput(sides.left) > 0 then
        return true
    end
end

print("Waiting...")
redstone.setOutput(sides.right, 15)
while true do
    if not isNetworkOn() then
        chatbox.say("Network down. Sleeping redstone for 5 seconds")
        redstone.setOutput(sides.right, 0)
        os.sleep(5)
        redstone.setOutput(sides.right, 15)
    end
    os.sleep()
end