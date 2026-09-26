extends BaseSetting
		
@export var values: Array[String] = []
@export var start_val: String = ""

@onready var label = $HBoxContainer/Label
@onready var select = $HBoxContainer/OptionButton

func _ready():
	# Set up slider properties from exported variables
	for value in values:
		select.add_item(value)
	set_value(start_val)
	label.text = setting_title

	# Connect the UI element signals to our handler functions
	select.item_selected.connect(_on_select_value_changed)
	super._ready()  # Call BaseSetting's _ready first

# Called by the main settings page to set the initial value.
func set_value(value: String):
	select.selected = values.find(value)
	
func reset_to_default():
	set_value(start_val)

# When the user drags the slider...
func _on_select_value_changed(value: float):
	value_changed.emit(setting_title, values[value])
	
