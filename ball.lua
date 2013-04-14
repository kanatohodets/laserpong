BallClass = {}
BallClass.xVel = 5
BallClass.yVel = 5
BallClass.radius = 4

BallClass.hitVelocityMult = 1.1

function BallClass:new(x, y)
    local me = {}
    setmetatable(me, self)
    self.__index = self
    self.__newindex = function(t, k, v)
        if self.k ~= nil then
            error("trying to set new field to BallClass table")
        else
            rawset(t, k, v)
        end
    end
    
    me.x = x
    me.y = y

    me.xVel = self.xVel
    me.yVel = self.startingYVel

    me.alive = true
    return me
end

function BallClass:draw()

end

function BallClass:update()
    self.x = self.x + self.xVel
    self.y = self.y + self.yVel
end

function BallClass:hit(x, y, team)
    self.yVel = self.yVel * self.hitVelocityMult
    self.xVel = -1 * self.xVel
end

function BallClass:die()

end
