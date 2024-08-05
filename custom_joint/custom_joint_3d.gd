extends Node3D
class_name CustomJoint3D

var _initial_position_head: Vector3
var _initial_position_body: Vector3
var _initial_position_roller: Vector3
var _initial_rotation_head: Quaternion
var _initial_rotation_body: Quaternion
var _initial_rotation_roller: Quaternion
var _head_joint_position_error_integral: Vector3
var _body_joint_position_error_integral: Vector3
var k_pos_p := 300.0
var k_pos_d := 30.0
var k_pos_i := 0.0
var k_rot_p := 30.0
var k_rot_d := 3.0
var bias_factor := 0.1

@onready var camera: Camera3D = $Camera3D
@onready var camera_anchor: Node3D = $Head/CameraAnchor
@onready var head: RigidBody3D = $Head
@onready var body: RigidBody3D = $Body
@onready var roller: RigidBody3D = $Roller


func _ready() -> void:
	_initial_position_head = head.position
	_initial_position_body = body.position
	_initial_position_roller = roller.position
	_initial_rotation_head = head.basis.get_rotation_quaternion()
	_initial_rotation_body = body.basis.get_rotation_quaternion()
	_initial_rotation_roller = roller.basis.get_rotation_quaternion()


func _physics_process(delta: float) -> void:
	_physics_process_body_joint(delta)
	_physics_process_head_joint(delta)
	camera.global_position = camera_anchor.global_position

func _physics_process_body_joint(delta: float):
	var c0 := (
		body.global_basis * (_initial_position_roller - _initial_position_body)
	)
	var q0 := _initial_rotation_roller * _initial_rotation_body.inverse()
	var dp := roller.global_position - body.global_position
	var dq := (
		roller.global_basis.get_rotation_quaternion()
		* body.global_basis.get_rotation_quaternion().inverse()
	)
	var ep := dp - c0
	_body_joint_position_error_integral += ep * delta
	var eq := dq * q0.inverse()
	var ew := 2.0 * Vector3(eq.x, eq.y, eq.z)
	var vr := roller.linear_velocity - body.linear_velocity
	var wr := roller.angular_velocity - body.angular_velocity
	var bias := bias_factor * ep / delta
	var f := k_pos_p * (ep + bias) + k_pos_d * vr + k_pos_i * _body_joint_position_error_integral
	var t := k_rot_p * ew + k_rot_d * wr
	var sm := body.mass + roller.mass
	body.apply_central_force(f * roller.mass / sm)
	roller.apply_central_force(-f * body.mass / sm)
	var body_inertia := Util.get_inertia(body)
	var roller_inertia := Util.get_inertia(roller)
	var si := body_inertia + roller_inertia
	body.apply_torque(t * roller_inertia / si)
	roller.apply_torque(-t * body_inertia / si)


func _physics_process_head_joint(delta: float):
	var c0 := (
		body.global_basis * (_initial_position_body - _initial_position_head)
	)
	var q0 := _initial_rotation_body * _initial_rotation_head.inverse()
	var dp := body.global_position - head.global_position
	var dq := (
		body.global_basis.get_rotation_quaternion()
		* head.global_basis.get_rotation_quaternion().inverse()
	)
	var ep := dp - c0
	_head_joint_position_error_integral += ep * delta
	var eq := dq * q0.inverse()
	var ew := 2.0 * Vector3(eq.x, eq.y, eq.z)
	var vr := body.linear_velocity - head.linear_velocity
	var wr := body.angular_velocity - head.angular_velocity
	var bias := bias_factor * ep / delta
	var f := k_pos_p * (ep + bias) + k_pos_d * vr + k_pos_i * _head_joint_position_error_integral
	var t := k_rot_p * ew + k_rot_d * wr
	var sm := head.mass + body.mass
	head.apply_central_force(f * body.mass / sm)
	body.apply_central_force(-f * head.mass / sm)
	var head_inertia := Util.get_inertia(head)
	var body_inertia := Util.get_inertia(body)
	var si := head_inertia + body_inertia
	head.apply_torque(t * body_inertia / si)
	body.apply_torque(-t * head_inertia / si)
