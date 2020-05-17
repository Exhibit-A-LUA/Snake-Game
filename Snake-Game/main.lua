-- ensure print function happens immediately
io.stdout:setvbuf("no")

require('game')

paused = false
godMode = false
silent = false
shoot = false
shooting = false
crosshairs = false
autoSnake = false
grid = true
debugSnake = false
gameOver = false
finished = false
gameState = "Options" -- "Options", "Restart", "Play", "Lost", "Won", "Next"

function love.load()
  
  love.window.setPosition(500,50,1)
  
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 16)
  love.graphics.setFont(mainFont)
  
  headImage = love.graphics.newImage("Images/snake_head_final.png")
  headTurnImage_UR_RD_DL_LU = love.graphics.newImage("Images/snake_head_turn01.png")
  headTurnImage_UL_LD_DR_RU = love.graphics.newImage("Images/snake_head_turn02.png")
  faceImage = love.graphics.newImage("Images/snake_grin.png")
  cashImage = love.graphics.newImage("Images/Cash100x100.png")
  beerImage = love.graphics.newImage("Images/Beer150x170.png")
  bodyImage = love.graphics.newImage("Images/snake_body_full.png")
  tailImage = love.graphics.newImage("Images/snake_tail_keya.png")
  bodyTurnImage = love.graphics.newImage("Images/snake_body_turn.png")
  appleImage = love.graphics.newImage("Images/Apple100x100.png")
  multiAppleImage = love.graphics.newImage("Images/AppleTree120x120.png")
  bombImage = love.graphics.newImage("Images/bomb120x120.png")
  explosionImage = love.graphics.newImage("Images/explosion.png")
  option01 = love.graphics.newImage("Options/Level01.JPG")
  option02 = love.graphics.newImage("Options/Level02.JPG")
  option03 = love.graphics.newImage("Options/Level03.JPG")
  option04 = love.graphics.newImage("Options/Level04.JPG")
  option05 = love.graphics.newImage("Options/Level05.JPG") 
  option06 = love.graphics.newImage("Options/Level06.JPG")
  option07 = love.graphics.newImage("Options/Level07.JPG")
  option08 = love.graphics.newImage("Options/Level08.JPG")
  option09 = love.graphics.newImage("Options/Level09.JPG")
  option10 = love.graphics.newImage("Options/Level10.JPG")
  option11 = love.graphics.newImage("Options/Level11.JPG")
  appleImg = love.graphics.newImage("Options/Apple.JPG")
  multiImg = love.graphics.newImage("Options/Multi.JPG")
  bombImg = love.graphics.newImage("Options/Bomb.JPG")
end

function love.draw()
  if gameState == "Play" or gameState == "Won" or gameState == "Lost" then gameDraw()
  elseif gameState == "Options" then optionDraw()
  elseif gameState == "Restart" then 
    gameState = "Options"
    startGame()
--  elseif gameState == "Lost" then
  elseif gameState == "Next" then 
    gameState = "Options"
    level = level + 1 
    if level <= maxChoices then
      startGame()
    else
      level = 1
    end
  end
end

function love.update(dt)
  if gameState == "Play" then
    if paused then return end
    interval = interval - 1
    if interval < 0 then 
      gameUpdate(dt) 
      interval = myInterval
    end
  end
  if gameState == "Options" then optionUpdate()  end
end

function pausePressed()
  if gameState == "Play" then
    if paused then
      pauseEnd = os.time()
      pauseTime = pauseTime + os.difftime(pauseEnd - pauseStart) -- do this when press 'n'
    else
      pauseStart = os.time() -- do this if won game
    end
    paused = not paused
  end
end

function startGame()
  if gameState == "Options" then 
    myGameSize = 800
    if level == 1 then SIZE = 120
    elseif level == 2 then SIZE = 100
    elseif level == 3 then SIZE = 80
    elseif level == 4 then SIZE = 60
    elseif level == 5 then SIZE = 50 
    elseif level == 6 then SIZE = 40 
    elseif level == 7 then SIZE = 30
    elseif level == 8 then SIZE = 20
    elseif level == 9 then SIZE = 15
    elseif level == 10 then SIZE = 10
    elseif level == 11 then SIZE = 5 -- useGraphics = false
    end
    gameState = "Play" 
    myInterval = 20
    autoSnake = false
    interval = myInterval
    setBoard()
    addApples(1)
  end
end

function changeSpeed(change)
  if gameState == "Play" then myInterval = myInterval + change end
end

function moveCursor(direction)
  if gameState == "Play" then
    if direction == 'left'      then left, right, up, down = true, false, false, false
    elseif direction == 'right' then left, right, up, down = false, true, false, false
    elseif direction == 'up'    then left, right, up, down = false, false, true, false
    elseif direction == 'down'  then left, right, up, down = false, false, false, true
  end
  elseif gameState == "Options" then
    if direction == 'up' then up, down = true, false
    elseif direction == 'down' then up, down = false, true
    end
  end
end

function love.keypressed(key)
  gameStarted = true
  if key == 'return' then startGame()
  elseif key == 'space'  then shoot = true --- NOT IMPLEMENTED YET
  elseif key == 'a'      then autoSnakeToggle()
  elseif key == 'r'      then restartLevel()
  elseif key == 'n'      then nextLevel()
  elseif key == 'o'      then optionsMenu()
  elseif key == 'kp+'    then changeSpeed(-1)
  elseif key == 'kp-'    then changeSpeed(1)
  elseif key == 'g'      then useGraphics = not useGraphics
  elseif key == 'c'      then crosshairs = not crosshairs
  elseif key == 'x'      then grid = not grid
  elseif key == '1'      then godMode = not godMode
  elseif key == 's'      then silent = not silent
  elseif key == 'd'      then debugSnake = not debugSnake
  elseif key == 'left'   then moveCursor('left')
  elseif key == 'right'  then moveCursor('right')
  elseif key == 'up'     then moveCursor('up')
  elseif key == 'down'   then moveCursor('down')
  elseif key == 'p'      then pausePressed()
  elseif key == 'escape' then escapeKeyPressed()
  end
end