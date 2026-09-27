extends Resource
class_name EnemyType

## res://EnemyBehaviour/types/ werden automatisch geladen

@export var scene: PackedScene
@export var base_stats: EnemyStats
@export var min_wave: int = 1
@export var max_wave: int = 0
@export var weight: float = 1.0
@export var is_boss: bool = false


func is_available(wave: int) -> bool:
	if scene == null or is_boss or weight <= 0.0:
		return false
	return wave >= min_wave and (max_wave <= 0 or wave <= max_wave)
