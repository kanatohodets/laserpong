
local announcementQueue = {}
local duration = 1

function updateAnnouncement (dt)
    if #announcementQueue > 0 then
        local ann = announcementQueue[#announcementQueue]
        if ann.life > 0 then
            ann.life = ann.life - 1 * dt
            announcementShader:send('time', t)
            announcementShader:send('player', ann.player)
        else
            table.remove(announcementQueue)
        end
    end
end

function resetAnnouncements()
    announcementQueue = {{text = 'GO!', player = 1, life = duration}, {text = 'Get Ready...', player = 0, life = duration}}
end

function addAnnouncement(t, p)
    table.insert(announcementQueue, 1, {text = t, player = p, life = duration})
end

function displayAnnouncement ()
    if #announcementQueue > 0 then
        local ann = announcementQueue[#announcementQueue]
        local scalar = ann.life / duration
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        local scalar = (44/100) * w
        local xTrans = math.min(scalar * math.sin(math.pi * ann.life) - scalar/2, 0)
        love.graphics.setFont(fontBIG)
        love.graphics.setPixelEffect(announcementShader)
        if ann.player == 0 then
            love.graphics.translate(xTrans, 0)
            printCentered(ann.text, 0, 2*(h/3), w, h/3)
            love.graphics.translate(-xTrans, 0)
        elseif ann.player == 1 then
            love.graphics.translate(-xTrans, 0)
            printCentered(ann.text, 0, 2*(h/3), w, h/3)
            love.graphics.translate(xTrans, 0)
        else
            -- not a player announcement
        end
        love.graphics.setPixelEffect()
        love.graphics.setFont(font)
    end
end

