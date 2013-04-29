math.randomseed(os.time())
math.random()
math.random()
math.random()
math.random()

COLORS = {gold = {255,215,0}, red = {255,0,0}, black = {0,0,0},
    white = {255,255,255},gray = {100,100,100},grey = {120,100,100},brown={145,100,50},
    green={0,200,0},yellow={255,255,0},magenta={255,0,160},blue={0,120,255},darkblue={0, 30, 255}}

require "lib/OO"
require "lib/announcement"
require "entity/player"
require "entity/laser"
require "entity/ball"
require "lib/sfx"
require "lib/screenEffects"
require "lib/stars"
require "lib/achievements"

font = love.graphics.newFont("lib/Courier New Bold.ttf", 16)
fontBIG = love.graphics.newFont("lib/Courier New Bold.ttf", 48)
love.graphics.setFont(font)
function printCentered(s, x, y, width, height)
    local fw = love.graphics.getFont():getWidth(s)
    local fh = love.graphics.getFont():getHeight()
    love.graphics.print(s, x + width/2 - fw/2, y + height/2 - fh/2)
end

players = {}
ball = nil
starBackground = nil
winner = 1
goalScore = 5

-- This is Marcus porting and tweaking some sweet GLSL code found here: http://glsl.heroku.com/e#8258.4
space = love.graphics.newPixelEffect [[
         extern float time;
         extern vec4 bgColor;
         float N = 12;
         
         vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
         {
            vec2 v = tc;
    
            float x = v.x;
            float y = v.y;
            
            float t = time * 0.15;
            float r;
            for ( int i = 0; i < N; i++ ){
                float d = 3.14159265 / float(N) * float(i) * 3.0;
                r = length(vec2(x,y)) + 0.01;
                float xx = x;
                x = x + cos(y +cos(r) + d) + cos(t);
                y = y - sin(xx+cos(r) + d) + sin(t);
            }
            float red = cos(r*sin(time*0.01));
            red = red*.2;
            vec4 mbgColor = bgColor/255.0;
            return vec4( red, red, red, 1.0 ) + mbgColor*mbgColor.a;
         }
      ]]

rainbow = love.graphics.newPixelEffect [[ 
        extern float time;

        vec4 hsv_to_rgb(float h, float s, float v, float a)
        {
            float c = v * s;
            h = mod((h * 6.0), 6.0);
            float x = c * (1.0 - abs(mod(h, 2.0) - 1.0));
            vec4 color;
         
            if (0.0 <= h && h < 1.0) {
                color = vec4(c, x, 0.0, a);
            } else if (1.0 <= h && h < 2.0) {
                color = vec4(x, c, 0.0, a);
            } else if (2.0 <= h && h < 3.0) {
                color = vec4(0.0, c, x, a);
            } else if (3.0 <= h && h < 4.0) {
                color = vec4(0.0, x, c, a);
            } else if (4.0 <= h && h < 5.0) {
                color = vec4(x, 0.0, c, a);
            } else if (5.0 <= h && h < 6.0) {
                color = vec4(c, 0.0, x, a);
            } else {
                color = vec4(0.0, 0.0, 0.0, a);
            }
         
            color.rgb += v - c;
         
            return color;
        }

        vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
        {
            return hsv_to_rgb(sin(pc.x*.001 + time)*cos(pc.y*.001+time), 1.0, 1.0, 1.0)*Texel(texture, tc);
        }
    ]]

announcementShader = love.graphics.newPixelEffect [[ 
        extern float time;
        extern number player;

        vec4 effect(vec4 color, Image texture, vec2 tc, vec2 pc)
        {
            float a = sin(time*50)/2.0 + 0.5;
            if (player == 0) {
                return vec4(1.0, a, a, 1.0)*Texel(texture, tc);
            } else {
                return vec4(a, a, 1.0, 1.0)*Texel(texture, tc);
            }
        }
    ]]


fb = love.graphics.newCanvas()

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

local ipString = ""

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
        end
        if key == "s" then
            players[0]:moveDown()
        end

        if key == "p" then
            players[1]:moveUp()
        end
        if key == "l" then
            players[1]:moveDown()
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
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line",0,0,w,h)
    
    if curState == states.ip then
        love.graphics.print("Enter the host's ip address and press enter (leave blank if you're a server):", 100, 100)
        love.graphics.print("IP: "..ipString, 100, 150)
    elseif curState == states.ingame then
        love.graphics.setBackgroundColor(ScreenFX.bgColor)
        fb:clear()
        love.graphics.setCanvas(fb)
        love.graphics.setColor(COLORS.white)
        love.graphics.setCanvas()
        love.graphics.setPixelEffect(space)
        love.graphics.draw(fb, 0, 0)
        love.graphics.setPixelEffect()
        starBackground:draw()
        love.graphics.rectangle("line",0,0,w,h)
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
    elseif curState == states.title then
        love.graphics.setPixelEffect(rainbow)
        love.graphics.setFont(fontBIG)
        printCentered("LAZERPONG", 0, 0, w, h)
        love.graphics.setFont(font)
        love.graphics.setPixelEffect()
        love.graphics.print("Controls:", (22.22 / 100) * w, (26.66 / 100) * h)
        love.graphics.print("Player 1:", (22.22 / 100) * w, 250)
        love.graphics.print("Q,S,D: up, down, shoot", (22.22 / 100) * w, (36 / 100) * h)
        love.graphics.print("G: toggle fullscreen", (22.22 / 100) * w, (42.667 / 100) * h)
        love.graphics.print("Player 2:", (55.55 / 100) * w, 250)
        love.graphics.print("P,L,K: up, down, shoot", (55.55 / 100) * w, (36 / 100) * h)
        love.graphics.print("Spacebar: change song", (66.667 / 100) * w, (42.667 / 100) * h)

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
end
