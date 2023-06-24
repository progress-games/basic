text = Object:extend()

--[[
how to use this text lib
description = text('this is an [yellow]example', yellow = {draw = function () colours.yellow:set() end})
the text will be set to white as default
]]

function text:new(txt, fx, font, align, limit)
    if txt:sub(1, 1) ~= '[' then
        txt = '[white]'..txt 
    end

    self.cleaned_text = {}
    self.raw_string = ''
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
end

function text:update(dt)
    for _, v in pairs(self.chars) do
        for _, tag in pairs(v.tags) do
            if tag.update then tag.update(dt, v) end
        end
    end
end

function text:print(x, y)
    colours.white:set()
    for _, v in pairs(self.chars) do
        for _, tag in pairs(v.tags) do
            if tag.draw then tag.draw() end
        end
        graphics.draw(v.obj, x + v.x, y + v.y)
        colours.white:set()
    end
end

--[[

functionality

create a text
print it 
animate it
every character needs:
colour
x, y, rotation

text:animate()
text:print()

print(text)
]]
