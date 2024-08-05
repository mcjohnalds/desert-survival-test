extends Control
class_name CustomHSlider

signal drag_ended


@export var value: float:
	get:
		return _slider.value
	set(value):
		_slider.value = value


@onready var _slider: HSlider = %Slider
@onready var _hover: Control = %Hover


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_slider.drag_started.connect(_on_drag_started)
	_slider.drag_ended.connect(_on_drag_ended)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_drag_started() -> void:
	global.play_click_small_sound()


func _on_drag_ended(_value_changed: bool) -> void:
	global.play_click_sound()
	drag_ended.emit()


func _on_mouse_entered() -> void:
	_hover.visible = true
	global.play_hover_sound()


func _on_mouse_exited() -> void:
	_hover.visible = false
