Textbox = Object:extend()

function Textbox:new(args)
    self.text = args.text
    x, y = args.x or 0, args.y or 0

    self.padding = {
        above = 5,
        below = 5,
        left = 5,
        right = 5
    }

    self:move(x, y)
    self.corners = args.corners or 2
    self.fill = args.fill or true
    self.draw_line = args.draw_line or true
    self.fill_colour = args.fill_colour or colours.black:opaque(0.2)
    self.line_colour = args.line_colour or colours.white
end

function Textbox:move(x, y)
    self.x, self.y = x, y

    self.box = Box(
        self.text.box.x + self.x - self.padding.left, 
        self.text.box.y + self.y - self.padding.above,
        self.text.box.w + self.padding.left + self.padding.right,
        self.text.box.h + self.padding.above + self.padding.below
    )
end

function Textbox:update(dt)
    self.text:update(dt)
end

function Textbox:draw()
    if self.fill then
        self.box:draw('fill', self.fill_colour, self.corners)
    end
    if self.draw_line then
        self.box:draw('line', self.line_colour, self.corners)
    end
    colours.white:set()
    self.text:print(self.x + self.padding.left, self.y + self.padding.above)
end

