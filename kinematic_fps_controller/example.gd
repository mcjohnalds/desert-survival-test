extends Node3D

@onready var _kinematic_fps_controller: KinematicFpsController = (
	$KinematicFpsController
)


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_kinematic_fps_controller.effect_created.connect(_on_effect_created)


func _on_effect_created(effect: Node3D) -> void:
	add_child(effect)
