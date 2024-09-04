extends Node2D

# Step 9 - Smooth Kernel and Smooth Growth - Lenia ready

# Constants
const GRID_SIZE := 64
const CELL_SIZE := 4
const T := 10.0  # Update frequency: larger value == slower simulation
const DT := 1.0 / T
const R := 10  # Kernel radius
const GROWTH_CENTER_M := 0.135
const GROWTH_WIDTH_S := 0.015

# Variables
var grid = []
var next_grid = []
var kernel = []

func _ready():
	#create_kernel()
	#create_handdrawn_kernel() # used with R = 5
	#normalize_kernel()
	create_gaussian_bell_kernel()
	randomize_grid()

func _process(_delta):
	apply_convolution()
	update_grid()
	queue_redraw()

func randomize_grid():
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(randf())
		grid.append(row)
		next_grid.append(row.duplicate())

func create_kernel():
	kernel = []
	for i in range(2 * R + 1):
		var row = []
		for j in range(2 * R + 1):
			if i == R and j == R:
				row.append(0.0)
			else:
				row.append(1.0)
		kernel.append(row)

func create_handdrawn_kernel():
	kernel = [
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
	return kernel

# Gaussian Kernel Creation Function
func create_gaussian_bell_kernel():
	#var sigma := R / 2.0  # Standard deviation
	kernel = []
	var total_sum := 0.0

	for x in range(2 * R + 1):
		var row = []
		for y in range(2 * R + 1):
			var dx := x - R
			var dy := y - R
			var distance := sqrt(dx * dx + dy * dy) / R
			#var value = exp(-distance * distance / (2 * sigma * sigma))
			var value = exp(-pow((distance - 0.5) / 0.15, 2) / 2.0)
			row.append(value)
			total_sum += value
		kernel.append(row)

	# Normalize the kernel
	for x in range(2 * R + 1):
		for y in range(2 * R + 1):
			kernel[x][y] /= total_sum

	return kernel

func normalize_kernel():
	var kernel_sum := 0.0
	for i in range(2 * R + 1):
		for j in range(2 * R + 1):
			kernel_sum += kernel[i][j]
	for i in range(2 * R + 1):
		for j in range(2 * R + 1):
			kernel[i][j] /= kernel_sum

func apply_convolution():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var neighbors := 0.0
			for i in range(-R, R + 1):
				for j in range(-R, R + 1):
					var ni = (x + i + GRID_SIZE) % GRID_SIZE
					var nj = (y + j + GRID_SIZE) % GRID_SIZE
					neighbors += grid[ni][nj] * kernel[i + R][j + R]
			# Apply the growth function with scaled increment
			next_grid[x][y] = clamp(grid[x][y] + DT * growth(neighbors), 0.0, 1.0)

func growth(U:float):
	#return float((U >= 0.12) and (U <= 0.15)) - float((U < 0.12) or (U > 0.15))
	return exp(-pow((U - GROWTH_CENTER_M) / GROWTH_WIDTH_S, 2) / 2.0) * 2.0 - 1.0

func update_grid():
	var temp = grid
	grid = next_grid
	next_grid = temp

func _draw():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var color_value :float= grid[x][y]
			var color := Color(color_value, color_value, color_value)
			draw_rect(Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)
