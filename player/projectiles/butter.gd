extends RigidBody3D


const ANGLE_UP_DEG := 45.0
const ANGLE_DOWN_DEG := -45.0
const Z_ROT_UP_DEG := -45.0
const Z_ROT_DOWN_DEG := 40.0
var damage = 1

@onready var sprite: Sprite3D = $CollisionShape3D/Sprite3D

@export var splashObject : PackedScene;

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	face_the_camera()


func face_the_camera():
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	# Sprite3D's front face renders toward local +Z, but look_at() points -Z
	# at the target, so we look at the point mirrored away from the camera
	# instead -- that way +Z (the front) ends up facing the camera.
	var mirrored_target := 2.0 * sprite.global_position - camera.global_transform.origin
	sprite.look_at(mirrored_target, Vector3.UP)
	
	var velocity := linear_velocity
	if velocity.length() <= 0.1:
		return

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var angle_deg := rad_to_deg(atan2(velocity.y, horizontal_speed))

	var t := inverse_lerp(ANGLE_UP_DEG, ANGLE_DOWN_DEG, angle_deg)
	t = clampf(t, 0.0, 1.0)
	sprite.rotation_degrees.z = lerp(Z_ROT_UP_DEG, Z_ROT_DOWN_DEG, t)
	


func _on_body_entered(body: Node) -> void:
	if body is EnemyBahaviour:
		body.take_damage(damage);
		var nSplash : Splash = splashObject.instantiate();
		get_tree().current_scene.add_child(nSplash);
		nSplash.position = position;
	queue_free() # destroy projectile
