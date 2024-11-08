graphics = love.graphics

function outline(func, border, colour)
    local c = graphics.getColor()
    colour:set()
    local offsets = {
        {0, border}, {0, -border}, {-border, 0}, {border, 0},
        {border, border}, {-border, border}, {border, -border}, {-border, -border}
    }
    for _, offset in ipairs(offsets) do
        graphics.push()
        graphics.translate(offset[1], offset[2])
        func()
        graphics.pop()
    end
    graphics.setColor(unpack(c))
    func()
end