extends Resource
class_name EnemyDifficulty

## Scales EnemyStats over time. Each growth value is the fraction added per minute,
## e.g. health_growth = 0.25 -> +25% health every minute (linear).
## Multipliers are clamped to max_multiplier (0 = no cap).

@export var health_growth: float = 0.25
@export var damage_growth: float = 0.1
@export var speed_growth: float = 0.05
@export var attack_speed_growth: float = 0.05
@export var value_growth: float = 0.1
@export var max_multiplier: float = 0.0


func get_multiplier(growth: float, elapsed_seconds: float) -> float:
	var multiplier := 1.0 + growth * (elapsed_seconds / 60.0)
	if max_multiplier > 0.0:
		multiplier = min(multiplier, max_multiplier)
	return max(multiplier, 0.0)


## Returns a scaled copy of base; base itself is not modified.
func apply(base: EnemyStats, elapsed_seconds: float) -> EnemyStats:
	var scaled: EnemyStats = base.duplicate()
	scaled.health *= get_multiplier(health_growth, elapsed_seconds)
	scaled.attack_damage *= get_multiplier(damage_growth, elapsed_seconds)
	scaled.speed *= get_multiplier(speed_growth, elapsed_seconds)
	var attack_speed := get_multiplier(attack_speed_growth, elapsed_seconds)
	if attack_speed > 0.0:
		scaled.attack_cooldown /= attack_speed
	scaled.value = int(round(scaled.value * get_multiplier(value_growth, elapsed_seconds)))
	return scaled
