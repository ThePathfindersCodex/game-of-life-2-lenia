extends Node2D

func load_sim(script:Script):
	%menu.visible=false
	%gridDisplay.set_script(script)
	%gridDisplay._ready()
	%gridDisplay.set_process(true)
	%gridDisplay.set_process_input(true)

func _on_btn_game_of_life_pressed():
	load_sim(load("res://step1-gol.gd"))

func _on_btn_kernel_convolution_pressed():
	load_sim(load("res://step2.gd"))

func _on_btn_incremental_growth_pressed():
	load_sim(load("res://step3.gd"))

func _on_btn_multiple_states_pressed():
	load_sim(load("res://step4.gd"))

func _on_btn_normalize_kernel_pressed():
	load_sim(load("res://step5.gd"))

func _on_btn_cont_states_time_pressed():
	load_sim(load("res://step6.gd"))

func _on_btn_cont_space_enlarge_kernel_pressed():
	load_sim(load("res://step7.gd"))

func _on_btn_cont_space_ring_kernel_pressed():
	load_sim(load("res://step8.gd"))

func _on_btn_cont_space_smooth_kernel_growth_pressed():
	load_sim(load("res://step9-lenia.gd"))

func _on_btn_orbium_pressed():
	load_sim(load("res://step10-orbium.gd"))

func _on_btn_four_panel_display_pressed():
	load_sim(load("res://step11-four-panel.gd"))


