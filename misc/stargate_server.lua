-- Components
local component = require("component")
local event = require("event")
local serialization = require("serialization")
local filesystem = require("filesystem")
local modem = component.modem

-- Global Variables
local dataFile = "/home/stargate_addresses.txt"

-- Helper Functions
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

local function saveAddresses(addresses)
  local file = io.open(dataFile, "w")
  file:write(serialization.serialize(addresses))
  file:close()
end

function tableContains(tbl, val)
    for _, v in pairs(tbl) do
      if v[2] == val then
        return true
      end
    end
    return false
  end
  

-- Event Handlers
local handlers = {}

handlers["modem_message"] = function(e)
    local _, _, _, _, _, message = table.unpack(e)
    message = serialization.unserialize(message)
  
    if type(message) == "string" and message == "request_addresses" then
      modem.broadcast(123, serialization.serialize(loadAddresses()))
    elseif type(message) == "table" and message.action == "add_address" then
      local addresses = loadAddresses()
      if not tableContains(addresses, message.address) then
        table.insert(addresses, {message.name, message.address})
        saveAddresses(addresses)
        modem.broadcast(123, serialization.serialize(loadAddresses()))  -- Broadcast the updated addresses
      end
    end
end

-- Main Loop
local function eventLoop()
  while true do
    local e = {event.pull()}
    local name = e[1]
    local handler = handlers[name]
    if handler then handler(e) end
  end
end

-- Main Function
local function main()
  modem.open(123) -- make sure to open the modem on the same port
  eventLoop()
end

main()
