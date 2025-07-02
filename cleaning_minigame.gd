extends Node2D

@onready var dish = $Dish
@onready var sponge = $Sponge
@onready var clean_label = $UI/CleanPercentage

func _ready():
	# Hide the default cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	# Update sponge position to follow mouse
	sponge.global_position = get_global_mouse_position()
	
	# Update cleanliness percentage
	var clean_percent = dish.get_clean_percentage()
	clean_label.text = "Clean: %d%%" % int(clean_percent * 100)
