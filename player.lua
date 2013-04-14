require "ball"
require "laser"

PlayerClass = {}
PlayerClass.speed = 5
PlayerClass.width = 100

--Width multiplied by this on laser impact
PlayerClass.hitPenalty = 0.9

PlayerClass.maxLives = 5


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
    my.y = y
    
    me.lives = self.maxLives
    me.width = self.width
    me.score = 0
    me.lasers = {}
    me.moveQueue = {}

    return me
end

function PlayerClass:draw()
    local rectX = math.floor(self.x - self.width / 2)
    local rectY = math.floor(self.y - self.height / 2)
    if (team == 0) then
        love.graphics.setColor(COLORS.red)
    elseif (team == 1) then
        love.graphics.setColor(COLORS.blue)
    end
    love.graphics.rectangle('fill', rectX, rectY, self.width, self.height)
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
    self.width = self.width * self.hitPenalty
end

function PlayerClass:shootLaser()
    self.lasers[#self.lasers] = LaserClass(self.x, self.y, self)
end
