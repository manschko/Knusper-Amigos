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
	var p := SFXplayers[next_player]
	p.stream = stream
	p.pitch_scale = 1.0
	p.set_meta("group", &"")
	p.set_meta("owner_id", 0)
	p.play()
	next_player = (next_player + 1) % num_players

## True while a sound started with [param owner] is still playing.
func is_playing_for(owner: Object) -> bool:
	return _player_for(owner) != null

## Stops the sound currently playing for [param owner] (if any), freeing its channel.
func stop_for(owner: Object) -> void:
	var p := _player_for(owner)
	if p:
		p.stop()

func _player_for(owner: Object) -> AudioStreamPlayer:
	if owner == null:
		return null
	var id := owner.get_instance_id()
	for p in SFXplayers:
		if p.playing and p.get_meta("owner_id", 0) == id:
			return p
	return null

## Plays a sound on a free SFX channel without cutting off other sounds.
## [param group] + [param max_in_group] cap how many channels one kind of sound
## may occupy (e.g. zombie groans), so frequent sounds can't hog all channels.
## With [param interrupt] the oldest-playing channel is taken over when all are busy.
## [param owner] tags the sound so it can be queried/stopped via is_playing_for/stop_for.
## Returns false if the sound was dropped.
func play_sfx(stream: AudioStream, group: StringName = &"", max_in_group: int = num_players,
		interrupt: bool = false, pitch: float = 1.0, owner: Object = null) -> bool:
	if not stream:
		return false
	var free_player: AudioStreamPlayer = null
	var oldest: AudioStreamPlayer = null
	var in_group := 0
	for p in SFXplayers:
		if not p.playing:
			if free_player == null:
				free_player = p
			continue
		if group != &"" and p.get_meta("group", &"") == group:
			in_group += 1
		if oldest == null or p.get_playback_position() > oldest.get_playback_position():
			oldest = p
	if group != &"" and in_group >= max_in_group:
		return false
	var target := free_player
	if target == null:
		if not interrupt:
			return false
		target = oldest
	target.stream = stream
	target.pitch_scale = pitch
	target.set_meta("group", group)
	target.set_meta("owner_id", owner.get_instance_id() if owner else 0)
	target.play()
	return true

func play_random_sfx(streams: Array[AudioStream], group: StringName = &"",
		max_in_group: int = num_players, interrupt: bool = false, owner: Object = null) -> bool:
	if streams.is_empty():
		return false
	return play_sfx(streams.pick_random(), group, max_in_group, interrupt, randf_range(0.9, 1.1), owner)
	
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
