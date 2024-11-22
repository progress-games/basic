Description = Textbox:extend()

function Description:new(args)
    self.tooltips = {}
    self.hovering = args.hovering or false
    self.display_tooltips = args.display_tooltips or false
    self.tooltip_spacing = args.tooltip_spacing or 5
    self.tooltip_position = args.tooltip_position or 'right'

    Description.super.new(self, args)
end

function Description:select()
    self.display_tooltips = true
end

function Description:deselect()
    self.display_tooltips = false
end

function Description:add_tooltip(textbox)
    table.insert(self.tooltips, textbox)
    self:align_tooltips()
end 

function Description:align_tooltips()
    local pos = self.tooltip_display.position
    local capsule = {w = 0, h = 0}
    local w, h = 0, 0

    -- create a box with horizontally arranged tooltips
    if pos == 'above' or pos == 'below' then
        capsule.w = table.reduce(self.tooltips, function (acc, val) return acc + val.box.w end, 0) +
            (#self.tooltips - 1) * self.tooltip_spacing
        capsule.h = table.reduce(self.tooltips, function (acc, val) return math.max(acc, val.box.h) end, 0)

        for _, v in pairs(self.tooltips) do
            if pos == 'above' then
                v:move(self.box.x + self.box.w/2 - capsule.w/2 + w, self.box.y - capsule.h - self.tooltip_spacing)
            elseif pos == 'below' then
                v:move(self.box.x + self.box.w/2 - capsule.w/2 + w, self.box.y + self.box.h + self.tooltip_spacing)
            end
            w = w + v.box.w + self.tooltip_spacing
        end   
        
    -- create a box with vertically arranged tooltips
    else
        capsule.w = table.reduce(self.tooltips, function (acc, val) return math.max(acc, val.box.w) end, 0)
        capsule.h = table.reduce(self.tooltips, function (acc, val) return acc + val.box.h end, 0) +
            (#self.tooltips - 1) * self.tooltip_spacing

        for _, v in pairs(self.tooltips) do
            if pos == 'left' then
                v:move(self.box.x - capsule.w - self.tooltip_spacing, self.box.y + self.box.h/2 - capsule.h/2 + h)
            elseif pos == 'right' then
                v:move(self.box.x + self.box.w + self.tooltip_spacing, self.box.y + self.box.h/2 - capsule.h/2 + h)
            end
            h = h + v.box.h + self.tooltip_spacing
        end
    end
end

function Description:draw_tooltips()
    for _, v in pairs(self.tooltips) do
        v:draw()
    end
end

function Description:draw()
    if self.display_tooltips then
        self:draw_tooltips()
    end

    Description.super.draw(self)
end