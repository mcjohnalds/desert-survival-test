@tool
extends Resource
class_name CustomOptionItem


@export var text := "":
	set(value):
		text = value
		emit_changed()
