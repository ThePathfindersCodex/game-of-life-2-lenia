extends Node2D

# Step 3 - Incremental Growth and Decay

# Constants
const GRID_SIZE = 128
const CELL_SIZE = 4

# Convolution Kernel
const KERNEL = [
	[1, 1, 1],
	[1, 0, 1],
	[1, 1, 1]
]

# Variables
var grid = []
var next_grid = []

func _ready():
	# Initialize the grid with random values
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(int(randf() < 0.5))
		grid.append(row)
		next_grid.append(row.duplicate())

func _process(_delta):
	# Update the grid
	apply_convolution()
	update_grid()
	queue_redraw()

func apply_convolution():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var neighbors = 0
			for i in range(-1, 2):
				for j in range(-1, 2):
					var ni = (x + i + GRID_SIZE) % GRID_SIZE
					var nj = (y + j + GRID_SIZE) % GRID_SIZE
					neighbors += grid[ni][nj] * KERNEL[i + 1][j + 1]
			# Apply the growth function
			next_grid[x][y] = clamp(grid[x][y] + growth(neighbors), 0, 1)

func growth(U):
	return int((U == 3)) - int((U < 2) or (U > 3))

func update_grid():
	var temp = grid
	grid = next_grid
	next_grid = temp

func _draw():
	# Draw the grid
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var color = Color(1, 1, 1) if grid[x][y] else Color(0, 0, 0)
			draw_rect(Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)
