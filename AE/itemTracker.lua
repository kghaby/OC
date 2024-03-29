--99% written by chatgpt. uses 10 ms/t and doesnt do anything visibly lol

local component = require("component")
local gpu = component.gpu
local me_network = component.me_interface
local computer = require("computer")
local os = require("os")
local Serial = require("serialization")
local math = require("math")
local colors = require("colors")


-- set display resolution
gpu.setResolution(160, 50)

-- get current time
local function getTime()
  return os.time()
end

-- get the current amount of the specified item in the ME network
local function getItemAmount(itemID)
  local items = me_network.getItemsInNetwork()
  for i = 1, #items do
    if items[i].label == itemID then
      return items[i].size
    end
  end
  return 0
end

local function drawLine(x1,y1,x2,y2)
    -- Bresenham line drawing algorithm
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy

    while true do
    gpu.set(x1, y1, "*") -- set a pixel at the current position

    if x1 == x2 and y1 == y2 then break end
    local e2 = err * 2
    if e2 > -dy then
    err = err - dy
    x1 = x1 + sx
    end
    if e2 < dx then
    err = err + dx
    y1 = y1 + sy
    end
    end
end

-- plot the data on the display
local function plotData(xValues, yValues)
  gpu.setBackground(black)
  gpu.fill(1, 1, 160, 50, " ")
  gpu.setBackground(blue)
  gpu.setForeground(white)

  local maxX = 0
  local maxY = 0
  for i = 1, #xValues do
    if xValues[i] > maxX then
      maxX = xValues[i]
    end
    if yValues[i] > maxY then
      maxY = yValues[i]
    end
  end

  local xScale = 140 / maxX
  local yScale = 40 / maxY

  for i = 2, #xValues do
    gpu.set(10 + math.floor(xValues[i - 1] * xScale), 50 - math.floor(yValues[i - 1] * yScale), ".")
    gpu.set(10 + math.floor(xValues[i] * xScale), 50 - math.floor(yValues[i] * yScale), ".")
    drawLine(10 + math.floor(xValues[i - 1] * xScale), 50 - math.floor(yValues[i - 1] * yScale), 10 + math.floor(xValues[i] * xScale), 50 - math.floor(yValues[i] * yScale))
  end
end

local itemID = "diamond"
local maxDataPoints = 150
local xValues = {}
local yValues = {}

while true do
  local time = getTime()
  local amount = getItemAmount(itemID)

  table.insert(xValues, time)
  table.insert(yValues, amount)

  if #xValues > maxDataPoints then
    table.remove(xValues, 1)
    table.remove(yValues, 1)
  end

  plotData(xValues, yValues)
  os.sleep(1)
end