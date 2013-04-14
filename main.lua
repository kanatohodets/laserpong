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
	local dist = math.sqrt(math.pow((xa-xb),2)+math.pow((ya-yb),2))
	if dist < ra + rb then
		return true
	end
	return false
end

require "player"
require "laser"
require "ball"
require "sfx"

players = {}
ball = nil

function love.load()
	players[0] = PlayerClass:new(50,love.graphics.getHeight()/2,0)
	players[1] = PlayerClass:new(love.graphics.getWidth()-50,love.graphics.getHeight()/2,1)

	ball = BallClass:new(200,200)
end

function love.update(dt)

    players[0]:update(dt)
    players[1]:update(dt)

	ball:update(dt)
end

function love.keypressed( key )
	if key == "escape" then
		love.event.push("quit")
	end

	if key == "q" then
        players[0]:moveUp()
    end
    if key == "s" then
        players[0]:moveDown()
    end
    if key == "d" then
        players[0]:shootLaser()
    end

    if key == "p" then
        players[1]:moveUp()
    end
    if key == "l" then
        players[1]:moveDown()
    end
    if key == "k" then
        players[1]:shootLaser()
    end
end

function love.keyreleased(key)
	if key == "q" then
		players[0]:stop(-1)
	elseif key == "s" then
		players[0]:stop(1)
	end

	if key == "p" then
        players[1]:stop(-1)
    end
    if key == "l" then
        players[1]:stop(1)
    end
end

function love.draw()
	for i=0,1 do
		players[i]:draw()
	end

	ball:draw()
end



