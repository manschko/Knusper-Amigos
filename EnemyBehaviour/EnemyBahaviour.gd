extends  CharacterBody3D

@export var _player : CharacterBody3D;
@export var _speed : float = 0.2

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	#var direction = (_player.position - position).normalized() * _speed;
	#direction.y = velocity.y;
	#if not is_on_floor():
		#direction.y = -gravity
	#velocity = direction;
	#look_at(-_player.position, Vector3.UP);
	
	velocity.y -= gravity;
