@tool
extends Control
class_name ItemIcon


@export var item_type := ItemViewer.ItemType.CUBE:
	set(value):
		item_type = value
		if not is_node_ready():
			await ready
		_item_viewer.item_type = item_type


@export var text := "":
	set(value):
		text = value
		if not is_node_ready():
			await ready
		_label.text = text


@export var primary := false:
	set(value):
		primary = value
		if not is_node_ready():
			await ready
		_button.primary = primary


@export var disabled := false:
	set(value):
		disabled = value
		if not is_node_ready():
			await ready
		_button.disabled = disabled


@export var hover := false:
	set(value):
		hover = value
		if not is_node_ready():
			await ready
		_button.hover = hover


@onready var _item_viewer: ItemViewer = %ItemViewer
@onready var _label: Label = %Label
@onready var _button: CustomButton = %Button
