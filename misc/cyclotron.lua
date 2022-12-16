--C24 must be in slot 1!
local component = require("component")
local computer = require("computer")
local os = require("os")

local transposer=component.transposer
local chest=transposer.getInventoryName(5)
local bus=transposer.getInventoryName(2)
local chestSide=5
local busSide=2

local function iterateInv(side)
    for i=1,transposer.getInventorySize(side),1 do
        item=transposer.getStackInSlot(side,i)
    end
end


while true do 


    os.sleep(0.05)
end