@tool
extends Node
## Custom handlers for settings that require special logic

signal closed

# Motion blur instance for toggling
var motion_blur_instance: Node

func _ready():
	# Wait for SettingsManager to be ready
	await get_tree().process_frame
	register_handlers()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_close()

func _on_close_button_pressed() -> void:
	_close()

func _close() -> void:
	closed.emit()
	queue_free()

func register_handlers():
	
	# Register resolution handler
	SettingsManager.register_setting_handler("resolution", _on_resolution_changed)
	
	# Register other custom handlers as needed
	SettingsManager.register_setting_handler("fullscreen", _on_fullscreen_changed)
	SettingsManager.register_setting_handler("vsync", _on_vsync_changed)
	SettingsManager.register_setting_handler("master", _on_master_volume_changed)
	SettingsManager.register_setting_handler("frame_rate_limit", _on_frame_rate_limit_changed)
	
	# Graphics quality settings
	SettingsManager.register_setting_handler("shadow_quality", _on_shadow_quality_changed)
	SettingsManager.register_setting_handler("texture_quality", _on_texture_quality_changed)
	SettingsManager.register_setting_handler("anti_aliasing", _on_anti_aliasing_changed)
	SettingsManager.register_setting_handler("render_scale", _on_render_scale_changed)
	SettingsManager.register_setting_handler("motion_blur", _on_motion_blur_changed)
	SettingsManager.register_setting_handler("field_of_view", _on_field_of_view_changed)
	
	# Additional audio settings
	SettingsManager.register_setting_handler("music", _on_music_volume_changed)
	SettingsManager.register_setting_handler("sfx", _on_sfx_volume_changed)
	SettingsManager.register_setting_handler("voice", _on_voice_volume_changed)
	SettingsManager.register_setting_handler("audio_output_device", _on_audio_output_device_changed)
	
	# Input settings
	SettingsManager.register_setting_handler("mouse_sensitivity", _on_mouse_sensitivity_changed)
	SettingsManager.register_setting_handler("invert_mouse_y", _on_invert_mouse_y_changed)
	SettingsManager.register_setting_handler("gamepad_vibration", _on_gamepad_vibration_changed)
	SettingsManager.register_setting_handler("screen_shake", _on_screen_shake_changed)
	
	# Accessibility settings
	SettingsManager.register_setting_handler("ui_scale", _on_ui_scale_changed)
	SettingsManager.register_setting_handler("colorblind_mode", _on_colorblind_mode_changed)
	SettingsManager.register_setting_handler("subtitle_size", _on_subtitle_size_changed)
	SettingsManager.register_setting_handler("language", _on_language_changed)
	SettingsManager.register_setting_handler("subtitles_enabled", _on_subtitles_enabled_changed)
	
	# Performance settings
	SettingsManager.register_setting_handler("particle_quality", _on_particle_quality_changed)
	SettingsManager.register_setting_handler("lighting_quality", _on_lighting_quality_changed)

func _on_resolution_changed(resolution_value):
	print("Resolution changed to: ", resolution_value)
	
	# Handle different resolution formats
	var resolution: Vector2i
	
	if resolution_value is String:
		# Parse string format like "1920x1080"
		var parts = resolution_value.split("x")
		if parts.size() == 2:
			resolution = Vector2i(int(parts[0]), int(parts[1]))
		else:
			push_error("Invalid resolution format: " + str(resolution_value))
			return
	elif resolution_value is Vector2i:
		resolution = resolution_value
	elif resolution_value is Vector2:
		resolution = Vector2i(resolution_value)
	else:
		push_error("Unsupported resolution type: " + str(typeof(resolution_value)))
		return
	
	# Apply the resolution change
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(resolution)
		# Center the window
		var screen_size = DisplayServer.screen_get_size()
		var window_pos = (screen_size - resolution) / 2
		DisplayServer.window_set_position(window_pos)
	else:
		# For fullscreen, we might need to change the display mode
		DisplayServer.window_set_size(resolution)

func _on_fullscreen_changed(fullscreen: String):
	print("Fullscreen changed to: ", fullscreen)
	
	match fullscreen.to_lower():
		"fullscreen":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		"windowed":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		"borderless":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_vsync_changed(vsync_enabled: bool):
	print_debug("VSync changed to: ", vsync_enabled)
	if vsync_enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_master_volume_changed(volume: float):
	print("Master volume changed to: ", volume)
	AudioManager.set_bus_volume("Master", volume)

func _on_frame_rate_limit_changed(frame_rate: String):
	print("Frame rate limit changed to: ", frame_rate)
	
	if frame_rate.to_lower() == "unlimited":
		Engine.max_fps = 0
	else:
		Engine.max_fps = int(frame_rate)

func _on_shadow_quality_changed(quality: String):
	print("Shadow quality changed to: ", quality)
	
	# Set shadow quality based on string value
	match quality.to_lower():
		"low":
			RenderingServer.directional_shadow_atlas_set_size(1024, true)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_HARD)
		"medium":
			RenderingServer.directional_shadow_atlas_set_size(2048, true)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		"high":
			RenderingServer.directional_shadow_atlas_set_size(4096, true)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		"ultra":
			RenderingServer.directional_shadow_atlas_set_size(8192, true)
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		"off":
			RenderingServer.directional_shadow_atlas_set_size(0, true)

func _on_texture_quality_changed(quality: String):
	print("Texture quality changed to: ", quality)
	
	# Set texture filtering and 3D scaling
	match quality.to_lower():
		"low":
			get_viewport().scaling_3d_scale = 0.5
		"medium":
			get_viewport().scaling_3d_scale = 0.75
		"high":
			get_viewport().scaling_3d_scale = 1.0
		"ultra":
			get_viewport().scaling_3d_scale = 1.25

func _on_anti_aliasing_changed(aa_mode: String):
	print("Anti-aliasing changed to: ", aa_mode)
	
	match aa_mode.to_lower():
		"off":
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		"fxaa":
			get_viewport().msaa_3d = Viewport.MSAA_DISABLED
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		"msaa_2x":
			get_viewport().msaa_3d = Viewport.MSAA_2X
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		"msaa_4x":
			get_viewport().msaa_3d = Viewport.MSAA_4X
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
		"msaa_8x":
			get_viewport().msaa_3d = Viewport.MSAA_8X
			get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED

func _on_render_scale_changed(scale: float):
	print("Render scale changed to: ", scale)
	
	# Clamp scale between reasonable values
	scale = clamp(scale, 0.25, 2.0)
	get_viewport().scaling_3d_scale = scale

func _on_motion_blur_changed(enabled: bool):
	print("Motion blur changed to: ", enabled)
	
	# Store motion blur setting for use by rendering pipeline
	ProjectSettings.set_setting("rendering/motion_blur", enabled)
	
	# Note: Motion blur implementation would depend on your specific shader setup
	# This is a placeholder for actual motion blur toggle logic

func _on_field_of_view_changed(fov: float):
	print("Field of view changed to: ", fov)
	
	# Clamp FOV to reasonable range
	fov = clamp(fov, 30.0, 90.0)
	
	# Apply to camera or viewport
	var camera = get_viewport().get_camera()
	if camera:
		camera.fov = fov

func _on_screen_shake_changed(enabled: bool):
	print("Screen shake changed to: ", enabled)
	
	# Store screen shake setting
	ProjectSettings.set_setting("screen_shake_enabled", enabled)

func _on_language_changed(language: String):
	print("Language changed to: ", language)
	
	# Store language setting
	ProjectSettings.set_setting("locale", language)

func _on_subtitles_enabled_changed(enabled: bool):
	print("Subtitles enabled changed to: ", enabled)
	
	# Store subtitles enabled setting
	ProjectSettings.set_setting("subtitles/enabled", enabled)

func _on_particle_quality_changed(quality: String):
	print("Particle quality changed to: ", quality)
	
	# Store particle quality setting
	ProjectSettings.set_setting("rendering/particle_quality", quality)
	
	# Note: Actual particle quality implementation would depend on your particle systems
	# You might adjust max particles, LOD distances, or particle material complexity

func _on_lighting_quality_changed(quality: String):
	print("Lighting quality changed to: ", quality)
	
	# Store lighting quality setting
	ProjectSettings.set_setting("rendering/lighting_quality", quality)
	
	# Note: Lighting quality implementation would adjust shadow distances,
	# light count limits, or reflection probe resolution

func _on_music_volume_changed(volume: float):
	print("Music volume changed to: ", volume)
	AudioManager.set_bus_volume("Music", volume)

func _on_sfx_volume_changed(volume: float):
	print("SFX volume changed to: ", volume)
	AudioManager.set_bus_volume("SFX", volume)

func _on_voice_volume_changed(volume: float):
	print("Voice volume changed to: ", volume)
	AudioManager.set_bus_volume("Voice", volume)

func _on_audio_output_device_changed(device_name: String):
	print("Audio output device changed to: ", device_name)
	
	# In Godot 4, audio device selection is more limited
	# This would typically involve platform-specific code
	# For now, we'll store the preference for potential future use
	ProjectSettings.set_setting("audio/driver/output_device", device_name)

func _on_mouse_sensitivity_changed(sensitivity: float):
	print("Mouse sensitivity changed to: ", sensitivity)
	
	ProjectSettings.set_setting("input/mouse_sensitivity", sensitivity)
	
	# Apply immediately to the active camera, if any.
	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("set_mouse_sensitivity"):
		cam.set_mouse_sensitivity(sensitivity)

func _on_invert_mouse_y_changed(invert: bool):
	print("Invert mouse Y-axis changed to: ", invert)
	
	ProjectSettings.set_setting("input/invert_mouse_y", invert)
	
	# Apply immediately to the active camera, if any.
	var cam = get_viewport().get_camera_3d()
	if cam and cam.has_method("set_invert_y"):
		cam.set_invert_y(invert)

func _on_gamepad_vibration_changed(enabled: bool):
	print("Gamepad vibration changed to: ", enabled)
	
	# Store gamepad vibration setting
	ProjectSettings.set_setting("input/gamepad_vibration", enabled)
	
	# If disabled, stop any current vibration
	if not enabled:
		for joy_id in Input.get_connected_joypads():
			Input.start_joy_vibration(joy_id, 0.0, 0.0, 0.0)

func _on_ui_scale_changed(scale: float):
	print("UI scale changed to: ", scale)
	
	# Clamp UI scale to reasonable values
	scale = clamp(scale, 0.5, 3.0)
	
	# Apply UI scaling using content scale factor
	get_tree().root.content_scale_factor = scale
	
	# Store the setting
	ProjectSettings.set_setting("display/ui_scale", scale)

func _on_colorblind_mode_changed(mode: String):
	print("Colorblind mode changed to: ", mode)
	
	# Apply colorblind-friendly shader or color adjustments
	var main_viewport = get_viewport()
	
	match mode.to_lower():
		"none", "off":
			# Remove any colorblind filters
			if main_viewport.has_method("set_colorblind_filter"):
				main_viewport.set_colorblind_filter(null)
		"protanopia":
			# Red-blind filter
			_apply_colorblind_filter("protanopia")
		"deuteranopia":
			# Green-blind filter
			_apply_colorblind_filter("deuteranopia")
		"tritanopia":
			# Blue-blind filter
			_apply_colorblind_filter("tritanopia")
		"protanomaly":
			# Red-weak filter
			_apply_colorblind_filter("protanomaly")
		"deuteranomaly":
			# Green-weak filter
			_apply_colorblind_filter("deuteranomaly")
		"tritanomaly":
			# Blue-weak filter
			_apply_colorblind_filter("tritanomaly")
	
	ProjectSettings.set_setting("accessibility/colorblind_mode", mode)

func _apply_colorblind_filter(filter_type: String):
	# This would apply a post-processing shader for colorblind accessibility
	# Implementation would depend on your shader setup
	print("Applying colorblind filter: ", filter_type)
	# Example: Load and apply appropriate shader material

func _on_subtitle_size_changed(size: int):
	print("Subtitle size changed to: ", size)
	
	# Clamp subtitle size to reasonable values
	size = clamp(size, 12, 48)
	
	# Apply subtitle size to UI theme or specific subtitle nodes
	var theme = ThemeDB.get_default_theme()
	if theme:
		# Update label font sizes for subtitles
		var font_size = size
		theme.set_font_size("font_size", "Label", font_size)
	
	# Store the setting
	ProjectSettings.set_setting("accessibility/subtitle_size", size)
	
	# You might also want to update existing subtitle labels
	_update_existing_subtitles(size)

func _update_existing_subtitles(size: int):
	# Find and update any existing subtitle labels
	var subtitle_nodes = get_tree().get_nodes_in_group("subtitles")
	for node in subtitle_nodes:
		if node is Label:
			var label_settings = LabelSettings.new()
			label_settings.font_size = size
			node.label_settings = label_settings
