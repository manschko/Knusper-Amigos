class_name ZombieSounds

## Zombie vocal clips from res://assets/ZombieVocals, grouped by file-name prefix.
## Loaded once on first use and shared by all enemies.

const VOCALS_DIR := "res://assets/ZombieVocals/"

static var _death: Array[AudioStream] = []
static var _hit: Array[AudioStream] = []
static var _movement: Array[AudioStream] = []
static var _loaded := false

static func death() -> Array[AudioStream]:
	_ensure_loaded()
	return _death

static func hit() -> Array[AudioStream]:
	_ensure_loaded()
	return _hit

static func movement() -> Array[AudioStream]:
	_ensure_loaded()
	return _movement

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	# ResourceLoader.list_directory also works in exported builds (remapped files).
	for file_name in ResourceLoader.list_directory(VOCALS_DIR):
		# Skip folders and macOS "._" metadata files.
		if file_name.ends_with("/") or file_name.begins_with("."):
			continue
		var target: Array[AudioStream]
		if file_name.begins_with("ZombieDeath"):
			target = _death
		elif file_name.begins_with("ZombieHit"):
			target = _hit
		elif file_name.begins_with("ZombieMovement"):
			target = _movement
		else:
			continue
		var stream := load(VOCALS_DIR + file_name) as AudioStream
		if stream:
			target.append(stream)
