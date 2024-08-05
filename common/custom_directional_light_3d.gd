extends DirectionalLight3D
class_name CustomDirectionalLight3d


func _enter_tree() -> void:
	global.graphics_preset_changed.connect(_update)
	_update()


func _update() -> void:
	# Shadows are not supported in web
	shadow_enabled = (
		OS.get_name() != "Web"
		and global.get_graphics_preset() > Global.GraphicsPreset.LOW
	)
