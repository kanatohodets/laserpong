math.randomseed(os.time())
math.random()
math.random()
math.random()
math.random()

COLORS = {gold = {255,215,0}, red = {255,0,0}, black = {0,0,0},
    white = {255,255,255},gray = {100,100,100},grey = {120,100,100},brown={145,100,50},
    green={0,200,0},yellow={255,255,0},magenta={255,0,160},blue={0,120,255},darkblue={0, 30, 255}}

require "lib/OO"
require "lib/utilities"
require "gfx/shaders"
require "lib/announcement"
require "entity/player"
require "entity/laser"
require "entity/ball"
require "lib/sfx"
require "lib/screenEffects"
require "lib/stars"
require "lib/achievements"

font = love.graphics.newFont("lib/Courier New Bold.ttf", 20)
fontBIG = love.graphics.newFont("lib/Courier New Bold.ttf", 48)
love.graphics.setFont(font)

players = {}
ball = nil
starBackground = nil
winner = 1
goalScore = 11
finishThem = false
paused = false

fb = love.graphics.newCanvas()
fb2 = love.graphics.newCanvas()

states = {
    ip = 1,
    ingame = 2,
    title = 3,
    endgame = 4,
}

endgameCounter = 0
endgameTime = 3

t = nil

curState = states.title

local songIndex = math.random(4)

function love.load()
    reset()
end

function reset()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    players[0] = Player:new(50, h / 2, 0)
    players[1] = Player:new(w - 50, h / 2, 1)

    ball = Ball:new(w / 2, h / 2)
    SFX.playSong(songIndex)
    starBackground = Stars:new()
    t = 0
    resetAnnouncements()
end

function love.update(dt)
    if curState == states.ip then
        -- networking screen
    elseif curState == states.ingame and love.graphics.hasFocus() then
        if paused then
            return
        end
        -- slow-mo at end of match
        if ball.slowDown > 0 then
            ball.slowDown = ball.slowDown - dt
            dt = dt*ball.slowDownMult
            if ball.slowDown <= 0 then
                curState = states.endgame
                ScreenFX.activeFX = {}
            end
        end

        achievements:logStat("Time Passed",dt)
        ScreenFX.evaluateFX(dt)
        players[0]:update(dt)
        players[1]:update(dt)
        if love.keyboard.isDown('k') then
            players[1]:shootLaser()
        end

        if love.keyboard.isDown('d') then
            players[0]:shootLaser()
        end

        ball:update(dt)
        Laser.player1HitPS:update(dt)
        Laser.player2HitPS:update(dt)
        starBackground:update(dt)
        updateAnnouncement(dt)
    elseif curState == states.endgame then
        endgameCounter = endgameCounter+dt
        if endgameCounter > endgameTime then
            curState = states.title
            endgameCounter = 0
        end
    end
    t = t+dt
    space:send('time', t)
    rainbow:send('time', t)
    local bg = {ScreenFX.bgColor[1], ScreenFX.bgColor[2], ScreenFX.bgColor[3], 255.0}
    space:send('bgColor', bg)

    for i,v in ipairs(achievements:getAchieved()) do
        addAnnouncement(v.name,v.player)
    end
end

function love.keypressed(key, unicode)
    if key == "escape" then
        love.event.push("quit")
    end
    if key == " " then
        songIndex = songIndex + 1
        SFX.playSong(songIndex)
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
        elseif key == "s" then
            players[0]:moveDown()
        elseif key == "p" then
            players[1]:moveUp()
        elseif key == "l" then
            players[1]:moveDown()
        elseif key == "b" then
            paused = not paused
        end
    elseif curState == states.title then
        if key == "g" then
            love.graphics.toggleFullscreen()
        end

        if key == "enter" or key == "return" then
            curState = states.ingame
            reset()
        elseif key == "7" then
            curState = states.ingame
            reset()
            players[1].AI = true
        elseif key == "8" then
            curState = states.ingame
            reset()
            players[1].AI = true
            players[0].AI = true
        end
    end
    if key == "h" then
        toggleMute()
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
    fb2:clear()
    love.graphics.setCanvas(fb2)
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line",0,0,w,h)
    
    if curState == states.ip then
        love.graphics.print("Enter the host's ip address and press enter (leave blank if you're a server):", 100, 100)
        love.graphics.print("IP: "..ipString, 100, 150)
    elseif curState == states.ingame then
        if paused then
            printCentered("PAUSED", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        else
            love.graphics.setBackgroundColor(ScreenFX.bgColor)
            fb:clear()
            love.graphics.setCanvas(fb)
            love.graphics.setColor(COLORS.white)
            love.graphics.setCanvas(fb2)
            love.graphics.setPixelEffect(space)
            love.graphics.draw(fb, 0, 0)
            love.graphics.setPixelEffect()
            starBackground:draw()
            love.graphics.translate(ScreenFX.coordTranslate[1], ScreenFX.coordTranslate[2])
            love.graphics.setColor(COLORS.white)
            love.graphics.print(players[0].score, w / 3, h / 3)
            love.graphics.print(players[1].score, w / 3 * 2, h / 3)
            for i=0,1 do
                players[i]:draw()
            end

            love.graphics.draw(Laser.player1HitPS, 0, 0)
            love.graphics.draw(Laser.player2HitPS, 0, 0)
            ball:draw()
            displayAnnouncement()
            if finishThem then
                love.graphics.setPixelEffect(invertShader)
            end
            love.graphics.rectangle("line",0,0,w,h)
        end
    elseif curState == states.title then
        love.graphics.setPixelEffect(rainbow)
        love.graphics.setFont(fontBIG)
        printCentered("LAZERPONG", 0, 70, w, h)
        love.graphics.setFont(font)
        love.graphics.setPixelEffect()
        printCentered("CONTROLS", 0, 0, w, h/3)
        love.graphics.print("Player 1:", (18 / 100) * w, (25/100) * h)
        love.graphics.print("Q,S,D: up, down, shoot", (18 / 100) * w, (28/100) * h)
        love.graphics.print("Player 2:", (52 / 100) * w, (25/100)*h)
        love.graphics.print("P,L,K: up, down, shoot", (52 / 100) * w, (28 / 100) * h)
        printCentered("Spacebar: change song", 0, 0, w, (74/100) * h)
        printCentered("G: toggle fullscreen", 0, 0, w, (79/100)*h)
        printCentered("B: pause game", 0, 0, w, (84/100)*h)
        printCentered("H: mute", 0, 0, w, (89/100)*h)

        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", w/4, (70/100)*h, w/2, (13/100)*h)
        love.graphics.rectangle("line", (16/100)*w, (14/100)*h, (68/100)*w, (35/100)*h)
        love.graphics.setLineWidth(2)
        printCentered("Press ENTER to start the game!", 0, h / 2, w, h / 2)
        printCentered("Press 7 to play the computer!", 0, h/2+20, w, h/2)
    elseif curState == states.endgame then
        love.graphics.setPixelEffect(rainbow)
        love.graphics.setFont(fontBIG)
        printCentered("Player "..(winner+1).." is the winner!", 0, -30, w, h)
        love.graphics.setFont(font)
        love.graphics.setPixelEffect()
        printCentered("Player "..((winner - 1) % 2 + 1).." is bad.", 0, 10, w, h)
    end
    love.graphics.setCanvas()
    love.graphics.draw(fb2, 0, 0)
    -- slow-mo at end of match
    if curState == states.ingame and ball.slowDown > 0 then
        love.graphics.setColor(0, 0, 0, ((Ball.slowDownTime - ball.slowDown)/Ball.slowDownTime) * 255)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end
    love.graphics.setPixelEffect()
end
