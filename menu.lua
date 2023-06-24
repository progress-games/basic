menu = Object:extend()

function menu:new()
    self.uses_canvas = true
    self.particles = particles()
    self.particles:new_type('test', {8, 14}, {to_dt(1), to_dt(3)}, {0, 2*math.pi}, colours.green, 50, {colour = colours.white, width = 1})
    self.particles:new_generator('test_gen', 40, 'test', 'mouse')
    test_texts = {text('the way this works is pretty straight forward. each character has any number of tags that can determine it\'s [red]colour[shaking], or movement[roll, yellow], or both[white] and i can easily make as many tags as i want without expanding this code!', text_tags, graphics.getFont(), 'center', 200)}
end

function menu:enter()

end

function menu:exit()

end

function menu:update(dt)
    self.particles:update(dt)
    if love.mouse.isDown(1) then
        self.particles:new_particles('test_gen')
    end
    for _, v in pairs(test_texts) do
        v:update(dt)
    end
end

function menu:draw()
    for i, v in ipairs(test_texts) do
        v:print(15, 50*i)
    end
    self.particles:draw()
end
