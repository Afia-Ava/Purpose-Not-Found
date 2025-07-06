extends Control

# Main Menu Script for Purpose Not Found
# Handles navigation for the streamlined main menu

@onready var start_game_btn = $TitleContainer/StartGameBtn
@onready var credits_btn = $SecondaryButtons/CreditsBtn
@onready var quit_btn = $SecondaryButtons/QuitBtn

func _ready():
	_connect_buttons()

func _connect_buttons():
	start_game_btn.pressed.connect(_on_start_game_pressed)
	credits_btn.pressed.connect(_on_credits_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _on_start_game_pressed():
	# Show the letter scene first
	get_tree().change_scene_to_file("res://scenes/letter_scene.tscn")

func _on_credits_pressed():
	_show_credits()

func _on_quit_pressed():
	get_tree().quit()

func _show_credits():
	# Create a credits popup
	var credits_popup = AcceptDialog.new()
	credits_popup.title = "Credits - Purpose Not Found"
	credits_popup.dialog_text = """
🌱 PURPOSE NOT FOUND 🌱
From Tech Bro to Zen Farmer
A game about finding meaning beyond the grind

🧠 CONCEPT
The Tech Bro Redemption Arc — your journey from ramen-fueled burnout to backyard peace.

🎮 GENRE
Visual Novel × Life Sim × Comedy RPG

🎭 VIBES
Stardew Valley meets Silicon Valley (HBO)

🎯 MINIGAMES
🍳 Burnt or Brunch – Cook something that's actually edible
🧽 Dish Dodge – Survive the never-ending sink pile
🌿 Zen Garden – Grow plants (and a little bit of peace)
"""
	
	add_child(credits_popup)
	credits_popup.popup_centered()
	
	# Remove popup when closed
	credits_popup.confirmed.connect(credits_popup.queue_free)

# Easter eggs for main menu
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_K:  # Kyle easter egg
				_show_popup("Kyle says:", "Bro, this main menu is bullish for user engagement!")
			KEY_H:  # Harrison easter egg
				_show_popup("Harrison says:", "Have you optimized your menu navigation funnel?")
			KEY_S:  # Sandra easter egg
				_show_popup("Sandra says:", "Every journey begins with a single step, dear.")

func _show_popup(title: String, text: String):
	var popup = AcceptDialog.new()
	popup.title = title
	popup.dialog_text = text
	add_child(popup)
	popup.popup_centered()
	popup.confirmed.connect(popup.queue_free)
