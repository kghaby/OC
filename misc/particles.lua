--written by chatgpt

local computer = require("computer")
local component = require("component")
local gpu = component.gpu
local math = require("math")
local os = require("os")

local particles = {}
local numParticles = 10 -- change this to the desired number of particles
local force = 1 -- change this to the desired repulsion force


local width, height = gpu.getResolution()
for i=1,numParticles,1 do
particles[i] = {x = math.random(width), y = math.random(height), r = math.random(1,10)} -- change the values of x, y, and r to the desired values
end

local function displayParticles(particles)
    for i, particle in ipairs(particles) do
        local r = math.random(255)
        local g = math.random(255)
        local b = math.random(255)
        gpu.setForeground(tonumber(string.format("0x%02x%02x%02x", r, g, b)))
        gpu.set(particle.x, particle.y, "o")
    end
end

local function updateParticles()
    for i=1,#particles,1 do
        for j=1,#particles,1 do
            if i ~= j then
                local dx = particles[i].x - particles[j].x
                local dy = particles[i].y - particles[j].y
                local distance = math.sqrt(dx * dx + dy * dy)

                local fx = (dx / distance) * force
                local fy = (dy / distance) * force
                if particles[i].x < 0 or particles[i].x > w then
                    fx=-fx
                end
                if particles[i].y < 0 or particles[i].y > h then
                    fy=-fy
                end
                particles[i].x = particles[i].x + fx
                particles[i].y = particles[i].y + fy

            end
        end
    end
end 

while true do
  updateParticles()
  gpu.fill(1, 1, width, height, " ")
  displayParticles(particles)
  os.sleep(0.05)
end
