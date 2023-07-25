text = Object:extend()

--[[
how to use

define some text tags
text tags are things that apply to text that either happen at initiation of text, update, or draw

an example is

yellow = {
    draw = function ()
        colours.yellow:set()
    end
}

when we add this to text, it will draw it in yellow (provided we have defined colours.yellow)
adding this to text is just doing 'this text is[yellow] yellow' so the words following [yellow] will be in yellow

GOAL:
we can make a textbox that automatically encapsulates a text object
we can then add additional textboxes (called tooltips) that appear when interacting with the main textbox
we can also add a function to the textbox that calls on press which turns it into a button
we can also add satisfying movement to the box when the mouse hovers over it
]]

function text:new(txt, fx, font, align, limit)
    if txt:sub(1, 1) ~= '[' then
        txt = '[white]'..txt 
    end

    self.cleaned_text = {}
    self.raw_string = ''
    self.line_height = font:getHeight()--/window.scale
    self.text_width = font:getWidth('v')
    self.chars = {}
    self.v = 0
    self.font = font
    for str, tags in txt:gmatch("([^%[]*)(%b[])") do
        if str ~= "" then
            table.insert(self.cleaned_text, str)
        end
        table.insert(self.cleaned_text, tags:sub(2, -2):gsub("%s+", ""):split(","))
    end

    local last = txt:match(".+%](.*)$")
    if last ~= "" then
        table.insert(self.cleaned_text, last)
    end

    local active_fx, a = {}, 1
    for _, str in ipairs(self.cleaned_text) do
        if type(str) == 'table' then
            active_fx = str
            active_fx = table.apply(active_fx, function (s) return fx[s] end)
        else
            self.raw_string = self.raw_string..str
            for c in str:gmatch'.' do
                table.insert(self.chars, {
                    obj = graphics.newText(self.font, c),
                    tags = active_fx,
                    i = a, x = 0, y = 0
                })
                a = a + 1
            end
        end
    end

    if align == nil then align = 'center' end
    if limit == nil then limit = 100 end
    self.align, self.limit = align, limit*window.scale
    self:position()
end

function text:position(align, limit)
    if align == nil then
        align, limit = self.align, self.limit
    else
        self.align, self.limit = align, limit
    end

    _, self.lines = self.font:getWrap(self.raw_string, self.limit)
    local center, height = self.limit/2, self.font:getHeight()
    local idx = 1
    for gaps, line in ipairs(self.lines) do
        local cur_line, line_width = '', self.font:getWidth(line)
        for c in line:gmatch'.' do
            if self.chars[idx].i ~= idx then
                error('indexing issue in text '..self.raw_string)
            else
                if self.align == 'center' then
                    self.chars[idx].x = center - line_width/2 + self.font:getWidth(cur_line)
                elseif self.align == 'right' then
                    self.chars[idx].x = (self.limit - line_width) + self.font:getWidth(cur_line)
                elseif self.align == 'left' then
                    self.chars[idx].x = self.font:getWidth(cur_line)
                end
                self.chars[idx].y = (gaps-1)*height
                cur_line = cur_line..c
                idx = idx + 1
            end
        end
    end
    self:init_tags()
end

function text:init_tags()
    for _, v in pairs(self.chars) do
        for _, tag in pairs(v.tags) do
            if tag.init then tag.init(v) end
        end
    end
    graphics.setCanvas()
end

function text:update(dt)
    for _, v in pairs(self.chars) do
        for _, tag in pairs(v.tags) do
            if tag.update then tag.update(dt, v) end
        end
    end
end


function text:print(x, y)
    --love.graphics.draw(global_canvas, 0, 0, 0, window.scale, window.scale)
    canvases:draw()
    --graphics.setDefaultFilter('linear', 'linear')
    x, y = x * window.scale, y * window.scale
    for _, v in pairs(self.chars) do
        for _, tag in pairs(v.tags) do
            if tag.draw then tag.draw() end
        end
        graphics.draw(v.obj, x + v.x, y + v.y)
        colours.white:set()
    end
    graphics.setDefaultFilter('nearest', 'nearest')
    canvases:another()
end


box = Object:extend()

function box:new(x, y, w, h, c)
    if c == nil then c = colours.white end
    self.colour = c
    self.x, self.y, self.w, self.h = x, y, w, h
    self.scale_prop = {w = 1, h = 1}
end

function box:scale(w, h)
    if h == nil then h = w end
    self.x = self.x - (self.w*w - self.w)/2
    self.y = self.y - (self.h*h - self.h)/2
    self.w = self.w*w
    self.h = self.h*h
end

function box:r_scale(w, h)
    if h == nil then h = w end
    self:scale(1/w, 1/h)
end

function box:draw(fill, c, r, w)
    if w == nil then w = 1 end
    if c == nil then
        self.colour:set()
    else
        c:set()
    end
    if r == nil then r = 2 end
    local prev_w = graphics.getLineWidth()
    graphics.setLineWidth(w)
    graphics.rectangle(fill, self.x - (self.w*self.scale_prop.w - self.w)/2,
    self.y - (self.h*self.scale_prop.h - self.h)/2, self.w*self.scale_prop.w, self.h*self.scale_prop.h, r, r)
    graphics.setLineWidth(prev_w)
end

function box:intercept(x, y)
    return x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h
end

textbox = Object:extend()

function textbox:new(txt, timer, x, y)
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

function textbox:move(x, y)
    self.x, self.y = x, y

    self.box = box(table.min(self.text.chars, 'x')/window.scale + self.x - self.padding.left, 
    table.min(self.text.chars, 'y') + self.y - self.padding.above,
    (table.max(self.text.chars, 'x') - table.min(self.text.chars, 'x') + self.text.text_width + self.padding.right + self.padding.left*window.scale)/window.scale, 
    (table.max(self.text.chars, 'y') - table.min(self.text.chars, 'y') + self.text.line_height + self.padding.below + self.padding.above*window.scale)/window.scale)
end

function textbox:add_tooltip(textbox)
    table.insert(self.tooltips, textbox)
    self:align_tooltips()
end

function textbox:align_tooltips()
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

function textbox:draw_tooltips()
    for _, tt in pairs(self.tooltips) do
        tt:draw()
    end
end

function textbox:add_function(func, ...)
    self.func = func
    self.on_click = true
    self.params = {...}
end

function textbox:update(dt)
    if self.hovering then
        for _, tt in pairs(self.tooltips) do
            tt:update(dt)
        end
    end
    self.text:update(dt)
end

function textbox:mousemoved()
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

function textbox:mousepressed()
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

function textbox:draw()
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