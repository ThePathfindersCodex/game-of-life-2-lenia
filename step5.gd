extends Node2D

# Constants
const GRID_SIZE := 128
const CELL_SIZE := 4
const STATES := 12

# Convolution Kernel
var KERNEL = [
	[1, 1, 1],
	[1, 0, 1],
	[1, 1, 1]
]

# Variables
var grid = []
var next_grid = []

func _ready():
	normalize_kernel()
	randomize_grid()

func _process(_delta):
	apply_convolution()
	update_grid()
	queue_redraw()

func randomize_grid():
	# Initialize the grid with random values
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(randi() % (STATES + 1))
		grid.append(row)
		next_grid.append(row.duplicate())

# Normalize Kernel
func normalize_kernel():
	var kernel_sum := 0.0
	for i in range(3):
		for j in range(3):
			kernel_sum += KERNEL[i][j]
	kernel_sum *= STATES
	for i in range(3):
		for j in range(3):
			KERNEL[i][j] /= kernel_sum

func apply_convolution():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var neighbors := 0.0
			for i in range(-1, 2):
				for j in range(-1, 2):
					var ni = (x + i + GRID_SIZE) % GRID_SIZE
					var nj = (y + j + GRID_SIZE) % GRID_SIZE
					neighbors += float(grid[ni][nj]) * KERNEL[i + 1][j + 1]
			# Apply the growth function
			next_grid[x][y] = clamp(grid[x][y] + growth(neighbors), 0, STATES)

func growth(U:float):
	return float((U >= 0.20) and (U <= 0.25)) - float((U <= 0.18) or (U >= 0.33))

func update_grid():
	var temp = grid
	grid = next_grid
	next_grid = temp

func _draw():
	# Draw the grid
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var color_value = float(grid[x][y]) / STATES
			var color = Color(color_value, color_value, color_value)
			draw_rect(Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)
