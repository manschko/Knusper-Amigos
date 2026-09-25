extends Control
# Quick & dirty debug panel for testing the upgrade system.
# Not meant to stay - just buttons + labels to exercise UpgradeManager.

@onready var damage_label: Label = $VBoxContainer/DamageLabel
@onready var speed_label: Label = $VBoxContainer/SpeedLabel


func _ready() -> void:
	UpgradeManager.upgrade_purchased.connect(_on_upgrade_changed)
	UpgradeManager.upgrade_failed.connect(_on_upgrade_failed)
	_refresh()


func _on_buy_damage_pressed() -> void:
	UpgradeManager.purchase("damage_boost")


func _on_buy_speed_pressed() -> void:
	UpgradeManager.purchase("speed_boost")


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
