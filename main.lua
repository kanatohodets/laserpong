math.randomseed(os.time())
math.random()
math.random()
math.random()
math.random()

COLORS = {gold = {255,215,0}, red = {255,0,0}, black = {0,0,0},
    white = {255,255,255},gray = {100,100,100},grey = {120,100,100},brown={145,100,50},
    green={0,200,0},yellow={255,255,0},magenta={255,0,160},blue={0,180,255},darkblue={0, 100, 255}}

require "lib/OO"
require "entity/player"
require "entity/laser"
require "entity/ball"
require "lib/sfx"
require "lib/screenEffects"

local font = love.graphics.newFont("lib/Courier New Bold.ttf", 16)
love.graphics.setFont(font)
function printCentered(s, x, y, width, height)
	local fw = font:getWidth(s)
	local fh = font:getHeight()
	love.graphics.print(s, x + width/2 - fw/2, y + height/2 - fh/2)
end

players = {}
ball = nil

local states = {
    ip = 1,
    ingame = 2,
    title = 3
}

local curState = states.title

local ipString = ""

local songIndex = math.random(4)

function love.load()
	players[0] = Player:new(50, love.graphics.getHeight() / 2, 0)
	players[1] = Player:new(love.graphics.getWidth() - 50, love.graphics.getHeight() / 2, 1)

	ball = Ball:new(love.graphics.getWidth() / 2,love.graphics.getHeight() / 2)
	SFX.playSong(SFX.songList[songIndex])
end

function love.update(dt)
	if curState == states.ip then
        -- networking screen
	elseif curState == states.ingame then
		ScreenFX.evaluateFX(dt)
	    players[0]:update(dt)
	    players[1]:update(dt)

		ball:update(dt)
	end
end

function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push("quit")
	end
	if key == " " then
		songIndex = songIndex + 1
		SFX.playSong(SFX.songList[songIndex % 4 + 1])
	end
	if curState == states.ip then
		if key == "enter" or key == "return" then

		elseif unicode == 127 and string.len(ipString) > 0 then
			ipString = string.sub(ipString, 0, string.len(ipString) - 1)
		else
			ipString = ipString .. key
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
	elseif curState == states.title then
		if key == "enter" or key == "return" then
			curState = states.ingame
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
		love.graphics.print(players[0].score, love.graphics.getWidth() / 3, love.graphics.getHeight() / 3)
		love.graphics.print(players[1].score, love.graphics.getWidth() / 3 * 2, love.graphics.getHeight() / 3)
		for i=0,1 do
			players[i]:draw()
		end

		ball:draw()
	elseif curState == states.title then
		printCentered("LAZERPONG", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.print("Controls:", 200, 200)
		love.graphics.print("Player 1:", 200, 250)
		love.graphics.print("Q,S,D: up, down, shoot", 200, 270)
		love.graphics.print("Player 2:", 500, 250)
		love.graphics.print("P,L,K: up, down, shoot", 500, 270)
		love.graphics.print("Spacebar: change song", 600, 320)

		printCentered("Press ENTER to start the game!", 0, love.graphics.getHeight() / 2, 
                      love.graphics.getWidth(), love.graphics.getHeight() / 2)
	end
end
