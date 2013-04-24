-- stars.lua
Stars = {}
Stars.radius = 1
Stars.parallaxMult = 1.5

function Stars:new()
	local me = {}
	setmetatable(me, self)
	self.__index = self
	me.starList = {{}, {}}
	for j=1,2 do
		for i=1,30 do
			table.insert(me.starList[j], {math.random(love.graphics.getWidth()), math.random(love.graphics.getHeight())})
		end
	end
	me.angle = 0
	return me
end

function Stars:draw()
	for i=1,2 do
		for k, v in ipairs(self.starList[i]) do
			love.graphics.circle("fill", v[1], v[2], self.radius)
		end
	end
end

function Stars:update(dt)
	local vel = math.abs(Ball.xVel)/2
	self.angle = (self.angle + .001)%(math.pi*2)
	local yChange = math.sin(self.angle)
	local xChange = math.cos(self.angle)
	for i=1,2 do
		for k, v in ipairs(self.starList[i]) do
			if i == 1 then
				v[1] = (v[1] + vel*dt*xChange)%love.graphics.getWidth()
				v[2] = (v[2] + vel*dt*yChange)%love.graphics.getHeight()
			else
				v[1] = (v[1] + vel*dt*xChange*Stars.parallaxMult)%love.graphics.getWidth()
				v[2] = (v[2] + vel*dt*yChange*Stars.parallaxMult) % love.graphics.getHeight()
			end
		end
	end
end
