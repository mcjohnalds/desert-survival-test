@tool
extends Control
class_name CustomButton

signal button_down


@export var text := "":
	set(value):
		text = value
		_update()


@export var checkbox := false:
	set(value):
		checkbox = value
		_update()


@export var checked := false:
	set(value):
		checked = value
		_update()


@export var chevron := false:
	set(value):
		chevron = value
		_update()


@export var primary := false:
	set(value):
		primary = value
		_update()


@export var back_icon := false:
	set(value):
		back_icon = value
		_update()


@export var disabled := false:
	set(value):
		disabled = value
		_update()


@export var hover := false:
	set(value):
		hover = value
		_update()


@export var _default_material: Material
@export var _primary_material: Material
@export var click_small_sound := false
@onready var _background: Panel = %Background
@onready var _label: Label = %Label
@onready var _checkbox: Control = %Checkbox
@onready var _check: Control = %Check
@onready var _chevron: Control = %Chevron
@onready var _hover: Control = %Hover
@onready var _back_icon: Control = %BackIcon
@onready var _disabled: Control = %Disabled


func _ready() -> void:
	_update()
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event
		if e.pressed:
			if click_small_sound:
				global.play_click_small_sound()
			else:
				global.play_click_sound()
			button_down.emit()
			accept_event()


func _update() -> void:
	if not is_node_ready():
		await ready
	_label.text = text
	_checkbox.visible = checkbox
	_check.visible = checked
	_chevron.visible = chevron
	_back_icon.visible = back_icon
	_disabled.visible = disabled
	_hover.visible = hover
	_background.material = (
		_primary_material if primary else _default_material
	)


func _on_mouse_entered() -> void:
	_hover.visible = true or hover
	global.play_hover_sound()


func _on_mouse_exited() -> void:
	_hover.visible = false or hover
