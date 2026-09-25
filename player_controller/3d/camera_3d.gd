extends Camera3D

@export var sensitivity = 0.2
@export var max_pitch = 85.0
@export var min_pitch = -85.0

var mouse_y_rotation = 0.0
var mouse_x_rotation = 0.0

func _ready():
	# Lock the mouse when the game starts
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotate the parent node (horizontal rotation)
		mouse_x_rotation -= event.relative.x * sensitivity
		rotation.y = deg_to_rad(mouse_x_rotation)
		
		# Rotate the camera node (vertical rotation)
		mouse_y_rotation -= event.relative.y * sensitivity
		mouse_y_rotation = clamp(mouse_y_rotation, min_pitch, max_pitch)
		rotation.x = deg_to_rad(mouse_y_rotation)
	
	if event.is_action_pressed("ui_cancel"): # Use a custom action for the menu
		toggle_menu()

func toggle_menu():
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
