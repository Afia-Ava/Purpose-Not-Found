extends Control

# Letter Scene Script
# Shows an introductory letter before starting the game

@onready var continue_button = $LetterContainer/LetterPage/ContinueButton
@onready var letter_container = $LetterContainer

func _ready():
	_setup_letter_scene()
	_connect_signals()

func _setup_letter_scene():
	# Add a subtle animation to the letter appearing
	letter_container.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(letter_container, "modulate:a", 1.0, 1.0)
	
	# Focus on the continue button
	continue_button.grab_focus()

func _connect_signals():
	continue_button.pressed.connect(_on_continue_pressed)

func _on_continue_pressed():
	# Fade out and transition to game choose page
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	# Go to game choose page
	get_tree().change_scene_to_file("res://scenes/game_choose.tscn")

func _input(event):
	# Allow pressing Enter/Space to continue
	if event.is_action_pressed("ui_accept"):
		_on_continue_pressed()
