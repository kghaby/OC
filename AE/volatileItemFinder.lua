local component = require("component")
local os = require("os")
local fs = require("filesystem")
local ME = component.me_interface

local function getItemsInNetwork()
    local items = {}
    local itemList = ME.getItemsInNetwork()
    for i=1, #itemList do
        local item = itemList[i]
        items[item.label] = item.size
    end
    return items
end

local function compareTables(t1, t2)
    local diffItems = {}
    for k,v in pairs(t1) do
        if t2[k] ~= nil and t2[k] ~= v then
            diffItems[k] = { label = k, difference = t2[k] - v}
        end
    end
    return diffItems
end

local function writeToFile(filename, data)
    local file = fs.open(filename, "w")
    for k,v in pairs(data) do
        local dots = string.rep(".", 50 - string.len(v.label))
        file:write(v.label..dots..v.difference.."\n")
    end
    file:close()
end

local itemsBefore = getItemsInNetwork()
print("Rolling 10 second window:")
while true do
    os.sleep(10)
    local itemsAfter = getItemsInNetwork()
    local diffItems = compareTables(itemsBefore, itemsAfter)
    
    if next(diffItems) ~= nil then
        for k,v in pairs(diffItems) do
            local dots = string.rep(".", 50 - string.len(v.label))
            print(v.label..dots..v.difference)
        end
        writeToFile("/home/diffItems.txt", diffItems)
    end
    itemsBefore=itemsAfter
end

