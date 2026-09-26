@tool
extends BaseSetting
		
@export var start_val: bool = false

@onready var label = $HBoxContainer/Label
@onready var checkbox = $HBoxContainer/CheckBox

func _ready():
	# Set up slider properties from exported variables
	
	label.text = setting_title
	set_value(start_val)
	# Connect the UI element signals to our handler functions
	checkbox.toggled.connect(_on_checkbox_value_changed)
	super._ready()  # Call BaseSetting's _ready first

# Called by the main settings page to set the initial value.
func set_value(value: bool):
	checkbox.button_pressed = value
	
func reset_to_default():
	set_value(start_val)

# When the user drags the slider...
func _on_checkbox_value_changed(value: bool):
	value_changed.emit(setting_title, value)
	
