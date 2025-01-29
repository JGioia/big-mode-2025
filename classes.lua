-- start Color def
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
-- end Color def


-- start Sound def
Sound = Object:extend()

function Sound:new(filepath, sourceType)
  self.sources = {love.audio.newSource(filepath, sourceType)}
end

function Sound:play()
  -- Try to find a stopped Source in our list, and play it if we find one.
  for _, source in ipairs(self.sources) do
    if not source:isPlaying() then
        source:play()
        return
    end
  end

  -- If there are no stopped Sources, create a new one and add it to the list.
  local source = self.sources[1]:clone()
  table.insert(self.sources, source)
  source:setLooping(false)
  source:play()
end
-- end Sound def


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
  if self.isOn then
    COLOR_WIRE_ON:activate()
  else
    COLOR_WIRE_OFF:activate()
  end
  love.graphics.circle("fill", self.x, self.y, NODE_RADIUS)
  COLOR_FOREGROUND:activate()
  love.graphics.setLineWidth(NODE_OUTLINE_WIDTH)
  love.graphics.circle("line", self.x, self.y, NODE_RADIUS)
end

function Node:hitsHitbox(x, y)
  return x >= self.x - NODE_RADIUS and
    x <= self.x + NODE_RADIUS and
    y >= self.y - NODE_RADIUS and
    y <= self.y + NODE_RADIUS
end

function Node:onMousePress(x, y)
  if self:hitsHitbox(x, y) then
    if #self.wiresOut < self.numMaxWiresOut then
      table.insert(self.wiresOut, Wire(self))
      return true
    else
      CopyListAndDelete(self.wiresOut)
      table.insert(self.wiresOut, Wire(self))
    end
  end
end

function Node:delete()
  CopyListAndDelete(self.wiresOut)
  CopyListAndDelete(self.wiresIn)
  self.super.delete(self)
end
--end Node def


-- start InputNode def
InputNode = Node:extend()

function InputNode:new(x, y, ticksPerChange, tickOffset)
  self.ticksPerChange = ticksPerChange
  self.tickOffset = tickOffset
  self.super.new(self, x, y, true, 1, 0)
end

function InputNode:update()
  if (TickNum + self.tickOffset) % self.ticksPerChange == 0 then
    self.isOn = not self.isOn
  end
end
-- end InputNode def


-- start OutputNode def
OutputNode = Node:extend()

function OutputNode:new(x, y, sound)
  self.sound = sound
  self.super.new(self, x, y, false, 0, 1)
end

function OutputNode:update()
  local prevIsOnVal = self.isOn
  self.isOn = #self.wiresIn > 0 and self.wiresIn[1].startNode.isOn
  if (self.isOn and not prevIsOnVal) then
    self.sound:play()
  end
end
-- end OutputNode def


-- start InverseNode def
InverseNode = Node:extend()

function InverseNode:new(x, y)
  self.super.new(self, x, y, false, 1, 1)
end

function InverseNode:update()
  self.isOn = #self.wiresIn > 0 and not self.wiresIn[1].startNode.isOn
end
-- end InverseNode def


-- start SplitterNode def
SplitterNode = Node:extend()

function SplitterNode:new(x, y)
  self.super.new(self, x, y, false, 2, 1)
end

function SplitterNode:update()
  self.isOn = #self.wiresIn > 0 and self.wiresIn[1].startNode.isOn
end
-- end SplitterNode def


-- start DelayNode def
DelayNode = Node:extend()

function DelayNode:new(x, y, ticksToDelay)
  -- Assuming ticksToDelay >= 1
  self.futureIsOn = {}
  for _ = 1, ticksToDelay do
    table.insert(self.futureIsOn, false);
  end
  self.super.new(self, x, y, false, 1, 1)
end

function DelayNode:update()
  self.isOn = self.futureIsOn[1]
  for i = 1, #self.futureIsOn - 1 do
    self.futureIsOn[i] = self.futureIsOn[i + 1]
  end
  self.futureIsOn[#self.futureIsOn] = #self.wiresIn > 0 and self.wiresIn[1].startNode.isOn
end
-- end DelayNode def


-- start AndNode def
AndNode = Node:extend()

function AndNode:new(x, y)
  self.super.new(self, x, y, false, 1, 2)
end

function AndNode:update()
  self.isOn = #self.wiresIn >= 2 and self.wiresIn[1].startNode.isOn and self.wiresIn[2].startNode.isOn
end
-- end AndNode def


-- start OrNode def
OrNode = Node:extend()

function OrNode:new(x, y)
  self.super.new(self, x, y, false, 1, 2)
end

function OrNode:update()
  self.isOn = (#self.wiresIn >= 1 and self.wiresIn[1].startNode.isOn) or 
              (#self.wiresIn >= 2 and self.wiresIn[2].startNode.isOn)
end
-- end OrNode def


-- start OrNode def
XorNode = Node:extend()

function XorNode:new(x, y)
  self.super.new(self, x, y, false, 1, 2)
end

function XorNode:update()
  local wire1IsOn = #self.wiresIn >= 1 and self.wiresIn[1].startNode.isOn
  local wire2IsOn = #self.wiresIn >= 2 and self.wiresIn[2].startNode.isOn
  self.isOn = Xor(wire1IsOn, wire2IsOn)
end
-- end OrNode def


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
      if Shapes[i]:hitsHitbox(x, y) and 
          #Shapes[i].wiresIn < Shapes[i].numMaxWiresIn then
        self.stopNode = Shapes[i]
        table.insert(Shapes[i].wiresIn, self)
        return true
      end
    end
    self:delete()
    return true
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