extends Node
class_name Player

signal stat_changed(stat_name: String, new_value: int)

enum CharacterState {
	STARTUP_BRO,
	QUESTIONING,
	LEARNING,
	GROWING,
	ZEN_FARMER
}

var current_state: CharacterState = CharacterState.STARTUP_BRO
var burnout_level: int = 80
var health: int = 40
var social_energy: int = 30
var cooking_skill: int = 10
var farming_skill: int = 0
var emotional_intelligence: int = 20

func update_burnout(change: int):
	burnout_level = max(0, min(100, burnout_level + change))
	stat_changed.emit("burnout", burnout_level)

func update_skill(skill_name: String, change: int):
	match skill_name:
		"cooking":
			cooking_skill = max(0, min(100, cooking_skill + change))
			stat_changed.emit("cooking", cooking_skill)
		"farming":
			farming_skill = max(0, min(100, farming_skill + change))
			stat_changed.emit("farming", farming_skill)
		"emotional":
			emotional_intelligence = max(0, min(100, emotional_intelligence + change))
			stat_changed.emit("emotional", emotional_intelligence)
		"health":
			health = max(0, min(100, health + change))
			stat_changed.emit("health", health)
		"social":
			social_energy = max(0, min(100, social_energy + change))
			stat_changed.emit("social", social_energy)
