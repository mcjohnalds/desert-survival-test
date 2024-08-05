@tool
extends TextureRect
class_name BloodVignette


@export_range(0.0, 1.0) var strength := 0.0:
	set(value):
		strength = value
		if not is_node_ready():
			await ready
		var s := get_viewport_rect().size
		size = s * remap(strength, 0.0, 1.0, 1.8, 1.2)
		position = s / 2.0 - size / 2.0
		modulate.a = remap(strength, 0.0, 1.0, 0.0, 0.5)


func _ready() -> void:
	strength = strength
