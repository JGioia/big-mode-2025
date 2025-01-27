function InitializeLevel()
  -- create first level layout
  table.insert(Shapes, InputNode(100, 100))
  table.insert(Shapes, OutputNode(300, 100))
  print(#Shapes)
end

function DrawNode(isOn, x, y)
  if isOn then
    COLOR_WIRE_ON:activate()
  else
    COLOR_WIRE_OFF:activate()
  end
  love.graphics.circle("fill", x, y, NODE_RADIUS)
  COLOR_FOREGROUND:activate()
  love.graphics.setLineWidth(NODE_OUTLINE_WIDTH)
  love.graphics.circle("line", x, y, NODE_RADIUS)
end