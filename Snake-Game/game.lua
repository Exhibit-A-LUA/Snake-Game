-- Work Left
-- Graphics
--    exploding apples
--    snake head and body and tail and turn segments, apples, bombs
-- Redo num of replays when dead/win based on taillength
-- redo speed stuff

------------------------ You can change these four ------------------------------------
myGameSize = 800 --defaultWindowSize (set to 350 to debug tail) 450 and 15 is fun Beat 400 20
SIZE = 10 -- Determines how big snake and apple is (40 is a good size)
-- won 200, 20  250, 20
-- won 300, 20  300, 30
-- won 350, 20  350, 30
-- won 400, 20  400, 25, 400, 30
-- won 800, 40
-- Challenge 800, 10


-- LEVELS --
--
-- Beginner
-- 01 800 120 
-- 02 800 100
-- 03 800 80
-- 04 800 60
-- ?? 05 800 50
-- 05 800 40
-- 06 800 30
-- 07 800 20
-- 08 800 15
-- 09 800 10
-- 10 800 5 - Insane
--



useGraphics = true -- Press '1' to toggle
local useMultiApples = true
---------------------------------------------------------------------------------------

local defaultWindowSize = 900 -- DO NOT CHANGE

score = 0

local boardSize = math.floor(defaultWindowSize/SIZE) -- board width and height in snake heads
local xyOffset = (defaultWindowSize - (SIZE * boardSize))/2 -- distance in pixels from left corner to draw gameboard

-- NEED TO REWRITE ALL OF THE SPEED STUFF
local speedIncrease = 8 -- how often the speed increases - smaller = faster
local FASTEST = 13 -- was 13 default smallest delay
local SLOWEST = 20 -- default largest delay

local lives = 5
local won = false
local usedGodMode = false

local appleNear = boardSize / 3 -- distance from apples is getting this small

local tryNewCode = true -- New code to find next apple position - IT WORKS

local dirX = 0 -- used to move snake
local dirY = 0 -- used to move sname

local snakeX = 0 -- snake's position
local snakeY = 0 -- snake's position

local bulletDirX = 0 -- used to move bullet
local bulletDirY = 0 -- used to move bullet
local bulletX = 0 -- bullet's position
local bulletY = 0 -- bullet's position

-- multi apple area
local multiAppleStartX = 0 
local multiAppleStartY = 0 
local multiAppleEndX = 0 
local multiAppleEndY = 0 
local oneMultiAppleAdded = false -- true when already added one multi apple 

local numApples = 0
local apples = {}
local onApplePosition = 0

local numBombs = 0 
local bombs = {} 
local onBombPosition = 0
local applesToExplode = 0
local saveApplesToExplode = 0
local applesToRemove = 0

local tailLength = 0
local saveTailLength = 0
local tailCorners = {}
local thisCorner = {{0,0},{0,0},{0,0}}
local tail = {}
local percentDone = 100*(tailLength+2)/(boardSize*boardSize)

local GAME_WON = 2 -- number of free spaces left to win game
local spacesLeft = (boardSize * boardSize) - tailLength -- number of free spaces left
local oldX = 0 -- snake position saved before move
local oldY = 0 -- snake tail position saved before move


-- IMAGE STUFF
lastTailX, lastTailY = 0,0


-- Replay Stuff
TOTAL_REPLAYS = 5
numReplays = TOTAL_REPLAYS
replayCount = 0
replay = {}
local replayDone = false
replayMoves = 0
local lastSnakeX, lestSnakeY = -1

up = false
down = false
left = false
right = false

lastUp = false
lastDown = false
lastLeft = false
lastRight = false

saveInterval = 0

start_time = os.time()
pauseStart = 0
pauseEnd = 0
pauseTime = 0
gameStarted = false
already_started = false

level = 1 --For Menu at start
maxChoices = 11


addAppleSound = love.audio.newSource("Sounds/button-09.mp3", "static") -- Add Apple Sound
addAppleSound:setVolume(0.2)
onAppleSound = love.audio.newSource("Sounds/button-35.mp3", "static") -- On Apple Sound
onAppleSound:setVolume(0.2)
onBombSound = love.audio.newSource("Sounds/button-14.mp3", "static") -- On Apple Sound
onBombSound:setVolume(0.2)
movingSound1 = love.audio.newSource("Sounds/button-34.mp3", "static") -- Moving Sound
movingSound1:setVolume(0.2)
movingSound2 = love.audio.newSource("Sounds/button-44.mp3", "static") -- Moving Sound
movingSound2:setVolume(0.2)
onTailSound = love.audio.newSource("Sounds/button-11.mp3", "static") -- Ran Over Tail
onTailSound:setVolume(0.2)
hitEdgeSound = love.audio.newSource("Sounds/button-37.mp3", "static") -- Ran Over Tail
hitEdgeSound:setVolume(0.2)
heartbeatSound = love.audio.newSource("Sounds/heartbeat-speeding-up-02.mp3", "static")
heartbeatSound:setVolume(0.2)
popSound = love.audio.newSource("Sounds/PopSound.mp3", "static")
--heartbeatSound:setVolume(0.2)

-- colour definitions
local white     = {1.0, 1.0, 1.0, 1.0}
local black     = {0.0, 0.0, 0.0, 1.0}

local red       = {1.0, 0.0, 0.0, 1.0}
local green     = {0.0, 1.0, 0.0, 1.0}
local blue      = {0.0, 0.0, 1.0, 1.0}

local red100    = {1.0, 0.0, 0.0, 1.0}
local red090    = {0.9, 0.0, 0.0, 1.0}
local red080    = {0.8, 0.0, 0.0, 1.0}
local red070    = {0.7, 0.0, 0.0, 1.0}
local red060    = {0.6, 0.0, 0.0, 1.0}
local red050    = {0.5, 0.0, 0.0, 1.0}
local red040    = {0.4, 0.0, 0.0, 1.0}
local red030    = {0.3, 0.0, 0.0, 1.0}
local red020    = {0.2, 0.0, 0.0, 1.0}
local red010    = {0.1, 0.0, 0.0, 1.0}


local pink      = {1.0, 0.0, 1.0, 1.0}
local yellow    = {1.0, 1.0, 0.0, 1.0}
local aqua      = {0.0, 1.0, 1.0, 1.0}
local purple    = {0.5, 0.0, 0.5, 1.0}
local gold      = {1.0, 1.0, 0.4, 1.0}
local apple     = {0.8, 0.9, 0.0, 1.0}
local darkgreen = {0.0, 0.6, 0.0, 1.0}
local asphalt   = {0.3, 0.3, 0.3, 1.0}
local turfgreen = {0.3, 0.4, 0.3, 1.0}
local nightsky  = {0.3, 0.3, 0.4, 1.0}
local snakeHead = {1.0, 0.35, 0.4, 1.0}


function SetMyColour(colour)
  love.graphics.setColor(unpack(colour))
end


-- Determines if the apple is close to the snake head
function appleClose()
  near = false
  for _, v in ipairs(apples) do
    if (math.abs(v[1] - snakeX) < appleNear) and (math.abs(v[2] - snakeY) < appleNear) then
      return true
    end
  end
  return near
end


-- Determines if position x y is on the snakes tail
function onTail(x,y)
  local ok = false
  if tailLength > 0 then
    -- if debugSnake then debugWriteTail() end
    for _, v in ipairs(tail) do
      if x == v[1] and y == v[2] then
        if not silent then onTailSound:play() end
        return true
      end
    end
  else
    ok = false
  end
  return ok
end

-- is position x,y on an apple
function onApple(x, y) -- return position of apple or 0 if no apple here
  for pos, v in ipairs(apples) do
    if x == v[1] and y == v[2] then
      return pos
    end
  end
  return 0
end

-- is position x,y on a bomb
function onBomb(x, y) -- return position of bomb or 0 if no apple here
  for pos, v in ipairs(bombs) do
    if x == v[1] and y == v[2] then
      return pos
    end
  end
  return 0
end

-- Determines if position x y is not being used
-- Only used in addApples so should be no apples and no bombs only snake (head and tail)
-- and maybe previous head
function free(x, y)
  if not(oldX == x and oldY == y) then
    if onApple(x, y) == 0 then --                  don't need??????????
      if onBomb(x, y) == 0 then --                 don't need??????????
        if not(snakeX == x and snakeY == y) then 
          if tailLength > 0 then
            for _, v in ipairs(tail) do
              if x == v[1] and y == v[2] then
                --src1:play()
                return false -- on tail
              end
            end
            return true
          else
            return true
          end
        else
          return false
        end
      else
        return false
      end
    else
      return false
    end
  else
    return false
  end
end

-- DEBUG function - Tested and works
function drawFreeSpaces()
  SetMyColour(white)
  love.graphics.rectangle('fill', 0, 0, boardSize*SIZE, boardSize*SIZE)
  SetMyColour(red)
  for _, v in ipairs(freeSpaces) do
    love.graphics.rectangle('fill', v[1]*SIZE, v[2]*SIZE, SIZE, SIZE, 10, 10)
  end
  --paused = true
end

-- Pick a random position from a list of free spaces add a new bomb
function addBomb()
  bombPosition = math.random(1,#freeSpaces) 
  table.insert(bombs, {freeSpaces[bombPosition][1],freeSpaces[bombPosition][2]})
  table.remove(freeSpaces,newBombPosition) --- DOES THIS FIX BUG with numapples and numbombs
  numBombs = numBombs + 1
end

-- Pick a random position from a list of free spaces add a new apple
function newApple()
  if not silent then addAppleSound:play() end
  newApplePosition = math.random(1,#freeSpaces) 
  table.insert(apples, {freeSpaces[newApplePosition][1],freeSpaces[newApplePosition][2]})
  table.remove(freeSpaces,newApplePosition) --- DOES THIS FIX BUG with numapples and numbombs
  numApples = numApples + 1
end

-- Add apples on screen
function addApples(count) 
  freeSpaces = {}
  for i = 0, boardSize - 1 do
    for j = 0, boardSize - 1 do
      if free(i,j) then
        table.insert(freeSpaces, {i,j})
      end
    end
  end
  if count > 1 then
    for i = 1, math.floor(count * 0.95) do
      newApple()
    end
    for i = 1, count - math.floor(count * 0.95) do 
      addBomb() 
    end
  else
    newApple()
  end
end


function centerPrint(words, width, line)
  love.graphics.print(words, (width-mainFont:getWidth(words))/2, line)
end
 
-- Game is over -- draw the scores
function drawScore()
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 150)
  love.graphics.setFont(mainFont)
  SetMyColour(red)
  if won then
    gameState = "Won"
    centerPrint('Winner!!',defaultWindowSize,50)
    mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 28)
    love.graphics.setFont(mainFont)
    SetMyColour(blue)
    centerPrint("Press 'r' to Restart Level, 'n' for Next Level, 'o' for Options Menu",defaultWindowSize,780)
  else
    gameState = "Lost"
    centerPrint('You Lost!!',defaultWindowSize,50)
    mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 28)
    love.graphics.setFont(mainFont)
    SetMyColour(blue)
    centerPrint("Press 'r' to Restart Level, 'o' for Options Menu",defaultWindowSize,780)
  end
-- Write the score (0 if you used god mode)    
  if usedGodMode then tailLength = 0 score = 0 end
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 100)
  love.graphics.setFont(mainFont)
  SetMyColour(green)
  centerPrint('Score '..string.format("%3s",score),defaultWindowSize,650)
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 16)
  love.graphics.setFont(mainFont)
  SetMyColour(white)
end

function findCorners()
  tailCorners = {}
  local tailXChanges = {}
  prevTailX = snakeX
  for i, v in ipairs(tail) do
    table.insert(tailXChanges, v[1] == prevTailX)
    prevTailX = v[1]
  end  
  for i = 1, #tailXChanges do
    if i == #tailXChanges then table.insert(tailCorners, false) 
    else 
      table.insert(tailCorners,(tailXChanges[i] and not tailXChanges[i+1]) or 
                               (not tailXChanges[i] and tailXChanges[i+1]))
    end
  end
end

--Draw the snake's tail
function drawTail()
  local alpha = 1
  findCorners()
  for i, v in ipairs(tail) do
    if i == tailLength - 1 then
      if useGraphics and not finished then
        drawTailPic(xyOffset+v[1]*SIZE, xyOffset+v[2]*SIZE,i,tailCorners[i],false)
        lastTailX = xyOffset+v[1]*SIZE
        lastTailY = xyOffset+v[2]*SIZE
      else
        love.graphics.setColor(darkgreen)
        love.graphics.rectangle('fill', xyOffset+v[1]*SIZE, xyOffset+v[2]*SIZE, SIZE, SIZE, 10, 10) 
      end
    elseif i == tailLength then
      if useGraphics and not finished then
        if i == 1 then -- if 1st segment ie only tip of tail
          lastTailX = xyOffset+snakeX*SIZE
          lastTailY = xyOffset+snakeY*SIZE
        end
        drawTailPic(xyOffset+v[1]*SIZE, xyOffset+v[2]*SIZE,i,tailCorners[i],true)
        lastTailX = xyOffset+v[1]*SIZE
        lastTailY = xyOffset+v[2]*SIZE
      else
        love.graphics.setColor(green)
        love.graphics.rectangle('fill', xyOffset+SIZE/4+v[1]*SIZE, xyOffset+SIZE/4+v[2]*SIZE, SIZE/2, SIZE/2, 10, 10) 
      end
    else
      if useGraphics and not finished then
-- MY GRAPHICS        
        if i == 1 then
          lastTailX = xyOffset+snakeX*SIZE
          lastTailY = xyOffset+snakeY*SIZE
        end
        drawTailPic(xyOffset+v[1]*SIZE, xyOffset+v[2]*SIZE,i,tailCorners[i],false)
        lastTailX = xyOffset+v[1]*SIZE
        lastTailY = xyOffset+v[2]*SIZE
      else
        if finished then
          love.graphics.setColor(0.3, 0.3, 0.3, math.max(0.3, alpha))
        else
          love.graphics.setColor(0.7, 0.35, 0.4, math.max(0.3, alpha))
        end
        love.graphics.rectangle('fill', xyOffset+v[1]*SIZE, xyOffset+v[2]*SIZE, SIZE, SIZE, 15, 15)
      end
    end  
    alpha = alpha - 1 / tailLength
  end
-- Replay snakes last moves by reducing the tail length    
  if finished and not gameOver then 
    tailLength = tailLength - 1; 
    if tailLength < 1 then 
      replayCount = replayCount + 1 
      tailLength = saveTailLength
    end
    if replayCount == numReplays then 
      tailLength = saveTailLength
      gameOver = true 
    end
  end
end

function inMultiArea(x,y)
  return xyOffset+SIZE/4+x*SIZE >= multiAppleStartX and xyOffset+SIZE/4+x*SIZE <= multiAppleEndX and 
         xyOffset+SIZE/4+y*SIZE >= multiAppleStartY and xyOffset+SIZE/4+y*SIZE <= multiAppleEndY
end

function drawBoard()
-- Draw Board border
  
  if percentDone >= 80 then 
    SetMyColour(yellow)
  else 
    if percentDone >= 70 then 
      SetMyColour(green)
    else
      if percentDone >= 60 then 
        SetMyColour(pink)
      else
        if percentDone >= 40 then 
          SetMyColour(red)
        else
          if percentDone >= 20 then 
            SetMyColour(blue)
          else 
            if percentDone >= 10 then 
              SetMyColour(purple) -- was blue
            else
              SetMyColour(white)
            end
          end
        end
      end
    end
  end
  
  love.graphics.setLineWidth(8)
  love.graphics.rectangle('line', xyOffset-2, xyOffset-2, boardSize*SIZE+4, boardSize*SIZE+4)
  love.graphics.setLineWidth(1)

-- Draw Background

-- Set Background Colour
  if percentDone >= 80 then 
    love.graphics.setColor(.5, .5, 1, 1) 
  else 
    if percentDone >= 70 then 
      love.graphics.setColor(.5, .5, .9, 1) 
    else
      if percentDone >= 60 then 
        love.graphics.setColor(.5, .5, .8, 1) 
      else
        if percentDone >= 40 then 
          love.graphics.setColor(.5, .5, .7, 1) 
        else
          if percentDone >= 20 then 
            love.graphics.setColor(.5, .5, .6, 1) 
          else 
            if percentDone >= 10 then 
              love.graphics.setColor(.5, .5, .5, 1)
            else
              love.graphics.setColor(.5, .5, 1, 1) -- Was .5 .5 .4 1
            end
          end
        end
      end
    end
  end
  
-- Draw Background Area
  love.graphics.rectangle('fill', xyOffset, xyOffset, boardSize*SIZE, boardSize*SIZE)

-- Draw Grid
  if grid then
    love.graphics.setColor(1,1,1,0.2)
    for i = 1, boardSize do
      love.graphics.line(xyOffset,xyOffset+(i*SIZE),xyOffset+boardSize*SIZE,xyOffset+(i*SIZE))
      love.graphics.line(xyOffset+(i*SIZE),xyOffset, xyOffset+(i*SIZE),xyOffset+boardSize*SIZE)
    end
    SetMyColour(white)
  end

-- Draw multi apple Area  
  if useMultiApples then
    saveBoardSize = boardSize
    boardSize = boardSize / 2
-- ensure area neatly fits snake and apple    
    if boardSize % 2 > 0 then boardSize = boardSize + 1 end
    xyOffset = (defaultWindowSize - (SIZE * boardSize))/2
    multiAppleStartX = xyOffset
    multiAppleStartY = xyOffset
    multiAppleEndX = xyOffset + boardSize*SIZE
    multiAppleEndY = xyOffset + boardSize*SIZE
    SetMyColour(gold)
    love.graphics.rectangle('line', xyOffset, xyOffset, boardSize*SIZE, boardSize*SIZE)
    boardSize = saveBoardSize 
    xyOffset = (defaultWindowSize - (SIZE * boardSize))/2
  end
end

function drawExplodingApple(x,y)
  SetMyColour(white)
  love.graphics.draw(explosionImage, SIZE/2+xyOffset+x*SIZE, SIZE/2+xyOffset+y*SIZE, 0, 
      SIZE/50, SIZE/50, 50, 50)
end

function drawApples()
  oneMultiAppleAdded = false
  for i, v in ipairs(apples) do 
    if i > applesToExplode then -- TEST LINE
      if useMultiApples and not oneMultiAppleAdded and 
        spacesLeft > 50 and inMultiArea(v[1],v[2]) then
        oneMultiAppleAdded = true
        SetMyColour(white)
        if useGraphics then
          love.graphics.draw(multiAppleImage, SIZE/2+xyOffset+v[1]*SIZE, SIZE/2+xyOffset+v[2]*SIZE, 0, SIZE/100, SIZE/100, 50, 50)
        else
          love.graphics.rectangle('fill', xyOffset+v[1]*SIZE, xyOffset+v[2]*SIZE, SIZE, SIZE, 10, 10)
          SetMyColour(blue)
          love.graphics.rectangle('fill', 
            xyOffset+SIZE/4+v[1]*SIZE, 
            xyOffset+SIZE/4+v[2]*SIZE, SIZE/2, SIZE/2, 10, 10) 
        end
      else
        if useGraphics then
          SetMyColour(white)
          love.graphics.draw(appleImage, SIZE/2+xyOffset+v[1]*SIZE, SIZE/2+xyOffset+v[2]*SIZE, 0, SIZE/100, SIZE/100, 50, 50)
        else
          SetMyColour(apple)
          love.graphics.rectangle('fill', xyOffset+v[1]*SIZE, xyOffset+v[2]*SIZE, SIZE, SIZE, 10, 10)
        end
      end
    else drawExplodingApple(v[1],v[2])
    end
  end
end

function drawBombs()
  for _, v in ipairs(bombs) do 
    if useGraphics then
      SetMyColour(white)
      love.graphics.draw(bombImage, SIZE/2+xyOffset+v[1]*SIZE, SIZE/2+xyOffset+v[2]*SIZE, 0, SIZE/100, SIZE/100, 50, 50)
    else
      SetMyColour(blue)
      love.graphics.rectangle('fill', xyOffset+v[1]*SIZE, xyOffset+v[2]*SIZE, SIZE, SIZE, 10, 10)
      SetMyColour(white)
      love.graphics.rectangle('fill', xyOffset+SIZE/4+v[1]*SIZE, xyOffset+SIZE/4+v[2]*SIZE, SIZE/2, SIZE/2, 10, 10) 
    end
  end
end


function drawTailPic(x,y,pos,corner,tip)
  SetMyColour(white)
-- love.graphics.draw(myImage, x, y, rotate, scaleX, scaleY, offsetX, offsetY)
-- radians = degrees*Pi/180


  rotate = 0
  if corner then
    if pos == 1 then                                  -- right behind head
      prevX, prevY = xyOffset+snakeX*SIZE, xyOffset+snakeY*SIZE
      nextX, nextY = xyOffset+tail[pos+1][1]*SIZE, xyOffset+tail[pos+1][2]*SIZE
    else                                             -- middle of snake
      prevX, prevY = xyOffset+tail[pos-1][1]*SIZE, xyOffset+tail[pos-1][2]*SIZE
      nextX, nextY = xyOffset+tail[pos+1][1]*SIZE, xyOffset+tail[pos+1][2]*SIZE
    end
    if     (x > nextX and y > prevY) or 
           (x > prevX and y > nextY) then rotate = math.rad(180) -- Down/Left or Right/Up
    elseif (x < nextX and y < prevY) or 
           (x < prevX and y < nextY) then rotate =   math.rad(0) -- Up/Right or Left/Down
    elseif (x < nextX and y > prevY) or 
           (x < prevX and y > nextY) then rotate =  math.rad(270) -- Down/Right or Left/UP
    elseif (x > nextX and y < prevY) or 
           (x > prevX and y < nextY) then rotate = math.rad(90) -- Up/Left or Right/Down
    end
  else
    if x < lastTailX  then rotate = math.rad(90) degrees = 90
    elseif x > lastTailX then rotate = math.rad(270) degrees = 270
    elseif y < lastTailY  then rotate = math.rad(180) degrees = 180
    elseif y > lastTailY  then rotate = math.rad(0) degrees = 0
    end
  end
  if pos == 1 then
--    print('Pos is 1 and rotate is '..degrees..
--          '   x,y is'..x..','..y..
--          '  lastTailX, lastTailY is '..lastTailX..','..lastTailY)
  end
  if tip then
    love.graphics.draw(tailImage, SIZE/2+x, SIZE/2+y, rotate, SIZE/100, SIZE/100, 50, 50)
  elseif corner then
    love.graphics.draw(bodyTurnImage, SIZE/2+x, SIZE/2+y, rotate, SIZE/100, SIZE/100, 50, 50)
  else
    love.graphics.draw(bodyImage, SIZE/2+x, SIZE/2+y, rotate, SIZE/100, SIZE/100, 50, 50)
  end
end

function drawCrossHairs()
  if crosshairs then
    love.graphics.setColor(0,0,0,0.2)
    love.graphics.setLineWidth(1)
    love.graphics.line(xyOffset+SIZE/2+snakeX*SIZE,
                       xyOffset+SIZE/2,
                       xyOffset+SIZE/2+snakeX*SIZE,
                       xyOffset+SIZE/2+(boardSize-1)*SIZE)
    love.graphics.line(xyOffset+SIZE/2,
                       xyOffset+SIZE/2+snakeY*SIZE,
                       xyOffset+SIZE/2+(boardSize-1)*SIZE,
                       xyOffset+SIZE/2+snakeY*SIZE)
  end
end

function drawSnakeHeadPic()
  SetMyColour(white)
-- love.graphics.draw(myImage, x, y, rotate, scaleX, scaleY, offsetX, offsetY)
-- radians = degrees*Pi/180
--  love.graphics.draw(explosionImage, 100, 100, 0, .2, .2, 50, 50)
  if up then rotate = math.rad(0)
  elseif right then rotate = math.rad(90)
  elseif down then rotate = math.rad(180)
  elseif left then rotate = math.rad(-90)
  end

  love.graphics.draw(headImage, SIZE/2+xyOffset+snakeX*SIZE, SIZE/2+xyOffset+snakeY*SIZE, rotate, SIZE/100, SIZE/100, 50, 50)


--  if tailLength == 0 then
--    love.graphics.draw(headImage, SIZE/2+xyOffset+snakeX*SIZE, SIZE/2+xyOffset+snakeY*SIZE, rotate, SIZE/100, SIZE/100, 50, 50)
--  elseif snakeX = tail[1][1] and snakeY < tail[1][2] or --
--         snakeX = tail[1][1] and snakeY > tail[1][2] or
--         snakeX > tail[1][1] and snakeY = tail[1][2] or
--         snakeX < tail[1][1] and snakeY = tail[1][2] then
--  love.graphics.draw(headTurnImage_UR_RD_DL_LU, SIZE/2+xyOffset+snakeX*SIZE, SIZE/2+xyOffset+snakeY*SIZE, rotate, SIZE/100, SIZE/100, 50, 50)
--  elseif snakeX = tail[1][1] and snakeY < tail[1][2] or --
--         snakeX = tail[1][1] and snakeY > tail[1][2] or
--         snakeX > tail[1][1] and snakeY = tail[1][2] or
--         snakeX < tail[1][1] and snakeY = tail[1][2] then
--  love.graphics.draw(headTurnImage_UL_LD_DR_RU, SIZE/2+xyOffset+snakeX*SIZE, SIZE/2+xyOffset+snakeY*SIZE, rotate, SIZE/100, SIZE/100, 50, 50)
--  else
--    love.graphics.draw(headImage, SIZE/2+xyOffset+snakeX*SIZE, SIZE/2+xyOffset+snakeY*SIZE, rotate, SIZE/100, SIZE/100, 50, 50)
--  end


--  love.graphics.draw(explosionImage, SIZE/2+xyOffset+snakeX*SIZE, SIZE/2+xyOffset+snakeY*SIZE, rotate, SIZE/100, SIZE/100, 50, 50)
end

function drawSnakeHead()
-- save snake moves - NOT USED
--  if not gameOver and not((snakeX == lastSnakeX) and (snakeY == 0)) then 
--    table.insert(replay, {snakeX,snakeY}) 
--    lastSnakeX = snakeX
--    lastSnakeY = snakeY
--  end
  if useGraphics then
    drawSnakeHeadPic()
  else
    SetMyColour(snakeHead)
    love.graphics.rectangle('fill', xyOffset+snakeX*SIZE, xyOffset+snakeY*SIZE, SIZE, SIZE, 10, 10) -- 15 = more rouded
  end
--  if shooting then 
--    SetMyColour(red)
--    love.graphics.rectangle('fill', bulletX, bulletY, 10, 10, 10, 10)
--    SetMyColour(white)
--  end
end

function drawDebugInfo()
  SetMyColour(green)
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 10)
  xOff = 40
  yOff = 5
  if myGameSize > 680 then
    if snakeY < boardSize/2 then yOff = 740 end
  end
  love.graphics.setFont(mainFont)
  love.graphics.print('Gaps Left: ' .. spacesLeft,   xOff+20, yOff+50, 0, 1.5, 1.5, 0, 0, 0, 0)
  love.graphics.print('Game Size: ' .. myGameSize,   xOff+220, yOff+50, 0, 1.5, 1.5, 0, 0, 0, 0)
  love.graphics.print('Snake Size: ' .. SIZE,        xOff+370, yOff+50, 0, 1.5, 1.5, 0, 0, 0, 0)
  love.graphics.print('Board Size: ' .. boardSize,   xOff+530, yOff+50, 0, 1.5, 1.5, 0, 0, 0, 0)
  love.graphics.print('Offset: ' .. xyOffset,        xOff+700, yOff+50, 0, 1.5, 1.5, 0, 0, 0, 0)
  love.graphics.print('Pause Time: ' .. pauseTime,   xOff+20, yOff+70, 0, 1.5, 1.5, 0, 0, 0, 0)
  love.graphics.print('Num Apples: ' .. numApples,   xOff+220, yOff+70, 0, 1.5, 1.5, 0, 0, 0, 0)
  love.graphics.print('Num Bombs: ' .. numBombs,     xOff+370, yOff+70, 0, 1.5, 1.5, 0, 0, 0, 0)
  love.graphics.print('myInterval: ' .. myInterval,  xOff+530, yOff+70, 0, 1.5, 1.5, 0, 0, 0, 0)
  love.graphics.print('Snake (x,y): ('
                      ..snakeX..','..snakeY..')',    xOff+700, yOff+70, 0, 1.5, 1.5, 0, 0, 0, 0)
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 16)
  love.graphics.setFont(mainFont)
  SetMyColour(white)
end

function drawText()
  scoreY = 0
  if myGameSize > 850 then
    if snakeY < boardSize / 2 then scoreY = 860 else scoreY = 20 end
  end
  SetMyColour(white)
  love.graphics.print('Collected Apples: ' 
                      .. tailLength..' ('..numApples..' left)', 25, scoreY, 0, 1.2, 1.2)
  centerPrint('Percentage complete: '
              .. string.format("%0.2f",percentDone)
              ..'%',defaultWindowSize,scoreY)
  
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 24)
  love.graphics.setFont(mainFont)
  SetMyColour(green)
  centerPrint('Level: '..level.. ' Score: '..score,defaultWindowSize,870)
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 16)
  love.graphics.setFont(mainFont)
  SetMyColour(white)
  
  timeY = 25
  if myGameSize > 800 then
    if snakeY < boardSize / 2 then timeY = 840 else timeY = 40 end
  end
  
-- calculate playing time
  if not finished then end_time = os.time() end
  elapsed_time = os.difftime(end_time-start_time) - pauseTime
  elapsed_minutes = math.floor(elapsed_time / 60)
  elapsed_seconds = elapsed_time-elapsed_minutes*60
  if not paused and gameStarted then
    centerPrint('(You will never get back these ' .. elapsed_minutes .. ' minutes and '
                .. elapsed_seconds .. ' seconds of your life!)',defaultWindowSize,timeY)
  end
  
  SetMyColour(red)
  love.graphics.print('Lives Left: ' .. lives, 700, scoreY, 0, 1.2, 1.2)
  SetMyColour(white)
  if debugSnake then drawDebugInfo() end
end


function gameDraw()
  --if tryNewCode then drawFreeSpaces() end
  collectgarbage("collect") -- Free Memory
  -- ensure time does not start until keypressed
  if gameStarted and not already_started then 
    start_time = os.time()
    already_started = true
  end
  if godMode then usedGodMode = true end
  if not finished then
    if tailLength == 0 then 
      percentDone = 0 
    else 
      percentDone = 100*(tailLength+2)/(boardSize*boardSize)
    end
  end
  drawBoard()
  drawBombs()
  drawApples()
  drawSnakeHead()
  drawCrossHairs()
  drawTail() 
  drawText()
  if gameOver then drawScore() end
end

-- increase the speed of the snake - NOT USED
-- REWRITE ALL SNAKE SPEED CODE
--function updateSpeed()
--  if not godMode then
--    lastIncrease = speedIncrease
--    speedIncrease = math.max(lastIncrease, math.floor(tailLength/speedIncrease)) 
--    myInterval = math.max(SLOWEST, FASTEST - math.floor(tailLength/speedIncrease))
--  else
--    myInterval = SLOWEST
--  end
--end

function newGame()
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 16)
  love.graphics.setFont(mainFont)
  numReplays = TOTAL_REPLAYS
  replayCount = 0
  replayMoves = 0
  paused = false
--  pauseTime = 0 -- only do this if not 'n'ext
  pauseStart = 0
  gameStarted = false
--  already_started = false  --- only do this if not 'n'ext
  silent = false
  replay = {}
  replayDone = false
  lastSnakeX, lastSnakeY = -1, -1
  crosshairs = SIZE < 16
  --grid = false
  gameOver, finished, godMode, usedGodMode, won = false, false, false, false, false
  up, down, left, right = false, false, false, false
  tailLength = 0
  saveTailLength = 0
  tail = {}
  tailCorners = {}
  numApples = 0 -- new multi apple count
  apples = {} -- new MULTI APPLES
  numBombs = 0 -- new multi apple count
  bombs = {} -- new MULTI APPLES
  saveApplesToExplode = 0
  applesToExplode = 0
  applesToRemove = 0
  math.randomseed(os.time())
  snakeX = math.random(boardSize-1)
  snakeY = math.random(boardSize-1)
  xyOffset = (defaultWindowSize - (SIZE * boardSize))/2
  spacesLeft = (boardSize * boardSize) - tailLength
  lives = math.max(5, boardSize)
end

function setSpeed()
  if boardSize > 100 then myInterval = 1  
    elseif boardSize > 90 then myInterval = 2
    elseif boardSize > 80 then myInterval = 3
    elseif boardSize > 70 then myInterval = 4
    elseif boardSize > 60 then myInterval = 5
    elseif boardSize > 50 then myInterval = 6
    elseif boardSize > 40 then myInterval = 7
    elseif boardSize > 30 then myInterval = 8
    elseif boardSize > 20 then myInterval = 9
    elseif boardSize > 15 then myInterval = 10
    elseif boardSize > 10 then myInterval = 12 
    elseif boardSize > 8 then myInterval = 15 
    else myInterval = 30
  end
end

-- Set up the game board
function setBoard()
  if myGameSize ~= defaultWindowSize then 
    boardSize = math.floor(myGameSize/SIZE)
  end
  if SIZE > (myGameSize / 4) then SIZE = myGameSize / 4 end -- ensure SIZE not too big
-- Ensure board has even number of rows
  while boardSize % 2 > 0 do
    SIZE = SIZE + 1
    boardSize = math.floor(myGameSize/SIZE)
  end
  appleNear = boardSize / 3
  setSpeed()
  newGame();
end

function gameFinished()
  finished = true
  if saveTailLength == 0 then saveTailLength = tailLength end
  left, right, up, down = false, false, false, false
end


-- checks that se are not moving into a wall
function canMove()
  return (up and snakeY > 0) or 
         (left and snakeX > 0) or 
         (down and snakeY < boardSize - 1) or 
         (right and snakeX < boardSize - 1)
end


function removeApple()
  if not silent then popSound:play() end
  table.remove(apples,1)
  numApples = numApples - 1
  applesToRemove = applesToRemove - 1
  applesToExplode = applesToExplode - 1 
end

function gameUpdate(dt)
  if applesToRemove > 0 then removeApple() end 
  if autoSnake then
    -- use up, down, left, right to move snake systematically along lines across whole board
    if up and (snakeX == boardSize - 1) then left = true up = false end
    if up and (snakeX == 1) and (snakeY > 0) then right = true up = false end 
    if canMove() and not(left and snakeX ==1 and snakeY > 0) then
      lastDown, lastUp, lastLeft, lastRight = down, up, left, right
    else
      left, right, up, down = false, false, false, false
      if lastRight then up = true 
      elseif lastUp and (snakeX == boardSize - 1) then left = true
      elseif lastUp and (snakeX == 1) then right = true
      elseif lastUp and (snakeX == 0) then down = true
      elseif lastLeft and (snakeY > 0) then up = true
      elseif lastLeft and (snakeY == 0) then down = true
      elseif lastDown then right = true
      end
    end
  end
  if up then dirX, dirY = 0, -1
    elseif down then dirX, dirY = 0, 1
    elseif left then dirX, dirY = -1, 0
    elseif right then dirX, dirY = 1, 0
--      else dirX, dirY = 0,0
  end
--  if shoot then
--      shooting = true
--      shoot = false
--      if dirX ~= 0 then bulletDirX = SIZE*4*dirX else bulletDirX = 0 end
--      if dirY ~= 0 then bulletDirY = SIZE*4*dirY else bulletDirY = 0 end
--      bulletX = xyOffset + snakeX * SIZE + SIZE / 2 - 5
--      bulletY = xyOffset + snakeY * SIZE + SIZE / 2 - 5
--  end
--  if shooting then
--      bulletX = bulletX + bulletDirX 
--      bulletY = bulletY + bulletDirY
--print('Bullet x,y = '..bulletX..','..bulletY)
--      if bulletX < xyOffset or bulletY < xyOffset or 
--         bulletX > boardSize * SIZE or bulletY > boardSize * SIZE then
--        shooting = false
--      end
--      if onApple(bulletX,bulletY) > 0 then 
--        shooting = false 
--print('shot apple')            
--      end
--  end
  if canMove() and not finished then -- I think the not finished is OK
    oldX, oldY = snakeX, snakeY
    snakeX = snakeX + dirX -- dirX/SIZE*dt*500 
    snakeY = snakeY + dirY -- dirY/SIZE*dt*500
  
    if onTail(snakeX,snakeY) and not finished then
      if not(godMode) then
        if not silent then onTailSound:play() end
        lives = lives - 1
      end
    end
    onApplePosition = onApple(snakeX,snakeY)
    if onApplePosition > 0 then 
      if numApples > 1 then 
        if not silent then onAppleSound:play() end
      end
      table.remove(apples,onApplePosition)
      numApples = numApples - 1
      if heartbeatSound:isPlaying() then heartbeatSound:stop() end
      if numApples == 0 then 
-- if all apples picked up, remove bombs        
        bombs = {}
        numBombs = 0
        if inMultiArea(snakeX,snakeY) and (spacesLeft > 50) and useMultiApples then 
          addApples(math.random(3,math.floor(spacesLeft/10))) 
        else
          addApples(1) 
        end
      end
      tailLength = tailLength + 1
      score = score + 1
      spacesLeft = (boardSize * boardSize) - tailLength
      if spacesLeft == GAME_WON and not finished then 
        gameFinished()
        pauseStart = os.time() -- do this if won game until presses 'n'
        won = true
--        gameState = "Won"
      end
      table.insert(tail, {0,0})
--      if myInterval > FASTEST and not finished then updateSpeed() end -- ADDED not finished
    elseif appleClose() and not(heartbeatSound:isPlaying()) then
      if not silent then heartbeatSound:play() end
    end
--Bombs    
    onBombPosition = onBomb(snakeX,snakeY)
    if onBombPosition > 0 then 
      if not silent then onBombSound:play() end
      table.remove(bombs,onBombPosition)
-- remove 20% of apples
      if numApples > 20 then applesToRemove = math.floor(numApples*0.2)
      elseif numApples > 10 then applesToRemove = math.floor(numApples*0.3)
      elseif numApples > 6 then applesToRemove = math.floor(numApples*0.4)
      elseif numApples > 1 then applesToRemove = math.floor(numApples*0.5)
      else 
        applesToRemove = 0
      end
      applesToExplode = applesToRemove
      saveApplesToExplode = applesToExplode
      numBombs = numBombs - 1
    end
    
--end Bombs
    if not(appleClose()) and heartbeatSound:isPlaying() then heartbeatSound:stop() end
    if tailLength > 0 then
      for _, v in ipairs(tail) do
        local x, y = v[1], v[2]
        v[1], v[2] = oldX, oldY
        oldX, oldY = x, y
      end
    end
    if appleClose() then
      if not silent then movingSound2:play() end
    else
      if not silent then movingSound1:play() end
    end
  else
    if up or down or left or right then
      if not godMode and not finished then
        if not silent then hitEdgeSound:play() end
        lives = lives - 1
      end
    end
  end
  if lives < 1 and not finished then 
    gameFinished() 
--    gameState = "Lost"
  end
end

function optionDraw()
  lineSpace = 20
  lineOffset = 20
  
  SetMyColour(aqua)
  mainFont = love.graphics.newFont("fonts/Roboto-BlackItalic.ttf", 80)
  love.graphics.setFont(mainFont)
  centerPrint('Snake 2.0',defaultWindowSize, 25)
  
  SetMyColour(asphalt)
  love.graphics.rectangle('fill', 160, 140, 600, 300)
  love.graphics.rectangle('fill', 50, 470, 800, 400)
  SetMyColour(white)
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 32)
  love.graphics.setFont(mainFont)
  centerPrint('Instructions',defaultWindowSize, 480+(0 * lineSpace))
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 16)
  love.graphics.setFont(mainFont)
  centerPrint('You are               , you eat               and grow. If you eat these last                , you get lots more             ',defaultWindowSize, lineOffset+500+(1 * lineSpace))
  love.graphics.draw(faceImage, 145, lineOffset+470, 0, 0.8, 0.8)
  love.graphics.draw(appleImage, 275, lineOffset+485, 0, 0.7, 0.7)
  love.graphics.draw(multiAppleImage, 555, lineOffset+490, 0, 0.5, 0.5)
  love.graphics.draw(appleImage, 755, lineOffset+485, 0, 0.7, 0.7)
  
  centerPrint('If you run over one of these                   you will lose lots of these                   so be careful!',defaultWindowSize, lineOffset+490+(4 * lineSpace))
  love.graphics.draw(bombImage, 340, lineOffset+535, 0, 0.6, 0.6)
  love.graphics.draw(appleImage, 595, lineOffset+535, 0, 0.7, 0.7)
  
  SetMyColour(yellow)
  centerPrint('Do not run over yourself!  Do not touch the sides! You will lose lives, you only get a few lives.',defaultWindowSize, lineOffset+500+(6 * lineSpace))
  
  SetMyColour(white)
  centerPrint('Press escape                           to quit',defaultWindowSize, lineOffset+520+(7 * lineSpace))
  centerPrint('Press "s"          to turn sound on/off',defaultWindowSize, lineOffset+520+(8 * lineSpace))
  centerPrint('Press "p"       to pause game on/off',defaultWindowSize, lineOffset+520+(9 * lineSpace))
  centerPrint('Press "c"   to turn crosshairs on/off',defaultWindowSize, lineOffset+520+(10 * lineSpace))
  centerPrint('Press "g"      to turn graphics on/off',defaultWindowSize, lineOffset+520+(11 * lineSpace))
  centerPrint('If you enjoyed this game, consider sending some                         so I can get some            .                   ',defaultWindowSize, lineOffset+520+(14 * lineSpace))
  love.graphics.draw(cashImage, 460, lineOffset+760, 0, 0.8, 0.8)
  love.graphics.draw(beerImage, 680, lineOffset+675, 0, 0.8, 0.8)
  
  
--  love.graphics.draw(headImage, 500, 100, 180*math.pi/180)
  
  love.graphics.draw(tailImage, 150, (level * 20) + -100, math.rad(180))
  love.graphics.draw(bodyImage, 150, (level * 20) + 0, math.rad(180))
  love.graphics.draw(bodyImage, 150, (level * 20) + 90, math.rad(180))
  love.graphics.draw(headImage, 150, (level * 20) + 190, math.rad(180))
  
  SetMyColour(aqua)
  
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 26)
  love.graphics.setFont(mainFont)
  love.graphics.print('Choose Your Level',165,140)
  
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 14)
  love.graphics.setFont(mainFont)
  love.graphics.print('(use Arrow Keys)',220,170)
  
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 16)
  love.graphics.setFont(mainFont)
  
  
  
  SetMyColour(green)
  love.graphics.print('Level   1 (6 x 6)',200,200)
  love.graphics.print('Level   2 (8 x 8)',200,220)
  love.graphics.print('Level   3 (10 x 10)',200,240)
  love.graphics.print('Level   4 (12 x 12)',200,260)
  love.graphics.print('Level   5 (16 x 16)',200,280)
  love.graphics.print('Level   6 (20 x 20)',200,300)
  love.graphics.print('Level   7 (26 x 26)',200,320)
  love.graphics.print('Level   8 (40 x 40)',200,340)
  love.graphics.print('Level   9 (50 x 50)',200,360)
  love.graphics.print('Level 10 (80 x 80)',200,380)
  love.graphics.print('Level 11 (160 x 160)',200,400)
  SetMyColour(white)
  if level == 1 then     
    love.graphics.print('Level   1 (6 x 6)',200,180+(level * 20)) 
    love.graphics.draw(option01, 450, 180, 0, 0.3, 0.3)
  elseif level == 2 then 
    love.graphics.print('Level   2 (8 x 8)',200,180+(level * 20))
    love.graphics.draw(option02, 450, 180, 0, 0.3, 0.3)
  elseif level == 3 then 
    love.graphics.print('Level   3 (10 x 10)',200,180+(level * 20))
    love.graphics.draw(option03, 450, 180, 0, 0.3, 0.3)
  elseif level == 4 then 
    love.graphics.print('Level   4 (12 x 12)',200,180+(level * 20))
    love.graphics.draw(option04, 450, 180, 0, 0.3, 0.3)
  elseif level == 5 then 
    love.graphics.print('Level   5 (16 x 16)',200,180+(level * 20))
    love.graphics.draw(option05, 450, 180, 0, 0.3, 0.3)
  elseif level == 6 then 
    love.graphics.print('Level   6 (20 x 20)',200,180+(level * 20))
    love.graphics.draw(option06, 450, 180, 0, 0.3, 0.3)
  elseif level == 7 then 
    love.graphics.print('Level   7 (26 x 26)',200,180+(level * 20))
    love.graphics.draw(option07, 450, 180, 0, 0.3, 0.3)
  elseif level == 8 then 
    love.graphics.print('Level   8 (40 x 40)',200,180+(level * 20))
    love.graphics.draw(option08, 450, 180, 0, 0.3, 0.3)
  elseif level == 9 then 
    love.graphics.print('Level   9 (50 x 50)',200,180+(level * 20))
    love.graphics.draw(option09, 450, 180, 0, 0.3, 0.3)
  elseif level == 10 then 
    love.graphics.print('Level 10 (80 x 80)',200,180+(level * 20))
    love.graphics.draw(option10, 450, 180, 0, 0.3, 0.3)
  elseif level == 11 then 
    love.graphics.print('Level 11 (160 x 160)',200,180+(level * 20))
    love.graphics.draw(option11, 450, 180, 0, 0.3, 0.3)
  end
  mainFont = love.graphics.newFont("fonts/Roboto-Bold.ttf", 16)
  love.graphics.setFont(mainFont)
end

function optionUpdate()
  if down then 
    if level < maxChoices then level = level + 1 end
    down = false
  elseif up then 
    if level > 1 then level = level - 1 end
    up = false
  end
end


function autoSnakeToggle()
  if gameState == "Play" then
    if autoSnake then
      autoSnake = false
      myInterval = saveInterval
    else
      if not(up or down or left or right) then right = true end
      autoSnake = true
      saveInterval = myInterval
      myInterval = 1
    end
  end
end

function escapeKeyPressed()
  if gameState == "Options" then love.event.quit() 
  else gameState = "Options"
    pauseTime = 0
    already_started = false
  end
end

function optionsMenu()
  gameState = "Options"
  pauseTime = 0
  score = 0
  already_started = false
end

function restartLevel()
  if gameState == "Won" or gameState == "Lost" then 
    gameState = "Restart" 
    pauseTime = 0
    score = 0
   already_started = false
  end
end

function nextLevel()
  if gameState == "Won" then 
    gameState = "Next" 
    pauseEnd = os.time()
    pauseTime = pauseTime + os.difftime(pauseEnd - pauseStart) 
    -- do running time stuff
    already_started = true
  end
end
