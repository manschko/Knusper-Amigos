extends Control

@export var game_scene: PackedScene
@export var ui_element: Node
@export var settings_Scene: PackedScene

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)


func _on_settings_button_pressed() -> void:
	ui_element.hide()
	var s = settings_Scene.instantiate()
	s.closed.connect(func(): ui_element.show())
	get_tree().current_scene.add_child(s)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
