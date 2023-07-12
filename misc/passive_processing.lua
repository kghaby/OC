local component = require("component")
local event = require("event")
local gpu = component.gpu
local rs = component.list("redstone")() -- get list of all redstone I/O blocks

-- Set screen resolution
local w,h=37,10
gpu.setResolution(w, h)

-- Define the buttons.
local buttons = {
  { name = "Button 1", state = false, rs= },
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
  { x1 = 2, y1 = 4, x2 = 9, y2 = 6 },
  { x1 = 11, y1 = 4, x2 = 18, y2 = 6 },
  { x1 = 20, y1 = 4, x2 = 27, y2 = 6 },
  { x1 = 29, y1 = 4, x2 = 36, y2 = 6 },
  { x1 = 2, y1 = 7, x2 = 9, y2 = 9 },
  { x1 = 11, y1 = 7, x2 = 18, y2 = 9 },
  { x1 = 20, y1 = 7, x2 = 27, y2 = 9 },
  { x1 = 29, y1 = 7, x2 = 36, y2 = 9 }
}

function centerText(w,text)
    -- Center text
    local padding = (w - #text) // 2
    centered= string.rep(" ", padding) .. text .. string.rep(" ", padding)
    return centered
end

-- Format button name to fit into 8x3 box and center the text.
function formatButtonName(name)
    local lines = {}
    local parts = {}

    -- Split the name into words by space, and include special characters as separate words
    for part in string.gmatch(name, "%S+") do
        table.insert(parts, part)
    end

    for i = 1, #parts do
        local word = parts[i]
        if #word > 1 and not word:match("^%a+$") then -- if word contains special character
        for specialChar in word:gmatch("%p") do
            local index = word:find(specialChar)
            local first = word:sub(1, index-1)
            local second = word:sub(index + 1, #word)
            word = (first ~= "" and first or nil)
            table.insert(parts, i+1, specialChar)
            if second ~= "" then
            table.insert(parts, i+2, second)
            end
            break
        end
        end
        parts[i] = word
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
        lines[i] = centerText(w,line)
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
  gpu.fill(coords.x1, coords.y1, coords.x2, coords.y2, ' ') -- Fill an area with the color.
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
gpu.set(1, 1, centerText(w,"PASSIVE PROCESSING"))
gpu.fill(1, 2, w, 2, '_')

-- Draw the initial state of the buttons.
for index, button in ipairs(buttons) do
  drawButton(button, buttonCoords[index])
end

-- Wait for user input.
while true do
  event.pull("touch")
  os.sleep()
end
