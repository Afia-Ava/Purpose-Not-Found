extends Control

@onready var play_btn = $CenterContainer/VBoxContainer/Play
@onready var options_btn = $CenterContainer/VBoxContainer/Options
@onready var exit_btn = $CenterContainer/VBoxContainer/Exit
@onready var main_menu = $CenterContainer/VBoxContainer
@onready var options_menu = $CenterContainer/VBoxContainer2
@onready var back_btn = $CenterContainer/VBoxContainer2/Back
@onready var fullscreen_btn = $CenterContainer/VBoxContainer2/Fullscreen
@onready var volume_slider = $CenterContainer/VBoxContainer2/Mastervolume

func _ready():
	_connect_buttons()
	_setup_audio()

func _connect_buttons():
	play_btn.pressed.connect(_on_play_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	fullscreen_btn.pressed.connect(_on_fullscreen_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)

func _setup_audio():
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.1
	volume_slider.value = 0.8

func _on_play_pressed():
	print("Starting new game...")
	get_tree().change_scene_to_file("res://scenes/acts/act1_burnout_boulevard.tscn")

func _on_options_pressed():
	main_menu.visible = false
	options_menu.visible = true

func _on_exit_pressed():
	get_tree().quit()

func _on_back_pressed():
	options_menu.visible = false
	main_menu.visible = true

func _on_fullscreen_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_btn.text = "Fullscreen"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_btn.text = "Windowed"

func _on_volume_changed(value: float):
	var bus_index = AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))