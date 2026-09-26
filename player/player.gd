# The script is attached to a CharacterBody3D node.
extends CharacterBody3D
class_name Player

signal health_changed(current: float, max_health: float)
signal died

@export var base_stats: PlayerStats

# Movement feel tuning - not part of PlayerStats since these aren't upgraded.
@export var jump_velocity = 4.5
@export var coyote_time = 0.2
@export var jump_buffer_time = 0.2
@export var jump_cut_multiplier = 0.5
@export var speed_transition = 6.0
@export var bobbing_amplitude = 0.02
@export var bobbing_frequency = 10.0
@export var shot_cooldown:float = 1.0
@export var projectile: PackedScene

var stats: PlayerStats
var current_health: float

var bobbing_time = 0.0
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var speed = 0.0
var shoot_timer = shot_cooldown

@onready var camera = $Camera3D
var initial_camera_y = 0.0

func _ready():
	initial_camera_y = camera.position.y
	stats = UpgradeManager.get_effective_stats(base_stats)
	current_health = stats.health
	speed = stats.walk_speed
	health_changed.emit(current_health, stats.health)

func take_damage(amount: float) -> void:
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health, stats.health)
	if current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	current_health = min(current_health + amount, stats.health)
	health_changed.emit(current_health, stats.health)

# Get the gravity from the project settings to ensure consistency.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta: float) -> void:
	handle_inputs(delta)
		
func handle_inputs(delta: float):
	if Input.is_action_just_pressed("shoot") and shot_cooldown <= shoot_timer:
		shoot_timer = 0.0
		var projectile = projectile.instantiate()
		var force = 20
		var direction = camera.global_basis * Vector3.FORWARD
		projectile.position = position
		projectile.linear_velocity = direction * force
		get_parent().add_child(projectile)
		print("Shoot!")
	
	if shot_cooldown >= shoot_timer:
		shoot_timer += delta
# This function is called every physics frame, which is ideal for
# handling physics-based movement
func _physics_process(delta):
	
	# Handle the jump input.
	handle_jump(delta)
	handle_movement(delta)

	
	
	
func handle_jump(delta):
	
	# Apply gravity. It's a continuous force applied to the y-velocity.
	var current_gravity = gravity
	if velocity.y > 0:  # Ascending
		current_gravity = gravity * 1 - jump_cut_multiplier  # Reduce gravity
	elif velocity.y < 0:  # Descending
		current_gravity = gravity * 1 + jump_cut_multiplier  # Increase gravity
	else:
		current_gravity = gravity  # Default gravity
		
	if not is_on_floor():
		velocity.y -= current_gravity * delta
		coyote_timer -= delta
	else:
		coyote_timer = coyote_time
		
	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
		
	if jump_buffer_timer > 0 and (coyote_timer > 0 or is_on_floor()):
		velocity.y = jump_velocity
		coyote_timer = 0
		jump_buffer_timer = 0


#todo stops to abruply especially in the air
func handle_movement(delta):
	# Get the input direction from the actions defined in the Input Map.
	# get_vector() returns a normalized Vector2 from the four actions,
	# making it easy to handle WASD-like input.
	var input_dir = Input.get_vector("moving_left", "moving_right", "moving_forward", "moving_backward")
	
	# Calculate the 3D movement direction.
	# `transform.basis` is used to convert the local input direction
	# into a global direction relative to the character's rotation.
	
	var flat_basis = camera.transform.basis
	flat_basis.y = Vector3.ZERO
	flat_basis.z.y = 0
	flat_basis.x.y = 0
	flat_basis = flat_basis.orthonormalized()  # Ensure the basis remains orthonormal
	var direction = (flat_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	Input.is_action_just_pressed("sprint")
	if Input.is_action_pressed("sprint"):
		speed = lerp(speed, stats.sprint_speed, delta)
	else:
		speed = lerp(speed, stats.walk_speed, delta)

	# If there is movement input, set the horizontal velocity.
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		bobbing_time += delta * bobbing_frequency * speed
		camera.position.y = initial_camera_y + bobbing_amplitude * sin(bobbing_time)
	else:
		# If there is no input, smoothly slow down the horizontal velocity.
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		bobbing_time = 0.0  # Reset bobbing when not moving
		camera.position.y = initial_camera_y


	# Use `move_and_slide()` to apply the final calculated velocity.
	# This function handles collision and sliding along surfaces.
	move_and_slide()
