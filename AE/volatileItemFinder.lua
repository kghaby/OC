local component = require("component")
local ME = component.me_interface
local serialization = require("serialization")

function simulateRequest(item)
    local craftables = ME.getCraftables({name = item})
    local data = {}

    for i, craftable in ipairs(craftables) do
        local request = craftable.request(1, true)
        data[i] = {
            available = request.getAvailableItems(),
            craftable = request.getCraftableItems()
        }
    end

    return data
end

function compareTables(t1, t2)
    local differences = {}

    for i = 1, #t1 do
        if t1[i].available ~= t2[i].available or t1[i].craftable ~= t2[i].craftable then
            table.insert(differences, i)
        end
    end

    return differences
end

function writeToFile(fileName, data)
    local file = io.open(fileName, "w")
    file:write(serialization.serialize(data))
    file:close()
end

local item = "S"  -- replace this with the item you want to check
local firstSimulation = simulateRequest(item)
os.sleep(10)
local secondSimulation = simulateRequest(item)
local differences = compareTables(firstSimulation, secondSimulation)

print("Differences found in items: " .. table.concat(differences, ", "))

writeToFile("differences.txt", differences)
