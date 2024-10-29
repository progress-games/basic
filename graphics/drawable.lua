Drawable = Object:extend()

function Drawable:new(object, x, y, s)
    self.object = object
    self.images = {self.object}
    self.idx = 1
    self.w, self.h = object:getDimensions()
    self.x, self.y = x, y
    self.scale = Spring(s)
    self.base = s
    self.box = Box(self.x, self.y, self.w, self.h)
    self.box:rescale(self.scale.x)
    self.spring_on_hover = 1.3
end

function Drawable:add_image(img)
    table.insert(self.images, img)
end

function Drawable:cycle_image()
    self.idx = self.idx % #self.images + 1
    self.object = self.images[self.idx]
end

function Drawable:move(x, y)
    self.x, self.y = x, y
    --self.box:rescale(self.scale.x)
end

function Drawable:replace_object(object)
    self.object = object
    self.w, self.h = object:getDimensions()
    self.box = Box(self.x, self.y, self.w*self.scale.x, self.h*self.scale.x)
end

function Drawable:rescale(s)
    self.base = s
end

function Drawable:on_hover(spring)
    self.spring_on_hover = spring
end

function Drawable:get_centre()
    return self.box.x + self.box.w/2, self.box.y + self.box.h/2
end

function Drawable:hover_text(text)
    self.text = text
end

function Drawable:update(dt, mx, my)
    self.box = Box(self.x - (self.scale.x - self.base)*self.w/2, self.y - (self.scale.x - self.base)*self.h/2, self.w*self.scale.x, self.h*self.scale.x)
    self.scale:update(dt)

    mx, my = mx or mouse.x, my or mouse.y
        
    self.hovering = self.box:intercept(mx, my) or self.force_hover

    if self.hovering then
        self.scale:animate(self.base*self.spring_on_hover)
    else
        self.scale:animate(self.base)
    end
end

function Drawable:add_function(func)
    self.on_click = func
end

function Drawable:enable_force_hover()
    self.force_hover = true
end

function Drawable:disable_force_hover()
    self.force_hover = false
end

function Drawable:intercept(x, y)
    return self.box:intercept(x, y)
end

function Drawable:clicked(mx, my)
    mx, my = mx or mouse.x, my or mouse.y
    return self:intercept(mx, my) and input:pressed('mouse1')
end

function Drawable:click_method() call(self.on_click) end

function Drawable:getWidth()
    return self.w*self.scale.x
end

function Drawable:getHeight()
    return self.h*self.scale.x
end

function Drawable:getBaseWidth()
    return self.w * self.base
end

function Drawable:getBaseHeight()
    return self.h * self.base
end

function Drawable:getUnscaledHeight()
    return self.h
end

function Drawable:getUnscaledWidth()
    return self.w
end

function Drawable:draw(c)
    --self.box:draw('line')
    if c ~= nil then c:set() end
    graphics.draw(self.object, self.x - (self.scale.x - self.base)*self.w/2, self.y - (self.scale.x - self.base)*self.h/2, 0, self.scale.x, self.scale.x)
end

function Drawable:outline(w, c)
    if w == 0 then self:draw(c); return end
    local o = self.object
    local x, y, s = self.x - (self.scale.x - self.base)*self.w/2, self.y - (self.scale.x - self.base)*self.h/2, self.scale.x, self.scale.x
    outline(function () graphics.draw(o, x, y, 0, s, s) end, w)

    self:draw(c)
end

function Drawable:top_outline(w, c, o_c)
    local o = self.object
    local x, y, s = self.x - (self.scale.x - self.base)*self.w/2, self.y - (self.scale.x - self.base)*self.h/2, self.scale.x, self.scale.x
    top_outline(function () graphics.draw(o, x, y, 0, s, s) end, w, o_c)

    self:draw(c)
end

function Drawable:draw_box(c, fill)
    if c ~= nil then c:set() end
    self.box:draw(fill or 'line')
end