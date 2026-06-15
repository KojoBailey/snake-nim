import raylib

import std/math
import std/random
import std/strformat

const
    screenWidth = 800
    screenHeight = 600
    cellSize = 40 # Should be a factor of width and height
    cellDimensions = Vector2(x: cellSize, y: cellSize)
    tickRate = 0.15

var isGameOver = true
var shouldShowStats = false
var score: uint64

proc triggerGameOver() =
    isGameOver = true
    shouldShowStats = true

proc getInputAxis(upper: KeyboardKey, lower: KeyboardKey): int =
    (if isKeyDown(upper): 1 else: 0) - (if isKeyDown(lower): 1 else: 0)

proc centerTextHorizontal(text: string, fontSize: int32): int32 =
    screenWidth div 2 - measureText(text, fontSize) div 2

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
    oldDirection: Direction

proc newSnake(startPos: Vector2): Snake =
    result.head = addr result.body[0]
    result.length = 1
    result.head.position = startPos
    result.head.direction = right

proc updateDirection(self: var Snake) =
    case getInputAxis(Right, Left)
    of  1:
        if self.oldDirection != left:
            self.head.direction = right
    of -1:
        if self.oldDirection != right:
            self.head.direction = left
    else: discard

    case getInputAxis(Up, Down)
    of  1:
        if self.oldDirection != down:
            self.head.direction = up
    of -1:
        if self.oldDirection != up:
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

    self.oldDirection = self.head.direction

proc checkCollision(self: var Snake) =
    if self.head.position.x >= screenWidth or self.head.position.y >= screenHeight or
        self.head.position.x < 0 or self.head.position.y < 0:
            triggerGameOver()

    for i in 1 .. self.length-1:
        if self.head.position == self.body[i].position:
            triggerGameOver()

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

proc reset() =
    isGameOver = false
    snake = newSnake(Vector2(x: cellSize, y: cellSize))
    apple = newApple()
    score = 0

initWindow(screenWidth, screenHeight, "Snake")
setTargetFPS(60)

randomize() # Initialise std/random

while not windowShouldClose():
    beginDrawing()
    clearBackground(Black)

    if isGameOver:
        if isKeyDown(Enter):
            reset()

        if shouldShowStats:
            let stats = fmt"You scored {score} that round"
            drawText(stats, centerTextHorizontal(stats, 40), 80, 40, Yellow)
            
            var tip: string
            case score
            of 0..2:
                tip = "Maybe try moving the arrow keys..."
            of 3..9:
                tip = "Giving up already?"
            of 10..19:
                tip = "Congrats, you hit double digits"
            of 20..29:
                tip = "Not bad... but far from great"
            of 30..39:
                tip = "Hey, that's pretty good"
            of 40..49:
                tip = "You have some stamina"
            of 50..59:
                tip = "Do you not get bored?"
            of 60..68:
                tip = "This is groundbreaking"
            of 69:
                tip = "Nice"
            of 70..79:
                tip = "Your commitment is admirable"
            of 80..89:
                tip = "Do your fingers not tire?"
            of 90..99:
                tip = "What is your goal?"
            of 100..199:
                tip = "Most impressive"
            else:
                tip = "You... win"
            drawText(tip, centerTextHorizontal(tip, 25), 140, 25, Red)
        else:
            const title = "Snake"
            drawText(title, centerTextHorizontal(title, 100), 80, 100, Green)

            const author = "by Kojo Bailey"
            drawText(author, centerTextHorizontal(author, 30), screenHeight - 140, 30, Yellow)
            const tool = "made in Nim with Naylib"
            drawText(tool, centerTextHorizontal(tool, 30), screenHeight - 100, 30, Yellow)

        const startText = "Press ENTER to start"
        drawText(startText, centerTextHorizontal(startText, 40), screenHeight div 2 - 20, 40, White)
    
    if not isGameOver:
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

        let scoreStr = $score
        const scoreFontWidth = 60
        drawText(scoreStr, centerTextHorizontal(scoreStr, scoreFontWidth), 40, scoreFontWidth, White)

    endDrawing()

closeWindow()
