require 'libs.misc'
Object = require 'libs.classic'
Camera = require 'libs.Camera'
Timer = require 'libs.Timer'
require 'objects.particles'
require 'objects.text'
require 'objects.colour'
graphics = love.graphics

require 'menu'

colours = {
    black = colour(0, 0, 0),
    white = colour(1, 1, 1),
    red = colour(1, 0, 0),
    green = colour(0, 1, 0),
    blue = colour(0, 0, 1),
    mum = colour(86, 240, 3),
    yellow = colour(1, 1, 0)
}

text_tags = {
    shaking = {
        init = function(char)
            char.shake = 1.1
            char.lock = {x = char.x, y = char.y}
            char.step = 2
        end,
        update = function (dt, char)
            char.step = char.step - 1
            if char.step <= 0 then
                char.x = char.lock.x
                char.y = char.lock.y
                char.x = char.x + random_float(-char.shake/2, char.shake/2)
                char.y = char.y + random_float(-char.shake/2, char.shake/2)
                char.step = 2
            end
        end
    },
    float = {
        init = function (char)         
            char.moved = math.random(0, 4)
            char.dir = 1
        end,
        update = function (dt, char)
            char.y = char.y + -1*char.dir
            char.moved = char.moved + 1
            if char.moved > 4 and char.dir == 1 then char.moved = 0; char.dir = -1/10
            elseif char.moved > 4 and char.dir == -1 then char.moved = 0; char.dir = 1/10 end
        end
    },
    roll = {
        init = function (char)         
            char.step = 4 + char.i
            char.moved = 0
            char.dir = 1
        end,
        update = function (dt, char)
            char.step = char.step - 1
            if char.step <= 0 then
                char.y = char.y + -1*char.dir
                char.moved = char.moved + 1
                char.step = 4
                if char.moved > 4 and char.dir == 1 then char.moved = 0; char.dir = -1
                elseif char.moved > 4 and char.dir == -1 then char.moved = 0; char.dir = 1 end
            end
        end
    }
}

for colour, obj in pairs(colours) do
    text_tags[colour] = {
        draw = function ()
            obj:set()
        end
    }
end

colours.black.lock = true
colours.white.lock = true

-- LÖVE 0.10.2 fixed timestep loop, Lua version
function love.run()
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.0001) end
    end
end

function love.load()
    --room management
    --love.window.setFullscreen(true)
    math.randomseed(os.time())

    --video settings
    window = {}
    window.x, window.y = love.graphics.getDimensions()
    window.scale = 2
    world = {
        x = window.x/window.scale,
        y = window.y/window.scale
    }
    centre = {
        x = world.x/2,
        y = world.y/2
    }
    mouse = {
        x = 0,
        y = 0
    }

    camera = Camera(world.x, world.y)
    love.graphics.setDefaultFilter('nearest', 'nearest')
    canvas = love.graphics.newCanvas(window.x/window.scale, window.y/window.scale)

    active_rooms = {menu()}
end

function love.update(dt)
    camera:update(dt)
    for _, room in ipairs(active_rooms) do
        local terminate = not room:update(dt)
        if terminate then call(room:exit()) end
    end
end

function love.draw()
    camera:attach()
    mouse_pos()
    for _, room in ipairs(active_rooms) do
        if room.uses_canvas then
            love.graphics.setCanvas(canvas)
            love.graphics.clear()
            love.graphics.setLineStyle('rough')
            
            room:draw()
            
            love.graphics.setCanvas()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setBlendMode('alpha', 'premultiplied')
            love.graphics.draw(canvas, 0, 0, 0, window.scale, window.scale )
            love.graphics.setBlendMode('alpha')
        else
            room:draw()
        end
    end
    camera:detach()
    camera:draw()
end

function love.keypressed(key)
    if key == 'escape' then love.event.quit() end
    table.call(active_rooms, function (room)
        call(room.keypressed, room, key)
    end)
end

function love.mousepressed()
    mouse_pos()
    table.call(active_rooms, function (room)
        call(room.mousepressed, room)
    end)
end

function mouse_pos()
    mouse.x, mouse.y = love.mouse.getPosition()
    mouse.x, mouse.y = (mouse.x + (camera.x - camera.w/2)*window.scale)/window.scale, (mouse.y + (camera.y - camera.h/2)*window.scale)/window.scale
end

function add_room(name, i)
    if i == nil then i = #active_rooms + 1 end
    active_rooms[i] = _G[name]
    call(active_rooms[i].enter, active_rooms[i])
end