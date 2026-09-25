extends Node

# Autoload: UpgradeManager
#
# Loads every Upgrade resource (.tres) found in UPGRADES_DIR, tracks how many
# levels of each have been purchased, spends crumbs (via Stats) to buy levels,
# and persists purchased levels to disk.
#
# Consumers (player.gd, enemy.gd, ...) do NOT get their stats mutated for
# them. Instead they ask for the current bonus and add it to their own base
# value, e.g.:
#   speed = base_speed + UpgradeManager.get_bonus_for_stat("speed")
# This keeps "what is the base stat" owned by the entity, and "how much extra
# has been bought" owned by the upgrade system, avoiding double-applying
# bonuses when a save is reloaded.

const UPGRADES_DIR := "res://incremental/upgrades/data/"
const SAVE_PATH := "user://upgrades_save.json"

signal upgrade_purchased(id: String, new_level: int)
signal upgrade_failed(id: String, reason: String)

var upgrades: Dictionary = {}   # id (String) -> Upgrade resource
var levels: Dictionary = {}     # id (String) -> int current level


func _ready() -> void:
	_load_upgrade_definitions()
	_load_levels()


func _load_upgrade_definitions() -> void:
	upgrades.clear()
	var dir := DirAccess.open(UPGRADES_DIR)
	if dir == null:
		push_warning("UpgradeManager: could not open '%s'" % UPGRADES_DIR)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource := load(UPGRADES_DIR + file_name)
			if resource is Upgrade:
				if upgrades.has(resource.id):
					push_warning("UpgradeManager: duplicate upgrade id '%s' in '%s'" % [resource.id, file_name])
				upgrades[resource.id] = resource
			else:
				push_warning("UpgradeManager: '%s' is not an Upgrade resource" % file_name)
		file_name = dir.get_next()
	dir.list_dir_end()


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


## Cost to buy the *next* level of this upgrade.
func get_cost(id: String) -> int:
	var upgrade := get_upgrade(id)
	if upgrade == null:
		return -1
	var level := get_level(id)
	return int(round(upgrade.cost * pow(upgrade.cost_growth, level)))


func can_afford(id: String) -> bool:
	var cost := get_cost(id)
	return cost >= 0 and Stats.get_crumbs() >= cost


## Total bonus this single upgrade currently grants (level * value_per_level).
func get_upgrade_bonus(id: String) -> float:
	var upgrade := get_upgrade(id)
	if upgrade == null:
		return 0.0
	return get_level(id) * upgrade.value_per_level


## Total bonus granted to a given stat by ALL purchased upgrades affecting it.
## Consumers should call this and add the result to their own base stat.
func get_bonus_for_stat(stat_key: String) -> float:
	var total := 0.0
	for id in upgrades.keys():
		var upgrade: Upgrade = upgrades[id]
		if upgrade.stat_key == stat_key:
			total += get_upgrade_bonus(id)
	return total


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
