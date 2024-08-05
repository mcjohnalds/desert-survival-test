@tool
extends Label
class_name CustomLabel

enum Type { BODY_MEDIUM, HEADER_SMALL, HEADER_MEDIUM, HEADER_LARGE, TITLE }


@export var type := Type.BODY_MEDIUM:
	set(value):
		type = value
		if not is_node_ready():
			await ready
		var font: Font
		var font_size: int
		match type:
			Type.BODY_MEDIUM:
				font = default_font
				font_size = 16
				_outline.visible = false
			Type.HEADER_SMALL:
				font = header_font
				font_size = 20
				_outline.visible = false
			Type.HEADER_MEDIUM:
				font = header_font
				font_size = 24
				_outline.visible = false
			Type.HEADER_LARGE:
				font = header_font
				font_size = 28
				_outline.visible = false
			Type.TITLE:
				font = title_font
				font_size = 32
				_outline.visible = true
		add_theme_font_override("font", font)
		add_theme_font_size_override("font_size", font_size)


@export var default_font: Font
@export var header_font: Font
@export var title_font: Font
@onready var _outline: Label = $Outline


func _ready() -> void:
	_outline.text = text
	type = type
