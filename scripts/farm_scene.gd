extends Control

# Farm Scene Script
# Intro screen for the farming experience

@onready var start_farming_button = $ContentContainer/ButtonContainer/StartFarmingButton
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
	start_farming_button.grab_focus()

func _connect_signals():
	start_farming_button.pressed.connect(_on_start_farming_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_start_farming_pressed():
	# For now, show a coming soon message since Act 3 farming isn't implemented yet
	_show_coming_soon()

func _on_back_pressed():
	# Go back to game choose page
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/game_choose.tscn")

func _show_coming_soon():
	var popup = AcceptDialog.new()
	popup.title = "Coming Soon"
	popup.dialog_text = "The farming experience is being cultivated! 🌱\n\nFor now, try the cooking or cleaning experiences to begin Chad's transformation from tech bro to zen farmer.\n\nPatience, young grasshopper—good things grow slowly."
	add_child(popup)
	popup.popup_centered()
	
	# Connect the popup close signal to refocus
	popup.confirmed.connect(_on_popup_closed)

func _on_popup_closed():
	start_farming_button.grab_focus()

func _input(event):
	# Allow pressing Enter/Space to start farming
	if event.is_action_pressed("ui_accept"):
		_on_start_farming_pressed()
	
	# Allow pressing Escape to go back
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
