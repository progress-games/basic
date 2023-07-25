Canvases = Object:extend()

function Canvases:new(presets)
    self.presets = presets
    self.current = graphics.newCanvas(unpack(self.presets))
end

function Canvases:set()
    love.graphics.setCanvas(self.current)
    love.graphics.clear()
    love.graphics.setLineStyle('rough')
end

function Canvases:draw()
    love.graphics.setCanvas()
    colours.white:set()
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.current, 0, 0, 0, window.scale, window.scale)
    love.graphics.setBlendMode('alpha')
end

function Canvases:another()
    self.current = graphics.newCanvas(unpack(self.presets))
    self:set()
end