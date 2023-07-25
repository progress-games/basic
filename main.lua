require 'libs.misc'
Object = require 'libs.classic'
Camera = require 'libs.Camera'
Timer = require 'libs.Timer'
require 'objects.particles'
require 'objects.text'
require 'objects.colour'
require 'objects.canvases'
graphics = love.graphics

require 'menu'

colours = {
    black = colour(0, 0, 0),
    white = colour(1, 1, 1),
    red = colour(1, 0, 0),
    green = colour(0, 1, 0),
    blue = colour(0, 0, 1),
    mum = colour(86, 240, 3),
    yellow = colour(1, 1, 0),
    invis = colour(0, 0, 0, 0),
    transparent = {
        black = colour(0, 0, 0, 0.5)
    }
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
            char.step = 4 + char.i*2
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
    if type(colour) ~= 'table' then
        text_tags[colour] = {
            draw = function ()
                obj:set()
            end
        }
    else
        for name, sub in pairs(obj) do
            text_tags[colour..'-'..name] = {
                draw = function ()
                    sub:set()
                end
            }
        end
    end
end

colours.black.lock = true
colours.white.lock = true

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

    config = {
        language = 'english'
    }

    font = {}
    font.english = {
        main = graphics.newFont(20)
    }
    font.current = graphics.getFont()

    camera = Camera(world.x, world.y)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    canvases = Canvases({window.x/window.scale, window.y/window.scale})

    active_rooms = {arena()}
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
            canvases:set()
            
            room:draw()
            
            canvases:draw()
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

function love.mousemoved()
    mouse_pos()
    table.call(active_rooms, function (room)
        call(room.mousemoved, room)
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