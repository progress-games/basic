menu = Object:extend()

function menu:new()
    self.uses_canvas = true
    self.particles = particles()
    self.particles:new_type('test', {8, 14}, {to_dt(1), to_dt(3)}, {0, 2*math.pi}, colours.green, 50, {colour = colours.white, width = 1})
    self.particles:new_generator('test_gen', 40, 'test', 'mouse')
    self.timer = Timer()
    set_font('main')
    test_text = text('quit!', text_tags, font.current, 'center', 100)
    test_textbox = textbox(test_text, self.timer, 100, 100)
    test_textbox:add_function(self.test_func, self)
    tooltip_text = text('insert [yellow]description [shaking]here', text_tags, font.current, 'center', 200)
    tooltip_textbox = textbox(tooltip_text, self.timer)
    tooltip_text2 = text('huh', text_tags, font.current, 'center', 200)
    tooltip_textbox2 = textbox(tooltip_text2, self.timer)
    test_textbox:add_tooltip(tooltip_textbox)
    test_textbox:add_tooltip(tooltip_textbox2)
end

function menu:enter()

end

function menu:exit()

end

function menu:test_func()
    print('pressed')
end

function menu:mousemoved()
    test_textbox:mousemoved()
end

function menu:mousepressed()
    test_textbox:mousepressed()
end

function menu:update(dt)
    self.timer:update(dt)
    self.particles:update(dt)
    test_textbox:update(dt)
end

function menu:draw()
    test_textbox:draw()
    self.particles:draw()
end

