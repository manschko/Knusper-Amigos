class_name DamageNumber
extends Label3D

const NORMAL_COLOR := Color.WHITE
const CRIT_COLOR := Color(1.0, 0.15, 0.15)
const RISE_HEIGHT := 1.5
const DURATION := 0.8


static func spawn(parent: Node, world_position: Vector3, amount: float, is_crit: bool) -> void:
	var number := DamageNumber.new()
	parent.add_child(number)
	number.global_position = world_position + Vector3(randf_range(-0.3, 0.3), 0.5, randf_range(-0.3, 0.3))
	number.setup(amount, is_crit)


func setup(amount: float, is_crit: bool) -> void:
	text = str(roundi(amount)) + ("!" if is_crit else "")
	modulate = CRIT_COLOR if is_crit else NORMAL_COLOR
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	render_priority = 127
	outline_render_priority = 126
	fixed_size = true
	pixel_size = 0.0008
	font_size = 48 * 2 if is_crit else 32 * 2
	outline_size = 6
	outline_modulate = Color.BLACK

	var start_scale := Vector3.ONE * (1.6 if is_crit else 1.3)
	scale = start_scale

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", global_position.y + RISE_HEIGHT, DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, DURATION * 0.5).set_delay(DURATION * 0.5)
	tween.tween_property(self, "outline_modulate:a", 0.0, DURATION * 0.5).set_delay(DURATION * 0.5)
	tween.chain().tween_callback(queue_free)
