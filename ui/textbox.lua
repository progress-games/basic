Textbox = Object:extend()

function Textbox:new(txt, timer, x, y)
    self.text = txt
    if x == nil then x, y = 0, 0 end
    self.padding = {
        above = 5,
        below = 5,
        left = 5,
        right = 5
    }

    self:move(x, y)

    self.id = {
        main = UUID()
    }
    self.id.move = self.id.main..'move'
    self.id.pressed = self.id.main..'pressed'

    self.timer = timer
    self.corners = 2
    self.fill = true
    self.draw_line = true
    self.on_click = false
    self.fill_colour = colours.transparent.black
    self.line_colour = colours.white

    --tooltips to display on hover
    self.tooltips = {}
    self.hovering = false
    self.display_tooltips = false
    self.tooltip_spacing = 5

    --follow will follow the mouse
    --position determines which corner is touching the mouse
    self.tooltip_display = {follow = false, position = 'top-left'}
end

function Textbox:move(x, y)
    self.x, self.y = x, y

    self.box = box(table.min(self.text.chars, 'x')/window.scale + self.x - self.padding.left, 
    table.min(self.text.chars, 'y') + self.y - self.padding.above,
    (table.max(self.text.chars, 'x') - table.min(self.text.chars, 'x') + self.text.text_width + self.padding.right + self.padding.left*window.scale)/window.scale, 
    (table.max(self.text.chars, 'y') - table.min(self.text.chars, 'y') + self.text.line_height + self.padding.below + self.padding.above*window.scale)/window.scale)
end

function Textbox:add_tooltip(Textbox)
    table.insert(self.tooltips, Textbox)
    self:align_tooltips()
end

function Textbox:align_tooltips()
    local pos = self.tooltip_display.position

    if self.tooltip_display.follow then
        x, y = mouse.x, mouse.y
    else
        x, y = self.box.x, self.box.y
    end

    local capsule = {x = 0, y = 0, w = 0, h = 0}

    for k, tt in pairs(self.tooltips) do
        capsule.w = capsule.w + tt.box.w
        if k < #self.tooltips then 
            capsule.w = capsule.w + self.tooltip_spacing 
        end
        capsule.h = math.max(capsule.h, tt.box.h)
    end

    capsule.x = x + self.box.w/2 - capsule.w/2
    capsule.y = y - self.tooltip_spacing - capsule.h

    if self.tooltip_display.follow and pos == 'top-right' then
        capsule.x = capsule.x + capsule.w/4
    elseif self.tooltip_display.follow and pos == 'top-left' then
        capsule.x = capsule.x - 3*capsule.w/4
    end

    if not self.tooltip_display.follow and pos == 'bottom-right' then
        capsule.y = y + self.box.h + self.tooltip_spacing
    end

    local cur_width = 0

    for _, tt in pairs(self.tooltips) do
        local sub = table.min(tt.text.chars, 'x')/2
        tt:move(capsule.x + cur_width - sub, capsule.y)
        cur_width = cur_width + tt.box.w + self.tooltip_spacing
    end
end

function Textbox:draw_tooltips()
    for _, tt in pairs(self.tooltips) do
        tt:draw()
    end
end

function Textbox:add_function(func, ...)
    self.func = func
    self.on_click = true
    self.params = {...}
end

function Textbox:update(dt)
    if self.hovering then
        for _, tt in pairs(self.tooltips) do
            tt:update(dt)
        end
    end
    self.text:update(dt)
end

function Textbox:mousemoved()
    if self.box:intercept(mouse.x, mouse.y) then
        if not self.hovering then
            self.hovering = true
            self.timer:cancel(self.id.move)
            self.box.scale_prop.w = 1
            self.timer:tween(0.5, self.box, {scale_prop = {w = 1.05}}, 'out-cubic', function () 
                self.timer:tween(0.5, self.box, {scale_prop = {w = 1}}, 'out-linear', function () end, self.id.move) 
            end, self.id.move)
        end
        if self.tooltip_display.follow then
            self:align_tooltips()
        end
    else
        if self.hovering then
            self.timer:cancel(self.id.move)
            self.timer:tween(0.5, self.box, {scale_prop = {w = 1}}, 'out-linear', function ()
                self.box.scale_prop.w = 1
            end, self.id.move)
            self.hovering = false
        end
    end
end

function Textbox:mousepressed()
    if self.box:intercept(mouse.x, mouse.y) and self.on_click then
        self.timer:cancel(self.id.pressed)
        self.box.scale_prop.w = 1
        self.timer:tween(0.2, self.box, {scale_prop = {w = 0.85, h = 0.95}}, 'out-elastic', function ()
            self.timer:tween(0.5, self.box, {scale_prop = {w = 1, h = 1}}, 'out-linear', function ()
            self.box.scale_prop = {w = 1, h = 1} end)
        end, self.id.pressed)
        self.func(unpack(self.params))
    end
end

function Textbox:draw()
    if self.fill then
        self.box:draw('fill', self.fill_colour, self.corners)
    end
    if self.draw_line then
        self.box:draw('line', self.line_colour, self.corners)
    end
    colours.white:set()
    self.text:print(self.x, self.y)
    if self.hovering then
        self:draw_tooltips()
    end
    colours.white:set()
end