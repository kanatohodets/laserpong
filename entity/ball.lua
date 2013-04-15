require "entity/movingEntity"

Ball = class("Ball")
Ball.boundingShape = "circle"
Ball.xVel = 400
Ball.yVel = 200
Ball.radius = 9
Ball.waitTime = 2

Ball.hitVelocityMultInc = 1.35
Ball.hitVelocityMultDec = 0.9

function Ball:new(x, y)
	local me = createMovingEntity(self, x, y)

    me.waiting = Ball.waitTime
    me.alive = true
    return me
end

function Ball:draw()
    love.graphics.setColor(COLORS.white)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Ball:update(dt)
    if self.waiting > 0 then
        self.waiting = self.waiting - dt
    else
        self.x = self.x + self.xVel * dt
        self.y = self.y + self.yVel * dt
        if (self.y - self.radius <= 0) or (self.y + self.radius >= love.graphics.getHeight()) then
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

function Ball:reset()
    players[0]:reset()
    players[1]:reset()

    if math.random() < .5 then
        self.yVel = Ball.yVel
    else
        self.yVel = Ball.yVel*-1
    end

    self.waiting = Ball.waitTime
    self.x = love.graphics.getWidth()/2
    self.y = love.graphics.getHeight()/2

    if math.random() < .5 then
        self.xVel = Ball.xVel
    else
        self.xVel = Ball.xVel*-1
    end
end

function Ball:hitPlayer(player)
    if (self.yVel - 0) * (self.y - player.y) > 0 then
        self.yVel = self.yVel * self.hitVelocityMultInc
    else
        self.yVel = self.yVel * self.hitVelocityMultDec
    end
    self.xVel = -1 * self.xVel
end

function Ball:hitLaser()
    self.xVel = -1 * self.xVel
    self.yVel = self.yVel * self.hitVelocityMultInc
end

function Ball:hitWall()
    self.yVel = -1 * self.yVel
end

function Ball:die()

end
