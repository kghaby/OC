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

local itemStockList=require("itemStock")
local sleepTime=60 --s

--online detect
local onlineDetector=component.onlinedetector
local function allOffline()
    if #onlineDetector.getPlayerList()==0 then
        return true
    else
        return false
    end
end

local function round(num) return math.floor(num+.5) end

local function getDisplayTime()
    return os.date("%H:%M:%S", computer.uptime())
end

local function getTimestamp()
    return "[" .. getDisplayTime() .. "] "
end

local running_l={}
local CPUname="Auto"


local function getAmtCrafting(name,stockReq)
    --gets the amount of the item thats already being crafted in <name> cpus
    local CPU_l=ME.getCpus()
    local amtCrafting=0
    for i=1,#CPU_l,1 do 
        local CPU=CPU_l[i]
        if string.find(CPU.name,name) and CPU.busy then
                local cpu=CPU.cpu
                local finalOutput=cpu.finalOutput()
                if finalOutput~=nil then
                    local finalLabel=finalOutput.label
                    if finalLabel == stockReq.label then
                        amtCrafting=amtCrafting+finalOutput.size
                    end
                end
        end
    end
    return amtCrafting
end

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
        print("All CPUs busy; resting 10 seconds.")
        os.sleep(10)
        CPU_l=ME.getCpus()
    end
    print("Could not find CPU containing "..name) --does not currently reach this line. need break in while loop
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

local match=true
local function trimListList(queryListList,bigList)
    local trimmedList={}
    for i=1,#bigList,1 do 
        local bigEntry=bigList[i]
        
        for k,v in pairs(queryListList) do
            local queryList=makeStockReq(queryListList[k])
            match=true
            if type(queryList)~="table" then
                print("Query not a table: "..queryList)
                os.exit()
            end
            for k,v in pairs(queryList) do
                if queryList[k]~=bigEntry[k] then
                    match=false
                    break
                end
            end
            if match then
                table.insert(trimmedList,bigEntry)
            end

        end
    end
    return trimmedList
end

local function trimList(queryList,bigList)
    local trimmedList={}
    for i=1,#bigList,1 do 
        local bigEntry=bigList[i]
        match=true
        for k,v in pairs(queryList) do
            if queryList[k]~=bigEntry[k] then
                match=false
                break
            end
        end
        if match then
            table.insert(trimmedList,bigEntry)
        end

    end
    return trimmedList
end


local function getItem(stockReq,itemList)
    local item_l=trimList(stockReq,itemList)
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


local function getPattern(stockReq)
    pattern_l=ME.getCraftables(stockReq)
    if #pattern_l>1 then 
        print("More than 1 pattern found with parameters "..Serial.serialize(stockReq))
        print("Use damage, name, tag, or hasTag to narrow search")
        SR_fh = io.open("pattern_SR.dat","w")
        for i=1,#pattern_l,1 do
            for k,v in pairs(pattern_l[i]) do
                SR_fh:write(tostring(k)..'    '..tostring(v)..'\n')
            end
            SR_fh:write('\n')
        end
        print("The pattern search results have been written to pattern_SR.dat. Exiting...")
        SR_fh:close()
        os.exit()
    else
        return pattern_l[1]
    end
end

local function requestCraft(stockReq, amt,CPU)
    local recipe = getPattern(stockReq)
    if recipe ~=nil then
        print(getTimestamp().."Requesting " .. amt .. " " .. stockReq["label"].." on "..CPU.name)
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
            print(getTimestamp().."Canceled. Reason: "..reason)
        --else
            --print("[" .. getDisplayTime() .. "] Done. "..'\n')
        end
    else
        print(getTimestamp().."No pattern yielded with query "..Serial.serialize(stockReq))
    end
end



local function iterItemStockQuery(stockList,itemList)

    for i=1,#stockList,1 do
        local stockEntry=stockList[i]
        if stockEntry.offlineOnly then
            if not allOffline() then
                print(getTimestamp().."Player(s) online. Skipping "..stockEntry.label)
                goto continue
            end
        end
        local stockReq=makeStockReq(stockEntry)
        local item=getItem(stockReq,itemList)
        if item==nil then
            print(getTimestamp().."No item yielded with query "..Serial.serialize(stockReq))
            goto continue
        end
        totSize=item.size+getAmtCrafting(CPUname,stockReq)
        if totSize < stockEntry.checkLvl then
            local CPU=getCPU(CPUname)
            --request craft
            requestCraft(stockReq, stockEntry.craftAmt,CPU)
        end
        ::continue::
    end
end

local function displayStats(itemList)
    local totalTypes=#itemList
    local totalCraftables=0
    for i=1,#totalTypes,1 do
        local entry=itemList[i] 
        if entry.isCraftable then
            totalCraftables=totalCraftables+1
        end
    end  

    gpu.fill(130,1,30,3," ")
    header="====STATS===="
    typeMsg=tostring(totalTypes).." Types"
    patternMsg=tostring(totalCraftables).." Patterns"
    gpu.set(w-#header-2,1,header)
    gpu.set(w-#typeMsg-2,2,typeMsg)
    gpu.set(w-#patternMsg-2,3,patternMsg)
end


while true do
    print(getTimestamp()..'Checking items...\n')

    local itemListFull=ME.getItemsInNetwork()
    itemList=trimListList(itemStockList,itemListFull)

    iterItemStockQuery(itemStockList,itemList)

    --displayStats(itemListFull) 
    print(getTimestamp()..'Resting for '..sleepTime..' seconds.\n')
    os.sleep(sleepTime)
end

