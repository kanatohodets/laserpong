LaserClass = {}
LaserClass.speed = 5
LaserClass.radius = 5

function LaserClass:new(x, y, owner)
    local me = {}
    setmetatable(me, self)
    self.__index = self
    self.__newindex = function(t, k, v)
        if self.k ~= nil then
            error("trying to set new field to LaserClass table")
        else
            rawset(t, k, v)
        end
    end
    
    me.x = x
    me.y = y

    me.team = owner.team
    me.alive = true

    return me
end

function LaserClass:draw()
    if (self.team == 0) then
        love.graphics.setColor(COLORS.red)
    elseif (self.team == 1) then
        love.graphics.setColor(COLORS.blue)
    end
    love.graphics.circle("fill",self.x,self.y,self.radius)
end

function LaserClass:update(dt, ball, player1, player2)
    if (self.team == 0) then
        self.x = self.x + speed * dt
    elseif (self.team == 1) then
        self.x = self.x - speed * dt
    end

    if circsCollide(self.x,self.y,self.radius,ball.x,ball.y,ball.radius) then
        self:hit(ball)
        ball:hitEntity(self)
    end

    if rectsCollide(self.x,self.y,self.radius*2,self.radius*2,player1.x,player1.y,player1.width,player1.height) then
        self:hit(ball)
        player1:hitByLaser(self)
    end

    if rectsCollide(self.x,self.y,self.radius*2,self.radius*2,player2.x,player2.y,player2.width,player2.height) then
        self:hit(ball)
        player2:hitByLaser(self)
    end
end

function LaserClass:hit(struckEntity)
    self:die()
end

function LaserClass:die()
    self.alive = false
end


