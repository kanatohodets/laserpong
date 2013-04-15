local socket = require "socket"
local udp = socket.udp()

require "utilities"

ClientClass = {}

function ClientClass:new(address, port)
    local me = {}
    setmetatable(me, self)
    self.__index = self
    self.__newindex = function(t, k, v)
        if self.k ~= nil then
            error("trying to set new field to PlayerClass table")
        else
            rawset(t, k, v)
        end
    end

    me.latestPacket = 0

    me.t = 0
    udp:settimeout(0)
    udp:setpeername(address, port)
    me.updateRate = 0.1
    return me
end

function ClientClass:send(dt, command)
    self.t = self.t + dt
    if self.t > updateRate then
        local dg = string.format("%s", command)
        udp:send(dg)
    end
    t = t - updateRate
end

function ClientClass:update()
    local data, msg = udp:receive()
    local fields = {}
    if data then
        fields = split(data, '||')
    end
    local ball = fields[1]
    local players = fields[2]
    return ball, players
end

ServerClass = {}
function ServerClass:new(port)
    local me = {}
    setmetatable(me, self)
    self.__index = self
    self.__newindex = function(t, k, v)
        if self.k ~= nil then
            error("trying to set new field to PlayerClass table")
        else
            rawset(t, k, v)
        end
    end

    me.packetCounter = 0

    udp:settimeout(0)
    udp:setsockname('*', port)

    me.port = port
    return me
end

function ServerClass:update(players, ball)
    local data, msg_or_ip, port_or_nill = udp:receivefrom()
    if data then
        return data
    end
end

function ServerClass:broadcast(players, ball)
    local dg = self.packetCounter
    local players = table.save(players)
    local ball = table.save(ball)
    dg = dg .. "||" .. players
    dg = dg .. "||" .. ball

    udp:send(dg)
    self.packetCounter = self.packetCounte + 1
end

--[[
function ServerClass:broadcast(players, ball)
    local dg = self.packetCounter 
    dg = dg .. "|ball-x:" .. ball.x .. "-y:" .. ball.y 
    dg = dg .. "-yVel:" .. ball.yVel
    for playerNum, player in ipairs(players) do
        dg = dg .. "|p" .. playerNum .. "-"
        dg = dg .. "-x:" .. player.x
        dg = dg .. "-y:" .. player.y
        dg = dg .. "-score:" .. player.score
        dg = dg .. "-lasers:"
        for laserNum, laser in pairs(player.lasers) do
            dg = dg .. "#" .. laserNum
            dg = dg .. "-x:" .. laser.x
            dg = dg .. "-y:" .. laser.y
        end
    end
    print(dg)
    udp:send(dg)

    self.packetCounter = self.packetCounter + 1
end
]]--

