local component = require("component")
local computer = require("computer")
local os = require("os")
local math = require("math")
local gpu = component.gpu
local ME = component.me_interface

local itemToTrack = "diamond"
local maxPoints = 50
local sampleInterval = 5 -- seconds

-- initialize the plot data with zeros
local plotData = {}
for i = 1, maxPoints do
  plotData[i] = 0
end

local function getCurrentCount()
  local itemCount = 0
  local itemList = ME.getItemsInNetwork()
  for i = 1, #itemList do
    local item = itemList[i]
    if item.name == itemToTrack then
      itemCount = itemCount + item.size
    end
  end
  return itemCount
end

-- update the plot data with the current item count
local function updatePlotData(currentCount)
  for i = 2, maxPoints do
    plotData[i - 1] = plotData[i]
  end
  plotData[maxPoints] = currentCount
end

-- plot the data on the screen
local function plotDataOnScreen()
  local maxCount = 0
  for i = 1, maxPoints do
    maxCount = math.max(maxCount, plotData[i])
  end
  gpu.setResolution(maxPoints, maxCount)
  local w, h = gpu.getResolution()
  gpu.fill(1, 1, w, h, " ")
  for i = 1, maxPoints do
    gpu.set(i, h - plotData[i] + 1, "*")
  end
end

while true do
  local currentCount = getCurrentCount()
  updatePlotData(currentCount)
  plotDataOnScreen()
  os.sleep(sampleInterval)
end
