extends Control

@onready var stress_bar = $StressBar
@onready var vc_reaction = $VCReaction
@onready var score_label = $ScoreLabel
@onready var result_timer = $ResultTimer

var stress_level: int = 50
var vc_score: int = 0
var buzzwords_used: int = 0
var game_over: bool = false
var buzzword_effects = {
	"leveraging synergy": {"stress": 15, "vc_love": 20, "cringe": 10},
	"disrupting disruption": {"stress": 25, "vc_love": 30, "cringe": 40},
	"scaling at scale": {"stress": 20, "vc_love": 25, "cringe": 30},
	"AI-powered growth": {"stress": 10, "vc_love": 35, "cringe": 20},
	"blockchain farming": {"stress": 30, "vc_love": 15, "cringe": 50},
	"unicorn potential": {"stress": 35, "vc_love": 40, "cringe": 45},
	"growing actual food": {"stress": -10, "vc_love": -20, "cringe": -30},
	"building community": {"stress": -5, "vc_love": -10, "cringe": -20},
	"sustainable practices": {"stress": 0, "vc_love": 10, "cringe": -10}
}

var vc_reactions = {
	"low_score": [
		"I'm not seeing the hockey stick growth potential here...",
		"This doesn't seem like a billion-dollar opportunity.",
		"Have you thought about the total addressable market?",
		"I'm just not feeling the product-market fit."
	],
	"medium_score": [
		"Interesting... tell me more about your go-to-market strategy.",
		"I can see some potential, but what's your moat?",
		"The market timing might be right for this.",
		"How are you planning to defend against competitors?"
	],
	"high_score": [
		"Now THIS is the kind of disruption we're looking for!",
		"I'm seeing serious unicorn potential here!",
		"This could be the next big thing in agtech!",
		"When can we schedule a Series A conversation?"
	],
	"cringe_overload": [
		"I think we're having some technical difficulties...",
		"Sorry, I'm getting another call. We'll circle back.",
		"My calendar is pretty full for the next... forever.",
		"Have you considered pivoting to a different industry?"
	]
}

func _ready():
	_connect_buttons()
	_update_ui()
	result_timer.timeout.connect(_end_game)

func _connect_buttons():
	for button in $BuzzwordButtons.get_children():
		button.pressed.connect(_on_buzzword_pressed.bind(button.text))

func _on_buzzword_pressed(buzzword: String):
	if game_over:
		return
		
	buzzwords_used += 1
	var effects = buzzword_effects[buzzword]
	stress_level += effects["stress"]
	vc_score += effects["vc_love"]	
	stress_level = min(stress_level, 100)
	_update_ui()
	_show_vc_reaction(buzzword, effects)	
	if stress_level >= 100:
		_trigger_stress_crash()
	elif buzzwords_used >= 3:
		result_timer.start()

func _show_vc_reaction(buzzword: String, effects: Dictionary):
	var reaction: String
	var color: String
	
	if effects["cringe"] > 30:
		reaction = "Chad winces visibly at '" + buzzword + "'"
		color = "red"
	elif effects["vc_love"] > 25:
		reaction = "Chad's eyes light up! '" + buzzword.capitalize() + "? I LOVE IT!'"
		color = "green"
	elif effects["stress"] < 0:
		reaction = "Chad looks confused. 'That's... refreshingly honest?'"
		color = "yellow"
	else:
		reaction = "Chad nods thoughtfully at '" + buzzword + "'"
		color = "white"
	vc_reaction.text = "[center][color=" + color + "]" + reaction + "[/color][/center]"

func _trigger_stress_crash():
	game_over = true
	vc_reaction.text = "[center][color=red]🔥 STRESS OVERLOAD! 🔥\nYou freeze up mid-sentence. Chad politely ends the call.[/color][/center]"
	
	await get_tree().create_timer(3.0).timeout
	_return_to_act1(false)

func _update_ui():
	stress_bar.value = stress_level
	score_label.text = "💰 VC Score: " + str(vc_score)
	
	if stress_level < 30:
		stress_bar.modulate = Color.GREEN
	elif stress_level < 70:
		stress_bar.modulate = Color.YELLOW
	else:
		stress_bar.modulate = Color.RED

func _end_game():
	if game_over:
		return
	
	game_over = true
	var success = _calculate_final_result()
	_show_final_reaction(success)
	
	await get_tree().create_timer(3.0).timeout
	_return_to_act1(success)

func _calculate_final_result() -> bool:
	var total_cringe = 0
	for button in $BuzzwordButtons.get_children():
		if button.button_pressed:
			total_cringe += buzzword_effects[button.text]["cringe"]
	
	return vc_score >= 40 and total_cringe < 80 and stress_level < 100

func _show_final_reaction(success: bool):
	var reaction_category: String
	
	if stress_level >= 100:
		reaction_category = "cringe_overload"
	elif success:
		reaction_category = "high_score"
	elif vc_score >= 20:
		reaction_category = "medium_score"
	else:
		reaction_category = "low_score"
	
	var reactions = vc_reactions[reaction_category]
	var reaction = reactions[randi() % reactions.size()]
	
	var color = "green" if success else "red"
	vc_reaction.text = "[center][color=" + color + "]Chad: '" + reaction + "'[/color][/center]"

func _return_to_act1(success: bool):
	if success:
		GameData.set_minigame_result("pitch_or_ditch", {"success": true, "vc_score": vc_score})
	else:
		GameData.set_minigame_result("pitch_or_ditch", {"success": false, "stress_crash": stress_level >= 100})
	
	get_tree().change_scene_to_file("res://scenes/acts/act1_burnout_boulevard.tscn")
