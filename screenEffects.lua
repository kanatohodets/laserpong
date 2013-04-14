-- screenEffects.lua

ScreenFX = {}

ScreenFX.coordTranslate = {0, 0}
ScreenFX.shear = {0, 0}
ScreenFX.scale = {1,1}
ScreenFX.bgColor = COLORS.black

ScreenFX.activeFX = {} -- table of all active effects

-- calculates effect stuff
ScreenFX.evaluateFX = function(dt)
	ScreenFX.coordTranslate = {0, 0}
	ScreenFX.shear = {0, 0}
	ScreenFX.scale = {1,1}
	ScreenFX.bgColor = COLORS.black
	for k, v in ipairs(ScreenFX.activeFX) do
		v.update(dt)
	end
end

ScreenFX.startEffect = function(effect)
	for k, v in ipairs(ScreenFX.activeFX) do
		if v == effect then
			effect.start()
			return
		end
	end
	table.insert(ScreenFX.activeFX, effect)
	effect.start()
end

ScreenFX.removeActiveEffect = function(effect)
	for k, v in ipairs(ScreenFX.activeFX) do
		if v == effect then
			table.remove(ScreenFX.activeFX, k)
			return
		end
	end
end

ScreenFX.smallShake = {
	timeSince = 3, --some number greater than the cut off of the function.
	update = function(dt)
		local trans = ScreenFX.smallShake.getTrapShakeTranslation(ScreenFX.smallShake.timeSince)
		ScreenFX.smallShake.timeSince = ScreenFX.smallShake.timeSince + dt
		ScreenFX.coordTranslate[1] = ScreenFX.coordTranslate[1] + trans[1]
		ScreenFX.coordTranslate[2] = ScreenFX.coordTranslate[2] + trans[2]
	end,
	getTrapShakeTranslation = function(t)
		local length = .25
		local max = 10
		if t >= length then
			ScreenFX.removeActiveEffect(ScreenFX.smallShake)
			return {0, 0}
		else
			biggest = max - max/length * t
			return {math.random(-1 * biggest, biggest), math.random(-1 * biggest, biggest)} --
		end
	end,
	start = function()
		ScreenFX.smallShake.timeSince = 0
	end,
}

ScreenFX.redFlash = {
	timeSince = 3,
	update = function(dt)
		ScreenFX.bgColor = ScreenFX.redFlash.getBGColor(ScreenFX.redFlash.timeSince)
		ScreenFX.redFlash.timeSince = ScreenFX.redFlash.timeSince + dt
	end,
	getBGColor = function(t)
		local length = .25
    	local max = 125
    	if t >= length then
    		ScreenFX.removeActiveEffect(ScreenFX.redFlash)
    	    return {0,0,0}
    	else
    	    return {max - (max/length)*t ,0,0}
    	end
    end,
    start = function()
    	ScreenFX.redFlash.timeSince = 0
	end,
}
