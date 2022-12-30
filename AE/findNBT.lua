local component = require("component")
local math = require("math")
local ME = component.me_interface

local function getTagsizeList(itemList)
    local tagsizeList={}
    totalTypes=#itemList
    for i=1,totalTypes,1 do 
        local item=itemList[i]
        if item.hasTag then
            itemTable={item.label,#item.tag}
            table.insert(tagsizeList,itemTable)
        end
    end
    return tagsizeList
end

print('Finding tags...')
local itemList=ME.getItemsInNetwork()
local tagsizeList=getTagsizeList(itemList)

--sort
table.sort(tagsizeList, function(lhs, rhs) return lhs[2] > rhs[2] end)

--write list
local tags_fh = io.open("tags.dat","w")
for _, v in ipairs(tagsizeList) do 
    tags_fh:write(v[1],'\t\t\t', v[2],'\n') 
end
tags_fh:close()

print("tags.dat contains "..#tagsizeList.."tags")



