import raylib

import std/math

const
    screenWidth = 800
    screenHeight = 600
    gridSize = 20 # Should be a factor of width and height
    gridDimensions = Vector2(x: gridSize, y: gridSize)
    tickRate = 0.15

type
    Direction = enum
        up, down, left, right

    Snake = object
        position: Vector2
        direction: Direction
        length: uint32

var
    snake: Snake
    lastTick = 0.0

initWindow(screenWidth, screenHeight, "Snake")
setTargetFPS(60)

snake.position = Vector2(x: screenWidth div 2, y: screenHeight div 2)
snake.direction = right

while not windowShouldClose():
    beginDrawing()
    clearBackground(Black)
    
    let leftRightDirection = (if isKeyDown(Right): 1 else: 0) - (if isKeyDown(Left): 1 else: 0)
    case leftRightDirection
    of  1: snake.direction = right
    of -1: snake.direction = left
    else: discard

    let upDownDirection = (if isKeyDown(Up): 1 else: 0) - (if isKeyDown(Down): 1 else: 0)
    case upDownDirection
    of  1: snake.direction = up
    of -1: snake.direction = down
    else: discard

    if getTime() - lastTick >= tickRate:
        lastTick = getTime()
        case snake.direction
        of    up: snake.position.y -= gridSize
        of  down: snake.position.y += gridSize
        of right: snake.position.x += gridSize
        of  left: snake.position.x -= gridSize

    drawRectangle(snake.position, gridDimensions, Green)

    endDrawing()

closeWindow()
