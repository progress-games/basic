Colour = Object:extend()

function Colour:new(r, g, b, a)
    if r > 1 or g > 1 or b > 1 then
        r = r/255
        g = g/255
        b = b/255
    end
    self.lock = false
    self.r, self.g, self.b, self.a = r, g, b, a or 1
end

function Colour:random(range)
    range = (range or 100)/255
    if not self.lock then
        r, g, b = self.r + random_float(-range/2, range/2), self.g + random_float(-range/2, range/2), self.b + random_float(-range/2, range/2)
        r, g, b = math.min(1, r), math.min(1, g), math.min(1, b)
        return Colour(r, g, b)
    else
        return self
    end
end

function Colour:unpack()
    return self.r, self.g, self.b, self.a
end

function Colour:lighten(amount)
    amount = (amount or 10)/255
    return Colour(self.r + amount, self.g + amount, self.b + amount)
end

function Colour:darken(amount)
    return self:lighten(-(amount or 0))
end

function Colour:set()
    graphics.setColor(self.r, self.g, self.b, self.a)
end