extends Area2D

# Sink boundary settings
@export var sink_width: float = 200.0  # Width of the sink basin
@export var sink_height: float = 150.0  # Height of the sink basin
@export var wall_thickness: float = 20.0  # Thickness of the sink walls
@export var create_boundaries: bool = true  # Auto-create boundary walls

var items_in_sink: Array = []

@onready var sprite: Sprite2D = $Sprite2D

# Boundary walls
var left_wall: StaticBody2D
var right_wall: StaticBody2D
var top_wall: StaticBody2D
var bottom_wall: StaticBody2D

signal item_entered_sink(item)
signal item_exited_sink(item)

func _ready():
	# Set collision layers for the sink detection area
	# Layer 2 = sink detection, Layer 1 = items/dishes
	collision_layer = 2  # This sink is on layer 2
	collision_mask = 1   # This sink detects items on layer 1
	
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	# Create boundary walls if enabled
	if create_boundaries:
		call_deferred("create_sink_boundaries")

func create_sink_boundaries():
	# Get the parent node to add walls to (they need to be in the main scene for collision)
	var parent = get_parent()
	if not parent:
		return
	
	# Create walls relative to the sink's global position
	var sink_pos = global_position
	
	# Create left wall
	left_wall = create_wall(parent, sink_pos + Vector2(-sink_width/2 - wall_thickness/2, 0), Vector2(wall_thickness, sink_height + wall_thickness*2))
	
	# Create right wall
	right_wall = create_wall(parent, sink_pos + Vector2(sink_width/2 + wall_thickness/2, 0), Vector2(wall_thickness, sink_height + wall_thickness*2))
	
	# Create top wall
	top_wall = create_wall(parent, sink_pos + Vector2(0, -sink_height/2 - wall_thickness/2), Vector2(sink_width + wall_thickness*2, wall_thickness))
	
	# Create bottom wall
	bottom_wall = create_wall(parent, sink_pos + Vector2(0, sink_height/2 + wall_thickness/2), Vector2(sink_width + wall_thickness*2, wall_thickness))

func create_wall(parent_node: Node, pos: Vector2, size: Vector2) -> StaticBody2D:
	var wall = StaticBody2D.new()
	var shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	
	# Set up the collision shape
	rect_shape.size = size
	shape.shape = rect_shape
	
	# IMPORTANT: Set wall collision layers
	# Layer 3 = sink walls (separate from items and sink detection)
	wall.collision_layer = 4  # Walls are on layer 4
	wall.collision_mask = 1   # Walls collide with items on layer 1
	
	# Position the wall
	wall.global_position = pos
	wall.add_child(shape)
	parent_node.add_child(wall)
	
	# Disable input pickup on walls so they don't block mouse clicks
	wall.input_pickable = false
	
	# Optional: Add visual representation for debugging
	var show_debug = true  # Set to false to hide wall boundaries
	if show_debug:
		var debug_sprite = ColorRect.new()
		debug_sprite.size = size
		debug_sprite.position = -size/2
		debug_sprite.color = Color(0.5, 0.5, 0.5, 0.8)  # Semi-transparent gray
		debug_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse input
		wall.add_child(debug_sprite)
	
	return wall

func _on_body_entered(body):
	if body not in items_in_sink:
		items_in_sink.append(body)
		item_entered_sink.emit(body)

func _on_body_exited(body):
	if body in items_in_sink:
		items_in_sink.erase(body)
		item_exited_sink.emit(body)

func _on_area_entered(area):
	# Handle Area2D nodes
	if area not in items_in_sink:
		items_in_sink.append(area)
		item_entered_sink.emit(area)

func _on_area_exited(area):
	if area in items_in_sink:
		items_in_sink.erase(area)
		item_exited_sink.emit(area)

# Public functions for external control
func get_items_in_sink() -> Array:
	return items_in_sink.duplicate()

# Utility functions for sink boundaries
func set_sink_size(width: float, height: float):
	"""Dynamically resize the sink boundaries"""
	sink_width = width
	sink_height = height
	
	# Remove old walls
	remove_boundaries()
	
	# Create new walls with new size
	if create_boundaries:
		call_deferred("create_sink_boundaries")

func remove_boundaries():
	"""Remove all boundary walls"""
	if left_wall: 
		left_wall.queue_free()
		left_wall = null
	if right_wall: 
		right_wall.queue_free()
		right_wall = null
	if top_wall: 
		top_wall.queue_free()
		top_wall = null
	if bottom_wall: 
		bottom_wall.queue_free()
		bottom_wall = null

func enable_boundaries(enabled: bool):
	"""Enable or disable sink boundaries"""
	create_boundaries = enabled
	
	if enabled and not left_wall:
		call_deferred("create_sink_boundaries")
	elif not enabled:
		remove_boundaries()

func _exit_tree():
	# Clean up walls when sink is removed
	remove_boundaries()
