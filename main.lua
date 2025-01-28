function love.load()
  -- this function is called once at the start of the game

  -- global vars (start with a capital letter and can be used in any file)
  Tick = require("libraries.tick")
  Object = require("libraries.classic")
  Shapes = {}
  MouseX = 0
  MouseY = 0
  TickNum = 0

  -- requires
  require("libraries.mylibrary")
  require("classes")
  require("functions")
  require("constants")

  -- procedures to run before the first frame
  COLOR_BACKGROUND:activateAsBackground()
  COLOR_FOREGROUND:activate()
  InitializeLevel()
end

function love.mousepressed(x, y)
  -- this function is called instantly every time a key is pressed
  for i = #Shapes, 1, -1 do
    if Shapes[i]:onMousePress(x, y) then
      break
    end
  end
end

function love.mousemoved(x, y)
  MouseX = x
  MouseY = y
end

function love.update(dt)
  -- this function is called once per tick before love.draw
  -- dt is delta time in seconds
  Tick.update(dt)
  TickNum = TickNum + 1
  for i = 1, #Shapes do
    Shapes[i]:update(dt)
  end
end

function love.draw()
  -- this function is called once per tick after love.draw
  for i=1,#Shapes do
    Shapes[i]:draw()
  end
end