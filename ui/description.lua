Description = Textbox:extend()

function Description:new(args)
    self.tooltips = {}
    self.hovering = args.hovering or false
    self.display_tooltips = args.display_tooltips or false
    self.tooltip_spacing = args.tooltip_spacing or 5
    self.tooltip_position = args.tooltip_position or 'right'

    Description.super.new(args)
end

function Description:add_tooltip(textbox)
    table.insert(self.tooltips, textbox)
    self:align_tooltips()
end 

function Description:align_tooltips()
    local pos = self.tooltip_display.position
    local capsule = {w = 0, h = 0}

    -- create a box with horizontally arranged tooltips
    if pos == 'above' or pos == 'below' then
        capsule.w = table.reduce(self.tooltips, function (acc, val) return acc + val.box.w end, 0) +
            (#self.tooltips - 1) * self.tooltip_spacing
        capsule.h = table.reduce(self.tooltips, function (acc, val) return math.max(acc, val.box.h) end, 0)

        local w, h = 0
        for _, v in pairs(self.tooltips) do
            w = w + v.box.w + self.tooltip_spacing
            if pos == 'above' then
                v:move(self.box.x - self.box.w/2 + w, capsule.y)
            elseif pos == 'below' then
                v:move(self.box.x - self.box.w/2 + w,, self.box.y + self.box.h + self.tooltip_spacing)
            end
        end   
        
    -- create a box with vertically arranged tooltips
    else
        capsule.w = table.reduce(self.tooltips, function (acc, val) return math.max(acc, val.box.w) end, 0)
        capsule.h = table.reduce(self.tooltips, function (acc, val) return acc + val.box.h end, 0) +
            (#self.tooltips - 1) * self.tooltip_spacing

        local w, h = 0
        for _, v in pairs(self.tooltips) do
            w, h = w + v.box.w + self.tooltip_spacing, h + v.box.h + self.tooltip_spacing
            if pos == 'above' then
                v:move(capsule.x + w, capsule.y)
            elseif pos == 'below' then
                v:move(capsule.x + w, capusle.y + capsule.h + self.tooltip_spacing)
            end
        end
    end
end