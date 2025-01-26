function InitializeLevel()
  -- create first level layout
  table.insert(Shapes, InputNode(100, 100))
  table.insert(Shapes, OutputNode(300, 100))
  print(#Shapes)
end
