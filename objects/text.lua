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
    self.line_height = font:getHeight()
    self.text_width = font:getWidth('v')
    self.chars = {}
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
    self:position(align, limit)
end

function text:position(align, limit)
    _, self.lines = self.font:getWrap(self.raw_string, limit)
    local center, height = limit/2, self.font:getHeight()
    local idx = 1
    for gaps, line in ipairs(self.lines) do
        local cur_line, line_width = '', self.font:getWidth(line)
        for c in line:gmatch'.' do
            if self.chars[idx].i ~= idx then
                error('indexing issue in text '..self.raw_string)
            else
                if align == 'center' then
                    self.chars[idx].x = center - line_width/2 + self.font:getWidth(cur_line)
                elseif align == 'right' then
                    self.chars[idx].x = (limit - line_width) + self.font:getWidth(cur_line)
                elseif align == 'left' then
                    self.chars[idx].x = self.font:getWidth(cur_line)
                end
                self.chars[idx].y = (gaps-1)*height
                cur_line = cur_line..c
                idx = idx + 1
            end
        end
    end
    self.limit = limit
    self.align = align
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

--UNCOMMENT THIS TEXT TO SEE IT WHEN IT HASN'T GOT THE CANVAS ENABLED
function text:print(x, y)
    --graphics.setCanvas()
    --x, y = x * window.scale, y * window.scale
    colours.white:set()
    for _, v in pairs(self.chars) do
        for _, tag in pairs(v.tags) do
            if tag.draw then tag.draw() end
        end
        graphics.draw(v.obj, x + v.x, y + v.y)
        colours.white:set()
    end
    --graphics.setCanvas(self.canvas)
end

box = Object:extend()

function box:new(x, y, w, h, c)
    if c == nil then c = colours.white end
    self.colour = c
    self.x, self.y, self.w, self.h = x, y, w, h
end

function box:scale(s)
    self.x = self.x - s
    self.y = self.y - s
    self.w = self.w + 2*s 
    self.h = self.h + 2*s 
end

function box:draw(fill, c, r)
    if c == nil then
        self.colour:set()
    else
        c:set()
    end
    if r == nil then r = 2 end
    graphics.rectangle(fill, self.x, self.y, self.w, self.h, r, r)
end


textbox = Object:extend()

function textbox:new(txt, x, y)
    self.text = txt
    if x == nil then x, y = 0, 0 end
    self:move(x, y)

    self.corners = 2
    self.fill = false
    self.draw_line = false
    self.fill_colour = colours.invis
    self.line_colour = colours.white
    self.parent = true

    --tooltips to display on hover
    self.tooltips = {}
    self.hovering = false
    self.display_tooltips = false
    self.tooltip_spacing = 10

    --follow will follow the mouse
    --position determines which corner is touching the mouse
    self.tooltip_display = {follow = false, position = 'top-left'}
end

function textbox:move(x, y)
    self.x, self.y = x, y

    self.box = box(table.min(self.text.chars, 'x') + self.x, 
    table.min(self.text.chars, 'y') + self.y,
    (table.max(self.text.chars, 'x') - table.min(self.text.chars, 'x') + self.text.text_width)/2, 
    (table.max(self.text.chars, 'y') - table.min(self.text.chars, 'y') + self.text.line_height)/2)
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
        capsule.x = capsule.x + capsule.w/2
    elseif self.tooltip_display.follow and pos == 'top-left' then
        capsule.x = capsule.x - capsule.w/2
    end
    local cur_width = 0

    for _, tt in pairs(self.tooltips) do
        tt:move(capsule.x + cur_width, capsule.y)
        cur_width = cur_width + tt.box.w + self.tooltip_spacing
    end
end

function textbox:draw_tooltips()
    for _, tt in pairs(self.tooltips) do
        tt:draw()
    end
end

function textbox:update(dt)
    for _, tt in pairs(self.tooltips) do
        tt:update(dt)
    end
    self.text:update(dt)
end

function textbox:draw()
    if self.fill then
        self.box:draw('fill', self.fill_colour, self.corners)
    end
    if self.draw_line then
        self.box:draw('line', self.line_colour, self.corners)
    end
    self.text:print(self.x, self.y)
    local box = box(self.x, self.y, self.text.limit, self.text.line_height, colours.red)
    box:draw('line')
    --self:draw_tooltips()
    colours.white:set()
end