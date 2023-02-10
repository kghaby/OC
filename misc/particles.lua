--written by chatgpt

local computer = require("computer")
local component = require("component")
local gpu = component.gpu
local math = require("math")
local os = require("os")

local width, height = gpu.getResolution()

local particle1 = {x = math.random(width), y = math.random(height)}
local particle2 = {x = math.random(width), y = math.random(height)}

local function distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

local function updateParticles()
  particle1.x = particle1.x + math.random(-1, 1)
  particle1.y = particle1.y + math.random(-1, 1)
  particle2.x = particle2.x + math.random(-1, 1)
  particle2.y = particle2.y + math.random(-1, 1)

  local d = distance(particle1.x, particle1.y, particle2.x, particle2.y)
  if d < 2 then
    local angle = math.atan2(particle2.y - particle1.y, particle2.x - particle1.x)
    particle2.x = particle1.x + 2 * math.cos(angle)
    particle2.y = particle1.y + 2 * math.sin(angle)
  end

  particle1.x = math.min(math.max(1, particle1.x), width - 1)
  particle1.y = math.min(math.max(1, particle1.y), height - 1)
  particle2.x = math.min(math.max(1, particle2.x), width - 1)
  particle2.y = math.min(math.max(1, particle2.y), height - 1)
end

while true do
  updateParticles()
  gpu.fill(1, 1, width, height, " ")
  gpu.set(math.floor(particle1.x), math.floor(particle1.y), "O")
  gpu.set(math.floor(particle2.x), math.floor(particle2.y), "O")
  --gpu.set(1, 1, "X")
  --gpu.set(width, 1, "X")
  --gpu.set(1, height, "X")
  --gpu.set(width, height, "X")
  --for i = 2, width - 1 do
  --  gpu.set(i, 1, "-")
  --  gpu.set(i, height, "-")
  --end
  --for i = 2, height - 1 do
  --  gpu.set(1, i, "|")
  --  gpu.set(width, i, "|")
  --end

  --computer.pushSignal("display") --needed?
  os.sleep(0.05)
end
