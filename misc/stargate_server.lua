-- Server
local component = require("component")
local event = require("event")
local serialization = require("serialization")
local filesystem = require("filesystem")
local sides = require("sides")

local modem = component.modem
local dataFile = "/home/stargate_addresses.txt"

--autoreboot with reboot IC gate
redstone=component.redstone
redstone.setOutput(sides.back,15)
redstone.setWakeThreshold(15)

-- Read the existing addresses from a file
local function loadAddresses()
  if filesystem.exists(dataFile) then
    local file = io.open(dataFile, "r")
    local data = file:read("*all")
    file:close()
    return serialization.unserialize(data)
  else
    return {}
  end
end

-- Save the updated addresses to a file
local function saveAddresses(addresses)
  local file = io.open(dataFile, "w")
  file:write(serialization.serialize(addresses))
  file:close()
end

local addresses = loadAddresses()

modem.open(123)

while true do
  local _, _, from, _, _, message = event.pull("modem_message")
  
  if message == "request_addresses" then
    local serializedAddresses = serialization.serialize(addresses)
    modem.send(from, 123, serializedAddresses)
  elseif type(message) == "table" and message.action == "add_address" then
    table.insert(addresses, message.address)
    saveAddresses(addresses)
  end
end
