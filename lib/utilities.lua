function printCentered(s, x, y, width, height)
    local fw = love.graphics.getFont():getWidth(s)
    local fh = love.graphics.getFont():getHeight()
    love.graphics.print(s, x + width/2 - fw/2, y + height/2 - fh/2)
end

