import raylib

import std/math
import std/random

const
    screenWidth = 800
    screenHeight = 600
    gridSize = 20 # Should be a factor of width and height
    gridDimensions = Vector2(x: gridSize, y: gridSize)
    tickRate = 0.15

proc getInputAxis(upper: KeyboardKey, lower: KeyboardKey): int =
    (if isKeyDown(upper): 1 else: 0) - (if isKeyDown(lower): 1 else: 0)

type
    Direction = enum
        up, down, left, right

type SnakePiece = object
    position: Vector2
    oldPosition: Vector2
    direction: Direction

proc advance(this: var SnakePiece) =
    case this.direction
    of    up: this.position.y -= gridSize
    of  down: this.position.y += gridSize
    of right: this.position.x += gridSize
    of  left: this.position.x -= gridSize

proc savePosition(this: var SnakePiece) =
    this.oldPosition = this.position

proc draw(this: SnakePiece) =
    drawRectangle(this.position, gridDimensions, Green)

type Snake = object
    head: ptr SnakePiece
    body: array[0..512, SnakePiece]
    length: uint32

proc newSnake(startPos: Vector2): Snake =
    result.head = addr result.body[0]
    result.length = 1
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

proc advance(this: var Snake) =
    this.head[].savePosition()
    this.head[].advance()

    if this.length > 1:
        for i in 1 .. this.length - 1:
            let curr = addr this.body[i]
            let prev = addr this.body[i-1]
            curr[].savePosition()
            curr.position = prev.oldPosition

proc grow(this: var Snake) =
    this.length += 1

proc draw(this: Snake) =
    for i in 0 .. this.length - 1:
        this.body[i].draw()

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

initWindow(screenWidth, screenHeight, "Snake")
setTargetFPS(60)

randomize() # Initialise std/random

snake = newSnake(Vector2(x: screenWidth div 2, y: screenHeight div 2))
apple = newApple()

while not windowShouldClose():
    beginDrawing()
    clearBackground(Black)
    
    snake.updateDirection()
    if getTime() - lastTick >= tickRate:
        snake.advance()
        if snake.head.position == apple.position:
            apple.goToRandPos()
            snake.grow()
        lastTick = getTime()

    apple.draw()
    snake.draw()

    endDrawing()

closeWindow()
