extends Control

# Game Choose Script
# Allows players to select which act to play

@onready var act1_button = $MainContainer/ActButtonsContainer/Act1Button
@onready var act2_button = $MainContainer/ActButtonsContainer/Act2Button
@onready var act3_button = $MainContainer/ActButtonsContainer/Act3Button
@onready var back_button = $MainContainer/BackButton

func _ready():
	_connect_signals()
	_setup_scene()

func _setup_scene():
	# Add fade-in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)
	
	# Don't auto-focus any button - let user choose by hovering/navigating

func _connect_signals():
	act1_button.pressed.connect(_on_act1_pressed)
	act2_button.pressed.connect(_on_act2_pressed)
	act3_button.pressed.connect(_on_act3_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_act1_pressed():
	_transition_to_scene("res://scenes/kitchen_scene.tscn")

func _on_act2_pressed():
	_transition_to_scene("res://scenes/sink_scene.tscn")

func _on_act3_pressed():
	_transition_to_scene("res://scenes/farm_scene.tscn")

func _on_back_pressed():
	_transition_to_scene("res://scenes/menu/mainMenu.tscn")

func _transition_to_scene(scene_path: String):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file(scene_path)

func _show_coming_soon(act_name: String):
	var popup = AcceptDialog.new()
	popup.title = "Coming Soon"
	popup.dialog_text = act_name + " is coming soon!\n\nFor now, try Act 1 or Act 2 to experience Chad's journey from tech bro to zen farmer."
	add_child(popup)
	popup.popup_centered()

func _input(event):
	# Allow ESC to go back
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
