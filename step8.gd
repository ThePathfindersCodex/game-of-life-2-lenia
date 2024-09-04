extends Node2D

# Step 8 - Ring Kernel

# Constants
const GRID_SIZE := 128
const CELL_SIZE := 4
const T := 10.0  # Update frequency: larger value == slower simulation
const DT := 1.0 / T
const R = 5  # Kernel radius

# Convolution Kernel
var KERNEL = []

# Variables
var grid = []
var next_grid = []

func _ready():
	create_handdrawn_kernel() # used with R = 5
	normalize_kernel()
	randomize_grid()

func _process(_delta):
	apply_convolution()
	update_grid()
	queue_redraw()

func randomize_grid():
	# Initialize the grid with random values between 0.0 and 1.0
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(randf())
		grid.append(row)
		next_grid.append(row.duplicate())

# Create a larger rectangular kernel
func create_kernel():
	KERNEL = []
	for i in range(2 * R + 1):
		var row = []
		for j in range(2 * R + 1):
			if i == R and j == R:
				row.append(0.0)
			else:
				row.append(1.0)
		KERNEL.append(row)

# Create the hand-drawn kernel
func create_handdrawn_kernel():
	KERNEL = [
		[0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
		[0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
		[1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1],
		[1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1],
		[1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
		[0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
		[0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0]
	]

# Normalize Kernel
func normalize_kernel():
	var kernel_sum := 0.0
	for i in range(2 * R + 1):
		for j in range(2 * R + 1):
			kernel_sum += KERNEL[i][j]
	for i in range(2 * R + 1):
		for j in range(2 * R + 1):
			KERNEL[i][j] /= kernel_sum

func apply_convolution():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var neighbors = 0.0
			for i in range(-R, R + 1):
				for j in range(-R, R + 1):
					var ni = (x + i + GRID_SIZE) % GRID_SIZE
					var nj = (y + j + GRID_SIZE) % GRID_SIZE
					neighbors += grid[ni][nj] * KERNEL[i + R][j + R]
			# Apply the growth function with scaled increment
			next_grid[x][y] = clamp(grid[x][y] + DT * growth(neighbors), 0.0, 1.0)

func growth(U:float):
	return float((U >= 0.12) and (U <= 0.15)) - float((U < 0.12) or (U > 0.15))
	
func update_grid():
	var temp = grid
	grid = next_grid
	next_grid = temp

func _draw():
	# Draw the grid
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var color_value :float= grid[x][y]
			var color := Color(color_value, color_value, color_value)
			draw_rect(Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)
