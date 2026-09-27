extends RigidBody3D
class_name EnemyProj

var damage = 10
var crit = false

@onready var sprite: Sprite3D = $CollisionShape3D/Sprite3D

@export var splashObject : PackedScene;

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func _on_body_entered(body: Node) -> void:
	if body is EnemyBahaviour:
		return;
	
	if body is Player:
		#todo display damage number
		body.take_damage(damage);
	queue_free() # destroy projectile
