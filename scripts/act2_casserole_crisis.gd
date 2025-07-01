extends Control

@onready var player = $Player
@onready var dialogue_text = $UI/DialogueBox/DialogueText
@onready var burnout_label = $UI/StatsPanel/StatsContainer/BurnoutLabel
@onready var health_label = $UI/StatsPanel/StatsContainer/HealthLabel
@onready var social_label = $UI/StatsPanel/StatsContainer/SocialLabel
@onready var cooking_label = $UI/StatsPanel/StatsContainer/CookingLabel
@onready var farming_label = $UI/StatsPanel/StatsContainer/FarmingLabel
@onready var cooking_btn = $UI/MinigameButtons/CookingBtn
@onready var grocery_btn = $UI/MinigameButtons/GroceryBtn
@onready var fridge_btn = $UI/MinigameButtons/FridgeBtn
@onready var talk_sandra_btn = $UI/MinigameButtons/TalkToSandraBtn

var current_dialogue_index: int = 0
var act2_dialogues: Array[Dictionary] = []
var sandra_conversation_stage: int = 0

var sandra_quotes = [
	"I see you looking at my garden, dear. Plants sense when someone needs grounding.",
	"You know, I've never seen someone look so hungry while holding a full coffee cup.",
	"The secret to good soil is patience, sweetie. Same with good cooking.",
	"Plants teach us that growth happens slowly, then all at once.",
	"Would you like to try growing something? I have some extra seeds."
]

func _ready():
	_setup_act2_dialogues()
	_connect_signals()
	_update_ui()
	_start_opening_scene()

func _setup_act2_dialogues():
	act2_dialogues = [
		{
			"speaker": "Narrator",
			"text": "Two weeks later. You've started taking walks to escape the frat house chaos. There's a neighbor with an impossible garden...",
			"mood": "curious"
		},
		{
			"speaker": "Player",
			"text": "How does she grow tomatoes in San Francisco? That defies all logic and weather patterns.",
			"mood": "confused_admiration"
		},
		{
			"speaker": "Sandra",
			"text": sandra_quotes[0],
			"mood": "wise_earth_mother"
		},
		{
			"speaker": "Player", 
			"text": "I... I don't even know how to make a salad without ordering it on DoorDash.",
			"mood": "embarrassed_honesty"
		},
		{
			"speaker": "Sandra",
			"text": "Well then, shall we start with something simple? Cooking is just chemistry with love.",
			"mood": "gentle_teaching"
		}
	]

func _connect_signals():
	cooking_btn.pressed.connect(_on_cooking_pressed)
	grocery_btn.pressed.connect(_on_grocery_pressed)
	fridge_btn.pressed.connect(_on_fridge_pressed)
	talk_sandra_btn.pressed.connect(_on_talk_sandra_pressed)	
	player.stat_changed.connect(_on_stat_changed)

func _start_opening_scene():
	dialogue_text.text = "[color=gray][i]You've been walking past this garden every day. The neighbor always seems to know exactly when you need to see something growing...[/i][/color]"
	
	await get_tree().create_timer(3.0).timeout
	_advance_dialogue()

func _advance_dialogue():
	if current_dialogue_index < act2_dialogues.size():
		var dialogue = act2_dialogues[current_dialogue_index]
		var color = _get_speaker_color(dialogue["speaker"])
		dialogue_text.text = "[color=" + color + "]" + dialogue["speaker"] + ":[/color] " + dialogue["text"]
		current_dialogue_index += 1
		if dialogue["speaker"] != "Player":
			await get_tree().create_timer(4.0).timeout
			_advance_dialogue()
		else:
			_enable_interaction_buttons()

func _get_speaker_color(speaker: String) -> String:
	match speaker:
		"Sandra": return "green"
		"Player": return "yellow"
		"Narrator": return "gray"
		_: return "white"

func _enable_interaction_buttons():
	cooking_btn.disabled = false
	grocery_btn.disabled = false 
	fridge_btn.disabled = false
	talk_sandra_btn.disabled = false

func _on_cooking_pressed():
	dialogue_text.text = "[color=yellow]Sandra hands you an apron. 'Let's start with scrambled eggs,' she says gently.[/color]"
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/minigames/overcooked_chill.tscn")

func _on_grocery_pressed():
	dialogue_text.text = "[color=yellow]Time to venture into the hipster grocery store of doom...[/color]"
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/minigames/grocery_quest.tscn")

func _on_fridge_pressed():
	dialogue_text.text = "[color=yellow]Your tiny SF fridge is about to become a Tetris nightmare...[/color]"
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/minigames/fridge_tetris.tscn")

func _on_talk_sandra_pressed():
	_have_sandra_conversation()

func _have_sandra_conversation():
	if sandra_conversation_stage < sandra_quotes.size():
		var quote = sandra_quotes[sandra_conversation_stage]
		dialogue_text.text = "[color=green]Sandra:[/color] " + quote
		sandra_conversation_stage += 1		
		player.update_skill("emotional", 5)
		
		match sandra_conversation_stage:
			2:
				await get_tree().create_timer(3.0).timeout
				dialogue_text.text = "[color=yellow]You:[/color] I've been living on delivery apps and energy drinks for two years."
			3:
				await get_tree().create_timer(3.0).timeout
				dialogue_text.text = "[color=yellow]You:[/color] I used to think patience was a inefficiency..."
			4:
				await get_tree().create_timer(3.0).timeout
				dialogue_text.text = "[color=yellow]You:[/color] Maybe I could try growing something small?"
				player.update_skill("farming", 10)
			5:
				await get_tree().create_timer(3.0).timeout
				dialogue_text.text = "[color=yellow]You:[/color] Thank you, Sandra. I... I haven't felt this calm in years."
				player.update_burnout(-15)
	else:
		dialogue_text.text = "[color=green]Sandra:[/color] You're learning to listen to yourself again, dear. That's the first step."

func _on_stat_changed(_stat_name: String, _new_value: int):
	_update_ui()

func _update_ui():
	burnout_label.text = "🔥 Burnout: " + str(player.burnout_level) + "%"
	health_label.text = "❤️ Health: " + str(player.health) + "%"
	social_label.text = "😊 Social: " + str(player.social_energy) + "%"
	cooking_label.text = "🍳 Cooking: " + str(player.cooking_skill) + "%"
	farming_label.text = "🌱 Farming: " + str(player.farming_skill) + "%"

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if current_dialogue_index < act2_dialogues.size():
			_advance_dialogue()
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_G:
				dialogue_text.text = "[color=green]Sandra:[/color] Each plant here has a story. This tomato? Took three tries to get right."
			KEY_S: 
				dialogue_text.text = "[color=gray][i]You breathe in. Rosemary, lavender, and something that smells like... hope?[/i][/color]"
			KEY_H: 
				dialogue_text.text = "[color=yellow]You:[/color] I spent $200,000 trying to 'disrupt' agriculture and Sandra's doing it in her backyard for free."

