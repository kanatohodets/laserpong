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

circsCollide = function(xa, ya, ra, xb, yb, rb)
	local dist = math.sqrt((xa*xa)-(xb*xb)+((ya*ya)-yb*yb))
	if dist < ra + rb then
		return true
	end
	return false
end

require "player"
require "laser"
require "ball"

local entities = {}
local players = {}

function love.load()
	players[0] = PlayerClass:new(50,50,0)
	players[1] = PlayerClass:new(love.graphics.getWidth()-50,50,1)

	entities[0] = BallClass:new(200,200)
end

function love.update(dt)
	for i=0,1 do
		--players[i].update(dt)
	end

	for i=0,#entities do
		entities[i]:update(dt)
	end
end

function love.draw()
	for i=0,1 do
		players[i]:draw()
	end

	for i=0,#entities do
		entities[i]:draw()
	end
end



