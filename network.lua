local socket = require "socket"
local udp = socket.udp()

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

    udp:settimeout(0)
    udp:setsockname('*', port)

    me.port = port
    return me
end

function ServerClass:update()
    local data, msg_or_ip, port_or_nill = udp:receivefrom()
    if data then
        return data
    end
end

