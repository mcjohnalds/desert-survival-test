extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var custom_joint: CustomJoint = $CustomJoint


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	var current := -camera.global_basis.z
	var target := camera.global_position.direction_to(
		custom_joint.body.global_position
	)
	var	new_dir := current.slerp(target, minf(delta * 5.0, 1.0))
	camera.look_at(camera.global_position + new_dir)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		get_viewport().get_camera_3d().current = false
	if event.is_action_pressed("slap"):
		custom_joint.body.apply_central_impulse(
			(Vector3.BACK * 0.1 + Vector3.LEFT * 0.1 + Vector3.UP * 1.8) * 20.5
		)
		custom_joint.body.apply_torque_impulse(
			(Vector3.UP * 0.1 + Vector3.RIGHT * 0.1) * 1.0
		)
