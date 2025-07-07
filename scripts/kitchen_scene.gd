extends Control

# Kitchen Scene Script
# Shows the kitchen scene and allows starting cooking activities

@onready var start_cooking_btn = $UI/ButtonContainer/StartCookingBtn
@onready var back_btn = $UI/ButtonContainer/BackBtn

func _ready():
	_setup_kitchen_scene()
	_connect_signals()

func _setup_kitchen_scene():
	# Add fade-in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	
	# Focus on the start cooking button
	start_cooking_btn.grab_focus()

func _connect_signals():
	start_cooking_btn.pressed.connect(_on_start_cooking_pressed)
	back_btn.pressed.connect(_on_back_pressed)

func _on_start_cooking_pressed():
	# Go to the new simple cooking scene
	_transition_to_scene("res://scenes/simple_cooking.tscn")

func _on_back_pressed():
	# Go back to game choose page
	_transition_to_scene("res://scenes/game_choose.tscn")

func _transition_to_scene(scene_path: String):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file(scene_path)

func _input(event):
	# Allow ESC to go back
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
