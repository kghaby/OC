local component = require("component")
local computer = require("computer")
local event = require("event")
local os = require("os")
local redstone = component.redstone
local sides = require("sides")
local chatbox=component.chat_box
local thread=require("thread")
local internet = require("internet")


--autoreboot with reboot IC gate
redstone.setOutput(sides.back,15)
redstone.setWakeThreshold(15)

-- Function to parse the response and get the current time
local function getCurrentTime()
    local ok1, response = pcall(internet.request, "http://worldtimeapi.org/api/timezone/America/Chicago")
    if ok1 then
        local ok2, response = pcall(response)
        if ok2 then
            local startIndex, endIndex = string.find(response, "datetime")
            local datetime = string.sub(response, startIndex + 11, endIndex +22)
            return datetime
        else
            print("Response was not ok2")
            return "0000-00-00T01:55:00" --phony datetime to trigger redstone off
        end
    else
        print("Response was not ok1")
        return "0000-00-00T01:55:00" --phony datetime to trigger redstone off
    end
  
   
end

-- Function to check if the current time is within x minutes of the target hours
local function isWithinMinutes(datetime,threshold)
    local targetHours = {2, 4, 6, 10, 14, 18, 22}
    local hour = tonumber(string.sub(datetime, 12, 13))
    local minute = tonumber(string.sub(datetime, 15, 16))
    for i = 1, #targetHours do
        if hour == (targetHours[i]-1) and (minute >= (60-threshold)) then
            return true
        end
    end
    return false
end

local function time2seconds(time)
    local hour = tonumber(string.sub(time, 12, 13))
    if hour == 1 then
        hour=hour+24
    end
    local minute = tonumber(string.sub(time, 15, 16))
    local seconds = tonumber(string.sub(time, 18, 19))
    timeInSeconds = hour * 3600 + minute * 60 + seconds
    return timeInSeconds
end

--[[
--uses chatbox. cant see /say so this doesnt work
local isRebooting=thread.create(function()  
    while true do
        local _, _, _, message = event.pull("chat_message")
        if message and string.find(message, "reboot in 1 minute") then
            local msg="Scheduled reboot detected. Sleeping redstone for 120 seconds"
            chatbox.say(msg)
            print(os.date().." "..msg)
            redstone.setOutput(sides.right, 0)
            os.sleep(120)
            redstone.setOutput(sides.right, 15)
        end
    end
end)
]]





local function isNetworkOn()
    if redstone.getInput(sides.left) > 0 then
        return true
    end
end

print("Waiting...")
redstone.setOutput(sides.right, 15)
local currentTime=""

local networkCheck=thread.create(function()  
    while true do
        if not isNetworkOn() then
            local msg="ME network down. Sleeping redstone for 10 seconds"
            chatbox.say(msg)
            print(getCurrentTime()..": "..msg)
            redstone.setOutput(sides.right, 0)
            os.sleep(10)
            redstone.setOutput(sides.right, 15)
        end
        os.sleep()
    end
end)

--downloads every 90 seconds until reboot is $minutes mins away, then sleeps for $minutes+4 mins,
    -- then sleeps for 3 hrs
local reboot=false
while true do
    currentTime = getCurrentTime()
    local minutes=20
    if isWithinMinutes(currentTime,minutes) then
        os.sleep(300) --bc reboot is actually 5 mins after the hour
        local sleepTime=(minutes+4)*60 --s
        local msg="Scheduled reboot predicted. Sleeping redstone for "..sleepTime.." seconds"
        chatbox.say(msg)
        print(getCurrentTime()..": "..msg)
        reboot=true
        redstone.setOutput(sides.right, 0)
        os.sleep(sleepTime)
        redstone.setOutput(sides.right, 15)
    else
        os.sleep(90)
    end
    if reboot then

        print(getCurrentTime()..": ".."Reboot successful. Sleeping for ~3 hrs")
        local beforeGame=computer.uptime()
        local beforeReal = getCurrentTime()
        os.sleep(10800)
        local afterGame=computer.uptime()
        local afterReal = getCurrentTime()
        
        gameDiff=(afterGame-beforeGame)/3600
        print(getCurrentTime()..": ".."Slept for "..gameDiff.." game hours")
        realDiff=(time2seconds(afterReal)-time2seconds(beforeReal))/3600
        print(getCurrentTime()..": ".."Slept for "..realDiff.." real hours")
        reboot=false
    end
end
