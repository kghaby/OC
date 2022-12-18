--C24 must be in slot 1!
local component = require("component")
local computer = require("computer")
local os = require("os")

local transposer=component.transposer

local chestSide=3
local chestName=transposer.getInventoryName(chestSide)
local upSide=1
local upName=transposer.getInventoryName(upSide)



local function iterateInv(side)
    for i=1,transposer.getInventorySize(side),1 do
        item=transposer.getStackInSlot(side,i)
    end
end


while true do 


    os.sleep(0.05)
end