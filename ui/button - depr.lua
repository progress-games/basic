--[[
How to use:

A button is a pressable piece of text that can play a function on click.

Define a button:

my_text_object('hello world', text_tags, my_font, align, limit)
my_button = Button(my_text_object, x, y, camera)

Once defined, a button does a couple of things by default but we can customise it using the following functions.

my_button:move(x, y)

x - the x location to move to (number)
y - the y location to move to (number)

my_button:add_tooltip(button)

button - a button that will reveal only when hovering this button
the name, 'button', is deceptive because you won't be able to click it (button object)

my_button:update_padding(pos, amount)

pos* - the location you'd like to update ('left', 'right', 'above', 'below')
amount - the new padding value (number)

my_button:add_function(function, parameters, ...)

function - the function that will play. only one can be added. (function)
parameters* - the arguments for the function (any)

my_button:update_colours(line_colour, line_width, fill_colour)

line_colour* - the colour of the line (colour object)
line_width* - the width of the line border (number)
fill_colour* - the colour of the box (colour object)

examples:
my_button:update_colours(yellow) - updates fill because no line_width was provided
my_button:update_colours(black, 3) - updates line because no fill_colour was provided
my_button:update_colours(black, 3, yellow) - updates everything

my_button:on_hover(play, line, fill)

play - determines if the text plays on hover (bool)
line* - determines if the line is visible on and off hover respectively (table(bool))
fill* - determines if the box is visible on and off hover respectively (table(bool))

my_button:add_toggle_text(text)

text - when clicked, it will toggle between this text, like on or off (text object)

my_button:make_static(on_hover, on_click)

on_hover* - determines if the button scale is not squashed when hovered (bool)
on_click* - determines if the button scale is not squashed when clicked (bool)

]]

Button = Object:extend()

function Button:new(txt, x, y, camera)
    self.text = txt
    self.scale = Spring(1)
    self.default_scale = 1
    if x == nil then x, y = 0, 0 end

    self.padding = {
        above = 5,
        below = 5,
        left = 5,
        right = 5
    }

    self:move(x, y)
    --self:move(x - self.box.w/2, y)

    self.corners = 2
    self.fill = true
    self.draw_line = true
    self.on_click = false
    self.fill_colour = colours.invis
    self.line_colour = colours.invis
    self.line_width = 1
    self.play_on_hover = false
    if camera == nil then
        error('button needs parent camera')
    end
    self.camera = camera

    --tooltips to display on hover
    self.tooltips = {}
    self.hovering = false
    self.display_tooltips = false
    self.tooltip_spacing = 5

    --follow will follow the mouse
    --position determines which corner is touching the mouse
    self.tooltip_display = {follow = false, position = 'top-right'}

    self.static = {}

    self:on_hover()
end

function Button:move(x, y)
    self.x, self.y = x, y

    self:update_box()
    if #(self.tooltips or {}) ~= 0 then
        self:align_tooltips()
    end
end

function Button:update_box()
    local dim = {
        x = table.min(self.text.chars, 'x') + self.x - self.padding.left, 
        y = table.min(self.text.chars, 'y') + self.y - self.padding.above,
        w = table.max(self.text.chars, 'x') - table.min(self.text.chars, 'x') + self.text.text_width + self.padding.right + self.padding.left, 
        h = table.max(self.text.chars, 'y') - table.min(self.text.chars, 'y') + self.text.line_height + self.padding.below + self.padding.above
    }

    self.box = Box(dim.x - (self.scale.x - self.default_scale)*dim.w/2, dim.y - (self.scale.x - self.default_scale)*dim.h/2, dim.w*(self.scale.x/self.default_scale), dim.h*(self.scale.x/self.default_scale))
end

function Button:add_tooltip(button)
    table.insert(self.tooltips, button)
    self:align_tooltips()
end

function Button:add_tooltips(text, f, w, ow, relative)
    w = w or 50
    f = f or 1
    ow = ow or 1
    out = ow
    ow = '[outline'..ow
    local text = string.lower(text)
    local added = {}
    for word, v in pairs(effects) do
        if v.obj and v.obj.get_type then 
            word = v.obj.get_type(v.obj)
        end

        if (string.find(text, ' '..word) or string.find(text, word..' ')) and not table.invals(added, word) and v.desc then
            local desc = v.desc
            local item_desc = Text(ow..', little_float, '..word..']'..word, text_tags, fonts.english[f].font, 'center', w)
            item_desc:merge_text(Text(ow..']'..format_desc(desc, out), text_tags, fonts.english[f].font, 'center', w))
            local tt = Button(item_desc, 0, 0, self.camera)
            table.insert(self.tooltips, tt)
            table.insert(added, word)
        end
    end
    self:align_tooltips(relative)
end

function Button:update_padding(pos, amount)
    if type(pos) == 'table' then
        for i, p in ipairs(pos) do
            self.padding[p] = amount[i]
        end
    else
        self.padding[pos] = amount
    end
    self:move(self.x, self.y)
end

function Button:align_tooltips(relative)
    local pos = self.tooltip_display.position

    if self.tooltip_display.follow then
        x, y = mouse.x, mouse.y
    else
        x, y = self.box.x, self.box.y
    end

    local capsule = {x = 0, y = 0, w = 0, h = 0}

    for k, tt in pairs(self.tooltips) do
        capsule.w = capsule.w + tt.box.w
        if k <= #self.tooltips and k > 1 then 
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

    if capsule.x + capsule.w > world.x and not relative then
        capsule.x = capsule.x - ((capsule.x + capsule.w) - world.x)
    end

    local cur_width = 0

    for _, tt in pairs(self.tooltips) do
        local sub = table.min(tt.text.chars, 'x')/2
        tt:move(capsule.x + cur_width - sub, capsule.y)
        cur_width = cur_width + tt.box.w + self.tooltip_spacing
    end
end

function Button:tooltip_apply(func_name, ...)
    for _, tt in pairs(self.tooltips) do
        tt[func_name](tt, ...)
    end
end

function Button:draw_tooltips()
    for _, tt in pairs(self.tooltips) do
        tt:draw()
    end
end

--eg:add_function(func, parameters) call func on click with parameters passed in
function Button:add_function(func, ...)
    self.func = func
    self.on_click = true
    self.params = {...}
end

function Button:add_right_click(func, ...)
    self.right_click = func
    self.on_click = true
    self.r_params = {...}
end

--eg:update_colours(colours.white, 3), updates only line
--eg:update_colours(colours.yellow), updates only fill
--eg:udpate_colours(colours.white, 3, colours.yellow), updates both line and fill
function Button:update_colours(colour1, w, colour2)
    if w == nil then
        self.fill_colour = colour1
    elseif colour2 == nil then
        self.line_colour = colour1
        self.line_width = w
    else
        self.line_colour = colour1
        self.line_width = w
        self.fill_colour = colour2
    end
end

--Button:on_hover(true, {false, false}, {true, false})
--plays Text on hover, doesnt line on or off hover, fills on but not off hover
function Button:on_hover(play, line, fill, tooltips)
    if type(play) == 'function' then
        self.hover_func = play
        self.hover_params = line
    else
        self.play_on_hover = play or false
        line = line or {false, false}
        fill = fill or {false, false}
        self.set_on_hover = function ()
            self.fill = fill[1]
            self.draw_line = line[1]
        end
        self.set_off_hover = function ()
            self.fill = fill[2]
            self.draw_line = line[2]
        end
        self.set_off_hover()
        self.tooltip_on_hover = tooltips
    end
end

--button will toggle back and forth from this text when it is pressed
function Button:add_toggle_text(text)
    self.alt_text = text
end

function Button:make_static(on_hover, on_click)
    self.static = {
        hover = on_hover or true,
        click = on_click or true
    }
end

function Button:rescale(new)
    self.default_scale = new
    self.text:rescale(self.default_scale)
    self.text:update(0)
end

function Button:getWidth()
    return self.text.limit
end

function Button:getCurWidth()
    return self.text.max_width + self.padding.left + self.padding.right
end

function Button:getHeight()
    return self.text:getHeight()*self.scale.x
end

function Button:getBaseHeight()
    return self.text:getHeight()
end

function Button:intercept(x, y)
    return self.box:intercept(x, y)
end

function Button:toggle_text()
    self.text, self.alt_text = self.alt_text, self.text
end

function Button:update(dt, mx, my)
    if not mx then
        mouse_pos(self.camera)
    else
        mouse.x, mouse.y = mx, my
    end
    if self.box:intercept(mouse.x, mouse.y) then
        call(self.hover_func, unpack(self.hover_params or {}))
        if not self.hovering then
            self.set_on_hover()
            self.hovering = true
            if not self.static.hover then
                self.scale:animate(self.default_scale*1.15)
            end
        end
        if self.tooltip_display.follow then
            self:align_tooltips()
        end
    else
        if self.hovering then
            self.hovering = false
            self.set_off_hover()
        end
        self.scale:animate(self.default_scale)
    end

    if self.hovering then
        for _, tt in pairs(self.tooltips) do
            tt:update(dt)
        end
    end
    if (self.hovering and self.play_on_hover) or not self.play_on_hover then
        self.text:update(dt)
    end

    if (input:pressed('mouse1') or input:pressed('mouse2')) and self.box:intercept(mouse.x, mouse.y) then
        if not self.static.click then
            self.scale:pull(0.2)
        end
        if self.on_click then
            if input:pressed('mouse1') then call(self.func, unpack(self.params or {}))
            else call(self.right_click, unpack(self.r_params or {})) end
            Sfx:play('click')
        end
        if self.alt_text then
            self:toggle_text()
            Sfx:play('click')
        end
    end

    for _, tt in pairs(self.tooltips) do
        tt:update(dt)
    end

    self.scale:update(dt)
    self:update_box()
end

function Button:draw()
    if self.fill then
        self.box:draw('fill', self.fill_colour, self.corners)
    end
    if self.draw_line then
        self.box:draw('line', self.line_colour, self.corners, self.line_width)
    end
    colours.white:set()
    self.text:print(self.x+self.padding.left, self.y, self.scale.x)
    if self.hovering and self.tooltip_on_hover then
        self:draw_tooltips()
    end
    colours.white:set()
end