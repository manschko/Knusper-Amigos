extends Node3D
class_name Splash

@export var _particles : PackedScene;
@export var _sprite : Sprite3D

@export var _frameTime : float = 0.1;
@export var _frame0 : Texture;
@export var _frame1 : Texture;

var _frame : int = 0;
var _frameTimer : float = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_frameTimer = _frameTime;
	_sprite.texture = _frame0;
	face_the_camera();
	spawn_particles();

func face_the_camera():
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	# Sprite3D's front face renders toward local +Z, but look_at() points -Z
	# at the target, so we look at the point mirrored away from the camera
	# instead -- that way +Z (the front) ends up facing the camera.
	var mirrored_target := 2.0 * _sprite.global_position - camera.global_transform.origin
	_sprite.look_at(mirrored_target, Vector3.UP)

func spawn_particles():
	var particles : GPUParticles3D = _particles.instantiate()
	get_tree().current_scene.add_child(particles);
	particles.position = position;
	particles.emitting = true;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_frameTimer -= delta;
	if _frameTimer > 0:
		return;
	
	_frameTimer = _frameTime;
	
	if _frame == 0:
		_frame = 1;
		_sprite.texture = _frame1;
		
		return;
	if _frame == 1:
		queue_free();
