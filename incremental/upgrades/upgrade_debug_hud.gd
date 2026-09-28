extends Control
# Quick & dirty debug panel for testing the upgrade system.
# Not meant to stay - just buttons + labels to exercise UpgradeManager.

@onready var damage_label: Label = $VBoxContainer/DamageLabel
@onready var speed_label: Label = $VBoxContainer/SpeedLabel
@onready var set_all_level_spinbox: SpinBox = $VBoxContainer/SetAllLevelRow/SetAllLevelSpinBox
@onready var include_enemy_debuffs_checkbox: CheckBox = $VBoxContainer/IncludeEnemyDebuffsCheckBox
@onready var set_wave_spinbox: SpinBox = $VBoxContainer/SetWaveRow/SetWaveSpinBox
@onready var wave_label: Label = $VBoxContainer/WaveLabel

# Remembers whether the mouse was captured (e.g. gameplay camera look) before
# the debug panel grabbed it, so we can hand control back on close.
var _mouse_was_captured := false


func _ready() -> void:
	UpgradeManager.upgrade_purchased.connect(_on_upgrade_changed)
	UpgradeManager.upgrade_failed.connect(_on_upgrade_failed)
	var wave_director := _get_wave_director()
	if wave_director != null:
		wave_director.wave_started.connect(_on_wave_started)
		wave_label.text = "Wave: %d" % wave_director.wave
	_refresh()


func _get_wave_director() -> WaveDirector:
	return get_tree().get_first_node_in_group("wave_director") as WaveDirector


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		_toggle_debug_panel()


## Shows/hides this debug panel and frees the mouse cursor so its buttons are
## clickable even while gameplay has the mouse captured (e.g. FPS camera look).
func _toggle_debug_panel() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		_mouse_was_captured = Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif _mouse_was_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_buy_damage_pressed() -> void:
	UpgradeManager.purchase("damage_boost")


func _on_buy_speed_pressed() -> void:
	UpgradeManager.purchase("speed_boost")


func _on_set_all_levels_pressed() -> void:
	var level := int(set_all_level_spinbox.value)
	var include_enemy_debuffs := include_enemy_debuffs_checkbox.button_pressed
	UpgradeManager.debug_set_all_levels(level, include_enemy_debuffs)


func _on_set_wave_pressed() -> void:
	var wave_director := _get_wave_director()
	if wave_director == null:
		print("UpgradeDebugHud: no WaveDirector found in group 'wave_director'")
		return
	wave_director.debug_set_wave(int(set_wave_spinbox.value))


func _on_wave_started(wave: int) -> void:
	wave_label.text = "Wave: %d" % wave


func _on_upgrade_changed(_id: String, _new_level: int) -> void:
	_refresh()


func _on_upgrade_failed(id: String, reason: String) -> void:
	print("Upgrade '%s' failed: %s" % [id, reason])
	_refresh()


func _refresh() -> void:
	_refresh_row("damage_boost", damage_label)
	_refresh_row("speed_boost", speed_label)


func _refresh_row(id: String, label: Label) -> void:
	var upgrade := UpgradeManager.get_upgrade(id)
	if upgrade == null:
		label.text = "%s: missing resource" % id
		return
	var level := UpgradeManager.get_level(id)
	var bonus := UpgradeManager.get_upgrade_bonus(id)
	if UpgradeManager.is_maxed(id):
		label.text = "%s Lv %d/%d (MAX) bonus +%.1f" % [upgrade.display_name, level, upgrade.max_level, bonus]
	else:
		label.text = "%s Lv %d/%d — cost %d (bonus +%.1f)" % [upgrade.display_name, level, upgrade.max_level, UpgradeManager.get_cost(id), bonus]
