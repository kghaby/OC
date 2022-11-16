

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

local gpu = component.gpu
local LSC = component.gt_machine

--local w,h=160,50
local w, h = gpu.getResolution()
local refreshRate=0.05 --s
local prevCharge = 0


local function round(num) return math.floor(num+.5) end

local function sciNot(n) 
    return string.format("%." .. (2) .. "E", n)
end

local function drawMainScreen()
    gpu.setBackground(xcolors.black)
    gpu.fill(1, 1, w, h, " ") -- clears the screen
    gpu.setResolution(80,15)
    maxEU=LSC.getEUMaxStored()
end


local function updateScreen()
    curEU=LSC.getEUStored()
    gpu.set(1, 1, curEU.."/"..maxEU)
end

drawMainScreen()
 while true do
    updateScreen()
    os.sleep(refreshRate)
 end
