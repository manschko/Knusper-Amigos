extends ProgressBar


var player: Player

func _ready() -> void:
	player = find_player_ancestor()
	if player:
		player.health_changed.connect(update_health)



func find_player_ancestor() -> Player:
	var p = get_parent()
	while p != null:
		if p is Player:
			return p
		p = p.get_parent()
	return null


func update_health(current: float, max_health: float):
	max_value = max_health
	value = current


func _on_health_pressed() -> void:
	if player:
		player.take_damage(30.0)
