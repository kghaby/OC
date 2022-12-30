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
local fs = component.proxy("e7f123ff-fa30-4772-8bdf-a7e13ab5e8e8")


function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


function sizeFormat(size) 
  if size < 1024 then
    return(size .. " B")
  end
  if size > 1024 and size < 1048576 then
    return(round(size / 1024, 2) .. " KiB")
  end
  if size > 1048576 and size < 1073741824 then
    return(round(size / 1048576, 2) .. " MiB")
  end
end

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
    tags_fh:write(v[1], v[2],'\n') 
end
tags_fh:close()

local size=math.ceil(fs.size("/home/tags.dat"))
print("tags.dat is "..sizeFormat(size).." and contains "..#tagsizeList.."tags.")



