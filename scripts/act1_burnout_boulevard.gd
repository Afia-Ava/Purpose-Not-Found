extends Control

# Act 1: Burnout Boulevard Script
# The frat house startup life - stress, mess, and bad decisions

@onready var player = $Player
@onready var dialogue_text = $UI/DialogueBox/DialogueText
@onready var burnout_label = $UI/StatsPanel/StatsContainer/BurnoutLabel
@onready var health_label = $UI/StatsPanel/StatsContainer/HealthLabel
@onready var social_label = $UI/StatsPanel/StatsContainer/SocialLabel
@onready var cooking_label = $UI/StatsPanel/StatsContainer/CookingLabel

@onready var pitch_ditch_btn = $UI/MinigameButtons/PitchDitchBtn
@onready var slack_attack_btn = $UI/MinigameButtons/SlackAttackBtn
@onready var cleaning_btn = $UI/MinigameButtons/CleaningBtn

var current_dialogue_index: int = 0
var act1_dialogues: Array[Dictionary] = []

# Character dialogue data
var character_dialogue = {
	"Kyle": {
		"startup_failure": "Bro, Y Combinator just doesn't understand our vision. Have you considered pivoting to DeFi?",
		"general": "This is actually bullish for our personal growth, dude!"
	},
	"Harrison": {
		"startup_failure": "The failure is just data, bro. What's your next growth hack?",
		"general": "I'm optimizing my rejection processing pipeline."
	},
	"Marcus": {
		"startup_failure": "Maybe this is the universe telling you to declutter your life goals.",
		"general": "I've minimized my expectations to zero. Very freeing."
	}
}

func _ready():
	_setup_act1_dialogues()
	_connect_signals()
	_update_ui()
	
	# Start with opening scene
	_start_opening_scene()

func _setup_act1_dialogues():
	act1_dialogues = [
		{
			"speaker": "Narrator",
			"text": "It's 3 PM on a Tuesday. You're in your boxers, eating cereal from a coffee mug because all the bowls are dirty.",
			"mood": "existential_dread"
		},
		{
			"speaker": "Kyle", 
			"text": character_dialogue["Kyle"]["startup_failure"],
			"mood": "clueless_optimism"
		},
		{
			"speaker": "Harrison",
			"text": "The failure is just data, bro. What's your next growth hack?",
			"mood": "toxic_positivity"
		},
		{
			"speaker": "Marcus",
			"text": "Maybe this is the universe telling you to declutter your life goals.",
			"mood": "minimalist_wisdom"
		},
		{
			"speaker": "Player",
			"text": "...Maybe I should just clean the kitchen first?",
			"mood": "small_epiphany"
		}
	]

func _connect_signals():
	pitch_ditch_btn.pressed.connect(_on_pitch_ditch_pressed)
	slack_attack_btn.pressed.connect(_on_slack_attack_pressed)
	cleaning_btn.pressed.connect(_on_cleaning_pressed)
	
	# Connect to player stats changes
	player.stat_changed.connect(_on_stat_changed)

func _start_opening_scene():
	dialogue_text.text = "[color=gray][i]The Y Combinator rejection email sits open on your laptop. Your startup dreams are crumbling faster than the week-old pizza in the corner...[/i][/color]"
	
	# Auto-advance to character dialogues after a moment
	await get_tree().create_timer(3.0).timeout
	_advance_dialogue()

func _advance_dialogue():
	if current_dialogue_index < act1_dialogues.size():
		var dialogue = act1_dialogues[current_dialogue_index]
		var color = _get_speaker_color(dialogue["speaker"])
		dialogue_text.text = "[color=" + color + "]" + dialogue["speaker"] + ":[/color] " + dialogue["text"]
		current_dialogue_index += 1
		
		# Auto-advance for story beats, pause for player input
		if dialogue["speaker"] != "Player":
			await get_tree().create_timer(4.0).timeout
			_advance_dialogue()
		else:
			# Enable minigame buttons when player speaks
			_enable_minigame_buttons()

func _get_speaker_color(speaker: String) -> String:
	match speaker:
		"Kyle": return "orange"
		"Harrison": return "cyan"
		"Marcus": return "white"
		"Player": return "yellow"
		"Narrator": return "gray"
		_: return "white"

func _enable_minigame_buttons():
	pitch_ditch_btn.disabled = false
	slack_attack_btn.disabled = false
	cleaning_btn.disabled = false

func _on_pitch_ditch_pressed():
	dialogue_text.text = "[color=yellow]Starting Pitch or Ditch minigame...[/color]"
	# Load the Pitch or Ditch minigame scene
	get_tree().change_scene_to_file("res://scenes/minigames/pitch_or_ditch.tscn")

func _on_slack_attack_pressed():
	dialogue_text.text = "[color=yellow]Slack messages incoming! Prepare for chaos...[/color]"
	# Load the Slack Attack minigame scene
	get_tree().change_scene_to_file("res://scenes/minigames/slack_attack.tscn")

func _on_cleaning_pressed():
	dialogue_text.text = "[color=yellow]Time to face the kitchen of doom...[/color]"
	# Start the cleaning rhythm game
	get_tree().change_scene_to_file("res://scenes/minigames/dishwashing_rhythm.tscn")

func _on_stat_changed(_stat_name: String, _new_value: int):
	_update_ui()

func _update_ui():
	burnout_label.text = "🔥 Burnout: " + str(player.burnout_level) + "%"
	health_label.text = "❤️ Health: " + str(player.health) + "%"
	social_label.text = "😊 Social: " + str(player.social_energy) + "%"
	cooking_label.text = "🍳 Cooking: " + str(player.cooking_skill) + "%"

# Easter eggs and environmental interactions
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if current_dialogue_index < act1_dialogues.size():
			_advance_dialogue()
	
	# Secret cheat codes for testing
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				player.update_burnout(-10)
			KEY_2:
				player.update_skill("cooking", 5)
			KEY_3:
				# Easter egg dialogue
				dialogue_text.text = "[color=orange]Kyle:[/color] Did you know our coffee machine is worth more than most people's cars? Peak 2023 energy."
