@tool
extends Control
class_name Upgrade_UI

@onready var label: Label = $MarginContainer2/MarginContainer/HBoxContainer/VBoxContainer/Label
@onready var cost: Label = $MarginContainer2/MarginContainer/HBoxContainer/VBoxContainer/Cost
@onready var description: Label = $MarginContainer2/MarginContainer/HBoxContainer/VBoxContainer/description
@onready var icon: TextureRect = $MarginContainer2/MarginContainer/HBoxContainer/MarginContainer/TextureRect

signal upgrade_pressed

func set_description(text: String):
	if not description:
		printerr("description broke")
		return
	description.text = text

func set_label(text: String):
	if not label:
		printerr("label broke")
		return
	label.text = text
	
func set_cost(text: String):
	if not cost:
		printerr("cost broke")
		return
	cost.text = text
	
func set_icon(texture:Texture2D):
	if not icon:
		printerr("icon broke")
		return
	icon.texture = texture

func _on_button_pressed() -> void:
	upgrade_pressed.emit()
