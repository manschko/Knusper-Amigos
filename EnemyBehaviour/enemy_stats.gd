extends Resource
class_name EnemyStats

## Upgrades can target any of these via stat_key = "enemy_<property>",
## e.g. "enemy_health" or "enemy_value".

@export var health: float = 100.0
@export var speed: float = 1.0
@export var attack_range: float = 2.0
@export var attack_damage: float = 1.0
@export var attack_cooldown: float = 1.0
@export var attack_animation_time: float = 0.5
@export var value: int = 1
