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
require "screenEffects"

font = love.graphics.newFont("Courier New Bold.ttf", 15)

players = {}
ball = nil

states = {ip=1,ingame=2}
curState = states.ingame

ipString = ""

function love.load()
	players[0] = PlayerClass:new(50,love.graphics.getHeight()/2,0)
	players[1] = PlayerClass:new(love.graphics.getWidth()-50,love.graphics.getHeight()/2,1)

	ball = BallClass:new(love.graphics.getWidth()/2,love.graphics.getHeight()/2)
end

function love.update(dt)
	if curState == states.ip then

	elseif curState == states.ingame then
		ScreenFX.evaluateFX(dt)
	    players[0]:update(dt)
	    players[1]:update(dt)

		ball:update(dt)
	end
end

function love.keypressed( key, unicode )
	if key == "escape" then
		love.event.push("quit")
	end
	if curState == states.ip then
		if key == "enter" or key == "return" then

		elseif unicode == 127 and string.len(ipString) > 0 then
			ipString = string.sub(ipString, 0, string.len(ipString)-1)
		else
			ipString = ipString..key
		end
	elseif curState == states.ingame then
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
end

function love.keyreleased(key)
	if curState == states.ingame then
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
end

function love.draw()
	if curState == states.ip then
		love.graphics.print("Enter the host's ip address and press enter (leave blank if you're a server):", 100, 100)
		love.graphics.print("IP: "..ipString, 100, 150)
	elseif curState == states.ingame then
		love.graphics.setBackgroundColor(ScreenFX.bgColor)
		love.graphics.translate(ScreenFX.coordTranslate[1], ScreenFX.coordTranslate[2])
		love.graphics.setColor(COLORS.white)
		love.graphics.print(players[0].score, love.graphics.getWidth()/3, love.graphics.getHeight()/3)
		love.graphics.print(players[1].score, love.graphics.getWidth()/3*2, love.graphics.getHeight()/3)
		for i=0,1 do
			players[i]:draw()
		end

		ball:draw()
	end
end



