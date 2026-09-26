extends Node

const SAVE_PATH := "user://upgrades_save.json"

signal upgrade_purchased(id: String, new_level: int)
signal upgrade_failed(id: String, reason: String)

var upgrades: Dictionary = {}   # id (String) -> Upgrade resource
var levels: Dictionary = {}     # id (String) -> int current level


func _ready() -> void:
	_update_upgrade_definitions()
	_load_levels()


func _update_upgrade_definitions() -> void:
	upgrades.clear()
	upgrades = UpgradeUtils.load_upgrade_definitions()
	

	



func get_upgrade(id: String) -> Upgrade:
	return upgrades.get(id, null)


func get_all_upgrades() -> Array:
	return upgrades.values()


func get_level(id: String) -> int:
	return levels.get(id, 0)


func is_maxed(id: String) -> bool:
	var upgrade := get_upgrade(id)
	if upgrade == null:
		return true
	return get_level(id) >= upgrade.max_level


func get_cost(id: String) -> int:
	var upgrade := get_upgrade(id)
	if upgrade == null:
		return -1
	var level := get_level(id)
	return int(round(upgrade.cost * pow(upgrade.cost_growth, level)))


func can_afford(id: String) -> bool:
	var cost := get_cost(id)
	return cost >= 0 and Stats.get_crumbs() >= cost


func get_upgrade_bonus(id: String) -> float:
	var upgrade := get_upgrade(id)
	if upgrade == null:
		return 0.0
	return get_level(id) * upgrade.value_per_level


func get_bonus_for_stat(stat_key: String) -> float:
	var total := 0.0
	for id in upgrades.keys():
		var upgrade: Upgrade = upgrades[id]
		if upgrade.stat_key == stat_key:
			total += get_upgrade_bonus(id)
	return total


func get_effective_stats(base: PlayerStats) -> PlayerStats:
	if base == null:
		push_warning("UpgradeManager: get_effective_stats() called with no base PlayerStats, using defaults")
		base = PlayerStats.new()
	var effective: PlayerStats = base.duplicate()
	for property in effective.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var bonus := get_bonus_for_stat(property.name)
			if bonus != 0.0:
				effective.set(property.name, effective.get(property.name) + bonus)
	return effective


## Attempts to buy the next level of the given upgrade.
## Returns true on success. Emits upgrade_purchased / upgrade_failed.
func purchase(id: String) -> bool:
	var upgrade := get_upgrade(id)
	if upgrade == null:
		upgrade_failed.emit(id, "unknown_upgrade")
		return false

	if is_maxed(id):
		upgrade_failed.emit(id, "max_level")
		return false

	var cost := get_cost(id)
	if not Stats.remove_crumbs(cost):
		upgrade_failed.emit(id, "not_enough_crumbs")
		return false

	levels[id] = get_level(id) + 1
	_save_levels()
	upgrade_purchased.emit(id, levels[id])
	return true


func reset_levels() -> void:
	levels.clear()
	_save_levels()


func _save_levels() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("UpgradeManager: could not open save file for writing")
		return
	file.store_string(JSON.stringify(levels))
	file.close()


func _load_levels() -> void:
	levels.clear()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("UpgradeManager: could not open save file for reading")
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) == TYPE_DICTIONARY:
		for id in data.keys():
			levels[id] = int(data[id])
