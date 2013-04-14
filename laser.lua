require "movingEntity"

Laser = class("Laser")
Laser.xVel = 500
Laser.radius = 10
Laser.boundingShape = "circle"

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
    elseif self.team == 1 then
        self.x = self.x - self.xVel * dt
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
