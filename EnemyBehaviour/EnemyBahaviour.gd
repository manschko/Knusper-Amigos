extends  CharacterBody3D
class_name EnemyBahaviour

@export var _player : Player;
@export var base_stats : EnemyStats;
@export var _deathTimer : float = 2;
@export var _walkCurve : Curve;
@export var _walkAnimationSpeed : float = 1;

@export var _groanIntervalMin : float = 4.0;
@export var _groanIntervalMax : float = 12.0;
const MAX_GROAN_CHANNELS := 3
const MAX_HIT_CHANNELS := 4

var stats : EnemyStats;

var _health : float;
var _dead : bool = false;
var _walkAnimationTimer : float = 1;
var _attackTimer : float = 0;
var _groanTimer : float = 0;
@onready var _sprite = $Sprite3D;
@onready var collision = $CollisionShape3D
signal _onDeathSignal(value: int)

@export var _isFlying = false;
@export var _projectile : PackedScene;
@export var _projectileSpeed : float;

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _startScale : float;

func _ready() -> void:
	if stats == null:
		stats = UpgradeManager.get_effective_enemy_stats(base_stats);
	_health = stats.health;
	_groanTimer = randf_range(0.0, _groanIntervalMax);
	if _isFlying:
		position.y += 3;
	_startScale = _sprite.scale.x;

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
		if _isFlying:
			_processAirAttack();
			_doFlyAnimation(delta);
		else:
			_processGroundAttack();
	else:
		_processMovement(delta);
	
	move_and_slide()


func _processMovement(delta : float) -> void:
	var moveDirection = _player.position - position;
	moveDirection.y = 0;
	moveDirection = moveDirection.normalized() * stats.speed;
	
	if not _isFlying:
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
	_sprite.scale = Vector3(_walkCurve.sample(_walkAnimationTimer), _walkCurve.sample(timerOffset), 1) * _startScale;
	
	_groanTimer -= delta;
	if _groanTimer <= 0:
		_groanTimer = randf_range(_groanIntervalMin, _groanIntervalMax);
		if not AudioManager.is_playing_for(self):
			AudioManager.play_random_sfx(ZombieSounds.movement(), &"zombie_movement", MAX_GROAN_CHANNELS, false, self);
	if not _isFlying:
		_sprite.scale = Vector3(_walkCurve.sample(_walkAnimationTimer), _walkCurve.sample(timerOffset), 1) * _startScale;
	else:
		_sprite.position = Vector3(0, _walkCurve.sample(_walkAnimationTimer), 0);

func _doFlyAnimation(delta : float) -> void:
	_walkAnimationTimer += delta * _walkAnimationSpeed;
	if _walkAnimationTimer > 1:
		_walkAnimationTimer -= 1;
	_sprite.position = Vector3(0, _walkCurve.sample(_walkAnimationTimer), 0);

func _processGroundAttack() -> void:
	if _attackTimer > 0:
		return;
	
	_sprite.scale = Vector3.ONE;
	_walkAnimationTimer = 1;
	
	velocity = Vector3.ZERO;
	_player.take_damage(stats.attack_damage);
	_attackTimer = stats.attack_cooldown;
	_sprite.frame = 1;
	

func _processAirAttack() -> void:
	if _attackTimer > 0:
		return;
	
	velocity = Vector3.ZERO;
	
	var proj : EnemyProj = _projectile.instantiate();
	var projToPlayer : Vector3 = (_player.position - position).normalized();
	proj.position = position + projToPlayer * 1;
	proj.linear_velocity = projToPlayer * _projectileSpeed;
	proj.damage = stats.attack_damage;
	get_tree().current_scene.add_child(proj);
	
	_attackTimer = stats.attack_cooldown;

func take_damage(damage: float) -> void:
	if _dead: return;
	_health -= damage;
	# Each zombie has one "voice": multishot hits on the same zombie don't stack.
	if _health > 0:
		if not AudioManager.is_playing_for(self):
			AudioManager.play_random_sfx(ZombieSounds.hit(), &"zombie_hit", MAX_HIT_CHANNELS, false, self);
		return;
	
	AudioManager.stop_for(self);
	AudioManager.play_random_sfx(ZombieSounds.death(), &"zombie_death", AudioManager.num_players, true, self);
	_onDeathSignal.emit(stats.value);
	collision_layer = 0
	
	_sprite.frame = 2;
	_dead = true;
	
