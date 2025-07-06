extends CharacterBody2D

@export var max_speed: float = 400.0
@export var acceleration: float = 800.0
@export var friction: float = 500.0
@export var slide_friction: float = 200.0  # Lower friction when sliding

# Rotation settings
@export var rotation_friction: float = 3.0  # How much rotational friction
@export var rotation_bias: float = 0.0  # Rotational bias in degrees/second (simulates weight distribution)
@export var movement_spin_factor: float = 2.0  # How much movement direction changes affect spin

# Collision settings
@export var collision_resistance: float = 0.5  # How much the pan resists being knocked around

# Dirt/cleaning settings
@export var dirt_texture: Texture2D  # Dirt overlay texture
@export var initial_dirt_level: float = 1.0  # Starting dirt amount (0.0 = clean, 1.0 = very dirty)
@export var cleaning_rate: float = 0.5  # How fast scrubbing cleans (higher = faster)
@export var scrub_radius: float = 30.0  # Radius around sponge that gets cleaned

@onready var sprite: Sprite2D = $Sprite2D  # Reference to the sprite
@onready var dirt_overlay: Sprite2D = $DirtOverlay  # Reference to dirt overlay

var angular_velocity: float = 0.0  # Current rotational speed
var last_velocity: Vector2 = Vector2.ZERO  # Track velocity changes
var current_dirt_level: float = 1.0  # Current dirt amount
var is_being_scrubbed: bool = false

func _ready():
	# Set collision layers for the pan
	# Layer 1 = items/dishes, Layer 4 = sink walls
	collision_layer = 1  # Pan is on layer 1
	collision_mask = 1 + 4  # Pan collides with other items (layer 1) and sink walls (layer 4)
	
	# Set up initial dirt level
	current_dirt_level = initial_dirt_level
	
	# Create dirt overlay if it doesn't exist
	if not dirt_overlay and dirt_texture:
		create_dirt_overlay()
	
	# Set initial dirt transparency
	update_dirt_display()

func create_dirt_overlay():
	# Create a new sprite for the dirt overlay
	dirt_overlay = Sprite2D.new()
	dirt_overlay.texture = dirt_texture
	dirt_overlay.name = "DirtOverlay"
	add_child(dirt_overlay)
	
	# Position it on top of the main sprite
	if sprite:
		dirt_overlay.position = sprite.position
		# Move dirt overlay above the main sprite
		move_child(dirt_overlay, get_child_count() - 1)

func _physics_process(delta):
	# Get input direction
	var input_dir = Vector2()
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	
	# Normalize diagonal movement
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		
		# Apply acceleration in the input direction
		velocity += input_dir * acceleration * delta
		
		# Clamp to max speed
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	else:
		# Apply friction when no input
		var friction_force = slide_friction * delta
		if velocity.length() > friction_force:
			velocity -= velocity.normalized() * friction_force
		else:
			velocity = Vector2.ZERO
	
	# Handle rotation physics
	if sprite:
		# Calculate spin from velocity changes (sudden direction changes cause spin)
		var velocity_change = velocity - last_velocity
		if velocity.length() > 0:
			var spin_impulse = velocity_change.cross(velocity.normalized()) * movement_spin_factor
			angular_velocity += spin_impulse * delta
		
		# Apply rotational bias (simulates weight distribution)
		angular_velocity += deg_to_rad(rotation_bias) * delta
		
		# Apply rotational friction
		if abs(angular_velocity) > 0:
			var friction_force = rotation_friction * delta
			if abs(angular_velocity) > friction_force:
				angular_velocity -= sign(angular_velocity) * friction_force
			else:
				angular_velocity = 0.0
		
		# Apply rotation to both sprites
		sprite.rotation += angular_velocity * delta
		if dirt_overlay:
			dirt_overlay.rotation = sprite.rotation
		
		# Store velocity for next frame
		last_velocity = velocity
	
	move_and_slide()
	
	# Handle collisions with other objects
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# If something hits us, apply counter-force
		if collider and collider.has_method("apply_collision_impulse"):
			var counter_impulse = -velocity.normalized() * 200  # Push back
			collider.apply_collision_impulse(counter_impulse, collision.get_position())

# Function for sponge to call when scrubbing
func scrub_at_position(sponge_position: Vector2, scrub_intensity: float, delta: float):
	var distance_to_sponge = global_position.distance_to(sponge_position)
	
	# Only clean if sponge is close enough
	if distance_to_sponge <= scrub_radius:
		# Calculate cleaning strength based on distance (closer = more cleaning)
		var cleaning_strength = 1.0 - (distance_to_sponge / scrub_radius)
		cleaning_strength = clamp(cleaning_strength, 0.0, 1.0)
		
		# Apply cleaning
		var cleaning_amount = cleaning_rate * scrub_intensity * cleaning_strength * delta
		current_dirt_level -= cleaning_amount
		current_dirt_level = clamp(current_dirt_level, 0.0, 1.0)
		
		# Update dirt display
		update_dirt_display()
		
		# Set scrubbing flag
		is_being_scrubbed = true
		
		# Debug output
		if current_dirt_level <= 0.0:
			print("Pan is completely clean!")

func update_dirt_display():
	if dirt_overlay:
		# Set transparency based on dirt level
		var alpha = current_dirt_level
		dirt_overlay.modulate = Color(1, 1, 1, alpha)

# Function for other objects to apply impulses to this pan
func apply_collision_impulse(impulse: Vector2, collision_point: Vector2):
	# Apply the impulse with resistance
	velocity += impulse * collision_resistance
	
	# Add spin from the collision point
	var relative_pos = collision_point - global_position
	var spin_force = impulse.cross(relative_pos) * 0.001
	angular_velocity += spin_force

# Public functions
func get_dirt_level() -> float:
	return current_dirt_level

func is_clean() -> bool:
	return current_dirt_level <= 0.0

func add_dirt(amount: float):
	"""Add dirt to the pan"""
	current_dirt_level += amount
	current_dirt_level = clamp(current_dirt_level, 0.0, 1.0)
	update_dirt_display()

func reset_dirt():
	"""Reset pan to fully dirty state"""
	current_dirt_level = initial_dirt_level
	update_dirt_display()
