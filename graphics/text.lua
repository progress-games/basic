Text = Object:extend()

function Text:new(args)
    self.fx = args.fx or {}
    self.font = args.font or love.graphics.newFont(16)
end

function Text:newText(args)
    return TextObj(args.txt, self.fx, self.font, args.align, args.limit)
end

TextObj = Object:extend()

function TextObj:new(args)
    self.fx = args.fx
    self.font = args.font

    self.cleaned = self:cleanText(args.text)

    self.chars, self.raw = self:addFx(self.cleaned)
    self.drawable = nil

    self.align = args.align or 'left'
    self.limit = args.limit or 100
    self:position()
end

function TextObj:cleanText(text)
    local cleaned = {}

    if text:sub(1, 1) ~= '[' then
        text = '[white]'..text
    end

    for str, tags in txt:gmatch("([^%[]*)(%b[])") do
        if str ~= "" then
            table.insert(cleaned, str)
        end
        table.insert(cleaned, tags:sub(2, -2):gsub("%s+", ""):split(","))
    end

    local last = text:match(".+%](.*)$")
    if last ~= "" then
        table.insert(cleaned, last)
    end

    return cleaned
end

function TextObj:addFx(cleaned)
    local active, raw, chars = {}, '', {}

    for i, str in ipairs(cleaned) do 
        if type(str) == 'table' then
            active = str
            active = table.map(active, function (s) return self.fx[s] end)
        else
            raw = raw..str

            for c in str:gmatch'.' do
                table.insert(chars, {
                    c = c,
                    tags = active,
                    i = i,
                    x = 0,
                    y = 0
                })
            end
        end
    end

    return chars, raw
end

function TextObj:position()
    _, self.lines = self.font:getWrap(self.raw, self.limit)
    local center, height = self.limit/2, self.font:getHeight()
    self.height = #self.lines * height

    for i, line in ipairs(self.lines) do
        local cur, width = '', self.font:getWidth(line)

        for c in line:gmatch'.' do
            local cur_width = self.font:getWidth(cur)

            if self.align == 'center' then
                self.chars[i].x = center - width/2 + cur_width
            elseif self.align == 'right' then
                self.chars[i].x = (self.limit - width) + cur_width
            else
                self.chars[i].x = cur_width
            end
            self.chars[i].y = (i - 1)*height
            cur = cur..c
        end
    end

    self:initTags()
end

function TextObj:initTags()
    for _, v in pairs(self.chars) do
        for _, tag in pairs(v.tags) do
            tag:init(v)
        end
    end
end

function TextObj:update(dt)
    for _, c in pairs(self.chars) do
        for _, tag in pairs(c.tags) do
            tag:update(dt, c)
        end
    end
end

function TextObj:print(args)
    local x, y = args.x, args.y
    for _, c in pairs(self.chars) do
        for _, tag in pairs(c.tags) do
            tag:draw(c, x.x + x, c.y + y)
        end
        love.graphics.print(c.c, c.x + x, c.y + y)
    end
end


TextTag = Object:extend()

function TextTag:new() end

function TextTag:init(c) end

function TextTag:update(dt, c) end

function TextTag:draw(c, x, y) end

-- Some basic text tags

local ColourTag = TextTag:extend()

function ColourTag:new(c)
    self.colour = c
end

function ColourTag:draw(...)
    self.colour:set()
end

local OutlineTag = TextTag:extend()

function OutlineTag:new(n)
    self.border = n
end

function OutlineTag:draw(c, x, y)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(c, x - self.border, y)
    love.graphics.print(c, x + self.border, y)
    love.graphics.print(c, x - self.border, y - self.border)
    love.graphics.print(c, x + self.border, y - self.border)
    love.graphics.print(c, x - self.border, y + self.border)
    love.graphics.print(c, x - self.border, y + self.border)
    love.graphics.print(c, x, y - self.border)
    love.graphics.print(c, x, y + self.border)
    love.graphics.setColor(r, g, b, a)
end

local RollTag = TextTag:extend()

function RollTag:new(height, speed)
    self.h = function (v) return height*math.cos(((2*math.pi)/speed)*v)
end

function RollTag:init(c)
    char.frame = char.i
    char.y = char.y + self.h(char.frame)
end

function RollTag:update(dt, c)
    char.y = char.y - self.h(char.frame)
    char.frame = char.frame + 1
    char.y = char.y + self.h(char.frame)
end