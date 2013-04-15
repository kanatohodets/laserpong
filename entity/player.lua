require "entity/movingEntity"
require "entity/ball"
require "entity/laser"

Player = class("Player")
Player.boundingShape = "rect"

-- expressed in % for easier reading
Player.yVel = (66.667 / 100) * love.graphics.getHeight()
Player.width =  (1.35 / 100) * love.graphics.getWidth()
Player.height =  (13.35 / 100) * love.graphics.getHeight()

--Width multiplied by this on laser impact
Player.hitPenalty = 0.7

--minimum interval between laser shots
Player.laserDelay = 0.30

function Player:new(x, y, teamNum)
    local me = createMovingEntity(self, x, y)
    
    me.team = teamNum
    me.score = 0
    me.lasers = {}
    me.moveQueue = {}

    me.laserCounter = 0
    return me
end

function Player:draw()
    if self.team == 0 then
        love.graphics.setColor(COLORS.red)
    elseif self.team == 1 then
        love.graphics.setColor(COLORS.blue)
    end
    love.graphics.rectangle('fill', self.left(), self.top(), self.width, self.height)

    for i = 1,#self.lasers do
        self.lasers[i]:draw()
    end
end

function Player:update(dt)
    self.laserCounter = self.laserCounter + dt
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

    if collide(self, ball) then
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
        end
    end
    self.lasers = goodOnes
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
        self.height = self.height * self.hitPenalty

        SFX.playEffect(SFX.hitByLaser)
        ScreenFX.startEffect(ScreenFX.smallShake)

        --teamcolor flash
        if (self.team == 0) then
            ScreenFX.startEffect(ScreenFX.redFlash)
        else
            ScreenFX.startEffect(ScreenFX.blueFlash)
        end
    end
end

function Player:shootLaser()
    if ball.waiting <= 0 then
        if (self.laserCounter > self.laserDelay) then
            SFX.playEffect(SFX.fireLaser)
            self.laserCounter = 0
            table.insert(self.lasers, Laser:new(self.x, self.y, self))
        end
    end
end

function  Player:reset()
    self.y = love.graphics.getHeight()/2
    self.height = Player.height
    self.laserCounter = 0
    self.lasers = {}
end

