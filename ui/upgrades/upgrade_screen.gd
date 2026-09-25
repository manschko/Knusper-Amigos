extends Control

## Simple, data-driven upgrade shop screen. Reads currency from the Inventory
## autoload and lists every Upgrade resource discovered by UpgradeManager
## (res://resources/upgrades/*.tres) - add/edit/tweak upgrades there, this
## screen needs no changes to reflect them.

@export var back_scene: PackedScene
@export var upgrade_component: PackedScene
@export var currency: Currency

@onready var upgrade_list: VBoxContainer = $MarginContainer/PanelContainer/MarginContainer2/VBoxContainer/ScrollContainer/UpgradeList

signal upgrades_closed

func _ready() -> void:
	refresh()

func refresh() -> void:
	_rebuild_upgrade_list()
	_link_currency()

func _link_currency() -> void:
	Stats.crumbs_updated.connect(func(crumbs): currency.set_label(str(crumbs)))
	currency.set_label(str(Stats.get_crumbs()))

func _rebuild_upgrade_list() -> void:
	for child in upgrade_list.get_children():
		child.queue_free()

	
	for upgrade in UpgradeManager.upgrades.values():
		_build_upgrade_row(upgrade)

func _build_upgrade_row(upgrade: Upgrade) -> Control:
	if not upgrade_component:
		printerr("upgradeComponente missing from upgrade screen")
		return
	
	var component: Upgrade_UI = upgrade_component.instantiate()
	upgrade_list.add_child(component)
	var level := UpgradeManager.get_level(upgrade.id)
	var maxed := UpgradeManager.is_maxed(upgrade.id)

	component.set_label("%s %d/%d" % [upgrade.display_name, level, upgrade.max_level])
	component.set_description(upgrade.description if upgrade.description else "")
	component.set_cost("MAXED" if maxed else _format_cost(upgrade.get_cost(level)))
	component.set_icon(upgrade.icon)
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
	#if back_scene:
		#get_tree().change_scene_to_packed(back_scene)
	#else:
		#get_tree().change_scene_to_file("res://scenes/Menu/main_menu.tscn")
