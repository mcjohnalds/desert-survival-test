@tool
extends Control
class_name MainMenu

signal started
signal resumed
signal restarted


@export var pause_menu := false:
	set(value):
		pause_menu = value
		_update_controls()


@export var settings_open := false:
	set(value):
		settings_open = value
		_update_controls()


@onready var _title: CustomLabel = %Title
@onready var _start_button: CustomButton = %StartButton
@onready var _resume_button: CustomButton = %ResumeButton
@onready var _restart_button: CustomButton = %RestartButton
@onready var _settings_button: CustomButton = %SettingsButton
@onready var _quit_button: CustomButton = %QuitButton
@onready var _back_button: CustomButton = %BackButton
@onready var _mouse_sensitivity_slider: CustomHSlider = %MouseSensitivitySlider
@onready var _effects_slider: CustomHSlider = %EffectsVolumeSlider
@onready var _music_slider: CustomHSlider = %MusicVolumeSlider
@onready var _invert_mouse_option_button: CustomOptionButton = (
	%InvertMouseOptionButton
)
@onready var _vsync_option_button: CustomOptionButton = %VsyncOptionButton
@onready var _performance_preset_option_button: CustomOptionButton = (
	%PerformancePresetOptionButton
)
@onready var _buttons_container: Control = %ButtonsContainer
@onready var _settings_container: Control = %SettingsContainer
@onready var _vsync_option: Control = %VsyncOption


func _ready() -> void:
	_update_controls()
	if Engine.is_editor_hint():
		return
	_start_button.button_down.connect(started.emit)
	_resume_button.button_down.connect(resumed.emit)
	_restart_button.button_down.connect(restarted.emit)
	_quit_button.button_down.connect(get_tree().quit)
	_settings_button.button_down.connect(_on_settings_button_down)
	_back_button.button_down.connect(_on_back_button_down)
	if Util.is_compatibility_renderer():
		# Compatibility renderer does not support vsync setting at all
		_vsync_option.visible = false
		# Compatibility renderer does not support things like volumetric fog
		_performance_preset_option_button.items = (
			_performance_preset_option_button.items.slice(0, 3)
		)
	if OS.get_name() == "macOS":
		# macOS does not support adaptive or mailbox vsync
		_vsync_option_button.items = _vsync_option_button.items.slice(0, 2)
	_mouse_sensitivity_slider.drag_ended.connect(
		_on_mouse_sensitivity_slider_drag_ended
	)
	_effects_slider.drag_ended.connect(
		_on_effects_slider_drag_ended
	)
	_music_slider.drag_ended.connect(
		_on_music_slider_drag_ended
	)
	_invert_mouse_option_button.item_selected.connect(
		_on_invert_mouse_item_selected
	)
	_vsync_option_button.item_selected.connect(
		_on_vsync_item_selected
	)
	_performance_preset_option_button.item_selected.connect(
		_on_performance_preset_item_selected
	)
	_read_settings_from_environment()


func _read_settings_from_environment() -> void:
	_mouse_sensitivity_slider.value = global.mouse_sensitivity
	_effects_slider.value = _db_to_slider_value(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Effects"))
	)
	_music_slider.value = _db_to_slider_value(
		AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	)
	_invert_mouse_option_button.selected_index = int(global.invert_mouse)
	_vsync_option_button.selected_index = (
		DisplayServer.window_get_vsync_mode()
	)
	_performance_preset_option_button.selected_index = (
		global.get_graphics_preset()
	)


func _on_mouse_sensitivity_slider_drag_ended() -> void:
	global.mouse_sensitivity = _mouse_sensitivity_slider.value


func _on_effects_slider_drag_ended() -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Effects"),
		_slider_value_to_db(_effects_slider.value)
	)


func _on_music_slider_drag_ended() -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		_slider_value_to_db(_music_slider.value)
	)


func _on_invert_mouse_item_selected(index: int) -> void:
	global.invert_mouse = bool(index)


func _on_vsync_item_selected(index: int) -> void:
	DisplayServer.window_set_vsync_mode(index)


func _on_performance_preset_item_selected(index: int) -> void:
	global.set_graphics_preset(index as Global.GraphicsPreset)


func _slider_value_to_db(slider_value: float) -> float:
	return -80.0 + 80.0 * pow(slider_value, 1.0 / 4.0)


func _db_to_slider_value(db: float) -> float:
	return pow(db / 80.0 + 1.0, 4.0)


func _on_settings_button_down() -> void:
	settings_open = true


func _on_back_button_down() -> void:
	settings_open = false


func _update_controls() -> void:
	if not is_node_ready():
		await ready
	_buttons_container.visible = not settings_open
	_settings_container.visible = settings_open
	_quit_button.visible = not Util.is_web_browser()
	if pause_menu:
		_title.text = "Paused"
		_title.type = CustomLabel.Type.HEADER_MEDIUM
		_start_button.visible = false
		_resume_button.visible = true
		_restart_button.visible = true
	else:
		_title.text = "Godot Temple"
		_title.type = CustomLabel.Type.TITLE
		_start_button.visible = true
		_resume_button.visible = false
		_restart_button.visible = false
