extends Control

@onready var player = $Player
@onready var dialogue_text = $UI/DialogueBox/DialogueText
# Stats panel hidden - removed all references
@onready var cooking_btn = $UI/MinigameButtons/CookingBtn
@onready var dishwashing_btn = $UI/MinigameButtons/DishwashingBtn
@onready var gardening_btn = $UI/MinigameButtons/GardeningBtn
@onready var talk_sandra_btn = $UI/MinigameButtons/TalkToSandraBtn
@onready var background_sprite = $Background

var current_dialogue_index: int = 0
var act2_dialogues: Array[Dictionary] = []
var sandra_conversation_stage: int = 0

# Background resources
var backgrounds = {
	"garden": preload("res://assets/kitchen-scene.jpg"),
	"kitchen": preload("res://assets/sink-scene.jpg"),
	"default": preload("res://assets/kitchen-scene.jpg")
}

var current_background: String = "garden"

var sandra_quotes = [
	"I see you looking at my garden, dear. Plants sense when someone needs grounding.",
	"You know, there's something therapeutic about clean dishes and fresh ingredients.",
	"The secret to good soil is patience, sweetie. Same with good cooking and clean dishes.",
	"Every task - cooking, cleaning, growing - teaches us something about caring for ourselves.",
	"Would you like to try? I have three simple lessons: cook, clean, and grow."
]

func _ready():
	_setup_act2_dialogues()
	_connect_signals()
	_set_background("garden")
	_start_opening_scene()

func _set_background(background_name: String):
	if background_name in backgrounds:
		current_background = background_name
		if background_sprite:
			background_sprite.texture = backgrounds[background_name]
		print("Background changed to: ", background_name)
	else:
		print("Background not found: ", background_name)

func _transition_background(new_background: String, duration: float = 1.0):
	if new_background == current_background:
		return
	
	# Create a smooth transition effect
	var tween = create_tween()
	tween.tween_property(background_sprite, "modulate:a", 0.0, duration / 2)
	tween.tween_callback(func(): _set_background(new_background))
	tween.tween_property(background_sprite, "modulate:a", 1.0, duration / 2)

func _setup_act2_dialogues():
	act2_dialogues = [
		{
			"speaker": "Narrator",
			"text": "You've started taking walks to escape the chaos. There's a neighbor with an impossible garden...",
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
			"text": "Well then, let's start with the basics. Cooking, cleaning, growing. Life's simple rhythms.",
			"mood": "gentle_teaching"
		},
		{
			"speaker": "Narrator",
			"text": "Choose your path: Learn to cook, master dishwashing, or discover the art of gardening.",
			"mood": "instructional"
		}
	]

func _connect_signals():
	cooking_btn.pressed.connect(_on_cooking_pressed)
	dishwashing_btn.pressed.connect(_on_dishwashing_pressed)
	gardening_btn.pressed.connect(_on_gardening_pressed)
	talk_sandra_btn.pressed.connect(_on_talk_sandra_pressed)

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
	dishwashing_btn.disabled = false 
	gardening_btn.disabled = false
	talk_sandra_btn.disabled = false

func _on_cooking_pressed():
	_transition_background("kitchen", 1.5)
	dialogue_text.text = "[color=yellow]Sandra hands you an apron. 'Let's start with scrambled eggs,' she says gently.[/color]"
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/minigames/cooking_minigame.tscn")

func _on_dishwashing_pressed():
	_transition_background("kitchen", 1.5)
	dialogue_text.text = "[color=yellow]Time to tackle the mountain of dishes. At least it's meditative... right?[/color]"
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/minigames/dishwashing_minigame.tscn")

func _on_gardening_pressed():
	_transition_background("garden", 1.5)
	dialogue_text.text = "[color=yellow]Sandra shows you her garden. 'Every plant teaches patience,' she says with a smile.[/color]"
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/minigames/gardening_minigame.tscn")

func _on_talk_sandra_pressed():
	_have_sandra_conversation()

func _have_sandra_conversation():
	if sandra_conversation_stage < sandra_quotes.size():
		var quote = sandra_quotes[sandra_conversation_stage]
		dialogue_text.text = "[color=green]Sandra:[/color] " + quote
		sandra_conversation_stage += 1		
		
		match sandra_conversation_stage:
			2:
				await get_tree().create_timer(3.0).timeout
				dialogue_text.text = "[color=yellow]You:[/color] I've been living on delivery apps and energy drinks for two years."
			3:
				_transition_background("kitchen", 2.0)
				await get_tree().create_timer(3.0).timeout
				dialogue_text.text = "[color=yellow]You:[/color] I used to think washing dishes was just... wasted time..."
			4:
				_transition_background("garden", 2.0)
				await get_tree().create_timer(3.0).timeout
				dialogue_text.text = "[color=yellow]You:[/color] Maybe I could try learning these three things?"
			5:
				await get_tree().create_timer(3.0).timeout
				dialogue_text.text = "[color=yellow]You:[/color] Thank you, Sandra. I... I want to learn how to take care of myself."
	else:
		dialogue_text.text = "[color=green]Sandra:[/color] Remember: cook with love, clean with mindfulness, grow with patience."

func _on_stat_changed(_stat_name: String, _new_value: int):
	# No stats tracking needed for story-driven experience
	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if current_dialogue_index < act2_dialogues.size():
			_advance_dialogue()
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_C:
				_transition_background("kitchen", 1.0)
				dialogue_text.text = "[color=green]Sandra:[/color] Cooking is about patience and love. Let's start simple."
			KEY_D:
				_transition_background("kitchen", 1.0)
				dialogue_text.text = "[color=green]Sandra:[/color] Clean dishes are the foundation of any good kitchen."
			KEY_G:
				_transition_background("garden", 1.0)
				dialogue_text.text = "[color=green]Sandra:[/color] Each plant here has a story. This tomato? Took three tries to get right."
			KEY_S: 
				dialogue_text.text = "[color=gray][i]You breathe in. Rosemary, lavender, and something that smells like... hope?[/i][/color]"
			KEY_H: 
				dialogue_text.text = "[color=yellow]You:[/color] I spent $200,000 trying to 'disrupt' agriculture and Sandra's doing it in her backyard for free."
