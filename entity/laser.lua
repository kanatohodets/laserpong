require "entity/movingEntity"

Laser = class("Laser")
Laser.boundingShape = "circle"

-- expressed in % for easier reading
Laser.xVel = (55.55 / 100) * love.graphics.getWidth()
Laser.radius = (1.11 / 100) * love.graphics.getWidth()

function Laser:new(x, y, owner)
    local me = createMovingEntity(self, x, y)
    

    me.team = owner.team
    me.alive = true
    return me
end

function Laser:draw()
    if self.team == 0 then
        love.graphics.setColor(COLORS.red)
    elseif self.team == 1 then
        love.graphics.setColor(COLORS.blue)
    end
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Laser:update(dt)
    local player1 = players[0]
    local player2 = players[1]

    if self.team == 0 then
        self.x = self.x + self.xVel * dt
        --uncomment to enable lasers blocking other lasers
        --[[
        for i = 1,#player2.lasers do
            if collide(self, player2.lasers[i]) then
                self:die()
                player2.lasers[i]:die()
            end
        end
        ]]--
    elseif self.team == 1 then
        self.x = self.x - self.xVel * dt
    end

    if self.x < -self.radius or self.x > love.graphics.getWidth() + self.radius then
        self:die()
        return
    end

    if collide(self, ball) then
        if (self.team == 0 and ball.xVel < 0) or (self.team == 1 and ball.xVel > 0) then
            self:hit(ball)
            ball:hitLaser(self)
            SFX.playEffect(SFX.laserHitBall)
            ScreenFX.startEffect(ScreenFX.smallShake)
            ScreenFX.startEffect(ScreenFX.greenFlash)
        end
    end

    if collide(self, player1) then
        self:hit(player1)
        player1:hitByLaser(self)
    end

    if collide(self, player2) then
        self:hit(player2)
        player2:hitByLaser(self)
    end
end

function Laser:hit(struckEntity)
    if struckEntity.team ~= self.team then
        self:die()
    end
end

function Laser:die()
    self.alive = false
end
