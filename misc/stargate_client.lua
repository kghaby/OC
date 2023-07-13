-- Required Libraries
local term = require("term")
local event = require("event")
local component = require("component")
local serialization = require("serialization")
local filesystem = require("filesystem")

-- Components
local gpu = component.getPrimary("gpu")
local sg = component.getPrimary("stargate")
local modem = component.modem
local dataFile = "/home/stargate_addresses.txt"

-- Global Variables
local running = true
local screen_width, screen_height = gpu.getResolution()
local key_event_name = "key_down"

-- Helper Functions
local function try(func, ...)
  local ok, result = pcall(func, ...)
  if not ok then print("Error: " .. result) end
end

local function setCursor(col, row)
  term.setCursor(col, row)
end

local function write(s)
  term.write(s)
end

local function pull_event()
  return event.pull()
end

local function key_event_char(e)
  return string.char(e[3])
end

local function pad(s, n)
  if string.len(s) < n then
    s = s .. string.rep(" ", n - string.len(s))
  end
  return s
end

local function extractErrorMessage(mess)
  mess = mess:match(":%s(.+)")
  return mess or "Unknown error"
end

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

-- Table contains function
function tableContains(tbl, val)
  for _, v in pairs(tbl) do
    if v[2] == val then
      return true
    end
  end
  return false
end

local addresses = loadAddresses()

local ownAddress = sg.localAddress()
if not tableContains(addresses, ownAddress) then
  table.insert(addresses, {sg.getName(), ownAddress})
  saveAddresses(addresses)
  modem.broadcast(123, serialization.serialize({action = "add_address", address = ownAddress}))
end

modem.broadcast(123, serialization.serialize("request_addresses"))

local _, _, _, _, _, message = event.pull("modem_message")

addresses = serialization.unserialize(message)
saveAddresses(addresses)

-- Display Functions
local function showAt(x, y, s)
  setCursor(x, y)
  write(pad(s, 50))
end

local function showMessage(mess)
  showAt(1, screen_height, mess)
end

local function showError(mess)
  showMessage("Error: " .. extractErrorMessage(mess))
end

-- Stargate Functions
local function getIrisState()
  local ok, result = pcall(sg.irisState)
  return result
end

local function dial(name, addr)
  showMessage(string.format("Dialling %s (%s)", name, addr))
  sg.dial(addr)
end

local function showState()
  local locAddr = sg.localAddress()
  local remAddr = sg.remoteAddress()
  local state, chevrons, direction = sg.stargateState()
  local energy = sg.energyAvailable()
  local iris = sg.irisState()
  showAt(30, 1, "Local:     " .. locAddr)
  showAt(30, 2, "Remote:    " .. remAddr)
  showAt(30, 3, "State:     " .. state)
  showAt(30, 4, "Energy:    " .. energy)
  showAt(30, 5, "Iris:      " .. iris)
  showAt(30, 6, "Engaged:   " .. chevrons)
  showAt(30, 7, "Direction: " .. direction)
end

local function showMenu()
  setCursor(1, 1)
  for i, na in pairs(addresses) do
    print(string.format("%d %s", i, na[1]))
  end
  print("\nD Disconnect\nO Open Iris\nC Close Iris\nQ Quit\n")
  write("Option? ")
end

-- Event Handlers
local handlers = {}

handlers[key_event_name] = function(e)
  local c = key_event_char(e)
  if c == "d" then
    sg.disconnect()
  elseif c == "o" then
    sg.openIris()
  elseif c == "c" then
    sg.closeIris()
  elseif c == "q" then
    running = false
  elseif c >= "1" and c <= "9" then
    local na = addresses[tonumber(c)]
    if na then
      dial(na[1], na[2])
    end
  end
end

handlers["sgChevronEngaged"] = function(e)
  local chevron = e[3]
  local symbol = e[4]
  showMessage(string.format("Chevron %s engaged! (%s)", chevron, symbol))
end

-- Main Loop
local function eventLoop()
  while running do
    showState()
    local e = {pull_event()}
    local name = e[1]
    local handler = handlers[name]
    if handler then
      showMessage("")
      try(handler, e)
    end
  end
end

-- Main Function
local function main()
  term.clear()
  showMenu()
  eventLoop()
  term.clear()
  setCursor(1, 1)
end

main()
