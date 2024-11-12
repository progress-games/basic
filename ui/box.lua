Box = Object:extend()

function Box:new(x, y, w, h, col, rot)
    if col == nil then col = colours.white end
    self.colour = col
    
    self.x, self.y, self.w, self.h = x, y, w, h
    self.rot = rot or 0
    self.scale = 1
    self.base = 1

    self:calculate_points()
end

function Box:calculate_points()
    if self.rot == 0 then 
        return nil 
    end

    self.rot = self.rot-math.pi/2
    self.centre = {x = self.x+self.w/2, y = self.y+self.h/2}
    self.points = {
        rotateAboutP({self.centre.x - self.w/2, self.centre.y - self.h/2}, self.centre, self.rot),
        rotateAboutP({self.centre.x + self.w/2, self.centre.y - self.h/2}, self.centre, self.rot),
        rotateAboutP({self.centre.x + self.w/2, self.centre.y + self.h/2}, self.centre, self.rot),
        rotateAboutP({self.centre.x - self.w/2, self.centre.y + self.h/2}, self.centre, self.rot),
    }
end

function Box:copy()
    return Box(self.x, self.y, self.w, self.h)
end

--scale the box 
function Box:rescale(s)
    self.scale = s

    self.x = self.x - (self.scale - self.base)*self.w/2
    self.y = self.y - (self.scale - self.base)*self.h/2
    self.w = self.w*(1 + self.scale - self.base)
    self.h = self.h*(1 + self.scale - self.base)

    self.base = self.scale
end

function Box:translate(x, y)
    self.x = self.x + x
    self.y = self.y + y
end

--scale the box inwards (reverse scale)
function Box:r_scale(w, h)
    if h == nil then h = w end
    self:scale(1/w, 1/h)
end

function Box:lock_rot(x, y)
    self.rot_lock = {x = x, y = y}
end

function Box:lock_box(box)
    self.box_lock = box
end

function Box:draw(fill, c, r, w, rot, scale)
    if w == nil then w = 1 end
    if rot == nil then rot = self.rot end
    if c == nil then
        self.colour:set()
    else
        c:set()
    end
    scale = scale or self.scale

    local prev_w = graphics.getLineWidth()
    graphics.setLineWidth(w)
    --graphics.rectangle('line', self.x, self.y, self.w, self.h)

    if self.points == nil then
        graphics.push()
        if not self.rot_lock then
            graphics.translate(self.x + self.w/2, self.y + self.h/2)
        else
            graphics.translate(self.rot_lock.x, self.rot_lock.y)
        end
        graphics.rotate(rot)
        if not self.box_lock then
            graphics.rectangle(fill, -self.w*scale/2, -self.h*scale/2,
            self.w*scale, self.h*scale, r, r)
        else
            graphics.rectangle(fill, -self.w*scale/2 - (self.box_lock.w/2 - self.w/2), -self.h*scale/2,
            self.w*scale, self.h*scale, r, r)
        end

        graphics.pop()
    else
        local prev = nil
        for _, point in pairs(self.points) do
            if prev == nil then
                prev = point
            else
                drawRoundedLine({prev[1], prev[2]}, {point[1], point[2]}, w)
                prev = point
            end
        end
        drawRoundedLine({prev[1], prev[2]}, {self.points[1][1], self.points[1][2]}, w)
    end

    graphics.setLineWidth(prev_w)
end

function Box:intercept(x, y)
    --rotate the point about the centre if there is rotation
    if self.rot ~= 0 then
        dis = math.sqrt((self.centre.x-x)^2+(self.centre.y-y)^2)
        x = x - dis*math.cos(self.rot)
        y = y - dis*math.sin(self.rot)
    end
    
    return x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h
end

--checks collision b/w a rotated box and a box
function Box:collide(b)
    local corners = {}

    if self.rot == 0 then
        corners = {
            {self.x, self.y},
            {self.x+self.w, self.y},
            {self.x, self.y+self.h},
            {self.x+self.w, self.y+self.h},
            {self.x + self.w/2, self.y+self.h/2}
        }
    else
        self:calculate_points()
        corners = self.points
    end

    for _, corner in pairs(corners) do
        if b:intercept(unpack(corner)) then
            return true
        end
    end
end

function Box:draw_image(image)
    graphics.draw(image, self.x, self.y, self.dir, self.scale, self.scale)
end

function Box:random_edge()
    local side = math.random(4)
    local point = {x = 0, y = 0}
    
    if side == 1 then
        point.x = self.x + math.random() * self.w
        point.y = self.y
    elseif side == 2 then
        point.x = self.x + math.random() * self.w
        point.y = self.y + self.h
    elseif side == 3 then
        point.x = self.x
        point.y = self.y + math.random() * self.h
    else
        point.x = self.x + self.w
        point.y = self.y + math.random() * self.h
    end
    
    return point.x, point.y
end
