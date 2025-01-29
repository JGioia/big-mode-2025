function InitializeLevel()
  -- create first level layout
  InputNode(100, 100, 10, 0)
  InverseNode(300, 100)
  SplitterNode(300, 200)
  DelayNode(300, 300, 6)
  AndNode(500, 100)
  OrNode(500, 200)
  XorNode(500, 300)
  OutputNode(700, 100, C_NOTE)
  OutputNode(700, 200, G_NOTE)
  OutputNode(700, 300, E_NOTE)
end

function CopyListAndDelete(shapesList)
  local shapesCopy = table.copy(shapesList)
  for i = 1, #shapesCopy do
    shapesCopy[i]:delete()
  end
  shapesList = {}
end