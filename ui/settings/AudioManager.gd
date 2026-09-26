extends Node

var num_players := 8
var SFXplayers: Array[AudioStreamPlayer] = []
var MusicPlayer:AudioStreamPlayer
var next_player := 0

#const DEFAULT_MUSIC_PATH := "res://sound/003_Vaporware.mp3"

func _init() -> void:
	# Keep playing audio (music/SFX) even while the game tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

func _ready() -> void:
	for i in range(num_players):
		var p = AudioStreamPlayer.new()
		add_child(p)
		p.bus = "SFX"
		SFXplayers.append(p)
			
	var p = AudioStreamPlayer.new()
	add_child(p)
	p.bus = "Music"
	MusicPlayer = p

	#var default_music: AudioStream = load(DEFAULT_MUSIC_PATH)
	#if default_music:
		#default_music.loop = true
		#play_music(default_music)

	# Apply any previously saved volume settings right away, so they take
	# effect from the moment the game starts (not just when the settings
	# menu happens to be opened). Default of 50 matches the sliders' own
	# default value when no setting has been saved yet.
	set_bus_volume("Master", SettingsManager.get_setting("Master", 50.0))
	set_bus_volume("Music", SettingsManager.get_setting("Music", 50.0))
	set_bus_volume("SFX", SettingsManager.get_setting("SFX", 50.0))
	set_bus_volume("Voice", SettingsManager.get_setting("Voice", 50.0))

func play_vfx_sound(stream: AudioStream) -> void:
	if not stream:
		return
	SFXplayers[next_player].stream = stream
	SFXplayers[next_player].play()
	next_player = (next_player + 1) % num_players
	
func play_music(stream: AudioStream) -> void:
	if not stream:
		return
	MusicPlayer.stream = stream
	MusicPlayer.play()

## Sets the volume of an audio bus from a 0-100 percentage value
## (as used by the settings sliders), converting it to decibels.
func set_bus_volume(bus_name: String, percent) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return
	var linear_volume = clamp(float(percent) / 100.0, 0.0, 1.0)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))
