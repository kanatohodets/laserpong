local Object = {}
Object.__index = function (table, key)
    error("Property " .. key .. " is unimplemented in a " .. table.name)
end

function class(name)
    local newObj = {}
    newObj.name = name
    setmetatable(newObj, Object)
    return newObj
end


