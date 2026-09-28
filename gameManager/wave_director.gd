extends Node
class_name WaveDirector

signal wave_started(wave: int)
signal wave_progress(kills: int, quota: int)
signal wave_time_changed(time_left: float, duration: float)
signal enemy_killed(value: int)
signal boss_spawned(boss: EnemyBahaviour)

const GROUP := "wave_director"

@export var config: WaveConfig = preload("res://Balancing/default_wave_config.tres")
@export_dir var enemy_types_dir: String = "res://EnemyBehaviour/types"

@export_group("Spawn area")
@export var min_spawn_distance: float = 12.0
@export var max_spawn_distance: float = 25.0
@export var arena_center: Vector3 = Vector3.ZERO
@export var arena_radius: float = 50.0

var wave: int = 100
var kills: int = 0
var quota: int = 0
var time_left: float = 0.0
var duration: float = 0.0
var running: bool = false

var _player: Player
var _enemy_parent: Node
var _types: Array[EnemyType] = []
var _spawn_timer: float = 0.0
var _wave_alive: int = 0
var _tracked: Dictionary = {}


func _ready() -> void:
	add_to_group(GROUP)
	if config == null:
		config = WaveConfig.new()
	_types = load_enemy_types(enemy_types_dir)
	if _types.is_empty():
		push_warning("WaveDirector: no EnemyType resources found in '%s'" % enemy_types_dir)


func start(player: Player, enemy_parent: Node, start_wave: int = 1) -> void:
	_player = player
	_enemy_parent = enemy_parent
	running = true
	_start_wave(max(start_wave, 1))


func stop() -> void:
	running = false


## Debug helper: jumps straight to [param target_wave] (min 1), resetting kills/quota/
## timer as if that wave had just started. If [param clear_enemies] is true (default),
## any currently alive enemies are removed so the new wave starts clean.
func debug_set_wave(target_wave: int, clear_enemies: bool = true) -> void:
	if clear_enemies:
		for id in _tracked.keys():
			var enemy := instance_from_id(id)
			if is_instance_valid(enemy):
				enemy.queue_free()
		_tracked.clear()
	_start_wave(max(target_wave, 1))


func get_alive_count() -> int:
	return _tracked.size()


func _process(delta: float) -> void:
	if not running or not is_instance_valid(_player):
		return

	time_left -= delta
	wave_time_changed.emit(max(time_left, 0.0), duration)
	if time_left <= 0.0:
		_start_wave(wave + 1)
		return

	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	if _wave_alive < config.get_max_alive(wave) and _tracked.size() < config.hard_alive_cap:
		_spawn_enemy()
		_spawn_timer = config.spawn_interval


func _start_wave(new_wave: int) -> void:
	wave = new_wave
	kills = 0
	quota = config.get_quota(wave)
	duration = config.get_duration(wave)
	time_left = duration
	_wave_alive = 0
	_spawn_timer = 0.0
	wave_started.emit(wave)
	wave_progress.emit(kills, quota)
	wave_time_changed.emit(time_left, duration)
	if _is_boss_wave(wave):
		_spawn_boss()


func _is_boss_wave(target_wave: int) -> bool:
	return config.boss_every > 0 and target_wave % config.boss_every == 0


func _spawn_enemy() -> void:
	var type := _pick_type()
	if type == null:
		return
	_instantiate_enemy(type, false)


func _spawn_boss() -> void:
	var type := _pick_type()
	if type == null:
		push_warning("WaveDirector: no enemy type available to spawn as a boss")
		return
	var boss := _instantiate_enemy(type, true)
	if boss != null:
		boss_spawned.emit(boss)


## Instantiates [param type], applies upgrade + wave-growth stat scaling (and, for
## bosses, the extra boss multipliers + visual scale-up), then tracks it like a
## normal enemy so existing kill/quota bookkeeping keeps working.
func _instantiate_enemy(type: EnemyType, is_boss: bool) -> EnemyBahaviour:
	var enemy := type.scene.instantiate() as EnemyBahaviour
	if enemy == null:
		push_warning("WaveDirector: scene of '%s' has no EnemyBahaviour root" % type.resource_path)
		return null

	var base := type.base_stats if type.base_stats else enemy.base_stats
	var stats := UpgradeManager.get_effective_enemy_stats(base)
	stats = config.apply(stats, wave)
	if is_boss:
		stats = config.apply_boss_bonus(stats)
		enemy.add_to_group("boss")
	enemy.stats = stats
	enemy._player = _player

	var id := enemy.get_instance_id()
	_tracked[id] = wave
	_wave_alive += 1
	enemy._onDeathSignal.connect(_on_enemy_died.bind(id))
	enemy.tree_exited.connect(_untrack.bind(id))

	enemy.position = _get_spawn_position()
	_enemy_parent.add_child(enemy)
	if is_boss:
		enemy.scale *= config.boss_scale_multiplier
	return enemy


func _pick_type() -> EnemyType:
	var total := 0.0
	var available: Array[EnemyType] = []
	for type in _types:
		if type.is_available(wave):
			available.append(type)
			total += type.weight
	if available.is_empty():
		return null

	var roll := randf() * total
	for type in available:
		roll -= type.weight
		if roll <= 0.0:
			return type
	return available.back()


func _get_spawn_position() -> Vector3:
	var origin := _player.global_position
	for i in 10:
		var angle := randf() * TAU
		var distance := randf_range(min_spawn_distance, max_spawn_distance)
		var pos := origin + Vector3(cos(angle), 0.0, sin(angle)) * distance
		if _is_inside_arena(pos):
			return pos
	var to_center := arena_center - origin
	to_center.y = 0.0
	var direction := to_center.normalized() if to_center.length() > 0.01 else Vector3.FORWARD
	return origin + direction * min_spawn_distance


func _is_inside_arena(pos: Vector3) -> bool:
	if arena_radius <= 0.0:
		return true
	return Vector2(pos.x - arena_center.x, pos.z - arena_center.z).length() <= arena_radius


func _on_enemy_died(value: int, id: int) -> void:
	_untrack(id)
	enemy_killed.emit(value)
	if not running:
		return
	kills += 1
	wave_progress.emit(kills, quota)
	if kills >= quota:
		Stats.add_crumbs(time_left * UpgradeManager.get_bonus_for_stat("rush_bonus"))
		_start_wave(wave + 1)


func _untrack(id: int) -> void:
	if not _tracked.has(id):
		return
	if _tracked[id] == wave:
		_wave_alive -= 1
	_tracked.erase(id)


static func load_enemy_types(dir_path: String) -> Array[EnemyType]:
	var types: Array[EnemyType] = []
	var dir := dir_path.trim_suffix("/") + "/"
	for file_name in ResourceLoader.list_directory(dir):
		if file_name.ends_with("/"):
			continue
		var resource := load(dir + file_name)
		if resource is EnemyType:
			types.append(resource)
		elif resource != null:
			push_warning("WaveDirector: '%s' is not an EnemyType resource" % (dir + file_name))
	return types
