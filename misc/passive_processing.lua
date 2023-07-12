local component = require("component")
local event = require("event")
local gpu = component.gpu


-- Set screen resolution
local w,h=37,9
gpu.setResolution(w, h)

-- Define the buttons.
local buttons = {
  { name = "BEE PROD & PROC", state = false, rs = component.proxy("5a625137-0956-4bc8-96d0-873572bca924")},
  { name = "LOG PROD & PROC", state = false, rs = component.proxy("6359483a-1898-455a-91a5-7f4c4ce9bd8c") },
  { name = "PLASMA PROC", state = false, rs = component.proxy("dc664d31-3f05-44f9-9fb3-290fa6815d86") },
  { name = "UUM PROD", state = false, rs = component.proxy("1fc0ce2e-36eb-4bf8-a0e8-90fd6c584b7e") },
  { name = "EECs", state = false, rs = component.proxy("8bfbbb9c-1208-4201-a7ba-e99bcddfb939") },
  { name = "n/a", state = false, rs = component.proxy("42229db7-8663-41f6-a899-061110ed3416") },
  { name = "n/a", state = false, rs = component.proxy("fa233804-aae9-4aae-b8de-c63ca8503f67") },
  { name = "n/a", state = false, rs = component.proxy("5cc70e7b-f9b1-4eca-a2d9-3dff18f36dcc") }
}

-- Define the coordinates of each button.
local buttonCoords = {
  { x1 = 2, y1 = 4, x2 = 9, y2 = 5 },
  { x1 = 11, y1 = 4, x2 = 18, y2 = 5 },
  { x1 = 20, y1 = 4, x2 = 27, y2 = 5 },
  { x1 = 29, y1 = 4, x2 = 36, y2 = 5 },
  { x1 = 2, y1 = 7, x2 = 9, y2 = 8 },
  { x1 = 11, y1 = 7, x2 = 18, y2 = 8 },
  { x1 = 20, y1 = 7, x2 = 27, y2 = 8 },
  { x1 = 29, y1 = 7, x2 = 36, y2 = 8 }
}

function centerText(w, text)
    -- Center text
    local padding = (w - #text + 1) // 2
    local centered = string.rep(" ", padding) .. text .. string.rep(" ", w - #text - padding)
    return centered
end

function formatButtonName(name)
    local lines = {}
    local parts = {}

    -- Split the name into words by space, and include special characters as separate words
    for part in string.gmatch(name, "%S+") do
        table.insert(parts, part)
    end

    local i = 1
    while i <= #parts do
        local line = parts[i]
        i = i + 1
        while i <= #parts and #line + 1 + #parts[i] <= 8 do
        line = line .. " " .. parts[i]
        i = i + 1
        end
        table.insert(lines, line)
    end

    -- Center text in each line.
    for i, line in ipairs(lines) do
        lines[i] = centerText(8, line)
    end

    return lines
end


-- Define a function to draw a button.
function drawButton(button, coords)
    -- Set the color based on the state of the button.
    if button.state then
      gpu.setBackground(0x00FF00) -- Green for on.
    else
      gpu.setBackground(0xFF0000) -- Red for off.
    end
  
    -- Draw the button.
    local lines = formatButtonName(button.name)
    local buttonWidth = coords.x2 - coords.x1 + 1
    local buttonHeight = coords.y2 - coords.y1 + 1
    gpu.fill(coords.x1, coords.y1, buttonWidth, buttonHeight, ' ')  
    for i, line in ipairs(lines) do
      gpu.set(coords.x1, coords.y1 + i - 1, line)
    end
    
    gpu.setBackground(0x000000) -- Reset the background color.
end

--redstone control
local function disengage(rs)
    rs.setOutput({0, 0, 0, 0, 0, 0})
end
local function engage(rs)
    rs.setOutput({15, 15, 15, 15, 15, 15})
end

-- Define a function to handle touch events.
function onTouch(_, _, x, y, _, _)
  -- Determine which button was clicked.
  for index, coords in ipairs(buttonCoords) do
    if y >= coords.y1 and y <= coords.y2 and x >= coords.x1 and x <= coords.x2 then
      local button = buttons[index]
      -- Toggle the state of the button.
      button.state = not button.state
      -- Update the redstone output.
      if button.state then
        engage(button.rs)
      else
        disengage(button.rs)
      end
      -- Redraw the button.
      drawButton(button, coords)
      os.sleep(0.1)
      break
    end
  end
end

-- Register the touch event handler.
event.listen("touch", onTouch)

-- Clear the screen before drawing.
gpu.setBackground(0x000000)
gpu.fill(1, 1, w, h, ' ')

-- Draw the header
gpu.set(1, 1, centerText(w,"PASSIVE PROCESSING"))
gpu.fill(1, 2, w, 1, '_')

-- Draw the initial state of the buttons.
for index, button in ipairs(buttons) do
  drawButton(button, buttonCoords[index])
  disengage(button.rs)
end

-- Wait for user input.
while true do
  event.pull("touch")
  os.sleep()
end
