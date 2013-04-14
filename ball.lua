
BallClass = {}
BallClass.xVel = 400
BallClass.yVel = 200
BallClass.radius = 9
BallClass.waitTime = 2

BallClass.hitVelocityMultInc = 1.1
BallClass.hitVelocityMultDec = 0.9

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
    me.waiting = BallClass.waitTime

    me.alive = true
    return me
end

function BallClass:draw()
    love.graphics.setColor(COLORS.white)
    love.graphics.circle("fill",self.x,self.y,self.radius)
end

function BallClass:update(dt)
    if self.waiting > 0 then
        self.waiting = self.waiting - dt
    else
        self.x = self.x + self.xVel * dt
        self.y = self.y + self.yVel * dt
        if self.y - self.radius <= 0 or self.y + self.radius >= love.graphics.getHeight() then
            self.y = self.y - self.yVel * dt
            self:hitWall()
        end

        if self.x < -self.radius then
            players[1].score = players[1].score + 1
            self:reset()
        elseif self.x > love.graphics.getWidth() + self.radius then
            players[0].score = players[0].score + 1
            self:reset()
        end
    end
end

function BallClass:reset()
    players[0]:reset()
    players[1]:reset()
    if math.random() < .5 then
        self.yVel = BallClass.yVel
    else
        self.yVel = BallClass.yVel*-1
    end
    self.waiting = BallClass.waitTime
    self.x = love.graphics.getWidth()/2
    self.y = love.graphics.getHeight()/2
    if math.random() < .5 then
        self.xVel = BallClass.xVel
    else
        self.xVel = BallClass.xVel*-1
    end
end

function BallClass:hitPlayer(player)
    if (self.yVel - 0) * (self.y - player.y) > 0 then
        self.yVel = self.yVel * self.hitVelocityMultInc
    else
        self.yVel = self.yVel * self.hitVelocityMultDec
    end
    self.xVel = -1 * self.xVel
end

function BallClass:hitLaser()
    self.xVel = -1 * self.xVel
    self.yVel = self.yVel * self.hitVelocityMultInc
end

function BallClass:hitWall()
    self.yVel = -1 * self.yVel
end

function BallClass:die()

end
