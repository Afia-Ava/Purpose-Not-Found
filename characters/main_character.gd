extends Node2D
class_name MainCharacter

@export var character_name: String = "Chad"  
@export var burnout_level: int = 85  
@export var health: int = 60
@export var social_energy: int = 40
@export var emotional_intelligence: int = 20
@export var cooking_skill: int = 5  
@export var cleaning_skill: int = 10
@export var farming_skill: int = 0
@export var emotional_growth: int = 15

enum CharacterState {
	TECH_BRO,      
	TRANSITIONING, 
	FARMER_CASUAL, 
	ZEN_FARMER     
}

@export var current_state: CharacterState = CharacterState.TECH_BRO
@export var sarcasm_level: int = 80  
@export var tech_jargon_usage: int = 90  
@export var self_awareness: int = 25  
@export var has_quit_startup: bool = false
@export var met_neighbor: bool = false
@export var started_therapy: bool = false
@export var bought_land: bool = false
@export var hosted_dinner_party: bool = false

var relationships: Dictionary = {
	"roommate_1": 60,   
	"roommate_2": 65,
	"roommate_3": 55,
	"wise_neighbor": 0,  
	"therapist": 0,     
	"ex_cofounder": 40  
}

signal stat_changed(stat_name: String, new_value: int)
signal relationship_changed(character: String, new_value: int)
signal character_state_changed(new_state: CharacterState)

func _ready():
	stat_changed.connect(_on_stat_changed)
	
func update_burnout(change: int):
	burnout_level = clamp(burnout_level + change, 0, 100)
	stat_changed.emit("burnout", burnout_level)
	_check_character_transformation()

func update_skill(skill_name: String, change: int):
	match skill_name:
		"cooking":
			cooking_skill = clamp(cooking_skill + change, 0, 100)
			stat_changed.emit("cooking", cooking_skill)
		"cleaning":
			cleaning_skill = clamp(cleaning_skill + change, 0, 100)
			stat_changed.emit("cleaning", cleaning_skill)
		"farming":
			farming_skill = clamp(farming_skill + change, 0, 100)
			stat_changed.emit("farming", farming_skill)
		"emotional":
			emotional_intelligence = clamp(emotional_intelligence + change, 0, 100)
			stat_changed.emit("emotional", emotional_intelligence)
			_update_personality_traits()

func update_relationship(character: String, change: int):
	if character in relationships:
		relationships[character] = clamp(relationships[character] + change, 0, 100)
		relationship_changed.emit(character, relationships[character])

func _update_personality_traits():
	sarcasm_level = max(20, 80 - emotional_intelligence)
	tech_jargon_usage = max(10, 90 - emotional_intelligence)
	self_awareness = emotional_intelligence

func _check_character_transformation():
	var old_state = current_state	
	if emotional_intelligence > 80 and farming_skill > 60:
		current_state = CharacterState.ZEN_FARMER
	elif farming_skill > 30 and emotional_intelligence > 50:
		current_state = CharacterState.FARMER_CASUAL
	elif has_quit_startup and emotional_intelligence > 30:
		current_state = CharacterState.TRANSITIONING
	else:
		current_state = CharacterState.TECH_BRO
	
	if old_state != current_state:
		character_state_changed.emit(current_state)

func get_dialogue_style() -> Dictionary:
	return {
		"sarcasm": sarcasm_level,
		"tech_jargon": tech_jargon_usage,
		"self_awareness": self_awareness,
		"emotional_maturity": emotional_intelligence
	}

func _on_stat_changed(_stat_name: String, _new_value: int):
	pass
