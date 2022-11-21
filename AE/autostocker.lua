--HELLO FRIENDS, IF YOU WANT TO ADD AN ITEM THEN ADD TO THE TOP OF THE ITEM STOCKING LIST BELOW. 
--format: {name="Example",damage="0",checkLvl=10,craftAmt=1000},
    --DONT FORGET THE COMMA
--damage is the number after the colon in an item's extended name. Only use to fistinguish between 2 items with same name
    --eg. for "Plastic Circuit Board 7124:32007", the damage is "32007"
--Essentia and fluids are represented as drops (1 drop = 1 mB)

local itemStock_l={
    {label="Memory (Tier 3.5)",hasTag=false,checkLvl=4,craftAmt=4},
    {label="Internet Card",hasTag=false,checkLvl=0,craftAmt=1},
    {label="Graphics Card (Tier 3)",hasTag=false,checkLvl=0,craftAmt=1},
    {label="Rack",hasTag=false,checkLvl=0,craftAmt=1},
    {label="Adapter",hasTag=false,checkLvl=0,craftAmt=1},
    {label="Keyboard",hasTag=false,checkLvl=0,craftAmt=1},
    {label="Central Processing Unit (CPU) (Tier 3)",hasTag=false,checkLvl=0,craftAmt=1},
    {label="Hard Disk Drive (Tier 3) (4MB)",hasTag=false,checkLvl=0,craftAmt=1},
    {label="Screen (Tier 3)",hasTag=false,checkLvl=6,craftAmt=6},
    {label="Server (Tier 3)",hasTag=false,checkLvl=0,craftAmt=1},
    {label="Pyrotheum Dust",damage=2843,checkLvl=10,craftAmt=1000}
}



local component = require("component")
local computer = require("computer")
local os = require("os")
local Serial = require("serialization")
local math = require("math")
local gpu = component.gpu
local basew,baseh=160,50
gpu.setResolution(basew/1,baseh/1)
local w, h = gpu.getResolution()
local ME = component.me_interface


itemStock_fh = io.open("itemStock.dat","r")
itemStock_l = Serial.unserialize(itemStock_fh:read())
itemStock_fh:close()

local function round(num) return math.floor(num+.5) end

function getDisplayTime()
    return os.date("%H:%M:%S", os.time())
end


local CPUname="ZAutostocker"
local function getCPU(name)
    local CPU_l=ME.getCpus()
    for i=1,#CPU_l,1 do 
        if CPU_l[i].name == name then
            return CPU_l[i]
        end
    end
    print("Could not find CPU "..name)
end


local function makeStockReq(stockEntry)
    local stockReq={}
    if stockEntry.label~=nil then
        stockReq["label"]=stockEntry.label
    end
    if stockEntry.damage~=nil then
        stockReq["damage"]=stockEntry.damage
    end
    if stockEntry.tag~=nil then
        stockReq["tag"]=stockEntry.tag
    end
    if stockEntry.name~=nil then
        stockReq["name"]=stockEntry.name
    end
    if stockEntry.hasTag~=nil then
        stockReq["hasTag"]=stockEntry.hasTag
    end
    return stockReq
end

local function getItem(stockReq)
    local item_l=ME.getItemsInNetwork(stockReq)
    if #item_l>1 then 
        print("More than 1 item found with parameters "..Serial.serialize(stockReq))
        print("Use damage, name, tag, or hasTag to narrow search")
        SR_fh = io.open("item_SR.dat","w")
        for i=1,#item_l,1 do
            for k,v in pairs(item_l[i]) do
                SR_fh:write(tostring(k)..'    '..tostring(v)..'\n')
            end
            SR_fh:write('\n')
        end
        print("The item search results have been written to item_SR.dat. Exiting...")
        SR_fh:close()
        os.exit()
        else
            return item_l[1]
    end
end


local function requestCraft(stockReq, amt)
    local recipe = ME.getCraftables(stockReq)[1]
    print("[" .. getDisplayTime() .. "] Requesting " .. amt .. " " .. stockReq["label"])
    local req = recipe.request(amt,false,CPUname)
    local cStatus,reason=req.isDone()
    while cStatus == false and req.isCanceled() == false do  
        os.sleep(1)
    end
    if req.isCanceled() == true then
        if reason == nil then
            reason="Dunno. Maybe human."
        end
        print("[" .. getDisplayTime() .. "] Canceled. Reason: "..reason..'\n')
    else
        print("[" .. getDisplayTime() .. "] Done. "..'\n')
    end
end

local function iterItemStockQuery(stock_l)
    for i=1,#stock_l,1 do
        local stockEntry=stock_l[i]
        local stockReq=makeStockReq(stockEntry)
        local item=getItem(stockReq)
        if item==nil then
            print("No item yielded with query "..Serial.serialize(stockReq))
            goto continue
        end
        if item.size < stockEntry.checkLvl then
            while getCPU(CPUname).busy do
                os.sleep(1)
            end
            --request craft
            requestCraft(stockReq, stockEntry.craftAmt)
        end
        ::continue::
    end
end

local function displayStats()
    local totalTypes=#ME.getItemsInNetwork()
    local totalCraftables=#ME.getCraftables()
    gpu.fill(130,1,30,3," ")
    header="====STATS===="
    typeMsg=tostring(totalTypes).." Types"
    patternMsg=tostring(totalCraftables).." Patterns"
    gpu.set(w-#header-2,1,header)
    gpu.set(w-#typeMsg-2,2,typeMsg)
    gpu.set(w-#patternMsg-2,3,patternMsg)
end


while true do
    iterItemStockQuery(itemStock_l)
    --displayStats() --lags server! 1k ms tick
    
    os.sleep(1)
end

