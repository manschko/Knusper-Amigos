extends Camera3D

@export var player_camera: Camera3D

func _process(delta):
	if player_camera:
		print(player_camera.global_position)
