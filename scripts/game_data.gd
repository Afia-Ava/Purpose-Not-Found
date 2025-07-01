extends Node

# Global game data singleton for tracking progress across scenes
class_name GameData

static var minigame_results: Dictionary = {}
static var current_act: int = 1
static var player_choices: Dictionary = {}

static func set_minigame_result(game_name: String, result: Dictionary):
	minigame_results[game_name] = result

static func get_minigame_result(game_name: String) -> Dictionary:
	return minigame_results.get(game_name, {})

static func set_player_choice(choice_name: String, value):
	player_choices[choice_name] = value

static func get_player_choice(choice_name: String, default_value = null):
	return player_choices.get(choice_name, default_value)
