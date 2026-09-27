@tool
extends PanelContainer
class_name UpgradeRow

## Larger, list-friendly upgrade entry meant to be stacked inside a VBoxContainer.

signal upgrade_pressed

const BORDER_NORMAL := Color(0.3647059, 0.3882353, 0.19607843, 1)
const BORDER_HOVER := Color(0.7176471, 0.9019608, 0.2509804, 1)

@onready var title_label: Label = %TitleLabel
@onready var level_label: Label = %LevelLabel
@onready var description_label: Label = %DescriptionLabel
@onready var level_bar: ProgressBar = %LevelBar
@onready var icon_rect: TextureRect = %Icon
@onready var icon_frame: PanelContainer = %IconFrame
@onready var buy_button: Button = %BuyButton

var _style: StyleBoxFlat

func _ready() -> void:
	# Duplicate so hovering one row doesn't highlight every row sharing the resource.
	_style = get_theme_stylebox("panel").duplicate()
	add_theme_stylebox_override("panel", _style)
	mouse_entered.connect(_set_highlight.bind(true))
	mouse_exited.connect(_set_highlight.bind(false))

func set_title(text: String) -> void:
	title_label.text = text

## Kept for compatibility with the old Upgrade_UI API.
func set_label(text: String) -> void:
	set_title(text)

func set_level(level: int, max_level: int) -> void:
	level_label.text = "Lv. %d / %d" % [level, max_level]
	level_bar.max_value = max(max_level, 1)
	level_bar.value = level

func set_description(text: String) -> void:
	description_label.text = text
	description_label.visible = not text.is_empty()

func set_cost(text: String) -> void:
	buy_button.text = text

func set_icon(texture: Texture2D) -> void:
	icon_rect.texture = texture
	icon_frame.visible = texture != null

func set_disabled(disabled: bool) -> void:
	buy_button.disabled = disabled

func _set_highlight(on: bool) -> void:
	if _style:
		_style.border_color = BORDER_HOVER if on else BORDER_NORMAL

func _on_buy_button_pressed() -> void:
	upgrade_pressed.emit()
