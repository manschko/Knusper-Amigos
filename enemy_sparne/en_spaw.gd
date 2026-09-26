extends Node3D

@export var charatke: Player
@export var enemy: PackedScene
# Called when the node enters the scene tree for the first time.
var timer = 1.0
var i = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0: 
		timer = 5.0
		i = randi_range(0, 1000)
		if i <= 950:
			spawn()
	
func spawn() -> void:
	var z = charatke.position.z
	var x = charatke.position.x
	var winkel = randf_range(0.0, TAU)
	var radius = randf_range(5, 25)
	var dx = x + cos(winkel) * radius
	var dz = z + sin(winkel) * radius
	var spawn_position = Vector3(
	dx,
	charatke.position.y,
	dz)
	var neuer_enemy = enemy.instantiate()
	neuer_enemy._player = charatke
	get_tree().current_scene.add_child(neuer_enemy)

	neuer_enemy.global_position = spawn_position
