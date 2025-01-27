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
  self.isOn = isOn
end

function Node:draw()
  DrawNode(self.isOn, self.x, self.y)
end

function Node:hitsHitbox(x, y)
  return x >= self.x - NODE_RADIUS and
    x <= self.x + NODE_RADIUS and
    y >= self.y - NODE_RADIUS and
    y <= self.y + NODE_RADIUS
end
--end Node def


-- start InputNode def
InputNode = Node:extend()

function InputNode:new(x, y)
  self.super.new(self, x, y, true)
end

function InputNode:onMousePress(x, y)
  if self:hitsHitbox(x, y) then
    table.insert(Shapes, Wire(self))
    return true
  end
end
-- end InputNode def


-- start OutputNode def
OutputNode = Node:extend()

function OutputNode:new(x, y)
  self.super.new(self, x, y, false)
  self.parentNode = nil
end

function OutputNode:draw()
  DrawNode(self.parentNode and self.parentNode.isOn, self.x, self.y)
end
-- end OutputNode def


-- start Wire def
Wire = Shape:extend()

function Wire:new(startNode)
  self.startNode = startNode
  self.stopNode = nil
end

function Wire:draw()
  if (self.startNode.isOn) then
    COLOR_WIRE_ON:activate()
  else
    COLOR_WIRE_OFF:activate()
  end
  local startX = self.startNode.x
  local startY = self.startNode.y
  local stopX, stopY
  if (self.stopNode) then
    stopX = self.stopNode.x
    stopY = self.stopNode.y
  else
    stopX = MouseX
    stopY = MouseY
  end
  love.graphics.setLineWidth(WIRE_WIDTH)
  love.graphics.line(startX, startY, stopX, stopY)
end

function Wire:onMousePress(x, y)
  for i = #Shapes, 1, -1 do
    if Shapes[i]:is(OutputNode) and Shapes[i]:hitsHitbox(x, y) then
      self.stopNode = Shapes[i]
      Shapes[i].parentNode = self.startNode
    end
  end
end
-- end Wire def