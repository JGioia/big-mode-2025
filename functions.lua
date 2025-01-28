function InitializeLevel()
  -- create first level layout
  InputNode(100, 100, 10, 0)
  OutputNode(300, 100, C_NOTE)
  OutputNode(300, 200, G_NOTE)
  OutputNode(300, 300, E_NOTE)
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

function CopyListAndDelete(shapesList)
  local shapesCopy = table.copy(shapesList)
  for i = 1, #shapesCopy do
    shapesCopy[i]:delete()
  end
end