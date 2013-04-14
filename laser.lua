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

end

function LaserClass:update()

end

function LaserClass:hit(struckEntity)

    self:die()
end

function LaserClass:die()
    self.alive = false
end


