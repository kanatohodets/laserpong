require "entity/movingEntity"
require "entity/ball"
require "entity/laser"

Player = class("Player")
Player.boundingShape = "rect"

-- expressed in % for easier reading
Player.yVel = (66.667 / 100) * love.graphics.getHeight()
Player.width =  (1.35 / 100) * love.graphics.getWidth()
Player.height =  (13.35 / 100) * love.graphics.getHeight()
Player.minHeight = (2 / 100) * love.graphics.getHeight()

--Height multiplied by this on laser impact
Player.hitPenalty = 0.5

--max number of lasers in the bank
Player.laserMax = 8

-- # seconds it takes to wait between laser shots
Player.laserCooldown = .05
-- # radius of mini lasers displayed next to player
Player.laserDisplaySpacing = Laser.radius / 2

--# seconds to wait before healing after sitting still
Player.healWait = 1
-- % of original size to gain back
Player.healAmount = 0.25

function Player:new(x, y, teamNum, AI)
    local me = createMovingEntity(self, x, y)
    
    me.team = teamNum
    me.score = 0
    me.AI = AI
    
    if math.random() > .5 then
        me.AIType = 0
    else
        me.AIType = 1
    end

    me.stationaryTime = 0

    me.lasers = {}
    me.laserReloadTimer = 0
    me.laserBank = self.laserMax
    me.laserCooldownCounter = Player.laserCooldown

    me.moveQueue = {}

    return me
end

function Player:draw()
    if self.team == 0 then
        love.graphics.setColor(COLORS.red)
    elseif self.team == 1 then
        love.graphics.setColor(COLORS.blue)
    end
    love.graphics.rectangle('fill', self.left(), self.top(), self.width, self.height)
    self:drawLasers()

    for i = 1,#self.lasers do
        self.lasers[i]:draw()
    end
end

function Player:drawLasers()
    local x
    if self.team == 0 then
        x = self.left() - self.laserDisplaySpacing - 10
        love.graphics.setColor({COLORS.red[1]*.5, COLORS.red[2]*.5, COLORS.red[3]*.5})
    elseif self.team == 1 then
        x = self.left() + self.width + self.laserDisplaySpacing + 10
        love.graphics.setColor({COLORS.blue[1]*.5, COLORS.blue[2]*.5, COLORS.blue[3]*.5})
    end
    for i=1,self.laserBank do
        if self.team == 0 then
            love.graphics.circle('fill', x, self.y - self.laserBank*self.laserDisplaySpacing - self.laserDisplaySpacing + i*self.laserDisplaySpacing*2, self.laserDisplaySpacing)
        else
            love.graphics.circle('fill', x, self.y - self.laserBank*self.laserDisplaySpacing - self.laserDisplaySpacing + i*self.laserDisplaySpacing*2, self.laserDisplaySpacing)
        end
    end
end

function Player:update(dt)
    if self.AI == true then
        self:doAI()
    end
    if self.moveQueue[1] == 1 then
        self.y = self.y + self.yVel * dt
        if self.bottom() > love.graphics.getHeight() then
            self.y = love.graphics.getHeight() - self.height/2
        end
    elseif self.moveQueue[1] == -1 then
        self.y = self.y - self.yVel * dt
        if self.y < self.height / 2 then
            self.y = self.height / 2
        end
    end

    if #self.moveQueue == 0 then
        self.stationaryTime = self.stationaryTime + dt
        if self.stationaryTime > self.healWait and self.height < Player.height then
            achievements:logStat("Regen",self.team)
            self.height = self.height + Player.height * Player.healAmount
            if self.height > Player.height then
                self.height = Player.height
            end
            self.stationaryTime = 0
        end
    else
        self.stationaryTime = 0
    end

    if collide(self, ball) and ((self.team == 0 and ball.x > self.x) or (self.team == 1 and ball.x < self.x)) then
        achievements:logStat("Ball Hit Player",self.team)
        ball:hitPlayer(self)
        if self.team == 0 then
            ball.x = self.x + ball.radius + self.width
        elseif self.team == 1 then
            ball.x = self.x - ball.radius - self.width
        end
    end

    for i = 1,#self.lasers do
        self.lasers[i]:update(dt)
    end

    local goodOnes = {}
    for i = 1,#self.lasers do
        if self.lasers[i].alive then
            table.insert(goodOnes,self.lasers[i])
        else
        -- reload as they go off the screen
            self.laserBank = self.laserBank + 1
        end
    end
    
    self.laserCooldownCounter = self.laserCooldownCounter+dt
    self.lasers = goodOnes

    self.laserReloadTimer = self.laserReloadTimer + dt
end

function Player:moveUp()
    if self.y > self.height / 2 then
        table.insert(self.moveQueue, 1, -1)
    end
end

function Player:moveDown()
    if self.y < love.graphics.getHeight() - self.height/2 then
        table.insert(self.moveQueue, 1, 1)
    end
end

function Player:stop(dir)
    for k, v in ipairs(self.moveQueue) do
        if v == dir then
            table.remove(self.moveQueue, k)
            return
        end
    end
end

function Player:hitByLaser(laser)
    if (laser.team ~= self.team) then
        achievements:logStat("Laser Hit Player",laser.team)
        if self.height > self.minHeight then
            self.height = self.height * self.hitPenalty
        end

        SFX.playEffect(SFX.hitByLaser)
        ScreenFX.startEffect(ScreenFX.smallShake)

        --teamcolor flash
        if (self.team == 0) then
            ScreenFX.startEffect(ScreenFX.redFlash)
            Laser.player1HitPS:stop()
            Laser.player1HitPS:setPosition(laser.x, laser.y)
            Laser.player1HitPS:start()
        else
            ScreenFX.startEffect(ScreenFX.blueFlash)
            Laser.player2HitPS:stop()
            Laser.player2HitPS:setPosition(laser.x, laser.y)
            Laser.player2HitPS:start()
        end
    end
end

function Player:shootLaser()
    if ball.waiting <= 0 then
        if self.laserBank > 0 and self.laserCooldownCounter > Player.laserCooldown then
            achievements:logStat("Laser Shot",self.team)
            self.laserBank = self.laserBank - 1
            self.laserCooldownCounter = 0
            self.laserReloadTimer = 0
            SFX.playEffect(SFX.fireLaser)
            table.insert(self.lasers, Laser:new(self.x, self.y, self))
        end
    end
end

function Player:reset()
    self.y = love.graphics.getHeight()/2
    self.height = Player.height
    self.lasers = {}
    self.laserBank = self.laserMax
    self.laserReloadTimer = 0
end

function Player:doAI()
    self.moveQueue = {}
    self:shootLaser()
    
    local dt = math.abs(self.x - ball.x)/math.abs(ball.xVel)
    if (self.AIType == 0) then
        if (self.team == 1 and ball.xVel < 0) then
            dt = math.abs(players[0].x - ball.x)/math.abs(ball.xVel)
        elseif (self.team == 0 and ball.xVel > 0) then
            dt = math.abs(players[1].x - ball.x)/math.abs(ball.xVel)
        end
    end
    
    --Ball is moving towards us, predict where it will hit
    --local dt = math.abs(self.x - ball.x)/math.abs(ball.xVel)
    local futureY = dt*ball.yVel+ball.y
    local endDir = 0
    
    while futureY < 0 or futureY > love.graphics.getHeight() do
        if futureY < 0 then
            futureY = futureY + love.graphics.getHeight()
            endDir = 1
        else
            futureY = futureY - love.graphics.getHeight()
            endDir = -1
        end
    end
    
    if endDir == -1 then
        futureY = love.graphics.getHeight() - futureY
    elseif endDir == 1 then
        futureY = love.graphics.getHeight() - futureY
    end
    
    if math.abs(futureY - self.y) > self.height / 2 then
        if futureY > self.y then
            self:moveDown()
        elseif futureY < self.y then
            self:moveUp()
        end
    end
end



