extends RigidBody3D

# Calibration points found by testing in the editor: the sprite's
# rotation_degrees.z doesn't map 1:1 to the flight angle, but it is close
# enough to linear between these two known points.
# Flight angle 45° (up)  -> sprite z rotation 0°
# Flight angle -45° (down) -> sprite z rotation 70°
const ANGLE_UP_DEG := 45.0
const ANGLE_DOWN_DEG := -45.0
const Z_ROT_UP_DEG := 0.0
const Z_ROT_DOWN_DEG := 70.0

@onready var sprite: Sprite3D = $Sprite3D

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return

	# The whole body (and its CollisionShape3D child) faces the camera
	# horizontally, same as a Y-locked billboard would.
	var target := camera.global_position
	target.y = global_position.y
	if target.distance_to(global_position) > 0.001:
		look_at(target, Vector3.UP)

	# The sprite then tilts locally on top of that to reflect the flight direction.
	var velocity := linear_velocity
	if velocity.length() <= 0.1:
		return

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var angle_deg := rad_to_deg(atan2(velocity.y, horizontal_speed))

	var t := inverse_lerp(ANGLE_UP_DEG, ANGLE_DOWN_DEG, angle_deg)
	t = clampf(t, 0.0, 1.0)
	sprite.rotation_degrees.z = lerp(Z_ROT_UP_DEG, Z_ROT_DOWN_DEG, t)
