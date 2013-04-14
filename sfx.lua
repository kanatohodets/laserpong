-- sfx.lua
-- instantiate basic sound effects

volume = 1

SFX = {}
SFX.laserHitBall = love.audio.newSource("sfx/laserHitBall.wav", "static")
SFX.fireLaser = love.audio.newSource("sfx/fireLaser.wav", "static")
SFX.hitByLaser = love.audio.newSource("sfx/hitByLaser.wav", "static")
SFX.score = love.audio.newSource("sfx/score.wav", "static")
SFX.songa = love.audio.newSource("sfx/songa.mp3", "static")
SFX.songa:setLooping(true)
SFX.songb = love.audio.newSource("sfx/songb.mp3", "static")
SFX.songb:setLooping(true)
SFX.songc = love.audio.newSource("sfx/songc.mp3", "static")
SFX.songc:setLooping(true)
SFX.songd = love.audio.newSource("sfx/songd.mp3", "static")
SFX.songd:setLooping(true)

SFX.songList = {SFX.songa, SFX.songb, SFX.songc, SFX.songd}

SFX.curSong = nil

SFX.playEffect = function(s)
	s:stop()
	s:play()
end

-- makes sure we're only playing one song at a time
SFX.playSong = function(s)
	if SFX.curSong ~= s then
		if SFX.curSong ~= nil then
			SFX.curSong:stop()
		end
		s:play()
		SFX.curSong = s
	end
end

function setVolume(v)
	volume = v
	love.audio.setVolume(volume)
end

function toggleMute()
	if love.audio.getVolume() == 0 then
		love.audio.setVolume(volume)
	else
		love.audio.setVolume(0)
	end
end
