require "entity/movingEntity"

Ball = class("Ball")
Ball.boundingShape = "circle"

-- expressed in % for easier reading
Ball.xVel = (44.44 / 100) * love.graphics.getWidth()
Ball.yVel = (26.667 / 100) * love.graphics.getHeight()
Ball.radius = (1 / 100) * love.graphics.getWidth()

Ball.yVelMax = Ball.yVel * 5;

Ball.hitVelocityIncX = Ball.xVel / 10
Ball.hitVelocityInc = Ball.yVel / 2
Ball.hitVelocityDec = Ball.yVel / 2

-- # seconds before ball starts moving after round end/reset
Ball.waitTime = 2

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
    if self.yVel > self.yVelMax then
        self.yVel = self.yVelMax
    end
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
            achievements:logStat("Game Over", 1)
            players[1].score = players[1].score + 1
            self:reset()
        elseif self.x > love.graphics.getWidth() + self.radius then
            achievements:logStat("Game Over", 0)
            players[0].score = players[0].score + 1
            self:reset()
        end
    end
end

function Ball:reset()
    if players[0].score >= goalScore then
        curState = states.endgame
        winner = 0
    elseif players[1].score >= goalScore then
        curState = states.endgame
        winner = 1
    end
    players[0]:reset()
    players[1]:reset()

    self.yVel = (math.random(201)-101)/100 * Ball.yVel

    if math.random() < .5 then
        self.xVel = Ball.xVel
    else
        self.xVel = Ball.xVel * -1
    end

    self.waiting = Ball.waitTime
    self.x = love.graphics.getWidth() / 2
    self.y = love.graphics.getHeight() / 2
end

function Ball:hitPlayer(player)
    if (self.yVel > 0) then
        if (self.y > player.y) then
            self.yVel = self.yVel + self.hitVelocityInc
        else
            self.yVel = self.yVel - self.hitVelocityDec
        end
    else 
        if (self.y < player.y) then
            self.yVel = self.yVel - self.hitVelocityInc
        else
            self.yVel = self.yVel + self.hitVelocityDec
        end
    end
    if self.xVel < 0 then
        self.xVel = -Ball.xVel
    else
        self.xVel = Ball.xVel
    end
    self.xVel = -1 * self.xVel
end

function Ball:hitLaser()
    self.xVel = -1 * self.xVel
    if self.yVel > 0 then
        self.yVel = self.yVel + self.hitVelocityInc
    else
        self.yVel = self.yVel - self.hitVelocityInc
    end
    if self.xVel < 0 then
        self.xVel = self.xVel - Ball.hitVelocityIncX
    else
        self.xVel = self.xVel + Ball.hitVelocityIncX
    end
end

function Ball:hitWall()
    self.yVel = -1 * self.yVel
end

function Ball:die()

end
