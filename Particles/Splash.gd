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
	spawn_particles();


func spawn_particles():
	var particles : GPUParticles3D = _particles.instantiate()
	get_parent().add_child(particles);
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
