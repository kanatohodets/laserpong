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

--max number of lasers in the bank
Player.laserMax = 10
--# seconds it takes to regenerate one laser shot
Player.laserRechargeRate = 1
-- # seconds it takes to wait between laser shots
Player.laserCooldown = .1

--# seconds to wait before healing after sitting still
Player.healWait = 2.5
-- % of original size to gain back 
Player.healAmount = 0.3

function Player:new(x, y, teamNum)
    local me = createMovingEntity(self, x, y)
    
    me.team = teamNum
    me.score = 0

    me.stationaryTime = 0

    me.lasers = {}
    me.laserReloadTimer = 0
    me.laserBank = self.laserMax
    me.laserCooldownCounter = Player.laserCooldown

    me.moveQueue = {}

    return me
end

function Player:draw()
    local bottom = love.graphics.getHeight()
    local barWidth = (self.laserBank / self.laserMax) * 100
    if self.team == 0 then
        love.graphics.setColor(COLORS.gray)
        love.graphics.rectangle('fill', self.left() + self.width, bottom - 100, barWidth, 25)
        love.graphics.setColor(COLORS.red)
    elseif self.team == 1 then
        love.graphics.setColor(COLORS.gray)
        love.graphics.rectangle('fill', self.left() - 100, bottom - 100, barWidth, 25)
        love.graphics.setColor(COLORS.blue)
    end
    love.graphics.rectangle('fill', self.left(), self.top(), self.width, self.height)

    for i = 1,#self.lasers do
        self.lasers[i]:draw()
    end
end

function Player:update(dt)
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
            self.height = self.height + Player.height * Player.healAmount
            if self.height > Player.height then
                self.height = Player.height
            end
            self.stationaryTime = 0
        end
    else
        self.stationaryTime = 0
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
    
    self.laserCooldownCounter = self.laserCooldownCounter+dt
    self.lasers = goodOnes

    self.laserReloadTimer = self.laserReloadTimer + dt
    if self.laserReloadTimer >= self.laserRechargeRate and self.laserBank < self.laserMax then
        self.laserBank = self.laserBank + 1
        self.laserReloadTimer = 0
    end
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
        if self.laserBank > 0 and self.laserCooldownCounter > Player.laserCooldown then
            self.laserBank = self.laserBank - 1
            self.laserCooldownCounter = 0
            self.laserReloadTimer = 0
            SFX.playEffect(SFX.fireLaser)
            table.insert(self.lasers, Laser:new(self.x, self.y, self))
        end
    end
end

function  Player:reset()
    self.y = love.graphics.getHeight()/2
    self.height = Player.height
    self.lasers = {}
    self.laserBank = self.laserMax
    self.laserReloadTimer = 0
end

