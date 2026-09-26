@tool
class_name BaseSetting extends Control

signal value_changed(label: String, new_value)
@export var setting_title: String
		

func set_value(value):
	assert(false, "ERROR: set_value must be implemented in " + self.setting_title)
	
func _ready():
	assert(setting_title != "", "ERROR: setting_title must be set in " + str(self.name))
	SettingsManager.register_component(self)
	var value = SettingsManager.get_setting(setting_title)
	if value != null:
		call_deferred("set_value", value)
			
func _exit_tree():
	SettingsManager.unregister_component(self)
	
func reset_to_default():
	assert(false, "ERROR: reset_to_default must be implemented in " + self.setting_title)
	
