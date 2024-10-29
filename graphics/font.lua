Font = Object:extend()

function Font:new(file, size)
    self.font = graphics.newFont(file, size)
end

function Font:set()
    graphics.setFont(self.font)
end

function Font:getWidth(str)
    return self.font:getWidth(str)
end

function Font:getHeight()
    return self.font:getHeight()
end

function Font:getWrap(text, limit)
    return self.font:getWrap(text, limit)
end