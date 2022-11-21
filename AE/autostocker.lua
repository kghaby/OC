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

--autoreboot with comparator next to comp >not gate>signal back into comp
RScard=component.proxy("dfeb5ae3-3e58-4467-b834-853af8bc6a9a")
RScard.setWakeThreshold(10)

local itemStock_l=require("itemStock")
local sleepTime=60 --s

local function round(num) return math.floor(num+.5) end

function getDisplayTime()
    return os.date("%H:%M:%S", os.time())
end


local CPUname="Auto"
local function getCPU(name)
    local CPU_l=ME.getCpus()
    local found=false
    while not found do
        for i=1,#CPU_l,1 do 
            --look for an avail CPU with Auto in the name 
            if string.find(CPU_l[i].name,name) and not CPU_l[i].busy then 
                found=true
                return CPU_l[i]
            end
        end
        os.sleep()
    end
    print("Could not find CPU containing "..name)
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


local function requestCraft(stockReq, amt,CPU)
    local recipe = ME.getCraftables(stockReq)[1]
    print("[" .. getDisplayTime() .. "] Requesting " .. amt .. " " .. stockReq["label"].." on "..CPU.name)
    local req = recipe.request(amt,false,CPU.name)
    
    --while not req.isDone() and not req.isCanceled() do  
    --    cStatus,reason=req.isDone()
    --    os.sleep()
    --end
    os.sleep(1)
    local cStatus,reason=req.isDone()
    if req.isCanceled() == true then
        if reason == nil then
            reason="Dunno. Maybe human."
        end
        print("[" .. getDisplayTime() .. "] Canceled. Reason: "..reason..'\n')
    --else
        --print("[" .. getDisplayTime() .. "] Done. "..'\n')
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
            local CPU=getCPU(CPUname)
            --request craft
            requestCraft(stockReq, stockEntry.craftAmt,CPU)
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
    print("[" .. getDisplayTime() .. '] Checking items...\n')
    iterItemStockQuery(itemStock_l)
    --displayStats() --lags server! 1k ms tick
    print("[" .. getDisplayTime() .. '] Resting for '..sleepTime..' seconds.\n')
    os.sleep(sleepTime)
end

