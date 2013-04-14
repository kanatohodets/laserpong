require "ball"
require "laser"

PlayerClass = {}
PlayerClass.speed = 500
PlayerClass.width = 12
PlayerClass.height = 100

PlayerClass.laserDelay = 0.30

--Width multiplied by this on laser impact
PlayerClass.hitPenalty = 0.7

function PlayerClass:new(x, y, teamNum)
    local me = {}
    setmetatable(me, self)
    self.__index = self
    self.__newindex = function(t, k, v)
        if self.k ~= nil then
            error("trying to set new field to PlayerClass table")
        else
            rawset(t, k, v)
        end
    end
    
    me.team = teamNum
    me.x = x
    me.y = y
    
    me.lives = self.maxLives
    me.width = self.width
    me.score = 0
    me.lasers = {}
    me.moveQueue = {}

    me.laserCounter = 0

    return me
end

function PlayerClass:draw()
    local rectX = self.x - self.width / 2
    local rectY = self.y - self.height / 2
    if (self.team == 0) then
        love.graphics.setColor(COLORS.red)
    elseif (self.team == 1) then
        love.graphics.setColor(COLORS.blue)
    end
    love.graphics.rectangle('fill', rectX, rectY, self.width, self.height)

    for i = 1,#self.lasers do
        self.lasers[i]:draw()
    end
end

function PlayerClass:update(dt)
    self.laserCounter = self.laserCounter + dt
    if self.moveQueue[1] == 1 then
        self.y = self.y + self.speed * dt
        if self.y + self.height/2 > love.graphics.getHeight() then
            self.y = love.graphics.getHeight() - self.height/2
        end
    elseif self.moveQueue[1] == -1 then
        self.y = self.y - self.speed * dt
        if self.y < self.height/2 then
            self.y = self.height/2
        end
    end

    if rectsCollide(self.x-self.width/2,self.y-self.height/2,self.width,self.height,ball.x-ball.radius,ball.y-ball.radius,ball.radius*2,ball.radius*2) then
        ball:hitPlayer(self)
        if (self.team == 0) then
            ball.x = self.x + ball.radius + self.width
        elseif (self.team == 1) then
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

function PlayerClass:moveUp()
    if (self.y > self.height/2) then
        table.insert(self.moveQueue, 1, -1)
    end
end

function PlayerClass:moveDown()
    if (self.y < love.graphics.getHeight() - self.height/2) then
        table.insert(self.moveQueue, 1, 1)
    end
end

function PlayerClass:stop(dir)
    for k, v in ipairs(self.moveQueue) do
        if v == dir then
            table.remove(self.moveQueue, k)
            return
        end
    end
end

function PlayerClass:hitByLaser(laser)
    if laser.team ~= self.team then
        self.height = self.height * self.hitPenalty
        SFX.playEffect(SFX.hitByLaser)
        ScreenFX.startEffect(ScreenFX.smallShake)
        if self.team == 0 then
            ScreenFX.startEffect(ScreenFX.redFlash)
        else
            ScreenFX.startEffect(ScreenFX.blueFlash)
        end
    end
end

function PlayerClass:shootLaser()
    if ball.waiting <= 0 then
        if self.laserCounter > self.laserDelay then
            SFX.playEffect(SFX.fireLaser)
            self.laserCounter = 0
            table.insert(self.lasers,LaserClass:new(self.x, self.y, self))
        end
    end
end

function  PlayerClass:reset()
    self.y = love.graphics.getHeight()/2
    self.height = PlayerClass.height
    self.laserCounter = 0
    self.lasers = {}
end

