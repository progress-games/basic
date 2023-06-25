menu = Object:extend()

function menu:new()
    self.uses_canvas = true
    self.particles = particles()
    self.particles:new_type('test', {8, 14}, {to_dt(1), to_dt(3)}, {0, 2*math.pi}, colours.green, 50, {colour = colours.white, width = 1})
    self.particles:new_generator('test_gen', 40, 'test', 'mouse')
    set_font('main')
    test_text = text('here\'s a simple text', text_tags, font.current, 'center', 100)
    test_textbox = textbox(test_text, 50, 100)
    tooltip_text = text('insert [yellow]description [shaking]here', text_tags, font.current, 'center', 400)
    tooltip_textbox = textbox(tooltip_text)
    test_textbox:add_tooltip(tooltip_textbox)
end

function menu:enter()

end

function menu:exit()

end

function menu:update(dt)
    self.particles:update(dt)
    test_textbox:update(dt)
end

function menu:draw()
    test_textbox:draw()
    self.particles:draw()
end
