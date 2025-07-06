extends Control

# Sink Scene Script
# Intro screen for the cleaning minigame

@onready var start_cleaning_button = $ContentContainer/ButtonContainer/StartCleaningButton
@onready var back_button = $ContentContainer/ButtonContainer/BackButton

func _ready():
	_connect_signals()
	_setup_scene()

func _setup_scene():
	# Add fade-in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	
	# Focus on the main button
	start_cleaning_button.grab_focus()

func _connect_signals():
	start_cleaning_button.pressed.connect(_on_start_cleaning_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_start_cleaning_pressed():
	# Fade out and transition to Act 2
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/acts/act2_casserole_crisis.tscn")

func _on_back_pressed():
	# Go back to game choose page
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/game_choose.tscn")

func _input(event):
	# Allow pressing Enter/Space to start cleaning
	if event.is_action_pressed("ui_accept"):
		_on_start_cleaning_pressed()
	
	# Allow pressing Escape to go back
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
