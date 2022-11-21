--HELLO FRIENDS, IF YOU WANT TO ADD AN ITEM THEN ADD TO THE TOP OF THE ITEM STOCKING LIST BELOW, REBOOT, AND RUN "autostocker"
--format: {name="Example",damage="0",checkLvl=10,craftAmt=1000},
    --DONT FORGET THE COMMA
--damage is the number after the colon in an item's extended name. Only use to fistinguish between 2 items with same name
    --eg. for "Plastic Circuit Board 7124:32007", the damage is "32007"
--Essentia and fluids are represented as drops (1 drop = 1 mB)

local itemStock_l={
    {label="BrainTech Aerospace Advanced Reinforced Duct Tape FAL-84",checkLvl=8,craftAmt=16},
    {label="Lubricant Cell",checkLvl=4,craftAmt=8},
    {label="Steel Screw",checkLvl=8,craftAmt=16},
    {label="Nanoprocessor",checkLvl=4,craftAmt=8},
    {label="Cable Anchor",checkLvl=40,craftAmt=100},
    {label="Drilling Fluid Cell",checkLvl=1000,craftAmt=1000},
    {label="Memory (Tier 3.5)",hasTag=false,checkLvl=4,craftAmt=4},
    {label="Internet Card",hasTag=false,checkLvl=1,craftAmt=1},
    {label="Graphics Card (Tier 3)",hasTag=false,checkLvl=1,craftAmt=1},
    {label="Rack",hasTag=false,checkLvl=1,craftAmt=1},
    {label="Adapter",hasTag=false,checkLvl=1,craftAmt=1},
    {label="Keyboard",hasTag=false,checkLvl=1,craftAmt=1},
    {label="Central Processing Unit (CPU) (Tier 3)",hasTag=false,checkLvl=1,craftAmt=1},
    {label="Hard Disk Drive (Tier 3) (4MB)",hasTag=false,checkLvl=1,craftAmt=1},
    {label="Screen (Tier 3)",hasTag=false,checkLvl=6,craftAmt=6},
    {label="Server (Tier 3)",hasTag=false,checkLvl=1,craftAmt=1},
    {label="Pyrotheum Dust",damage=2843,checkLvl=100,craftAmt=1000}
}

return itemStock_l
