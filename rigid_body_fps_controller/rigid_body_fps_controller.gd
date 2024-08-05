extends RigidBody3D
class_name RigidBodyFpsController

@export var aim_sensitivity := 0.002
@export var aim_limit := 0.24 * TAU
@export var standing_force_p_gain := 100.0
@export var standing_force_d_gain := 10.0
@export var upright_force_p_gain := 30.0
@export var upright_force_d_gain := 6.0
@export var turn_force_p_gain := 71.0
@export var turn_force_d_gain := 35.0
@export var ground_friction_coefficient := 20.0
@export var walk_acceleration := 35.0
@export var walk_speed_max := 6.0
@export var walk_overspeed_deceleration := 2.0
@export var jump_accel := 6.0
@export var air_control_min_acceleration := 100.0
@export var air_control_max_acceleration := 200.0


@export var ground_clearance := 0.3:
	set(value):
		ground_clearance = value
		if not is_node_ready():
			await ready
		# _update_tree()


@export var height := 1.7:
	set(value):
		height = value
		if not is_node_ready():
			await ready
		# _update_tree()


@export var radius := 0.6:
	set(value):
		radius = value
		if not is_node_ready():
			await ready
		# _update_tree()


var _last_standing_error: float
var _last_upright_error: Vector3
var _last_turn_error: Vector3
@onready var collision_shape: CollisionShape3D = $CollisionShape
@onready var debug_capsule: MeshInstance3D = $DebugCapsule
@onready var camera: Camera3D = $Camera3D
@onready var camera_anchor: Node3D = $CameraAnchor
@onready var shape_cast: ShapeCast3D = $ShapeCast3D
@onready var hip_anchor: Node3D = $HipAnchor


func _ready() -> void:
	await get_tree().create_timer(0.1).timeout


func _physics_process(delta: float) -> void:
	var is_on_ground := _physics_process_standing_force(delta)
	_physics_process_walking_force(is_on_ground)
	_physics_process_air_control(is_on_ground)
	_physics_process_upright_force(delta)
	_physics_process_turn_force(delta)
	camera.global_position = camera_anchor.global_position


func _physics_process_standing_force(delta: float) -> bool:
	# var query := PhysicsRayQueryParameters3D.new()
	# var offset := 0.1
	# query.from = global_position + Vector3(0.0, ground_clearance + offset, 0.0)
	# query.to = global_position - 10.0 * Vector3(0.0, ground_clearance, 0.0)
	# query.exclude = [self.get_rid()]
	# var collision := get_world_3d().direct_space_state.intersect_ray(query)

	# var distance := 10.0
	# if collision:
	# 	var point: Vector3 = collision.position
	# 	distance = query.from.distance_to(point) - offset

	var distance := hip_anchor.position.y
	if shape_cast.is_colliding():
		distance = absf(hip_anchor.global_position.y - shape_cast.get_collision_point(0).y)

	var error := hip_anchor.position.y - distance
	var error_delta := (error - _last_standing_error) / delta
	var up_accel := minf(
		standing_force_p_gain * error + standing_force_d_gain * error_delta,
		1000.0
	)
	var is_on_ground := error > 0.0
	var is_close_to_ground := error > -0.0
	if is_close_to_ground:
		# apply_force(Vector3.UP * up_accel * mass, hip_anchor.global_position - global_position)
		apply_central_force(Vector3.UP * up_accel * mass)
	_last_standing_error = error
	return is_on_ground


func _physics_process_walking_force(is_on_ground: bool) -> void:
	if not is_on_ground:
		return

	var camera_space_input := Input.get_vector(
		"move_right",
		"move_left",
		"move_backward",
		"move_forward"
	)

	var global_space_input := (
		Vector3(camera_space_input.x, 0.0, camera_space_input.y)
			.rotated(Vector3.UP, camera.rotation.y + TAU / 2.0)
	)

	var is_walking := global_space_input.length() > 0.0
	var accel: Vector3
	if is_walking:
		var walk_space := Basis.looking_at(
			global_space_input, Vector3.UP, true
		)
		var walk_space_vel := walk_space.transposed() * linear_velocity
		var forward_accel := (
			global_space_input.length() * walk_acceleration if (
				walk_space_vel.z < walk_speed_max
			)
			else -walk_space_vel.z * walk_overspeed_deceleration
		)
		var walk_space_accel := Vector3(
			-walk_space_vel.x * ground_friction_coefficient,
			0.0,
			maxf(
				-walk_space_vel.z * ground_friction_coefficient, forward_accel
			)
		)
		accel = walk_space * walk_space_accel
	else:
		accel = -Vector3(
			linear_velocity.x, 0.0, linear_velocity.z
		) * ground_friction_coefficient

	apply_central_force(mass * accel)


func _physics_process_air_control(is_on_ground: bool) -> void:
	if is_on_ground:
		return

	var camera_space_input := Input.get_vector(
		"move_right",
		"move_left",
		"move_backward",
		"move_forward"
	)

	var global_space_input := (
		Vector3(camera_space_input.x, 0.0, camera_space_input.y)
			.rotated(Vector3.UP, camera.rotation.y + TAU / 2.0)
	)

	var horiz_vel := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	var vel_space := (
		Basis.IDENTITY if horiz_vel.is_zero_approx()
		else Basis.looking_at(horiz_vel, Vector3.UP, true)
	)
	var vel_space_vel := vel_space.transposed() * horiz_vel
	var vel_space_input := vel_space.transposed() * global_space_input
	var air_control_accel := lerpf(
		air_control_min_acceleration,
		air_control_max_acceleration,
		minf(horiz_vel.length() / walk_speed_max, 1.0)
	)
	var vel_space_accel := air_control_accel * Vector3(
		vel_space_input.x,
		0.0,
		vel_space_input.z if vel_space_vel.z < walk_speed_max else 0.0
	)
	var global_space_accel = vel_space * vel_space_accel
	apply_central_force(mass * global_space_accel)


func _physics_process_upright_force(delta: float) -> void:
	var target := Vector3.MODEL_TOP
	var current := global_basis.y
	var error := current.cross(target)
	var error_delta := (error - _last_upright_error) / delta
	var accel := (
		upright_force_p_gain * error + upright_force_d_gain * error_delta
	)
	apply_torque(accel * Util.get_inertia(self))
	_last_upright_error = error


func _physics_process_turn_force(delta: float) -> void:
	var target := -Vector3(
		camera.global_basis.z.x, 0.0, camera.global_basis.z.z
	).normalized()
	var current := Vector3(
		global_basis.z.x, 0.0, global_basis.z.z
	).normalized()
	var error := current.cross(target)
	var error_delta := (error - _last_turn_error) / delta
	var torque := turn_force_p_gain * error + turn_force_d_gain * error_delta
	apply_torque(torque * Util.get_inertia(self))
	_last_turn_error = error


func _input(event: InputEvent) -> void:
	if (
		event is InputEventMouseMotion
		and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	):
		var motion := event as InputEventMouseMotion 
		var rx := camera.rotation.x - motion.relative.y * aim_sensitivity
		var ry := camera.rotation.y - motion.relative.x * aim_sensitivity
		camera.rotation.x = clamp(rx, -aim_limit, aim_limit)
		camera.rotation.y = ry
	if event.is_action_pressed("move_jump"):
		apply_central_impulse(mass * jump_accel * Vector3.UP)


func _update_tree() -> void:
	# TODO: complete me
	var capsule: CapsuleShape3D = collision_shape.shape
	capsule.radius = radius
	capsule.height = height - ground_clearance
	collision_shape.position = Vector3(
		0.0, ground_clearance + capsule.height / 2.0, 0.0
	)
	debug_capsule.position = collision_shape.position
	var capsule_mesh: CapsuleMesh = debug_capsule.mesh
	capsule_mesh.radius = radius
	capsule_mesh.height = capsule.height
	debug_capsule.position = collision_shape.position
