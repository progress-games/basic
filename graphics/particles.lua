particles = Object:extend()

function particles:new()
    self.particles = {}
    self.types = {}
    self.generators = {}
    self.box = {x = 0, y = 0, w = world.x, h = world.y}
end

function particles:new_type(name, size, speed, direction, colour, decay, outline, sprite)
    self.types[name] = {size = size, 
        speed = speed, 
        direction = direction, 
        colour = colour, 
        decay = decay,
        outline = outline,
        sprite = sprite or nil
    }
    if self.types[name].sprite then
        self.types[name].sprite = {img = sprite, w = sprite:getWidth(), h = sprite:getHeight()}
    end
end

function particles:new_generator(gen_name, amount, par_name, position)
    self.generators[gen_name] = {
        amount = amount,
        name = par_name,
        position = position
    }
end

function particles:new_particles(name)
    local gen = self.generators[name]
    if type(gen.amount) == 'table' then
        amount = math.random(unpack(gen.amount))
    else
        amount = gen.amount
    end
    local particle = self.types[gen.name]

    for i=1, amount do
        table.insert(self.particles, {
            x = _G[gen.position].x,
            y = _G[gen.position].y,
            r = random_float(unpack(particle.size)),
            s = random_float(unpack(particle.speed)),
            dir = random_float(unpack(particle.direction)),
            colour = particle.colour:random(),
            decay = particle.decay,
            outline = particle.outline
        })
    end
end

function particles:update(dt)
    for i, v in pairs(self.particles) do
        if v.r < 0.5 or v.s < 0.05 then
            table.remove(self.particles, i)
        else
            v.x = v.x + v.s*dt*math.cos(v.dir)
            v.y = v.y + v.s*dt*math.sin(v.dir)
            v.r = v.r - v.r/v.decay
            v.s = v.s - v.s/v.decay
        end
    end
end

function particles:draw()
    for _, v in pairs(self.particles) do
        if v.outline then
            if not v.sprite then
                v.outline.colour:set()
                graphics.circle('fill', v.x, v.y, v.r+v.outline.width)
            else
                local scale = 1 + outline.width
                v.outline.colour:set()
                graphics.draw(v.sprite.img, v.x - v.sprite.w*scale/2, v.y - v.sprite.h*scale/2, 0, scale, scale)
            end
        end
    end
    
    for i, v in pairs(self.particles) do
        v.colour:set()
        if v.sprite then
            graphics.draw(v.sprite.img, v.x - v.sprite.w/2, v.y - v.sprite.h/2)
        else
            graphics.circle('fill', v.x, v.y, v.r)
        end
    end
    colours.white:set()
end