extends Node2D

# Variables
var GRID_SIZE :int= 64
var CELL_SIZE :int= 4
var T :float= 30  # Update frequency: larger value == slower simulation
var DT :float= 1.0 / T # TODO: use setter function
var R :int= 10  # Kernel radius
var GROWTH_CENTER_M :float= 0.135
var GROWTH_WIDTH_S :float= 0.015

# Matrix Variables - untyped for now
var grid = []
var next_grid = []
var kernel = []
var weighted_grid_U = [] # Weighted neighbor sums
var growth_grid_H = [] # Resulting growth values

func _ready():
	randomize()
	empty_grid()
	randomize_grid()
	load_pattern_orbium()
	
func _process(_delta):
	apply_convolution()
	update_grid()
	queue_redraw()

func _draw():
	var half_grid_size :int= int(GRID_SIZE / 2)
	var kernel_offset_x :int= half_grid_size - R
	var kernel_offset_y :int= half_grid_size - R

	# Draw World Grid (top left)
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			#var color_value = grid[x][y]
			#var color = Color(color_value, color_value, color_value)
			var color :Color= get_color_viridis(grid[x][y])
			draw_rect(Rect2(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

	# Draw Growth Grid (top right)
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			#var color_value = growth_grid_H[x][y]
			#var color = Color(color_value, color_value, color_value)
			var color :Color= get_color_viridis(growth_grid_H[x][y])
			draw_rect(Rect2((x + GRID_SIZE) * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

	# Draw Weighted Neighbor Sums (bottom left)
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			#var color_value = weighted_grid_U[x][y]
			#var color = Color(color_value, color_value, color_value)
			var color :Color= get_color_viridis(weighted_grid_U[x][y])
			draw_rect(Rect2(x * CELL_SIZE, (y + GRID_SIZE) * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

	# Draw Kernel (bottom right, centered)
	var kernel_scale_factor :float= 170  # Scale factor to make kernel values more visible
	for x in range(2 * R + 1):
		for y in range(2 * R + 1):
			var value :float= kernel[x][y] * kernel_scale_factor
			value = clamp(value, 0.0, 1.0)  # Ensure the color value is within the valid range
			#var color = Color(color_value, color_value, color_value)
			var color :Color= get_color_viridis(value)
			draw_rect(Rect2((kernel_offset_x + x + GRID_SIZE) * CELL_SIZE, (kernel_offset_y + y + GRID_SIZE) * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)


func empty_grid():
	grid = []
	next_grid = []
	weighted_grid_U = []
	growth_grid_H = []	
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(0.0)
		grid.append(row)
		next_grid.append(row.duplicate())
		weighted_grid_U.append(row.duplicate())
		growth_grid_H.append(row.duplicate())
		
func randomize_grid():
	grid = []
	next_grid = []
	weighted_grid_U = []
	growth_grid_H = []	
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(randf())
		grid.append(row)
		next_grid.append(row.duplicate())
		weighted_grid_U.append(row.duplicate())
		growth_grid_H.append(row.duplicate())
		
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
			#next_grid[x][y] = clamp(grid[x][y] + DT * growth(neighbors), 0.0, 1.0)
			weighted_grid_U[x][y] = neighbors
			growth_grid_H[x][y] = clamp(grid[x][y] + DT * growth(neighbors), 0.0, 1.0)
			next_grid[x][y] = growth_grid_H[x][y]

func growth(U:float):
	return exp(-pow((U - GROWTH_CENTER_M) / GROWTH_WIDTH_S, 2) / 2.0) * 2.0 - 1.0

func update_grid():
	var temp = grid
	grid = next_grid
	next_grid = temp
	
func create_basic_kernel():
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

func create_gaussian_bell_kernel():
	#var sigma :float= R / 2.0  # Standard deviation
	kernel = []
	var total_sum :float= 0.0

	for x in range(2 * R + 1):
		var row = []
		for y in range(2 * R + 1):
			var dx :float= x - R
			var dy :float= y - R
			var distance :float= sqrt(dx * dx + dy * dy) / R
			var value :float= exp(-pow((distance - 0.5) / 0.15, 2) / 2.0)
			row.append(value)
			total_sum += value
		kernel.append(row)

	# Normalize the kernel
	for x in range(2 * R + 1):
		for y in range(2 * R + 1):
			kernel[x][y] /= total_sum

	return kernel

func normalize_kernel():
	var kernel_sum :float= 0.0
	for i in range(2 * R + 1):
		for j in range(2 * R + 1):
			kernel_sum += kernel[i][j]
	for i in range(2 * R + 1):
		for j in range(2 * R + 1):
			kernel[i][j] /= kernel_sum

func load_pattern_orbium():
	T = 10
	DT = 1.0 / T
	R = 13
	GROWTH_CENTER_M = 0.15
	GROWTH_WIDTH_S = 0.014
	empty_grid()
	center_object_in_grid(create_orbium())
	create_gaussian_bell_kernel()

func center_object_in_grid(data_to_center):
	var data_size_x :int= data_to_center.size()
	var data_size_y :int= data_to_center[0].size()
	var start_x :int= int( (GRID_SIZE - data_size_x) / 2 )
	var start_y :int= int( (GRID_SIZE - data_size_y) / 2 )

	for x in range(data_size_x):
		for y in range(data_size_y):
			grid[start_x + x][start_y + y] = data_to_center[x][y]
	return grid
	
func create_orbium():
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

func get_color_jet(value):
	if value <= 0.25:
		# Interpolate between blue and cyan
		var t = value / 0.25
		return Color(0, 0, 1).lerp(Color(0, 1, 1), t)
	elif value <= 0.5:
		# Interpolate between cyan and yellow
		var t = (value - 0.25) / 0.25
		return Color(0, 1, 1).lerp(Color(1, 1, 0), t)
	elif value <= 0.75:
		# Interpolate between yellow and red
		var t = (value - 0.5) / 0.25
		return Color(1, 1, 0).lerp(Color(1, 0, 0), t)
	else:
		# Interpolate between red and dark red
		var t = (value - 0.75) / 0.25
		return Color(1, 0, 0).lerp(Color(0.5, 0, 0), t)
func get_color_viridis(value):
	if value <= 0.25:
		# Interpolate between dark blue and blue
		var t = value / 0.25
		return Color(0.267, 0.004, 0.329).lerp(Color(0.282, 0.140, 0.458), t)
	elif value <= 0.5:
		# Interpolate between blue and green
		var t = (value - 0.25) / 0.25
		return Color(0.282, 0.140, 0.458).lerp(Color(0.127, 0.566, 0.551), t)
	elif value <= 0.75:
		# Interpolate between green and yellow-green
		var t = (value - 0.5) / 0.25
		return Color(0.127, 0.566, 0.551).lerp(Color(0.598, 0.884, 0.282), t)
	else:
		# Interpolate between yellow-green and yellow
		var t = (value - 0.75) / 0.25
		return Color(0.598, 0.884, 0.282).lerp(Color(0.992, 0.906, 0.145), t)
func get_color_plasma(value):
	if value <= 0.25:
		# Interpolate between dark purple and purple
		var t = value / 0.25
		return Color(0.050, 0.029, 0.529).lerp(Color(0.301, 0.000, 0.598), t)
	elif value <= 0.5:
		# Interpolate between purple and orange
		var t = (value - 0.25) / 0.25
		return Color(0.301, 0.000, 0.598).lerp(Color(0.800, 0.200, 0.200), t)
	elif value <= 0.75:
		# Interpolate between orange and light orange
		var t = (value - 0.5) / 0.25
		return Color(0.800, 0.200, 0.200).lerp(Color(0.988, 0.644, 0.128), t)
	else:
		# Interpolate between light orange and yellow
		var t = (value - 0.75) / 0.25
		return Color(0.988, 0.644, 0.128).lerp(Color(0.940, 0.975, 0.131), t)
func get_color_red_blue(value):
	var midpoint = 0.5
	if value < midpoint:
		# Interpolate between blue and gray
		var t = value / midpoint
		return Color(0, 0, 1).lerp(Color(0.5, 0.5, 0.5), t)
	else:
		# Interpolate between gray and red
		var t = (value - midpoint) / midpoint
		return Color(0.5, 0.5, 0.5).lerp(Color(1, 0, 0), t)
func get_color_rainbow(value):
	if value <= 0.17:
		var t = value / 0.17
		return Color(1, 0, 0).lerp(Color(1, 0.65, 0), t) # Red to Orange
	elif value <= 0.34:
		var t = (value - 0.17) / 0.17
		return Color(1, 0.65, 0).lerp(Color(1, 1, 0), t) # Orange to Yellow
	elif value <= 0.51:
		var t = (value - 0.34) / 0.17
		return Color(1, 1, 0).lerp(Color(0, 1, 0), t) # Yellow to Green
	elif value <= 0.68:
		var t = (value - 0.51) / 0.17
		return Color(0, 1, 0).lerp(Color(0, 0, 1), t) # Green to Blue
	elif value <= 0.85:
		var t = (value - 0.68) / 0.17
		return Color(0, 0, 1).lerp(Color(0.29, 0, 0.51), t) # Blue to Indigo
	else:
		var t = (value - 0.85) / 0.15
		return Color(0.29, 0, 0.51).lerp(Color(0.56, 0, 1), t) # Indigo to Violet
func get_color_discreet_bgyr(value, minVal):
	if value < minVal:
		return Color(0.5, 0.5, 0.5) # Gray for values below min
	else:
		# Scale value to the range [0, 1] above the min threshold
		var t = (value - minVal) / (1.0 - minVal)
		if t <= 0.33:
			# Light blue to green
			return Color(0.68, 0.85, 0.9).lerp(Color(0, 1, 0), t / 0.33)
		elif t <= 0.66:
			# Green to yellow
			return Color(0, 1, 0).lerp(Color(1, 1, 0), (t - 0.33) / 0.33)
		else:
			# Yellow to red
			return Color(1, 1, 0).lerp(Color(1, 0, 0), (t - 0.66) / 0.34)
func get_color_discreet_bw(value, minVal):
	if value < minVal:
		return Color(0.5, 0.5, 0.5) # Gray for values below min
	else:
		# Scale value to the range [0, 1] above the min threshold
		var t = (value - minVal) / (1.0 - minVal)
		return Color(0.5, 0.5, 0.5).lerp(Color(0, 0, 0), t)

