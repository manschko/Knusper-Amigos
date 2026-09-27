extends Control

## Shows every image in COMIC_DIR in order; each click advances to the next page.
## After the last page, switches to next_scene.

const COMIC_DIR := "res://assets/comic/"
const IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp", "svg"]

@export_file("*.tscn") var next_scene: String

@onready var image: TextureRect = $TextureRect

var pages: Array[Texture2D] = []
var current_page := 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Let clicks reach this Control's _gui_input instead of the image.
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pages = _load_pages()
	if pages.is_empty():
		push_warning("Comic: no images found in '%s'" % COMIC_DIR)
		_finish()
		return
	image.texture = pages[0]

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		next_page()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		next_page()

func next_page() -> void:
	current_page += 1
	if current_page >= pages.size():
		_finish()
		return
	image.texture = pages[current_page]

func _finish() -> void:
	if next_scene:
		get_tree().change_scene_to_file.call_deferred(next_scene)

static func _load_pages() -> Array[Texture2D]:
	var files: Array[String] = []
	# ResourceLoader.list_directory also works in exported builds (remapped/imported files).
	for file_name in ResourceLoader.list_directory(COMIC_DIR):
		if file_name.get_extension().to_lower() in IMAGE_EXTENSIONS:
			files.append(file_name)
	# Natural order so "Story_10" comes after "Story_9".
	files.sort_custom(func(a: String, b: String): return a.naturalnocasecmp_to(b) < 0)

	var textures: Array[Texture2D] = []
	for file_name in files:
		var texture := load(COMIC_DIR + file_name) as Texture2D
		if texture:
			textures.append(texture)
	return textures
