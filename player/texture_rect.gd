extends TextureRect
@export var holding: Texture
@export var throwing: Texture


func throw():
	texture = throwing
	
func hold():
	texture = holding
