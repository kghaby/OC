--HELLO FRIENDS, IF YOU WANT TO ADD AN ITEM THEN ADD TO THE TOP OF THE STOCKING LIST BELOW. DONT FORGET THE COMMA IF APPENDING
--format: {name="Example",damage="0",checkLvl=10,craftAmt=1000},
--damage is the number after the colon in an item's extended name. Only use to fistinguish between 2 items with same name
	--eg. for "Plastic Circuit Board 7124:32007", the damage is "32007"

local stock_l={

	{name="Example",checkLvl=10,craftAmt=1000}
}

local component = require("component")
local computer = require("computer")
local os = require("os")
local Serial = require("serialization")
local math = require("math")
local gpu = component.gpu
local basew,baseh=160,50
gpu.setResolution(basew/1.5,baseh/1.5)
local w, h = gpu.getResolution()

local ME = component.me_interface

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

function getDisplayTime()
	return os.date("%H:%M:%S", os.time())
end


local name="ZAutostocker"
local function getCPU(name)
    local CPU_l=ME.getCPUs())
    for i=1,#CPU_l,1 do 
        if CPU_l[i].name == name then
            return CPU_l[i]
        end
    end
    print("Could not find CPU "..name)
end

local function iterItems()

end


while true do
	os.sleep()
end

