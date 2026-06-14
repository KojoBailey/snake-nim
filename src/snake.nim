import raylib

import std/math
import std/random

const
    screenWidth = 800
    screenHeight = 600
    cellSize = 40 # Should be a factor of width and height
    cellDimensions = Vector2(x: cellSize, y: cellSize)
    tickRate = 0.15

var isGameOver = false
var score = 0

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
    of    up: self.position.y -= cellSize
    of  down: self.position.y += cellSize
    of right: self.position.x += cellSize
    of  left: self.position.x -= cellSize

proc savePosition(self: var SnakePiece) =
    self.oldPosition = self.position

proc draw(self: SnakePiece) =
    drawRectangle(self.position, cellDimensions, Green)

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
    of  1:
        if self.head.direction != left:
            self.head.direction = right
    of -1:
        if self.head.direction != right:
            self.head.direction = left
    else: discard

    case getInputAxis(Up, Down)
    of  1:
        if self.head.direction != down:
            self.head.direction = up
    of -1:
        if self.head.direction != up:
            self.head.direction = down
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

proc checkCollision(self: var Snake) =
    if self.head.position.x >= screenWidth or self.head.position.y >= screenHeight or
        self.head.position.x < 0 or self.head.position.y < 0:
            isGameOver = true

    for i in 1 .. self.length-1:
        if self.head.position == self.body[i].position:
           isGameOver = true

proc grow(self: var Snake) =
    self.length += 1
    self.body[self.length-1].position = Vector2(x: -1000.0, y: -1000.0)
    score += 1

proc draw(self: Snake) =
    for i in 0 .. self.length - 1:
        self.body[i].draw()

type Apple = object
    position: Vector2

proc draw(self: var Apple) =
    drawRectangle(self.position, cellDimensions, Red)

var
    snake: Snake
    apple: Apple
    lastTick = 0.0

proc goToRandPos(self: var Apple) =
    while true:
        self.position = Vector2(
            x: float32(rand(0..(screenWidth div cellSize - 1)) * cellSize),
            y: float32(rand(0..(screenHeight div cellSize - 1)) * cellSize),
        )

        var isInSnake = false
        for i in 0..snake.length-1:
            if snake.body[i].position == self.position:
                isInSnake = true
                break
        if not isInSnake: break

proc newApple(): Apple =
    result.goToRandPos()

initWindow(screenWidth, screenHeight, "Snake")
setTargetFPS(60)

randomize() # Initialise std/random

snake = newSnake(Vector2(x: cellSize, y: cellSize))
apple = newApple()

while not windowShouldClose() and not isGameOver:
    beginDrawing()
    clearBackground(Black)
    
    snake.updateDirection()
    if getTime() - lastTick >= tickRate:
        snake.advance()
        snake.checkCollision()
        if snake.head.position == apple.position:
            apple.goToRandPos()
            snake.grow()
        lastTick = getTime()

    apple.draw()
    snake.draw()
    drawText($score, screenWidth div 2 - measureText($score, 40) div 2, 40, 40, White)

    endDrawing()

closeWindow()
