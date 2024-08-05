extends Node3D
class_name Global

signal graphics_preset_changed
enum GraphicsPreset { LOW, MEDIUM, HIGH, INSANE }
@export var environments: Array[Environment] = []
var mouse_sensitivity := 0.25
var invert_mouse := false
var _graphics_preset: GraphicsPreset = GraphicsPreset.MEDIUM
@onready var _music_audio_stream_player: AudioStreamPlayer = (
	$MusicAudioStreamPlayer
)
@onready var _click_audio_stream_player: AudioStreamPlayer = (
	$ClickAudioStreamPlayer
)
@onready var _click_small_audio_stream_player: AudioStreamPlayer = (
	$ClickSmallAudioStreamPlayer
)
@onready var _hover_audio_stream_player: AudioStreamPlayer = (
	$HoverAudioStreamPlayer
)


func _ready() -> void:
	if OS.is_debug_build():
		# The music is annoying when developing
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Music"), -80.0
		)
		if OS.get_name() != "Web":
			# Convent size because you can still see the Godot editor console
			get_window().mode = Window.MODE_WINDOWED
			get_window().size *= 2
	_music_audio_stream_player.play()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()


func get_graphics_preset() -> GraphicsPreset:
	return _graphics_preset


func set_graphics_preset(graphics_preset: GraphicsPreset) -> void:
	_graphics_preset = graphics_preset

	var physics_ticks_per_second: int
	var max_physics_steps_per_frame: int
	var scaling_3d_scale: float
	var msaa_3d: Viewport.MSAA
	var environment_volumetric_fog_enabled: bool
	var environment_glow_enabled: bool
	var environment_ssao_enabled: bool
	var environment_ssil_enabled: bool
	var environment_sdfgi_enabled: bool

	match graphics_preset:
		GraphicsPreset.LOW:
			physics_ticks_per_second = 60
			max_physics_steps_per_frame = 8
			scaling_3d_scale = 0.5
			msaa_3d = Viewport.MSAA_DISABLED
			environment_volumetric_fog_enabled = false
			environment_glow_enabled = false
			environment_ssao_enabled = false
			environment_ssil_enabled = false
			environment_sdfgi_enabled = false
		GraphicsPreset.MEDIUM:
			physics_ticks_per_second = 60
			max_physics_steps_per_frame = 8
			scaling_3d_scale = 0.5
			msaa_3d = Viewport.MSAA_2X
			environment_volumetric_fog_enabled = false
			environment_glow_enabled = true
			environment_ssao_enabled = false
			environment_ssil_enabled = false
			environment_sdfgi_enabled = false
		GraphicsPreset.HIGH:
			physics_ticks_per_second = 60
			max_physics_steps_per_frame = 8
			scaling_3d_scale = 1.0
			msaa_3d = Viewport.MSAA_2X
			environment_volumetric_fog_enabled = false
			environment_glow_enabled = true
			environment_ssao_enabled = true
			environment_ssil_enabled = false
			environment_sdfgi_enabled = false
		GraphicsPreset.INSANE:
			physics_ticks_per_second = 120
			max_physics_steps_per_frame = 16
			scaling_3d_scale = 1.0
			msaa_3d = Viewport.MSAA_4X
			environment_volumetric_fog_enabled = true
			environment_glow_enabled = true
			environment_ssao_enabled = true
			environment_ssil_enabled = true
			environment_sdfgi_enabled = true

	Engine.physics_ticks_per_second = physics_ticks_per_second
	Engine.max_physics_steps_per_frame = max_physics_steps_per_frame
	get_viewport().scaling_3d_scale = scaling_3d_scale
	get_viewport().msaa_3d = msaa_3d
	if OS.get_name() == "Web":
		for environment in environments:
			environment.volumetric_fog_enabled = false
			environment.glow_enabled = false
			environment.ssao_enabled = false
			environment.ssil_enabled = false
			environment.sdfgi_enabled = false
	else:
		for environment in environments:
			environment.volumetric_fog_enabled = (
				environment_volumetric_fog_enabled
			)
			environment.glow_enabled = environment_glow_enabled
			environment.ssao_enabled = environment_ssao_enabled
			environment.ssil_enabled = environment_ssil_enabled
			environment.sdfgi_enabled = environment_sdfgi_enabled

	graphics_preset_changed.emit()


func play_click_sound() -> void:
	_click_audio_stream_player.play()


func play_click_small_sound() -> void:
	_click_small_audio_stream_player.play()


func play_hover_sound() -> void:
	_hover_audio_stream_player.play()
