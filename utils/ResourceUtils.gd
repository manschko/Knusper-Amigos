extends Node
class_name UpgradeUtils

const UPGRADES_DIR := "res://incremental/upgrades/data/"

static func load_upgrade_definitions() -> Dictionary:
	var found_upgrades: Dictionary = {}
	var dir := DirAccess.open(UPGRADES_DIR)
	if dir == null:
		push_warning("UpgradeManager: could not open '%s'" % UPGRADES_DIR)
		return found_upgrades

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource := load(UPGRADES_DIR + file_name)
			if resource is Upgrade:
				if found_upgrades.has(resource.id):
					push_warning("UpgradeManager: duplicate upgrade id '%s' in '%s'" % [resource.id, file_name])
				found_upgrades[resource.id] = resource
			else:
				push_warning("UpgradeManager: '%s' is not an Upgrade resource" % file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return found_upgrades
