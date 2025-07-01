extends Control

# Act 5: Farmhouse Festival - The Final Transformation
# Host a harvest dinner, reconnect with old friends, show your growth

@onready var player = $Player
@onready var dialogue_text = $UI/DialogueBox/DialogueText
@onready var zen_farmer_btn = $UI/EndingButtons/ZenFarmerBtn
@onready var climate_startup_btn = $UI/EndingButtons/ClimateStartupBtn  
@onready var teach_others_btn = $UI/EndingButtons/TeachOthersBtn

var ending_selected: bool = false
var dinner_party_complete: bool = false

# Final dialogue sequence showing transformation
var final_dialogues = [
	{
		"speaker": "Narrator",
		"text": "Six months later. Your hands are dirty with soil, not with stress. The old frat house feels like a different lifetime.",
		"mood": "reflective"
	},
	{
		"speaker": "Kyle",
		"text": "Bro... your tomatoes are literally organic and profitable. Have you considered tokenizing this operation?",
		"mood": "still_missing_the_point"
	},
	{
		"speaker": "Player",
		"text": "Kyle, sometimes the best investment is just... being present.",
		"mood": "zen_master"
	},
	{
		"speaker": "Harrison",
		"text": "I've been tracking your happiness metrics. Your baseline well-being has increased 340%. Can you teach me?",
		"mood": "finally_getting_it"
	},
	{
		"speaker": "Sandra",
		"text": "You've learned that growing something real takes time, patience, and dirty hands. I'm proud of you, sweetie.",
		"mood": "mentor_validation"
	},
	{
		"speaker": "Player",
		"text": "I used to think success meant scaling fast and breaking things. Now I know it means growing slow and healing things.",
		"mood": "wisdom_earned"
	}
]

var current_dialogue_index: int = 0

func _ready():
	_connect_signals()
	_update_final_stats()
	_start_final_scene()

func _connect_signals():
	zen_farmer_btn.pressed.connect(_on_zen_farmer_ending)
	climate_startup_btn.pressed.connect(_on_climate_startup_ending)
	teach_others_btn.pressed.connect(_on_teach_others_ending)

func _update_final_stats():
	# Show the transformed character stats
	player.burnout_level = 15
	player.health = 95
	player.social_energy = 85
	player.cooking_skill = 80
	player.farming_skill = 90
	player.emotional_intelligence = 85
	
	# Update UI to reflect final state
	player.current_state = player.CharacterState.ZEN_FARMER

func _start_final_scene():
	dialogue_text.text = "[color=gray][i]The harvest dinner is set. Your old roommates are coming. Time to show them what you've become...[/i][/color]"
	
	await get_tree().create_timer(3.0).timeout
	_advance_dialogue()

func _advance_dialogue():
	if current_dialogue_index < final_dialogues.size():
		var dialogue = final_dialogues[current_dialogue_index]
		var color = _get_speaker_color(dialogue["speaker"])
		dialogue_text.text = "[color=" + color + "]" + dialogue["speaker"] + ":[/color] " + dialogue["text"]
		current_dialogue_index += 1
		
		await get_tree().create_timer(4.0).timeout
		_advance_dialogue()
	else:
		_show_ending_choices()

func _get_speaker_color(speaker: String) -> String:
	match speaker:
		"Kyle": return "orange"
		"Harrison": return "cyan"
		"Sandra": return "green"
		"Player": return "yellow"
		"Narrator": return "gray"
		_: return "white"

func _show_ending_choices():
	dialogue_text.text = "[center][color=gold]🌟 THE PATH FORWARD 🌟\n\nYou've transformed your life. Now, what's next?[/color][/center]"
	
	# Enable ending choice buttons
	zen_farmer_btn.disabled = false
	climate_startup_btn.disabled = false
	teach_others_btn.disabled = false

func _on_zen_farmer_ending():
	if ending_selected:
		return
	ending_selected = true
	
	dialogue_text.text = "[center][color=green]🧘‍♂️ ZEN FARMER ENDING 🧘‍♂️\n\nYou choose peace. Your farm becomes a sanctuary where burnt-out tech workers come to heal. You have chickens now. They're very wise.[/color][/center]"
	_show_final_message("zen_farmer")

func _on_climate_startup_ending():
	if ending_selected:
		return
	ending_selected = true
	
	dialogue_text.text = "[center][color=blue]🌱 ETHICAL ENTREPRENEUR ENDING 🌱\n\nYou start a climate tech company, but this time you hire ethically, work sustainable hours, and water your office plants daily. Work-life balance unlocked.[/color][/center]"
	_show_final_message("climate_startup")

func _on_teach_others_ending():
	if ending_selected:
		return
	ending_selected = true
	
	dialogue_text.text = "[center][color=purple]🎓 MENTOR ENDING 🎓\n\nYou become the person Sandra was for you. Teaching other burnt-out startup bros that there's more to life than hockey stick growth curves.[/color][/center]"
	_show_final_message("mentor")

func _show_final_message(ending_type: String):
	await get_tree().create_timer(4.0).timeout
	
	var final_message = "[center][color=gold]🎮 THANK YOU FOR PLAYING 🎮\n\n"
	final_message += "You completed: PURPOSE NOT FOUND → PURPOSE FOUND\n\n"
	
	match ending_type:
		"zen_farmer":
			final_message += "Achievement Unlocked: 'Touched Grass (Literally)'\n"
			final_message += "Fun Fact: You can now identify 47 types of soil by smell"
		"climate_startup":
			final_message += "Achievement Unlocked: 'Ethical Disruption'\n"
			final_message += "Fun Fact: Your company's mission statement fits in one sentence"
		"mentor":
			final_message += "Achievement Unlocked: 'Pay It Forward'\n"
			final_message += "Fun Fact: You've saved 23 startup bros from burnout"
	
	final_message += "\n\nPress ESC to return to menu[/color][/center]"
	
	dialogue_text.text = final_message

# Easter eggs and interactions
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/menu/mainMenu.tscn")
	
	if event.is_action_pressed("ui_accept") and not ending_selected:
		if current_dialogue_index < final_dialogues.size():
			_advance_dialogue()
	
	# Final easter eggs
	if event is InputEventKey and event.pressed and not ending_selected:
		match event.keycode:
			KEY_C:  # Check chickens
				dialogue_text.text = "[color=gray]Your chickens are named Agile, Scrum, and DevOps. They're very productive.[/color]"
			KEY_G:  # Garden wisdom
				dialogue_text.text = "[color=green]Sandra:[/color] Look how far you've grown, dear. From ramen cups to harvest festivals."
			KEY_M:  # Marcus reaction
				dialogue_text.text = "[color=white]Marcus:[/color] Your life now has the perfect minimalist aesthetic: only what brings joy."
