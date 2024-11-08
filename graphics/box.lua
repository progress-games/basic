Box = Object:extend()

function Box:new(x, y, w, h, c)
    self.colour = c or colours.white
    self.x, self.y, self.w, self.h = x, y, w, h
    self.rot = 0
end

function Box:scale(w, h)
    h = h or w
    self.x = self.x - (self.w*w - self.w)/2
    self.y = self.y - (self.h*h - self.h)/2
    self.w = self.w*w
    self.h = self.h*h
end

function Box:setColour(c)
    self.colour = c
end

function Box:draw(fill, c, r, w)
    w = w or 1
    r = r or 2
    self.colour:set()

    local prev = graphics.getLineWidth()

    love.graphics.push()
    love.graphics.translate(self.x + self.w / 2, self.y + self.h / 2)
    love.graphics.rotate(self.rot)
    love.graphics.rectangle("fill", -self.w / 2, -self.h / 2, self.w, self.h)
    love.graphics.pop()  

    graphics.setLineWidth(prev)
end

function Box:intercept(x, y)
    x = math.cos(-self.rot) * (x - (self.x + self.w / 2)) - math.sin(-self.rot) * (y - (self.y + self.h / 2))
    y = math.sin(-self.rot) * (x - (self.x + self.w / 2)) + math.cos(-self.rot) * (y - (self.y + self.h / 2))

    return x >= -self.w / 2 and x <= self.w / 2 and y >= -self.h / 2 and y <= self.h / 2
end