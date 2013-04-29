require "entity/movingEntity"

Laser = class("Laser")
Laser.boundingShape = "circle"

-- expressed in % for easier reading
Laser.xVel = (55.55 / 100) * love.graphics.getWidth()
Laser.radius = (1.11 / 100) * love.graphics.getWidth()
Laser.player1HitPSImage = love.graphics.newImage("gfx/particle.png");

-- define particle system for player 1 getting hit
Laser.player1HitPS = love.graphics.newParticleSystem(Laser.player1HitPSImage, 200)
Laser.player1HitPS:setEmissionRate(100)
Laser.player1HitPS:setSpeed(100, 200)
Laser.player1HitPS:setGravity(0)
Laser.player1HitPS:setColors(0, 0, 255, 255, 255, 0, 0, 255)
Laser.player1HitPS:setLifetime(.1)
Laser.player1HitPS:setParticleLife(.3)
Laser.player1HitPS:setDirection(0)
Laser.player1HitPS:setSpread(6.28)
Laser.player1HitPS:setRadialAcceleration(0)
Laser.player1HitPS:setSpin(0,6)
Laser.player1HitPS:setTangentialAcceleration(0)
Laser.player1HitPS:stop()

-- define particle system for player 2 getting hit
Laser.player2HitPS = love.graphics.newParticleSystem(Laser.player1HitPSImage, 200)
Laser.player2HitPS:setEmissionRate(100)
Laser.player2HitPS:setSpeed(100, 200)
Laser.player2HitPS:setGravity(0)
Laser.player2HitPS:setColors(255, 0, 0, 255, 0, 0, 255, 255)
Laser.player2HitPS:setLifetime(.1)
Laser.player2HitPS:setParticleLife(.3)
Laser.player2HitPS:setDirection(0)
Laser.player2HitPS:setSpread(6.28)
Laser.player2HitPS:setRadialAcceleration(0)
Laser.player2HitPS:setSpin(0,6)
Laser.player2HitPS:setTangentialAcceleration(0)
Laser.player2HitPS:stop()

function Laser:new(x, y, owner)
    local me = createMovingEntity(self, x, y)

    me.team = owner.team
    
    me.trail = love.graphics.newParticleSystem(Laser.player1HitPSImage, 200)
    me.trail:setEmissionRate(20)
    me.trail:setSpeed(100, 200)
    me.trail:setGravity(0)
    if me.team == 1 then
        me.trail:setColors(0, 0, 255, 255, 0, 0, 255, 0)
        me.trail:setDirection(3.14)
    else
        me.trail:setColors(255, 0, 0, 255, 255, 0, 0, 0)
        me.trail:setDirection(0)
    end
    me.trail:setLifetime(-1)
    me.trail:setParticleLife(1)
    me.trail:setSpread(3.14/4)
    me.trail:setRadialAcceleration(200)
    me.trail:setSpin(0,6)
    me.trail:setTangentialAcceleration(0)
    me.trail:setPosition(x,y)
    me.trail:stop()

    me.trail:start()

    me.alive = true
    return me
end

function Laser:draw()
    if self.team == 0 then
        love.graphics.setColor(COLORS.red)
    elseif self.team == 1 then
        love.graphics.setColor(COLORS.blue)
    end
    love.graphics.draw(self.trail,0,0)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Laser:update(dt)
    local player1 = players[0]
    local player2 = players[1]

    if self.team == 0 then
        self.x = self.x + self.xVel * dt
        --uncomment to enable lasers blocking other lasers
        
        for i = 1,#player2.lasers do
            if collide(self, player2.lasers[i]) then
                self:die()
                player2.lasers[i]:die()
            end
        end
        
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
            achievements:logStat("Ball Hit Laser",self.team)
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

    self.trail:update(dt)
    self.trail:setPosition(self.x,self.y)
end

function Laser:hit(struckEntity)
    if struckEntity.team ~= self.team then
        self:die()
    end
end

function Laser:die()
    self.alive = false
end
