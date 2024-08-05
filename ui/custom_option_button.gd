@tool
extends Control
class_name CustomOptionButton

signal item_selected(item_index: int)
const _CUSTOM_BUTTON_SCENE := preload("res://ui/custom_button.tscn")


@export var selected_index := -1:
	set(value):
		selected_index = clampi(value, -1, items.size() - 1)
		_update_ui()


@export var items: Array[CustomOptionItem] = []:
	set(value):
		items = value
		_update_ui()


@onready var _main_button: CustomButton = $MainButton
@onready var _dropdown: Control = $Dropdown
var _button_down_event_received := false


func _ready() -> void:
	_update_ui()
	if Engine.is_editor_hint():
		return
	_main_button.button_down.connect(_on_main_button_down)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var e: InputEventMouseButton = event
		if not e.pressed:
			return
		await get_tree().process_frame
		if _button_down_event_received:
			_button_down_event_received = false
		else:
			_dropdown.visible = false


func _on_main_button_down() -> void:
	_dropdown.global_position = _main_button.global_position
	_dropdown.global_position.y += _main_button.size.y - 1.0
	_dropdown.size.x = _main_button.size.x
	_dropdown.visible = not _dropdown.visible
	_button_down_event_received = true


func _on_dropdown_button_down(item_index: int) -> void:
	selected_index = item_index
	_button_down_event_received = true
	_dropdown.visible = false
	item_selected.emit(item_index)


func _update_ui() -> void:
	if not is_node_ready():
		await ready
	if selected_index == -1:
		_main_button.text = " "
	else:
		_main_button.text = items[selected_index].text
	for child in _dropdown.get_children():
		_dropdown.remove_child(child)
	for i in items.size():
		var item := items[i]
		if not item:
			continue
		if not item.changed.is_connected(_update_ui):
			item.changed.connect(_update_ui)
		var button: CustomButton = _CUSTOM_BUTTON_SCENE.instantiate()
		button.text = item.text
		button.button_down.connect(_on_dropdown_button_down.bind(i))
		button.checkbox = true
		button.checked = i == selected_index
		_dropdown.add_child(button)
