
BallClass = {}
BallClass.xVel = 200
BallClass.yVel = 200
BallClass.radius = 9

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
    love.graphics.setColor(COLORS.darkblue)
    love.graphics.circle("fill",self.x,self.y,self.radius)
end

function BallClass:update(dt)
    self.x = self.x + self.xVel * dt
    self.y = self.y + self.yVel * dt
    if self.y <= 0 or self.y >= love.graphics.getHeight() then
        self.y = self.y - self.yVel * dt
        self:hitWall()
    end
end

function BallClass:hitEntity(entity)
    self.yVel = self.yVel * self.hitVelocityMult
    self.xVel = -1 * self.xVel
end

function BallClass:hitWall()
    self.yVel = -1 * self.yVel
end

function BallClass:die()

end
