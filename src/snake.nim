import raylib

const
    screenWidth = 800
    screenHeight = 600
    gridSize = 20 # Should be a factor of width and height
    gridDimensions = Vector2(x: gridSize, y: gridSize)

type
    Snake = object
        position: Vector2
        length: uint32
        speed: float32

var
    snake: Snake

initWindow(screenWidth, screenHeight, "Snake")
setTargetFPS(60)

snake.position = Vector2(x: screenWidth div 2, y: screenHeight div 2)

while not windowShouldClose():
    beginDrawing()
    clearBackground(Black)

    drawRectangle(snake.position, gridDimensions, Green)

    endDrawing()

closeWindow()
