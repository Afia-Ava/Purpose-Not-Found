extends Node2D

@export var rotation_speed = 2.0

var last_position: Vector2

func _ready():
	last_position = global_position

func _process(delta):
	# Add slight rotation based on movement
	var movement = global_position - last_position
	if movement.length() > 0.1:
		rotation += movement.x * rotation_speed * delta
	
	last_position = global_position
