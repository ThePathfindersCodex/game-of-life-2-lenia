extends Node2D

# Constants
const GRID_SIZE = 128
const CELL_SIZE = 4

# Variables
var grid = []
var next_grid = []

func _ready():
	# Initialize the grid with random values
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(randf() < 0.5)
		grid.append(row)
		next_grid.append(row.duplicate())

func _process(_delta):
	# Update the grid
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var neighbors = get_neighbors(x, y)
			if grid[x][y]:
				next_grid[x][y] = neighbors == 2 or neighbors == 3
			else:
				next_grid[x][y] = neighbors == 3
	
	# Swap grids
	var temp = grid
	grid = next_grid
	next_grid = temp
	
	queue_redraw()

func _draw():
	# Draw the grid
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var color = Color(1, 1, 1) if grid[x][y] else Color(0, 0, 0)
			draw_rect(Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

func get_neighbors(x, y):
	var count = 0
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = (x + dx + GRID_SIZE) % GRID_SIZE
			var ny = (y + dy + GRID_SIZE) % GRID_SIZE
			if grid[nx][ny]:
				count += 1
	return count

func _input(event):
	# mouse click to change to (or restart) custom pattern mode
	if event is InputEventMouseButton && event.is_released():
		custom_patterns()
		
func custom_patterns():
	# reset grid to empty
	grid = []
	next_grid = []
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(0)
		grid.append(row)
		next_grid.append(row.duplicate())

	## add blinking oscillators
	grid[23][23]=1
	grid[23][24]=1
	grid[23][25]=1
	grid[23][26]=1
	grid[23][27]=1
	
	## add glider
	grid[63][63]=1
	grid[64][64]=1
	grid[65][62]=1
	grid[65][63]=1
	grid[65][64]=1
	
