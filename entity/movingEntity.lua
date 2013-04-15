
function createMovingEntity (prototype, x, y)
    local newObj = {}
    setmetatable(newObj, prototype)
    for k, v in pairs(prototype) do
        newObj[k] = prototype[k] 
    end

    newObj.x = x
    newObj.y = y

    local boundingWidthAdjust
    local boundingHeightAdjust

    if newObj.boundingShape == "rect" then
        boundingWidthAdjust = newObj.width / 2
        boundingHeightAdjust = newObj.height / 2
    elseif newObj.boundingShape == "circle" then
        boundingWidthAdjust = newObj.radius 
        boundingHeightAdjust = newObj.radius
        -- bit hackish: circles get a 'width' and 'height' 
        -- property so they can easily be run through
        -- the 'collideRects' function
        newObj.width = newObj.radius * 2
        newObj.height = newObj.radius * 2
    end

    newObj.left = function ()
        return newObj.x - boundingWidthAdjust
    end

    newObj.top = function ()
        return newObj.y - boundingHeightAdjust
    end
    
    newObj.bottom = function ()
        return newObj.y + boundingHeightAdjust
    end

    return newObj
end

-- returns true if the provided rectangles are colliding
local rectsCollide = function(entityA, entityB)
    local lefta, topa, wa, ha = entityA.left(), entityA.top(), entityA.width, entityA.height
    local leftb, topb, wb, hb = entityB.left(), entityB.top(), entityB.width, entityB.height

    if topa > topb+hb then
        return false
    elseif topb > topa+ha then
        return false
    elseif lefta > leftb+wb then
        return false
    elseif leftb > lefta+wa then
        return false
    end
    return true
end

local circsCollide = function(entityA, entityB)
    local xa, ya, ra = entityA.x, entityA.y, entityA.radius
    local xb, yb, rb = entityB.x, entityB.y, entityB.radius
    local dist = math.sqrt(math.pow((xa-xb),2)+math.pow((ya-yb),2))
    if dist < ra + rb then
        return true
    end
    return false
end

collide = function (entityA, entityB)
    local typeA = entityA.boundingShape
    local typeB = entityB.boundingShape

    if (typeA == 'circle' and typeB == 'circle') then
        return circsCollide(entityA, entityB)
    else
        return rectsCollide(entityA, entityB)
    end
end


