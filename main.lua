COLORS = {gold = {255,215,0}, red = {255,0,0}, black = {0,0,0},
    white = {255,255,255},gray = {100,100,100},grey = {120,100,100},brown={145,100,50},
    green={0,200,0},yellow={255,255,0},magenta={255,0,160},blue={0,180,255},darkblue={0, 100, 255}}

-- returns true if the provided rectangles are colliding
rectsCollide = function(lefta, topa, wa, ha, leftb, topb, wb, hb)
    if topa > topb+hb then
        return false
    elseif topb > topa+ha then
        return false
    elseif lefta > leftb+wb then
        return false
    elseif leftb > lefta+wa then
        return false
    end
    return true
end

require "player"
require "laser"
require "ball"

local entities = {}
local players = {}

function love.load()

end

function love.update(dt)

end



