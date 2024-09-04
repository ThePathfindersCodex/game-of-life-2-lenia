extends Node2D

# Constants
const GRID_SIZE := 64
const CELL_SIZE := 4

# Variables
var T := 30.0  # Update frequency: larger value == slower simulation
var DT := 1.0 / T # TODO: this should be recalc every time T is changed! use setter?
var R := 10  # Kernel radius
var GROWTH_CENTER_M := 0.135
var GROWTH_WIDTH_S := 0.015

# Matrix Variables
var grid = []
var next_grid = []
var kernel = []

func _ready():
	randomize()
	empty_grid()
	randomize_grid()
	
	## EXAMPLE WAYS TO LOAD CONFIG
	#create_kernel()
	#create_handdrawn_kernel()
	#normalize_kernel()
	#create_gaussian_bell_kernel()

	## or LOAD CONFIG FOR A SPECIFIC PATTERN
	load_pattern_orbium()

func load_pattern_orbium():
	T = 10
	DT = 1.0 / T
	R = 13
	GROWTH_CENTER_M = 0.15
	GROWTH_WIDTH_S = 0.014
	empty_grid()
	center_object_in_grid(create_orbium())
	create_gaussian_bell_kernel()

func center_object_in_grid(data_to_center:Array):
	var data_size_x := data_to_center.size()
	var data_size_y :int= data_to_center[0].size()
	var start_x = int( (GRID_SIZE - data_size_x) / 2 )
	var start_y = int( (GRID_SIZE - data_size_y) / 2 )

	for x in range(data_size_x):
		for y in range(data_size_y):
			grid[start_x + x][start_y + y] = data_to_center[x][y]
	return grid
	
func create_orbium()->Array:
	var cells = [
			 [0, 0, 0, 0, 0, 0, 0.1, 0.14, 0.1, 0, 0, 0.03, 0.03, 0, 0, 0.3, 0, 0, 0, 0],
			 [0, 0, 0, 0, 0, 0.08, 0.24, 0.3, 0.3, 0.18, 0.14, 0.15, 0.16, 0.15, 0.09, 0.2, 0, 0, 0, 0],
			 [0, 0, 0, 0, 0, 0.15, 0.34, 0.44, 0.46, 0.38, 0.18, 0.14, 0.11, 0.13, 0.19, 0.18, 0.45, 0, 0, 0],
			 [0, 0, 0, 0, 0.06, 0.13, 0.39, 0.5, 0.5, 0.37, 0.06, 0, 0, 0, 0.02, 0.16, 0.68, 0, 0, 0],
			 [0, 0, 0, 0.11, 0.17, 0.17, 0.33, 0.4, 0.38, 0.28, 0.14, 0, 0, 0, 0, 0, 0.18, 0.42, 0, 0],
			 [0, 0, 0.09, 0.18, 0.13, 0.06, 0.08, 0.26, 0.32, 0.32, 0.27, 0, 0, 0, 0, 0, 0, 0.82, 0, 0],
			 [0.27, 0, 0.16, 0.12, 0, 0, 0, 0.25, 0.38, 0.44, 0.45, 0.34, 0, 0, 0, 0, 0, 0.22, 0.17, 0],
			 [0, 0.07, 0.2, 0.02, 0, 0, 0, 0.31, 0.48, 0.57, 0.6, 0.57, 0, 0, 0, 0, 0, 0, 0.49, 0],
			 [0, 0.59, 0.19, 0, 0, 0, 0, 0.2, 0.57, 0.69, 0.76, 0.76, 0.49, 0, 0, 0, 0, 0, 0.36, 0],
			 [0, 0.58, 0.19, 0, 0, 0, 0, 0, 0.67, 0.83, 0.9, 0.92, 0.87, 0.12, 0, 0, 0, 0, 0.22, 0.07],
			 [0, 0, 0.46, 0, 0, 0, 0, 0, 0.7, 0.93, 1, 1, 1, 0.61, 0, 0, 0, 0, 0.18, 0.11],
			 [0, 0, 0.82, 0, 0, 0, 0, 0, 0.47, 1, 1, 0.98, 1, 0.96, 0.27, 0, 0, 0, 0.19, 0.1],
			 [0, 0, 0.46, 0, 0, 0, 0, 0, 0.25, 1, 1, 0.84, 0.92, 0.97, 0.54, 0.14, 0.04, 0.1, 0.21, 0.05],
			 [0, 0, 0, 0.4, 0, 0, 0, 0, 0.09, 0.8, 1, 0.82, 0.8, 0.85, 0.63, 0.31, 0.18, 0.19, 0.2, 0.01],
			 [0, 0, 0, 0.36, 0.1, 0, 0, 0, 0.05, 0.54, 0.86, 0.79, 0.74, 0.72, 0.6, 0.39, 0.28, 0.24, 0.13, 0],
			 [0, 0, 0, 0.01, 0.3, 0.07, 0, 0, 0.08, 0.36, 0.64, 0.7, 0.64, 0.6, 0.51, 0.39, 0.29, 0.19, 0.04, 0],
			 [0, 0, 0, 0, 0.1, 0.24, 0.14, 0.1, 0.15, 0.29, 0.45, 0.53, 0.52, 0.46, 0.4, 0.31, 0.21, 0.08, 0, 0],
			 [0, 0, 0, 0, 0, 0.08, 0.21, 0.21, 0.22, 0.29, 0.36, 0.39, 0.37, 0.33, 0.26, 0.18, 0.09, 0, 0, 0],
			 [0, 0, 0, 0, 0, 0, 0.03, 0.13, 0.19, 0.22, 0.24, 0.24, 0.23, 0.18, 0.13, 0.05, 0, 0, 0, 0],
			 [0, 0, 0, 0, 0, 0, 0, 0, 0.02, 0.06, 0.08, 0.09, 0.07, 0.05, 0.01, 0, 0, 0, 0, 0]
			]
	return cells
	
func _process(_delta):
	apply_convolution()
	update_grid()
	queue_redraw()

func empty_grid():
	grid = []
	next_grid = []
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(0.0)
		grid.append(row)
		next_grid.append(row.duplicate())
		
func randomize_grid():
	grid = []
	next_grid = []	
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
			var value := exp(-pow((distance - 0.5) / 0.15, 2) / 2.0)
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
