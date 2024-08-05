class_name CustomParticles3D
extends GPUParticles3D

@export var free_after_lifetime := false
@export var face_camera := false


func _init() -> void:
	global.graphics_preset_changed.connect(_update)
	_update()


func _ready() -> void:
	if face_camera:
		Util.safe_look_at(
			self, get_viewport().get_camera_3d().global_position, true
		)
	if free_after_lifetime:
		await get_tree().create_timer(lifetime).timeout
		queue_free()


func _process(delta: float) -> void:
	if face_camera:
		Util.safe_look_at(
			self, get_viewport().get_camera_3d().global_position, true
		)


func _update() -> void:
	if global.get_graphics_preset() == Global.GraphicsPreset.LOW:
		amount = maxi(amount / 2, 1)
	if global.get_graphics_preset() >= Global.GraphicsPreset.HIGH:
		if draw_pass_1 is QuadMesh:
			var mesh: QuadMesh = draw_pass_1
			if mesh.material is StandardMaterial3D:
				var mat: StandardMaterial3D = mesh.material
				mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if global.get_graphics_preset() == Global.GraphicsPreset.INSANE:
		amount = amount * 2
