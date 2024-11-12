Font = Object:extend()

function Font:new(file, size)
    self.font = graphics.newFont(file, size)
end

function Font:set()
    graphics.setFont(self.font)
end

function Font:width(str)
    return self.font:getWidth(str)
end

function Font:height()
    return self.font:getHeight()
end

function Font:wrap(text, limit)
    return self.font:getWrap(text, limit)
end