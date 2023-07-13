-- Components
local thread = require("thread") 
local component = require("component")
local event = require("event")
local serialization = require("serialization")
local term = require("term")
local filesystem = require("filesystem")
local gpu = component.getPrimary("gpu")
local sg = component.getPrimary("stargate")
local modem = component.modem

-- Set screen resolution
local w,h=80,16
gpu.setResolution(w, h)

-- Global Variables
local running = true
local screen_width, screen_height = gpu.getResolution()
local key_event_name = "key_down"
local dataFile = "/home/stargate_addresses.txt"

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
local function listenAndUpdateAddresses()
  -- Create a separate thread to receive addresses
  thread.create(function()
    while true do
      modem.broadcast(123, serialization.serialize("request_addresses"))
      local _, _, _, _, _, message = event.pull("modem_message")
      if message then
        local possibleAddresses = serialization.unserialize(message)
        -- Check if it's a valid address list
        if type(possibleAddresses) == "table" then
          local valid = true
          for _, entry in pairs(possibleAddresses) do
            if type(entry) ~= "table" or #entry ~= 2 or type(entry[1]) ~= "string" or type(entry[2]) ~= "string" then
              valid = false
              break
            end
          end
          -- If it's a valid address list, update the global addresses
          if valid then
            globalAddresses = possibleAddresses
            saveAddresses(globalAddresses)
          end
        end
      end
      os.sleep(3) -- sleep for 3 seconds before trying again
    end
  end)
end


local function checkAndAddOwnAddress()
  -- Add own address if not present
  local ownAddress = sg.localAddress()
  if not tableContains(globalAddresses, ownAddress) then
    print("Address not found. Enter a name for this Stargate: ") -- Debugging
    local gateName = io.read()
    table.insert(globalAddresses, {gateName, ownAddress})
    saveAddresses(globalAddresses)
    modem.broadcast(123, serialization.serialize({action = "add_address", address = ownAddress, name = gateName}))
  end
end


addresses = {}


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
  print("Options:")
  print("\nD Disconnect\nO Open Iris\nC Close Iris\nQ Quit\n")
  for i, na in pairs(globalAddresses) do
    print(string.format("%d %s", i, na[1]))
  end
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
    local na = globalAddresses[tonumber(c)]
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

-- Function to continuously update the menu
local function updateMenuContinuously()
  thread.create(function()
    while true do
      -- Load the latest addresses and update the global variable
      globalAddresses = loadAddresses()
      -- Refresh the menu
      term.clear()
      showMenu()
      -- Wait for some time before updating again
      os.sleep(30) -- sleep for 3 seconds before refreshing again
    end
  end)
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
    os.sleep()
  end
end

local function main()
  term.clear()
  modem.open(123) -- Make sure to open the modem
  globalAddresses = loadAddresses()
  listenAndUpdateAddresses()
  os.sleep(5) -- Give it some time to populate the addresses
  checkAndAddOwnAddress()
  updateMenuContinuously()
  eventLoop()
  term.clear()
  setCursor(1, 1)
end


main()
