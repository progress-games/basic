colour = Object:extend()

function colour:new(r, g, b, a)
    if r > 1 or g > 1 or b > 1 then
        r = r/255
        g = g/255
        b = b/255
    end
    if a == nil then a = 1 end
    self.lock = false
    self.r, self.g, self.b, self.a = r, g, b, a
    self.tags = {}
end

function colour:random(range)
    if range == nil then range = 100 end
    range = range/255
    if not self.lock then
        r, g, b = self.r + random_float(-range/2, range/2), self.g + random_float(-range/2, range/2), self.b + random_float(-range/2, range/2)
        r, g, b = math.min(1, r), math.min(1, g), math.min(1, b)
        return colour(r, g, b)
    else
        return self
    end
end

function colour:lighten(amount)
    if amount == nil then amount = 10 end
    amount = amount/255
    return colour(self.r + amount, self.g + amount, self.b + amount)
end

function colour:add_tag(func, name, play, dur)
    if play == nil then play = false end
    self.tags[name] = {func = func, play = play, dur = dur}
end

function colour:play(name)
    self.tags[name].play = true
    self.tags[name].timer = 0
end

function colour:update(dt)
    for _, v in pairs(self.tags) do
        if v.play then
            v.timer = v.timer + dt
            v.func(dt, v.dur)
            if v.timer >= v.dur then v.play = false end
        end
    end
end

function colour:set()
    graphics.setColor(self.r, self.g, self.b, self.a)
end