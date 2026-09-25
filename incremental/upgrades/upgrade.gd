extends Resource
class_name Upgrade

@export var id: String
@export var display_name: String
@export var description: String
@export var cost: int       
@export var max_level: int = 10
@export var cost_growth: float = 1.15
@export var stat_key: String = ""
@export var value_per_level: float = 0.0
@export var icon: Texture2D


func get_cost(current_level: int) -> int:
	return int(cost * pow(cost_growth, current_level))
