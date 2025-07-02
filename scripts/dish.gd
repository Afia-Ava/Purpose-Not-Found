extends Node2D

@export var move_speed = 200.0
@export var dirt_texture_path = "res://dirt_overlay.png"

@onready var dirt_overlay = $DirtOverlay
@onready var dish_area = $DishArea

var dirt_image: Image
var dirt_texture: ImageTexture
var original_dirt_pixels: int = 0
var is_being_scrubbed = false

func _ready():
	# Load and setup the dirt texture
	setup_dirt_texture()
	
	# Connect area signals
	dish_area.area_entered.connect(_on_area_entered)
	dish_area.area_exited.connect(_on_area_exited)

func setup_dirt_texture():
	# Load the original dirt texture
	var original_texture = load(dirt_texture_path)
	dirt_image = original_texture.get_image()
	
	# Create a copy we can modify
	dirt_image = dirt_image.duplicate()
	
	# Count original dirty pixels
	for x in dirt_image.get_width():
		for y in dirt_image.get_height():
			var pixel = dirt_image.get_pixel(x, y)
			if pixel.a > 0.1:  # If pixel is not transparent
				original_dirt_pixels += 1
	
	# Create texture from image
	dirt_texture = ImageTexture.create_from_image(dirt_image)
	dirt_overlay.texture = dirt_texture

func _process(delta):
	# Handle WASD movement
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * move_speed
		position += velocity * delta
	
	# Clean the dish if sponge is touching
	if is_being_scrubbed:
		clean_at_position(get_local_mouse_position())

func clean_at_position(local_pos: Vector2):
	# Convert local position to texture coordinates
	var texture_size = dirt_image.get_size()
	var sprite_size = dirt_overlay.texture.get_size()
	
	# Adjust for sprite centering
	var texture_pos = local_pos + sprite_size / 2
	
	# Clean radius (how big the sponge cleaning area is)
	var clean_radius = 20
	
	# Clean pixels in a circular area
	for x in range(-clean_radius, clean_radius):
		for y in range(-clean_radius, clean_radius):
			var px = int(texture_pos.x + x)
			var py = int(texture_pos.y + y)
			
			# Check if within texture bounds
			if px >= 0 and px < texture_size.x and py >= 0 and py < texture_size.y:
				# Check if within circle
				if x * x + y * y <= clean_radius * clean_radius:
					# Make pixel transparent
					dirt_image.set_pixel(px, py, Color(0, 0, 0, 0))
	
	# Update the texture
	dirt_texture.update(dirt_image)

func get_clean_percentage() -> float:
	if original_dirt_pixels == 0:
		return 1.0
	
	var current_dirt_pixels = 0
	for x in dirt_image.get_width():
		for y in dirt_image.get_height():
			var pixel = dirt_image.get_pixel(x, y)
			if pixel.a > 0.1:
				current_dirt_pixels += 1
	
	var cleaned_pixels = original_dirt_pixels - current_dirt_pixels
	return float(cleaned_pixels) / float(original_dirt_pixels)

func _on_area_entered(area: Area2D):
	if area.get_parent().name == "Sponge":
		is_being_scrubbed = true

func _on_area_exited(area: Area2D):
	if area.get_parent().name == "Sponge":
		is_being_scrubbed = false
