Particles = Object:extend()
g = love.graphics

function Particles:new(args)
    self.on = args.on or true
    self.systems = args.systems or {}
    self.default = {
        base = 10,
        lifetime = {0.5, 1.5},
        size = {2, 0.5, 0},
        speed = {50, 200},
        spread = 2 * math.pi,
        colours = {
            1, 1, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 1
        },
        amount = 300,
        outline = {colour = Colour(0, 0, 0), width = 2}
    }
end

function Particles:updateVis(new)
    self.on = new
end

function Particles:newSystem(name, args)
    local img = args.sprite or g.newCanvas(self.default.base, self.default.base)
    if not args.img then
        g.setCanvas(img)
        g.circle('fill', self.default.base, self.default.base, self.default.base)
        g.setCanvas()
    end

    local ps = g.newParticleSystem(img, 1000)
    local lifetime, size, speed, spread, colours = 
        args.lifetime or self.default.lifetime, 
        args.size or self.default.size,
        args.speed or self.default.speed,
        args.spread or self.default.spread,
        args.colours or self.default.colours

    ps:setParticleLifetime(lifetime[1], lifetime[2])
    ps:setSizes(size[1], size[2], size[3])
    ps:setSpeed(speed[1], speed[2])
    ps:setSpread(spread)
    ps:setColors(unpack(colours))

    self.systems[name] = {
        system = ps,
        outline = {colour = args.outline_colour or self.default.outline.colour, 
            width = args.outline_colour or self.default.outline.width}
    }
end

function Particles:emit(name, x, y, amount)
    if not self.on or not self.systems[name] then return end

    local ps = self.systems[name].system
    ps:setPosition(x, y)
    ps:emit(amount or 50)
end

function Particles:update(dt)
    if not self.on then return end

    for _, ps in pairs(self.systems) do
        ps.system:update(dt)
    end
end

function Particles:draw()
    if not self.on then return end

    for _, ps in pairs(self.systems) do
        outline(function () love.graphics.draw(ps.system, 0, 0) end, ps.outline.width, ps.outline.colour)
        love.graphics.draw(ps.system, 0, 0)
    end
end
