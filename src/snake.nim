import raylib

import std/math
import std/random

const
    screenWidth = 800
    screenHeight = 600
    gridSize = 20 # Should be a factor of width and height
    gridDimensions = Vector2(x: gridSize, y: gridSize)
    tickRate = 0.15

type
    Direction = enum
        up, down, left, right

    SnakePiece = object
        position: Vector2
        direction: Direction

proc getInputAxis(upper: KeyboardKey, lower: KeyboardKey): int =
    (if isKeyDown(upper): 1 else: 0) - (if isKeyDown(lower): 1 else: 0)

type Snake = object
        head: ptr SnakePiece
        body: array[0..512, SnakePiece]
        length: uint32

proc newSnake(startPos: Vector2): Snake =
    result.head = addr result.body[0]
    result.head.position = startPos
    result.head.direction = right

proc updateDirection(this: var Snake) =
    case getInputAxis(Right, Left)
    of  1: this.head.direction = right
    of -1: this.head.direction = left
    else: discard

    case getInputAxis(Up, Down)
    of  1: this.head.direction = up
    of -1: this.head.direction = down
    else: discard

proc move(this: var Snake) =
    case this.head.direction
    of    up: this.head.position.y -= gridSize
    of  down: this.head.position.y += gridSize
    of right: this.head.position.x += gridSize
    of  left: this.head.position.x -= gridSize

proc grow(this: var Snake) =
    this.length += 1

proc draw(this: var Snake) =
    drawRectangle(this.head.position, gridDimensions, Green)

type Apple = object
        position: Vector2

proc goToRandPos(this: var Apple) =
        this.position = Vector2(
            x: float32(rand(0..(screenWidth div gridSize)) * gridSize),
            y: float32(rand(0..(screenHeight div gridSize)) * gridSize),
        )

proc newApple(): Apple =
    result.position = Vector2(x: 100, y: 100)

proc draw(this: var Apple) =
    drawRectangle(this.position, gridDimensions, Red)

var
    snake: Snake
    apple: Apple
    lastTick = 0.0

proc checkApple() =
    if snake.head.position == apple.position:
        apple.goToRandPos()
        snake.grow()

initWindow(screenWidth, screenHeight, "Snake")
setTargetFPS(60)

randomize()

snake = newSnake(Vector2(x: screenWidth div 2, y: screenHeight div 2))
apple = newApple()

while not windowShouldClose():
    beginDrawing()
    clearBackground(Black)
    
    snake.updateDirection()
    if getTime() - lastTick >= tickRate:
        snake.move()
        checkApple()
        lastTick = getTime()

    apple.draw()
    snake.draw()

    endDrawing()

closeWindow()
