extends GPUParticles3D

var _lifeTimer : float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_lifeTimer = lifetime;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_lifeTimer -= delta
	if _lifeTimer <= 0:
		queue_free();
