extends Node3D

@export var playerScene: PackedScene
@export_file("*.tscn") var upgradeScene: String

@onready var wave_director: WaveDirector = $WaveDirector

var player: Player


func _ready() -> void:
	wave_director.enemy_killed.connect(_on_enemy_killed)
	spawn_player()


func spawn_player() -> void:
	player = playerScene.instantiate()
	player.position = Vector3(0, 2, 0)
	player.died.connect(_on_player_died)
	player.ready.connect(func(): wave_director.start(player, get_tree().current_scene), CONNECT_ONE_SHOT)
	get_tree().current_scene.add_child.call_deferred(player)


func _on_enemy_killed(value: int) -> void:
	Stats.add_crumbs(value * (UpgradeManager.get_bonus_for_stat('crumb_boost') + 1))
	player.heal(UpgradeManager.get_bonus_for_stat('lifesteal'))


func _on_player_died() -> void:
	# The player emits died on every hit at 0 health, only handle the first one.
	if not wave_director.running:
		return
	wave_director.stop()
	Stats.submit_wave(wave_director.wave)
	get_tree().change_scene_to_file(upgradeScene)
