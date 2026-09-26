extends  CharacterBody3D
class_name EnemyBahaviour

@export var _player : Player;
@export var base_stats : EnemyStats;
@export var _deathTimer : float = 2;
@export var _walkCurve : Curve;
@export var _walkAnimationSpeed : float = 1;

## Final stats for this enemy. Set by the spawner before add_child (with difficulty
## applied); otherwise built from base_stats + upgrades in _ready.
var stats : EnemyStats;

var _health : float;
var _dead : bool = false;
var _walkAnimationTimer : float = 1;
var _attackTimer : float = 0;
@onready var _sprite = $Sprite3D;
signal _onDeathSignal(value: int)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if stats == null:
		stats = UpgradeManager.get_effective_enemy_stats(base_stats);
	_health = stats.health;

func _physics_process(delta: float) -> void:
	
	if _dead:
		_deathTimer -= delta;
		if _deathTimer <= 0:
			queue_free();
		return;
	
	var lookAtTarget = _player.position
	lookAtTarget.y = position.y
	look_at_from_position(position, lookAtTarget, Vector3.UP);
	
	var attackTimerBefore = _attackTimer
	_attackTimer -= delta;
	if _attackTimer > 0:
		if attackTimerBefore > stats.attack_animation_time and _attackTimer <= stats.attack_animation_time:
			_sprite.frame = 0;
		return;
	
	if position.distance_to(_player.position) <= stats.attack_range:
		_processAttack();
	else:
		_processMovement(delta);
	
	move_and_slide()


func _processMovement(delta : float) -> void:
	var moveDirection = (_player.position - position).normalized() * stats.speed;
	moveDirection.y = velocity.y;
	if not is_on_floor():
		moveDirection.y = -gravity
	velocity = moveDirection;
	
	_walkAnimationTimer += delta * _walkAnimationSpeed;
	if _walkAnimationTimer > 1:
		_walkAnimationTimer -= 1;
	var timerOffset = _walkAnimationTimer + 0.5;
	if timerOffset > 1:
		timerOffset -= 1;
	_sprite.scale = Vector3(_walkCurve.sample(_walkAnimationTimer), _walkCurve.sample(timerOffset), 1);

func _processAttack() -> void:
	if _attackTimer > 0:
		return;
	
	_sprite.scale = Vector3.ONE;
	_walkAnimationTimer = 1;
	
	velocity = Vector3.ZERO;
	_player.take_damage(stats.attack_damage);
	_attackTimer = stats.attack_cooldown;
	_sprite.frame = 1;
	

func take_damage(damage: float) -> void:
	if _dead: return;
	_health -= damage;
	if _health > 0: return;
	
	_onDeathSignal.emit(stats.value);
	
	_sprite.frame = 2;
	_dead = true;
	
