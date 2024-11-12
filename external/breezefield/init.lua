-- breezefield: init.lua
--[[
   implements Collider and World objects
   Collider wraps the basic functionality of shape, fixture, and body
   World wraps world, and provides automatic drawing simplified collisions
]]--



BF = {}


local Collider = require(... ..'/collider')
local World = require(... ..'/world')


function BF.newWorld(...)
   return BF.World:new(...)
end

BF.Collider = Collider
BF.World = World
