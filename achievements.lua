achievements = {Slingshot,Dunked,Disciplined,Sniper,Relentless,PaddleControl,
				AbsentMinded,Negator,RapidFire,Regenerator,ZenMaster}

achievements.Slingshot = {name = "Slingshot",hits = 0, targetHits = 8, delay = 0.3, cooldown = 0}
achievements.Dunked = {name = "Dunked",hitPlayer = nil, hitLaser = nil, lost = nil,delay = 0.5,cooldown = 0}
achievements.Disciplined = {name = "Disciplined",time = 10,counter = {0,0}}
achievements.Sniper = {name = "Sniper",sniped = nil}

function achievements:logStat(stat, value)
	if stat == "Time Passed" then

		-- Slingshot
		self.Slingshot.cooldown = self.Slingshot.cooldown + value

		-- Dunked
		self.Dunked.cooldown = self.Dunked.cooldown + value
		if self.Dunked.cooldown > self.Dunked.delay then
			self.Dunked.hitPlayer = nil
			self.Dunked.hitLaser = nil
			self.Dunked.lost = nil
		end

		-- Disciplined
		if ball.waiting <= 0 then
			self.Disciplined.counter[1] = self.Disciplined.counter[1] + value
			self.Disciplined.counter[2] = self.Disciplined.counter[2] + value
		end

	elseif stat == "Ball Hit Laser" then

		-- Slingshot
		if self.Slingshot.cooldown > self.Slingshot.delay then
			self.Slingshot.hits = 1
		else
			self.Slingshot.hits = self.Slingshot.hits + 1
		end
		self.Slingshot.cooldown = 0

		-- Dunked
		if self.Dunked.hitPlayer ~= nil then
			self.Dunked.hitLaser = value
			self.Dunked.cooldown = 0
		end

		-- Sniper
		if players[value].laserBank == players[value].laserMax - 1 and math.abs(ball.x-players[value].x) > love.graphics.getWidth()/4 then
			sniped = value
		end

	elseif stat == "Ball Hit Player" then

		-- Dunked
		self.Dunked.hitPlayer = value
		self.Dunked.hitLaser = nil
		self.Dunked.cooldown = 0

	elseif stat == "Laser Shot" then

		-- Disciplined
		self.Disciplined.counter[value+1] = 0

	elseif stat == "Game Over" then

		-- Dunked
		if self.Dunked.hitLaser ~= nil then
			self.Dunked.lost = value
			cooldown = 0
		end

		self.Disciplined.counter[1] = 0
		self.Disciplined.counter[2] = 0

	end
end

function achievements:getAchieved()
	achieved = {}
	if self.Slingshot.hits >= self.Slingshot.targetHits then
		table.insert(achieved,{name = self.Slingshot.name, player = 1})
		self.Slingshot.hits = 0
		self.Slingshot.cooldown = 0
	end
	if self.Dunked.lost ~= nil and self.Dunked.hitPlayer ~= self.Dunked.hitLaser and self.Dunked.hitLaser == self.Dunked.lost then
		table.insert(achieved,{name = self.Dunked.name, player = self.Dunked.hitLaser})
		self.Dunked.hitPlayer = nil
		self.Dunked.hitLaser = nil
		self.Dunked.lost = nil
		self.Dunked.cooldown = 0
	end
	if self.Disciplined.counter[1] > self.Disciplined.time then
		table.insert(achieved,{name = self.Disciplined.name, player = 0})
		self.Disciplined.counter[1] = 0
	end
	if self.Disciplined.counter[2] > self.Disciplined.time then
		table.insert(achieved,{name = self.Disciplined.name, player = 1})
		self.Disciplined.counter[2] = 0
	end
	if self.Sniper.sniped ~= nil then
		table.insert(achieved,{name = self.Sniper.name,player = self.Sniper.sniped})
	end
	return achieved
end
