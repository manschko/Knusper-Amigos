extends Node3D

@export var playerScene: PackedScene
@export var enemy: PackedScene
@export var difficulty: EnemyDifficulty = preload("res://EnemyBehaviour/default_difficulty.tres")
@export_file("*.tscn") var upgradeScene: String
var enemy_count = 0
var enemy_death = 0
var total_enemy = 50
var enemys_spawned = 0
var wave_bonus = 0.5
var wave_timer = 0.0


var player: Player
# Called when the node enters the scene tree for the first time.
var timer: float = 1.0
var elapsed_time: float = 0.0


func _ready():
	spawn_player()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	wave_timer += delta
	if wave_timer <= 45.0: 
		enemy_count = 0
		enemy_death = 0
		total_enemy += total_enemy * wave_bonus
		enemys_spawned = 0
		wave_timer = 0.0
		
	spawn_enemy(delta)
	
	
	
func spawn_player() -> void:
	player = playerScene.instantiate()
	player.position = Vector3(0,2,0)
	player.died.connect(func(): get_tree().change_scene_to_file(upgradeScene))
	get_tree().current_scene.add_child.call_deferred(player)

	
func on_enemy_death(value) -> void:
	enemy_count -= 1
	Stats.add_crumbs(value)
	
func spawn_enemy(delta: float) -> void:
	
	
	timer -= delta
	if timer >= 0.0: 
		return
		
	timer = randi_range(1, 10)
	if not enemy:
		print("no Enemy")
		return
	
	if enemy_count < 5 :
		while (enemys_spawned != total_enemy && enemy_count < 5):
			var neuer_enemy: EnemyBahaviour = enemy.instantiate()
			neuer_enemy._player = player
			neuer_enemy._onDeathSignal.connect(on_enemy_death)
			get_tree().current_scene.add_child(neuer_enemy)
			neuer_enemy.global_position = set_pos()
			enemy_count += 1
			enemys_spawned += 1
	elif not enemys_spawned == total_enemy:
		var neuer_enemy: EnemyBahaviour = enemy.instantiate()
		neuer_enemy._player = player
		neuer_enemy._onDeathSignal.connect(on_enemy_death)
		get_tree().current_scene.add_child(neuer_enemy)
		neuer_enemy.global_position = set_pos()
		enemy_count += 1
		enemys_spawned += 1

func set_pos():
	var z = player.position.z
	var x = player.position.x
	var winkel = randf_range(0.0, TAU)
	var radius = randf_range(5, 25)
	var dx = x + cos(winkel) * radius
	var dz = z + sin(winkel) * radius
	var spawn_position = Vector3(
	dx,
	player.position.y,
	dz)
	var neuer_enemy: EnemyBahaviour = enemy.instantiate()
	neuer_enemy._player = player
	var enemy_stats: EnemyStats = UpgradeManager.get_effective_enemy_stats(neuer_enemy.base_stats)
	if difficulty:
		enemy_stats = difficulty.apply(enemy_stats, elapsed_time)
	neuer_enemy.stats = enemy_stats
	neuer_enemy._onDeathSignal.connect(on_enemy_death)
	get_tree().current_scene.add_child(neuer_enemy)

	neuer_enemy.global_position = spawn_position
	return spawn_position
