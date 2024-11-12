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

function Colour:opaque(a)
    return Colour(self.r, self.g, self.b, a)
end

function Colour:set()
    graphics.setColor(self.r, self.g, self.b, self.a)
end

colours = {
    white = Colour(1, 1, 1),
    black = Colour(0, 0, 0),
    red = Colour(1, 0, 0),
    green = Colour(0, 1, 0),
    blue = Colour(0, 0, 1),
    yellow = Colour(1, 1, 0),
    magenta = Colour(1, 0, 1),
    cyan = Colour(0, 1, 1),
    orange = Colour(1, 0.5, 0),
    purple = Colour(0.5, 0, 0.5),
    pink = Colour(1, 0.75, 0.8),
    brown = Colour(0.6, 0.3, 0),
    grey = Colour(0.5, 0.5, 0.5),
    light_grey = Colour(0.75, 0.75, 0.75),
    dark_grey = Colour(0.25, 0.25, 0.25),
    olive = Colour(0.5, 0.5, 0),
    teal = Colour(0, 0.5, 0.5),
    navy = Colour(0, 0, 0.5),
    lavender = Colour(0.9, 0.6, 1),
    beige = Colour(0.96, 0.96, 0.86),
    mint = Colour(0.6, 1, 0.6),
    coral = Colour(1, 0.5, 0.31),
    gold = Colour(1, 0.84, 0),
    silver = Colour(0.75, 0.75, 0.75),
    maroon = Colour(0.5, 0, 0),
}
