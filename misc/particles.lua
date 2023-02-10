local computer = require("computer")
local component = require("component")
local gpu = component.gpu
local math = require("math")
local os = require("os")

local particles = {}
local numParticles = 3 -- change this to the desired number of particles
local force = 1 -- change this to the desired repulsion force
local boundaryForce=2


local width, height = gpu.getResolution()
for i=1,numParticles,1 do
particles[i] = {x = math.random(width), y = math.random(height)} -- change the values of x, y to the desired values
end

local function colorParticles(particles)
    for i, particle in ipairs(particles) do
        local r = math.random(255)
        local g = math.random(255)
        local b = math.random(255)
        particle.color=tonumber(string.format("0x%02x%02x%02x", r, g, b))
    end
end

local function displayParticles(particles)
    for i, particle in ipairs(particles) do
        gpu.setForeground(particle.color)
        gpu.set(particle.x, particle.y, "o")
    end
end

local function calcForce(x1,y1,x2,y2)
    local dx = particles[i].x - particles[j].x
    local dy = particles[i].y - particles[j].y
    local distance = math.sqrt(dx * dx + dy * dy)
    local fx = (dx / distance) * force
    local fy = (dy / distance) * force
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

                local Bdx = particles[i].x-0
                local Bdy = particles[i].y-0
                local Bdistance = math.sqrt(Bdx * Bdx + Bdy * Bdy)
                local Bfx = (Bdx / Bdistance) * boundaryForce
                local Bfy = (Bdy / Bdistance) * boundaryForce

                local Tdx = particles[i].x-width
                local Tdy = particles[i].y-height
                local Tdistance = math.sqrt(Tdx * Tdx + Tdy * Tdy)
                local Tfx = (Tdx / Tdistance) * boundaryForce
                local Tfy = (Tdy / Tdistance) * boundaryForce

                particles[i].x = particles[i].x + math.random(-1, 1) + fx + Bfx + Tfx
                particles[i].y = particles[i].y + math.random(-1, 1) + fy + Bfy + Tfy

            end
        end
    end
end 

colorParticles(particles)
while true do
  updateParticles()
  gpu.fill(1, 1, width, height, " ")
  displayParticles(particles)
  os.sleep(0.05)
end
