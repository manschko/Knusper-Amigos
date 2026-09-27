extends Control

## Simple, data-driven upgrade shop screen. Reads currency from the Inventory
## autoload and lists every Upgrade resource discovered by UpgradeManager
## (res://resources/upgrades/*.tres) - add/edit/tweak upgrades there, this
## screen needs no changes to reflect them.

@export_file("*.tscn") var back_scene: String
@export var upgrade_component: PackedScene
@export var currency: Currency

@onready var upgrade_list: VBoxContainer = %UpgradeList
@onready var run_info: Label = %RunInfo

signal upgrades_closed

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	refresh()

func refresh() -> void:
	_rebuild_upgrade_list()
	_link_currency()
	_update_run_info()

func _update_run_info() -> void:
	var best := Stats.get_best_wave()
	run_info.visible = best > 0
	run_info.text = "Wave %d   Best %d" % [Stats.get_last_wave(), best]

func _link_currency() -> void:
	Stats.crumbs_updated.connect(func(crumbs): currency.set_label(str(crumbs)))
	currency.set_label(str(Stats.get_crumbs()))

func _rebuild_upgrade_list() -> void:
	for child in upgrade_list.get_children():
		child.queue_free()

	# Maxed upgrades go to the bottom; otherwise keep the original order.
	var available: Array = []
	var maxed: Array = []
	for upgrade in UpgradeManager.upgrades.values():
		if UpgradeManager.is_maxed(upgrade.id):
			maxed.append(upgrade)
		else:
			available.append(upgrade)

	for upgrade in available + maxed:
		_build_upgrade_row(upgrade)

func _build_upgrade_row(upgrade: Upgrade) -> Control:
	if not upgrade_component:
		printerr("upgradeComponente missing from upgrade screen")
		return
	
	var component: UpgradeRow = upgrade_component.instantiate()
	upgrade_list.add_child(component)
	var level := UpgradeManager.get_level(upgrade.id)
	var maxed := UpgradeManager.is_maxed(upgrade.id)

	component.set_title(upgrade.display_name)
	component.set_level(level, upgrade.max_level)
	component.set_description(upgrade.description if upgrade.description else "")
	component.set_cost("MAXED" if maxed else _format_cost(upgrade.get_cost(level)))
	component.set_icon(upgrade.icon)
	component.set_disabled(maxed or not UpgradeManager.can_afford(upgrade.id))
	component.upgrade_pressed.connect(_on_buy_pressed.bind(upgrade))


	return component

func _format_cost(cost: int) -> String:
	return "%d Crumbs" % cost

func _on_buy_pressed(upgrade: Upgrade) -> void:
	if UpgradeManager.purchase(upgrade.id):
		refresh()

func _on_back_button_pressed() -> void:
	hide()
	upgrades_closed.emit()
	if back_scene:
		get_tree().change_scene_to_file(back_scene)
	else:
		pass
		#get_tree().change_scene_to_file("res://scenes/Menu/main_menu.tscn")
