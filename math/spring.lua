-- A Spring class. This is extremely useful for juicing things up. (src a327ex)
-- See this article https://github.com/a327ex/blog/issues/60 for more details.
-- The argument passed in are: the initial value of the spring, its stiffness and damping.
Spring = Object:extend()
function Spring:new(x, k, d)
  self.x = x or 0
  self.k = k or 100
  self.d = d or 10
  self.target_x = self.x
  self.v = 0
end


function Spring:update(dt)
  dt = math.min(dt, 1/20)
  local a = -self.k*(self.x - self.target_x) - self.d*self.v
  self.v = self.v + a*dt
  self.x = self.x + self.v*dt, self.cap
end


-- Pull the spring with a certain amount of force. This force should be related to the initial value you set to the spring.
function Spring:pull(f, k, d)
  if not f then return end
  if k then self.k = k end
  if d then self.d = d end
  self.x = self.x + f
end


-- Animates the spring such that it reaches the target value in a smoothy springy motion.
-- Unlike pull, which tugs on the spring so that it bounces around the anchor, this changes that anchor itself.
function Spring:animate(x, k, d)
  if not x then return end
  if k then self.k = k end
  if d then self.d = d end
  self.target_x = x
  self.cap = self.target_x * 2
end