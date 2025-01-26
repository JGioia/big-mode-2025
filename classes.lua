-- start color def
Color = Object:extend()

function Color:new(hex_string, alpha)
  -- hex_string example input is '#FFFFFF'
  self.r = tonumber(string.sub(hex_string, 2, 3), 16) / 255
  self.g = tonumber(string.sub(hex_string, 4, 5), 16) / 255
  self.b = tonumber(string.sub(hex_string, 6, 7), 16) / 255
  self.alpha = (alpha == nil and 1) or alpha
end

function Color:activate()
  love.graphics.setColor(self.r, self.g, self.b, self.alpha)
end

function Color:activateAsBackground()
  love.graphics.setBackgroundColor(self.r, self.g, self.b, self.alpha)
end
-- end color def


-- start Shape def
Shape = Object:extend()

function Shape:new()
  -- to implement in child classes
end

function Shape:update(dt)
  -- to implement in child classes
end

function Shape:draw()
  -- to implement in child classes
end

function Shape:hitsHitbox(x, y)
  -- to implement in child classes
  return false
end

function Shape:onMousePress(x, y)
  -- to implement in child classes
  -- returns whether to prevent further mouse press actions from being processed
  return false
end
-- end Shape def


-- start Node def
Node = Shape:extend()

function Node:new(x, y, isOn)
  self.x = x
  self.y = y
  self.radius = NODE_RADIUS
  self.isOn = isOn
end

function Node:draw()
  if self.isOn then
    COLOR_WIRE_ON:activate()
  else
    COLOR_WIRE_OFF:activate()
  end
  love.graphics.circle("fill", self.x, self.y, self.radius)
  COLOR_FOREGROUND:activate()
  love.graphics.circle("line", self.x, self.y, self.radius)
end

function Node:hitsHitbox(x, y)
  return x >= self.x - self.radius and
    x <= self.x + self.radius and
    y >= self.y - self.radius and
    y <= self.y + self.radius
end
--end Node def


-- start InputNode def
InputNode = Node:extend()

function InputNode:new(x, y)
  -- I spent like 40 minutes debugging these 4 lines of code
  -- For some reason self.super:new(x, y, true) does not work.
  -- It sets all instances of Node to have the same values and i don't
  -- understand why. I think it has something to do with metatables
  -- but i feel like im going crazy
  self.x = x
  self.y = y
  self.radius = NODE_RADIUS
  self.isOn = true
end

function InputNode:onMousePress(x, y)
  if self:hitsHitbox(x, y) then
    self.isOn = not self.isOn
    return true
  end
end
-- end InputNode def


-- start OutputNode def
OutputNode = Node:extend()

function OutputNode:new(x, y)
  self.x = x
  self.y = y
  self.radius = NODE_RADIUS
  self.isOn = false
end
-- end OutputNode def