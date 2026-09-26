extends PanelContainer

@export var settingsScene: PackedScene

var pause = false
var settings: Node

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and not settings:
		togglePause()


func _on_continue_pressed() -> void:
	togglePause()
	

func togglePause():
	if pause:
		hide()
		get_tree().paused = false
		pause = false
	else:
		show()
		get_tree().paused = true
		pause = true

func _on_settings_pressed() -> void:
	if settings:
		return
	settings = settingsScene.instantiate()
	settings.closed.connect(_on_settings_close)
	add_child(settings)

func _on_settings_close() -> void:
	settings = null
	


func _on_quit_pressed() -> void:
	get_tree().quit()
	#get_tree().paused = false
	#pause = false
