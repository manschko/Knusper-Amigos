@tool
extends BaseSetting
		
@export var min_val: float = 0.0
@export var max_val: float = 100.0
@export var start_val: float = 50.0

@onready var label = $HBoxContainer/MarginContainer/Label
@onready var slider = $HBoxContainer/HBoxContainer/HSlider
@onready var line_edit = $HBoxContainer/HBoxContainer/LineEdit

var is_updating = false # Prevents infinite signal loops

func _ready():
	# Set up slider properties from exported variables
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = start_val
	line_edit.text = str(int(start_val))
	slider.step = (max_val - min_val) / 100.0 # A reasonable step
	label.text = setting_title

	# Connect the UI element signals to our handler functions
	slider.value_changed.connect(_on_slider_value_changed)
	line_edit.text_submitted.connect(_on_line_edit_text_submitted)
	super._ready()  # Call BaseSetting's _ready first

# Called by the main settings page to set the initial value.
func set_value(value: float):
	is_updating = true # Prevent signals from firing back and forth
	slider.value = value
	line_edit.text = str(int(value))
	is_updating = false
	
func reset_to_default():
	set_value(start_val)

# When the user drags the slider...
func _on_slider_value_changed(value: float):
	if is_updating: return
	is_updating = true
	line_edit.text = str(int(value))
	value_changed.emit(setting_key, value)
	is_updating = false

# When the user presses Enter in the text box...
func _on_line_edit_text_submitted(new_text: String):
	if is_updating: return
	# Convert text to a float, validating it first.
	var new_val = new_text.to_float()
	# Clamp the value to be within the slider's valid range.
	new_val = clamp(new_val, slider.min_value, slider.max_value)

	is_updating = true
	slider.value = new_val
	line_edit.text = str(int(new_val)) # Update text to the clamped value
	value_changed.emit(setting_key, new_val)
	is_updating = false
	
func set_label(value: String):
	label.text = value
