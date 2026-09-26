extends GPUParticles3D

var _lifeTimer : float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_lifeTimer = lifetime;
	face_the_camera();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_lifeTimer -= delta
	if _lifeTimer <= 0:
		queue_free();

func face_the_camera():
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	# Sprite3D's front face renders toward local +Z, but look_at() points -Z
	# at the target, so we look at the point mirrored away from the camera
	# instead -- that way +Z (the front) ends up facing the camera.
	var mirrored_target := 2.0 * global_position - camera.global_transform.origin
	look_at(mirrored_target, Vector3.UP)
