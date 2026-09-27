extends Resource
class_name WaveConfig

@export_group("Pacing")
@export var base_quota: int = 8
@export var quota_per_wave: int = 4
@export var base_duration: float = 20.0
@export var duration_per_wave: float = 2.0
@export var max_duration: float = 45.0
@export var base_max_alive: int = 5
@export var max_alive_per_wave: int = 1
@export var max_alive_cap: int = 40
@export var hard_alive_cap: int = 80 # hard cap für performance
@export var spawn_interval: float = 0.25

@export_group("Stat growth per wave")
@export var health_growth: float = 1.15
@export var damage_growth: float = 1.08
@export var attack_speed_growth: float = 1.02
@export var speed_growth: float = 1.03
@export var max_speed_multiplier: float = 2.0 #0 uncap
@export var value_growth: float = 1.10

@export_group("Bosses")
@export var boss_every: int = 0


func get_quota(wave: int) -> int:
	return base_quota + quota_per_wave * (wave - 1)


func get_duration(wave: int) -> float:
	return min(base_duration + duration_per_wave * (wave - 1), max_duration)


func get_max_alive(wave: int) -> int:
	return min(base_max_alive + max_alive_per_wave * (wave - 1), max_alive_cap)


func get_multiplier(growth: float, wave: int) -> float:
	return pow(growth, wave - 1)


## Returns a scaled copy of base; base itself is not modified.
func apply(base: EnemyStats, wave: int) -> EnemyStats:
	var scaled: EnemyStats = base.duplicate()
	scaled.health *= get_multiplier(health_growth, wave)
	scaled.attack_damage *= get_multiplier(damage_growth, wave)
	scaled.attack_cooldown /= get_multiplier(attack_speed_growth, wave)
	var speed_multiplier := get_multiplier(speed_growth, wave)
	if max_speed_multiplier > 0.0:
		speed_multiplier = min(speed_multiplier, max_speed_multiplier)
	scaled.speed *= speed_multiplier
	scaled.value = int(round(scaled.value * get_multiplier(value_growth, wave)))
	return scaled
