local component = require("component")
local event = require("event")
local gpu = component.gpu
local rs = component.list("redstone")() -- get list of all redstone I/O blocks

-- Set screen resolution
gpu.setResolution(37, 17)

-- Define the buttons.
local buttons = {
  { name = "Button 1", state = false },
  { name = "Button 2", state = false },
  { name = "LOG PROD&PROC", state = false },
  { name = "Button 4", state = false },
  { name = "Button 5", state = false },
  { name = "Button 6", state = false },
  { name = "Button 7", state = false },
  { name = "Button 8", state = false }
}

-- Define the coordinates of each button.
local buttonCoords = {
  { x1 = 1, y1 = 4, x2 = 8, y2 = 6 },
  { x1 = 10, y1 = 4, x2 = 17, y2 = 6 },
  { x1 = 19, y1 = 4, x2 = 26, y2 = 6 },
  { x1 = 28, y1 = 4, x2 = 35, y2 = 6 },
  { x1 = 1, y1 = 10, x2 = 8, y2 = 12 },
  { x1 = 10, y1 = 10, x2 = 17, y2 = 12 },
  { x1 = 19, y1 = 10, x2 = 26, y2 = 12 },
  { x1 = 28, y1 = 10, x2 = 35, y2 = 12 }
}

-- Format button name to fit into 8x3 box and center the text.
function formatButtonName(name)
  local lines = {}
  local words = {}
  
  -- Split the name into words by space or & symbol.
  for word in string.gmatch(name, "([^ &]+)") do
    table.insert(words, word)
  end

  local i = 1
  while i <= #words do
    local line = words[i]
    i = i + 1
    while i <= #words and #line + #words[i] + 1 <= 8 do
      line = line .. " " .. words[i]
      i = i + 1
    end
    table.insert(lines, line)
  end

  -- Center text in each line.
  for i, line in ipairs(lines) do
    local padding = (8 - #line) // 2
    lines[i] = string.rep(" ", padding) .. line .. string.rep(" ", padding)
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
  gpu.fill(coords.x1, coords.y1, 8, 3, ' ') -- Fill an area with the color.
  for i, line in ipairs(lines) do
    gpu.set(coords.x1, coords.y1 + i - 1, line)
  end
  
  gpu.setBackground(0x000000) -- Reset the background color.
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
        component.invoke(rs, "setOutput", index - 1, 15)
      else
        component.invoke(rs, "setOutput", index - 1, 0)
      end
      -- Redraw the button.
      drawButton(button, coords)
      break
    end
  end
end

-- Register the touch event handler.
event.listen("touch", onTouch)

-- Clear the screen before drawing.
gpu.setBackground(0x000000)
gpu.fill(1, 1, 37, 17, ' ')

-- Draw the header
gpu.set(14, 1, "Passive Processing")

-- Draw the initial state of the buttons.
for index, button in ipairs(buttons) do
  drawButton(button, buttonCoords[index])
end

-- Wait for user input.
while true do
  event.pull("touch")
end
