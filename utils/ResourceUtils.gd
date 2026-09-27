extends Node
class_name UpgradeUtils

const UPGRADES_DIR := "res://Balancing/upgrades/"

static func load_upgrade_definitions() -> Dictionary:
	var found_upgrades: Dictionary = {}
	# ResourceLoader.list_directory (unlike DirAccess) resolves the ".remap"
	# files that exported builds use instead of the original ".tres" files.
	var files := ResourceLoader.list_directory(UPGRADES_DIR)
	if files.is_empty():
		push_warning("UpgradeManager: no resources found in '%s'" % UPGRADES_DIR)
		return found_upgrades

	for file_name in files:
		if not file_name.ends_with(".tres"):
			continue
		var resource := load(UPGRADES_DIR + file_name)
		if resource is Upgrade:
			if found_upgrades.has(resource.id):
				push_warning("UpgradeManager: duplicate upgrade id '%s' in '%s'" % [resource.id, file_name])
			found_upgrades[resource.id] = resource
		else:
			push_warning("UpgradeManager: '%s' is not an Upgrade resource" % file_name)
	return found_upgrades
