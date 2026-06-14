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

proc advance(self: var SnakePiece) =
    case self.direction
    of    up: self.position.y -= gridSize
    of  down: self.position.y += gridSize
    of right: self.position.x += gridSize
    of  left: self.position.x -= gridSize

proc savePosition(self: var SnakePiece) =
    self.oldPosition = self.position

proc draw(self: SnakePiece) =
    drawRectangle(self.position, gridDimensions, Green)

type Snake = object
    head: ptr SnakePiece
    body: array[0..512, SnakePiece]
    length: uint32

proc newSnake(startPos: Vector2): Snake =
    result.head = addr result.body[0]
    result.length = 1
    result.head.position = startPos
    result.head.direction = right

proc updateDirection(self: var Snake) =
    case getInputAxis(Right, Left)
    of  1: self.head.direction = right
    of -1: self.head.direction = left
    else: discard

    case getInputAxis(Up, Down)
    of  1: self.head.direction = up
    of -1: self.head.direction = down
    else: discard

proc advance(self: var Snake) =
    self.head[].savePosition()
    self.head[].advance()

    if self.length > 1:
        for i in 1 .. self.length - 1:
            let curr = addr self.body[i]
            let prev = addr self.body[i-1]
            curr[].savePosition()
            curr.position = prev.oldPosition

proc grow(self: var Snake) =
    self.length += 1

proc draw(self: Snake) =
    for i in 0 .. self.length - 1:
        self.body[i].draw()

type Apple = object
    position: Vector2

proc goToRandPos(self: var Apple) =
        self.position = Vector2(
            x: float32(rand(0..(screenWidth div gridSize - 1)) * gridSize),
            y: float32(rand(0..(screenHeight div gridSize - 1)) * gridSize),
        )

proc newApple(): Apple =
    result.position = Vector2(x: 100, y: 100)

proc draw(self: var Apple) =
    drawRectangle(self.position, gridDimensions, Red)

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
