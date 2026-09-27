extends Node

const SAVE_PATH := "user://stats_save.json"
signal crumbs_updated

var stats: Dictionary = {
	"crumbs": 100,
	"best_wave": 0,
	"last_wave": 0,
						}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_stats()


func add_crumbs(amount: int) -> void:
	stats["crumbs"] += amount
	save_stats()


func get_crumbs() -> int:
	return stats["crumbs"]


func reset_stats() -> void:
	stats["crumbs"] = 0
	save_stats()


func submit_wave(wave: int) -> bool:
	stats["last_wave"] = wave
	var is_record := wave > get_best_wave()
	if is_record:
		stats["best_wave"] = wave
	save_stats()
	return is_record


func get_best_wave() -> int:
	return int(stats["best_wave"])


func get_last_wave() -> int:
	return int(stats["last_wave"])

func remove_crumbs(amount: int) -> bool:
	var old_value = stats["crumbs"]
	stats["crumbs"] -= amount
	if stats["crumbs"] < 0:
		stats["crumbs"] = old_value
		return false
	save_stats()
	return true


func save_stats() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Stats: could not open save file for writing")
		return
	file.store_string(JSON.stringify(stats))
	file.close()
	crumbs_updated.emit(stats["crumbs"])


func load_stats() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Stats: could not open save file for reading")
		return
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) == TYPE_DICTIONARY:
		for key in data.keys():
			stats[key] = data[key]
