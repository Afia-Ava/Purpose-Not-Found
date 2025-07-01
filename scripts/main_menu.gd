extends Control

# Main Menu Script for Purpose Not Found
# Handles navigation between acts and game modes

@onready var new_game_btn = $MenuButtons/NewGameBtn
@onready var act1_btn = $MenuButtons/Act1Btn
@onready var act2_btn = $MenuButtons/Act2Btn
@onready var act5_btn = $MenuButtons/Act5Btn
@onready var credits_btn = $MenuButtons/CreditsBtn
@onready var quit_btn = $MenuButtons/QuitBtn

func _ready():
	_connect_buttons()
	_setup_intro_animation()

func _connect_buttons():
	new_game_btn.pressed.connect(_on_new_game_pressed)
	act1_btn.pressed.connect(_on_act1_pressed)
	act2_btn.pressed.connect(_on_act2_pressed)
	act5_btn.pressed.connect(_on_act5_pressed)
	credits_btn.pressed.connect(_on_credits_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _setup_intro_animation():
	# Animate the character transformation preview
	var zen_farmer = $CharacterPreview/ZenFarmerPreview
	
	# Start with tech bro visible
	zen_farmer.modulate = Color(1, 1, 1, 0)
	
	# Create a repeating transformation animation
	_animate_transformation()

func _animate_transformation():
	var tech_bro = $CharacterPreview/TechBroPreview
	var zen_farmer = $CharacterPreview/ZenFarmerPreview
	
	var tween = create_tween()
	tween.set_loops()
	
	# Tech bro visible for 3 seconds
	tween.tween_interval(3.0)
	
	# Fade to zen farmer
	tween.tween_property(tech_bro, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.parallel().tween_property(zen_farmer, "modulate", Color(1, 1, 1, 1), 1.0)
	
	# Zen farmer visible for 3 seconds
	tween.tween_interval(3.0)
	
	# Fade back to tech bro
	tween.tween_property(zen_farmer, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.parallel().tween_property(tech_bro, "modulate", Color(1, 1, 1, 1), 1.0)

func _on_new_game_pressed():
	# Start from the beginning
	get_tree().change_scene_to_file("res://scenes/acts/act1_burnout_boulevard.tscn")

func _on_act1_pressed():
	# Jump to Act 1
	get_tree().change_scene_to_file("res://scenes/acts/act1_burnout_boulevard.tscn")

func _on_act2_pressed():
	# Jump to Act 2
	get_tree().change_scene_to_file("res://scenes/acts/act2_casserole_crisis.tscn")

func _on_act5_pressed():
	# Jump to final act
	get_tree().change_scene_to_file("res://scenes/acts/act5_farmhouse_festival.tscn")

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

CONCEPT: Tech Bro Redemption Arc
GENRE: Visual Novel × Life Sim × Comedy RPG  
VIBES: Stardew Valley meets Silicon Valley (HBO)

🎮 MINIGAMES:
• Pitch or Ditch - VC Buzzword Bingo
• Slack Attack - Message Management Chaos
• Overcooked but Chill - Cooking with Sandra
• Fridge Tetris - SF Apartment Tetris
• Therapy Thursdays - Emotional Growth

🎭 CHARACTERS:
• You - Burnt-out Startup Founder
• Crypto Kyle - The NFT True Believer  
• Hustle Harrison - Productivity Bro
• Minimalist Marcus - Anxious Declutterer
• Sage Sandra - Wise Neighbor with Impossible Garden
• Dr. Patricia Chen - Therapist with Plants
• Venture Victor - Your Ex-Cofounder

🎯 ENDINGS:
• Zen Farmer - Peace through Plants
• Climate Startup - Ethical Entrepreneurship  
• Mentor Mode - Teaching Other Burnt Bros

Thanks for playing! 
May your vegetables be organic and your stress levels low.

Created with love, soil, and way too much caffeine.
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
