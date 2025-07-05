extends CharacterBody2D

@export var pickup_distance: float = 50.0
@export var max_speed: float = 400.0
@export var slide_friction: float = 200.0
@export var throw_force: float = 800.0

# Rotation settings (only when not held)
@export var rotation_friction: float = 3.0
@export var rotation_bias: float = 0.0
@export var movement_spin_factor: float = 2.0

# Pan interaction settings (only when held)
@export var pan_push_force: float = 150.0
@export var pan_push_distance: float = 60.0
@export var pan_center_safe_zone: float = 30.0

var is_picked_up: bool = false
var original_position: Vector2
var mouse_offset: Vector2
var last_mouse_position: Vector2
var mouse_velocity: Vector2

# Physics when not held
var angular_velocity: float = 0.0
var last_velocity: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	original_position = global_position
	last_mouse_position = get_global_mouse_position()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var distance_to_mouse = global_position.distance_to(mouse_pos)
		
		if event.pressed and distance_to_mouse <= pickup_distance:
			# Pick up the sponge
			is_picked_up = true
			mouse_offset = global_position - mouse_pos
			last_mouse_position = mouse_pos
			modulate = Color(1, 1, 1, 0.8)
			
			# Disable collision when held
			if collision_shape:
				collision_shape.set_deferred("disabled", true)
				
		elif not event.pressed and is_picked_up:
			# Drop/throw the sponge
			is_picked_up = false
			modulate = Color(1, 1, 1, 1)
			
			# Re-enable collision when dropped
			if collision_shape:
				collision_shape.set_deferred("disabled", false)
			
			# Apply throw velocity
			velocity = mouse_velocity * throw_force * 0.001
			angular_velocity += randf_range(-5, 5)

func _process(delta):
	# Visual feedback when hovering (only when not picked up)
	if not is_picked_up:
		var mouse_pos = get_global_mouse_position()
		var distance_to_mouse = global_position.distance_to(mouse_pos)
		
		if distance_to_mouse <= pickup_distance:
			modulate = Color(1.2, 1.2, 1.2, 1)
		else:
			modulate = Color(1, 1, 1, 1)

func _physics_process(delta):
	if is_picked_up:
		# When held: follow mouse directly, no physics
		var current_mouse_pos = get_global_mouse_position()
		mouse_velocity = (current_mouse_pos - last_mouse_position) / delta
		last_mouse_position = current_mouse_pos
		
		# Move directly to mouse position (no physics)
		global_position = current_mouse_pos + mouse_offset
		velocity = Vector2.ZERO  # No physics velocity when held
		
		# Check for pan pushing when held
		check_pan_interaction()
		
	else:
		# When not held: full physics and rotation
		
		# Apply sliding friction
		var slide_friction_force = slide_friction * delta
		if velocity.length() > slide_friction_force:
			velocity -= velocity.normalized() * slide_friction_force
		else:
			velocity = Vector2.ZERO
		
		# Handle rotation physics
		if sprite:
			var velocity_change = velocity - last_velocity
			if velocity.length() > 0:
				var spin_impulse = velocity_change.cross(velocity.normalized()) * movement_spin_factor
				angular_velocity += spin_impulse * delta
			
			# Apply rotational bias
			angular_velocity += deg_to_rad(rotation_bias) * delta
			
			# Apply rotational friction
			if abs(angular_velocity) > 0:
				var rotational_friction_force = rotation_friction * delta
				if abs(angular_velocity) > rotational_friction_force:
					angular_velocity -= sign(angular_velocity) * rotational_friction_force
				else:
					angular_velocity = 0.0
			
			# Apply rotation
			sprite.rotation += angular_velocity * delta
			last_velocity = velocity
		
		# Move with physics
		move_and_slide()

func check_pan_interaction():
	# Only push pans when being held by player
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collision_mask = 1
	
	for angle in range(0, 360, 30):
		var check_pos = global_position + Vector2.from_angle(deg_to_rad(angle)) * pan_push_distance
		query.position = check_pos
		var results = space_state.intersect_point(query, 1)
		
		for result in results:
			var collider = result.collider
			if collider and collider.has_method("apply_collision_impulse"):
				var distance_to_pan = global_position.distance_to(collider.global_position)
				
				if distance_to_pan > pan_center_safe_zone and distance_to_pan <= pan_push_distance:
					var push_direction = (collider.global_position - global_position).normalized()
					var push_strength = 1.0 - (distance_to_pan - pan_center_safe_zone) / (pan_push_distance - pan_center_safe_zone)
					push_strength = clamp(push_strength, 0.0, 1.0)
					
					var push_impulse = push_direction * pan_push_force * push_strength * get_process_delta_time()
					collider.apply_collision_impulse(push_impulse, collider.global_position)

# Function for other objects to apply impulses when not held
func apply_collision_impulse(impulse: Vector2, collision_point: Vector2):
	if not is_picked_up:  # Only respond to collisions when not held
		velocity += impulse
		var spin_force = impulse.cross(collision_point - global_position) * 0.001
		angular_velocity += spin_force

func reset_position():
	is_picked_up = false
	global_position = original_position
	velocity = Vector2.ZERO
	angular_velocity = 0.0
	modulate = Color(1, 1, 1, 1)
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
