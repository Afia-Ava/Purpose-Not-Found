extends Control

func _ready():
	print("🎮 Test scene loaded successfully!")
	print("Game is working!")

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_SPACE):
		print("Loading main menu...")
		get_tree().change_scene_to_file("res://scenes/menu/mainMenu.tscn")
