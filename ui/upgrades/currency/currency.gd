@tool
extends HBoxContainer
class_name Currency

@onready var Icon = $icon
@onready var label = $label

@export var icon: Texture2D:
	set(value):
		icon = value
		if is_node_ready():
			Icon.texture = value

func _ready() -> void:
	Icon.texture = icon
		
func set_label(text: String):
	label.text = text
