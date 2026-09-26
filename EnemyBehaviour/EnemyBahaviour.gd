extends  CharacterBody3D

@export var _player : Player;
@export var _speed : float = 0.2;
@export var _attackRange : float = 1;
@export var _attackDamage : float = 1;
@export var _attackCooldown : float = 0.2;
@export var _attackAnimationTime : float = 0.1;

var _attackTimer : float = 0;
@onready var _sprite = $Sprite3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	
	var lookAtTarget = _player.position
	lookAtTarget.y = position.y
	look_at_from_position(position, lookAtTarget, Vector3.UP);
	
	var attackTimerBefore = _attackTimer
	_attackTimer -= delta;
	if _attackTimer > 0:
		if attackTimerBefore > _attackAnimationTime and _attackTimer <= _attackAnimationTime:
			_sprite.frame = 0;
		return;
	
	if position.distance_to(_player.position) <= _attackRange:
		_processAttack();
	else:
		_processMovement();
	
	move_and_slide()


func _processMovement() -> void:
	var moveDirection = (_player.position - position).normalized() * _speed;
	moveDirection.y = velocity.y;
	if not is_on_floor():
		moveDirection.y = -gravity
	velocity = moveDirection;

func _processAttack() -> void:
	if _attackTimer > 0:
		return;
	
	velocity = Vector3.ZERO;
	_player.take_damage(_attackDamage, position);
	_attackTimer = _attackCooldown;
	_sprite.frame = 1;
