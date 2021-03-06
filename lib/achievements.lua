achievements = {Slingshot,Dunked,Disciplined,Sniper,Relentless,PaddleControl,
                AbsentMinded,RapidFire,Regenerator,ZenMaster,Skunked,Changeup}

achievements.Slingshot = {name = "WHIPLASH",hits = 0, targetHits = 4, delay = 0.3, cooldown = 0, lastHit = 0}
achievements.Dunked = {name = "DUNKED", hitPlayer = nil, scoredOnPlayer = nil, delay = 0.65, cooldown = 0}
achievements.Disciplined = {name = "DISCIPLINED", time = 6, counter = {0,0}}
achievements.Sniper = {name = "SNIPER", sniped = nil, canSnipe = true}
achievements.Relentless = {name = "RELENTLESS", hit = nil, regen = true}
achievements.PaddleControl = {name = "PADDLE CONTROL", hit = nil}
achievements.AbsentMinded = {name = "ABSENT-MINDED", initial = true, lost = nil}
achievements.RapidFire = {name = "RAPID FIRE",target = Player.laserMax * 3,limit = 3,timer = {0,0},roundsFired = {0,0}}
achievements.Regenerator = {name = "REGENERATOR",small = {false,false}}
achievements.ZenMaster = {name = "ZEN MASTER", target = 0.75, time = {0,0}, hit = {false,false}}
achievements.Changeup = {name = "CHANGEUP",achieved = {false,false}}

function achievements:logStat(stat, value)
    if stat == "Time Passed" then -- value == dt

        -- Slingshot
        self.Slingshot.cooldown = self.Slingshot.cooldown + value

        -- Dunked
        if self.Dunked.hitPlayer ~= nil then
            self.Dunked.cooldown = self.Dunked.cooldown + value
            if self.Dunked.cooldown > self.Dunked.delay then
                self.Dunked.hitPlayer = nil
                self.Dunked.cooldown = 0
            end
        end

        -- Disciplined
        if ball.waiting <= 0 then
            self.Disciplined.counter[1] = self.Disciplined.counter[1] + value
            self.Disciplined.counter[2] = self.Disciplined.counter[2] + value
        end

        -- Rapid Fire
        if self.RapidFire.timer[1] > self.RapidFire.limit then
        	self.RapidFire.roundsFired[1] = 0
        else
        	self.RapidFire.timer[1] = self.RapidFire.timer[1] + value
        end
        if self.RapidFire.timer[2] > self.RapidFire.limit then
        	self.RapidFire.roundsFired[2] = 0
        else
        	self.RapidFire.timer[2] = self.RapidFire.timer[2] + value
        end

        -- Zen Master
        if ball.waiting <= 0 then
            self.ZenMaster.time[1] = self.ZenMaster.time[1] + value
            self.ZenMaster.time[2] = self.ZenMaster.time[2] + value        
        end

    elseif stat == "Ball Hit Laser" then -- value == team of laser

        -- Slingshot
        if self.Slingshot.cooldown > self.Slingshot.delay then
            self.Slingshot.hits = 1
        else
            self.Slingshot.hits = self.Slingshot.hits + 1
            if ball.xVel > 0 then self.Slingshot.lastHit = 0 else self.Slingshot.lastHit = 1 end
        end
        self.Slingshot.cooldown = 0

        -- Sniper
        if self.Sniper.canSnipe and players[value].laserBank == players[value].laserMax - 1 and math.abs(ball.x-players[value].x) > love.graphics.getWidth()/3 then
            self.Sniper.sniped = value
        end

        -- Absent Minded
        self.AbsentMinded.initial = false

    elseif stat == "Ball Hit Player" then -- value == team of player

        -- Dunked
        self.Dunked.hitPlayer = value
        self.Dunked.cooldown = 0

        -- Paddle Control
        if players[value].height <= Player.minHeight then
            self.PaddleControl.hit = value
        end

        -- Absent Minded
        self.AbsentMinded.initial = false

        -- Zen Master
        if self.ZenMaster.time[value+1] > self.ZenMaster.target and ball.yVel >= ball.yVelMax/4  then
            self.ZenMaster.hit[value+1] = true
        end

        -- Change up
        if ball.xVel >= (3/2) * Ball.xVel then
            self.Changeup.achieved[value+1] = true
        end

    elseif stat == "Laser Hit Player" then -- value == team of laser    

        -- Relentless
        if players[(value+1)%2].height <= Player.minHeight and self.Relentless.regen then
            self.Relentless.hit = value
            self.Relentless.regen = false
        end

    elseif stat == "Laser Shot" then -- value == team of laser
        -- Disciplined
        self.Disciplined.counter[value+1] = 0

        -- Rapid Fire
        if players[value].laserBank == 1 then
        	self.RapidFire.timer[value+1] = 0
        	self.RapidFire.roundsFired[value+1] = self.RapidFire.roundsFired[value+1] + 1
        end

        -- Sniper
        if players[value].laserBank == Player.laserMax then
            self.Sniper.canSnipe = true
        else
            self.Sniper.canSnipe = false
        end
    elseif stat == "Regen" then -- value == team of player regenerating
        
        -- Relentless
        self.Relentless.regen = true

        -- Regenerator
        if players[value].height <= Player.minHeight then
            self.Regenerator.small[value+1] = true
        end

    elseif stat == "Move" then -- value == team of player moving

        -- Zen Master
        self.ZenMaster.time[value+1] = 0

    elseif stat == "Game Over" then -- value == losing team

        -- Dunked
        if self.Dunked.cooldown <= self.Dunked.delay and self.Dunked.hitPlayer then
            self.Dunked.hitPlayer = nil
            self.Dunked.scoredOnPlayer = value
            self.Dunked.cooldown = 0
        end

        -- Disciplined
        self.Disciplined.counter[1] = 0
        self.Disciplined.counter[2] = 0

        -- Relentless
        self.Relentless.regen = true

        -- Absent Minded
        if self.AbsentMinded.initial then
            self.AbsentMinded.lost = value
        end
        self.AbsentMinded.initial = true

        -- Rapid Fire
        self.RapidFire.roundsFired[1] = 0
        self.RapidFire.roundsFired[2] = 0

        -- Regenerator
        self.Regenerator.small[1] = false
        self.Regenerator.small[2] = false

        -- Zen Master
        self.ZenMaster.time[1] = 0
        self.ZenMaster.time[2] = 0

    end
end

function achievements:getAchieved()
    achieved = {}
    if self.Slingshot.hits >= self.Slingshot.targetHits and self.Slingshot.cooldown > self.Slingshot.delay then
        table.insert(achieved,{name = self.Slingshot.name, player = self.Slingshot.lastHit})
        self.Slingshot.hits = 0
        self.Slingshot.cooldown = 0
    end
    if self.Dunked.scoredOnPlayer then
        table.insert(achieved,{name = self.Dunked.name, player = self.Dunked.scoredOnPlayer})
        self.Dunked.hitPlayer = nil
        self.Dunked.scoredOnPlayer = nil
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
        self.Sniper.sniped = nil
    end
    if self.Relentless.hit ~= nil then
        table.insert(achieved,{name = self.Relentless.name,player = self.Relentless.hit})
        self.Relentless.hit = nil
    end
    if self.PaddleControl.hit ~= nil then
        table.insert(achieved,{name = self.PaddleControl.name,player = self.PaddleControl.hit})
        self.PaddleControl.hit = nil
    end
    if self.AbsentMinded.lost ~= nil then
        table.insert(achieved,{name = self.AbsentMinded.name,player = self.AbsentMinded.lost})
        self.AbsentMinded.lost = nil
    end
    if self.RapidFire.roundsFired[1] > self.RapidFire.target then
        table.insert(achieved,{name = self.RapidFire.name, player = 0})
        self.RapidFire.roundsFired[1] = 0
    end
    if self.RapidFire.roundsFired[2] > self.RapidFire.target then
        table.insert(achieved,{name = self.RapidFire.name, player = 1})
        self.RapidFire.roundsFired[2] = 0
    end
    if self.Regenerator.small[1] == true and players[0].height == Player.height then
        table.insert(achieved,{name = self.Regenerator.name,player = 0})
        self.Regenerator.small[1] = false
    end
    if self.Regenerator.small[2] == true and players[1].height == Player.height then
        table.insert(achieved,{name = self.Regenerator.name,player = 1})
        self.Regenerator.small[2] = false
    end
    if self.ZenMaster.hit[1] == true then
        table.insert(achieved,{name = self.ZenMaster.name,player = 0})
        self.ZenMaster.hit[1] = false
        self.ZenMaster.time[1] = 0
    end
    if self.ZenMaster.hit[2] == true then
        table.insert(achieved,{name = self.ZenMaster.name,player = 1})
        self.ZenMaster.hit[2] = false
        self.ZenMaster.time[2] = 0
    end
    if self.Changeup.achieved[1] == true then
        table.insert(achieved,{name = self.Changeup.name,player = 0})
        self.Changeup.achieved[1] = false
    end
    if self.Changeup.achieved[2] == true then
        table.insert(achieved,{name = self.Changeup.name,player = 1})
        self.Changeup.achieved[2] = false
    end
    return achieved
end
