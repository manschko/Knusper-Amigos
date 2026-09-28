extends Control

const TIME_WARNING := 5.0
const TIME_COLOR := Color(1, 1, 1, 1)
const TIME_WARNING_COLOR := Color(1, 0.45, 0.35, 1)

@onready var wave_label: Label = %WaveLabel
@onready var kills_bar: ProgressBar = %KillsBar
@onready var kills_label: Label = %KillsLabel
@onready var time_label: Label = %TimeLabel
@onready var banner: Label = %Banner

var _director: WaveDirector
var _banner_tween: Tween


func _ready() -> void:
	banner.modulate.a = 0.0
	_director = get_tree().get_first_node_in_group(WaveDirector.GROUP)
	if _director == null:
		hide()
		return
	_director.wave_started.connect(_on_wave_started)
	_director.wave_progress.connect(_on_wave_progress)
	_director.wave_time_changed.connect(_on_wave_time_changed)
	_director.boss_spawned.connect(_on_boss_spawned)
	if _director.running:
		wave_label.text = "Wave %d" % _director.wave
		_on_wave_progress(_director.kills, _director.quota)
		_on_wave_time_changed(_director.time_left, _director.duration)


func _on_wave_started(wave: int) -> void:
	wave_label.text = "Wave %d" % wave
	_show_banner("Wave %d" % wave)


func _on_boss_spawned(_boss: EnemyBahaviour) -> void:
	_show_banner("BOSS INCOMING")


func _on_wave_progress(kills: int, quota: int) -> void:
	kills_bar.max_value = max(quota, 1)
	kills_bar.value = kills
	kills_label.text = "%d / %d" % [kills, quota]


func _on_wave_time_changed(time_left: float, _duration: float) -> void:
	var seconds := int(ceil(time_left))
	time_label.text = "%d:%02d" % [floori(seconds / 60.0), seconds % 60]
	time_label.add_theme_color_override("font_color", TIME_WARNING_COLOR if time_left <= TIME_WARNING else TIME_COLOR)


func _show_banner(text: String) -> void:
	banner.text = text
	banner.pivot_offset = banner.size / 2.0
	if _banner_tween:
		_banner_tween.kill()
	banner.modulate.a = 0.0
	banner.scale = Vector2(1.4, 1.4)
	_banner_tween = create_tween()
	_banner_tween.tween_property(banner, "modulate:a", 1.0, 0.15)
	_banner_tween.parallel().tween_property(banner, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_banner_tween.tween_interval(0.9)
	_banner_tween.tween_property(banner, "modulate:a", 0.0, 0.4)
