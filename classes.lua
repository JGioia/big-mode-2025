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
  table.insert(Shapes, self)
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

function Shape:delete()
  table.removeKey(Shapes, self)
end
-- end Shape def


-- start Node def
Node = Shape:extend()

function Node:new(x, y, isOn, numMaxWiresOut, numMaxWiresIn)
  self.x = x
  self.y = y
  self.isOn = isOn
  self.numMaxWiresOut = numMaxWiresOut
  self.numMaxWiresIn = numMaxWiresIn
  self.wiresOut = {}
  self.wiresIn = {}
  -- Note: I have no clue why this is necessary for this class and
  -- not for Wire. Shape:extend should automatically set super to Shape
  self.super = Shape
  self.super.new(self)
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

function Node:onMousePress(x, y)
  if self:hitsHitbox(x, y) and #self.wiresOut < self.numMaxWiresOut then
    table.insert(self.wiresOut, Wire(self))
    return true
  end
end

function Node:delete()
  local wiresOutCopy = table.copy(self.wiresOut)
  for i = 1, #wiresOutCopy do
    wiresOutCopy[i]:delete()
  end
  local wiresInCopy = table.copy(self.wiresIn)
  for i = 1, #wiresInCopy do
    wiresInCopy[i]:delete()
  end
  self.super.delete(self)
end
--end Node def


-- start InputNode def
InputNode = Node:extend()

function InputNode:new(x, y)
  self.super.new(self, x, y, true, 1, 0)
end
-- end InputNode def


-- start OutputNode def
OutputNode = Node:extend()

function OutputNode:new(x, y)
  self.super.new(self, x, y, false, 0, 1)
end

function OutputNode:draw()
  DrawNode(#self.wiresIn > 0 and self.wiresIn[1].startNode.isOn, self.x, self.y)
end
-- end OutputNode def


-- start Wire def
Wire = Shape:extend()

function Wire:new(startNode)
  self.startNode = startNode
  self.stopNode = nil
  self.super.new(self)
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
  if self.stopNode == nil then
    for i = #Shapes, 1, -1 do
      if Shapes[i]:is(OutputNode) and 
          Shapes[i]:hitsHitbox(x, y) and 
          #Shapes[i].wiresIn < Shapes[i].numMaxWiresIn then
        self.stopNode = Shapes[i]
        table.insert(Shapes[i].wiresIn, self)
        return true
      end
    end
    self:delete()
  end
end

function Wire:delete()
  table.removeKey(self.startNode.wiresOut, self)
  if self.stopNode then
    table.removeKey(self.stopNode.wiresIn, self)
  end
  self.super.delete(self)
end
-- end Wire def