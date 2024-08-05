extends Object
class_name Util

## Minimum positive 64-bit floating-point number > 0.
## [br]0x0000000000000001
const FLOAT64_MIN_SUBNORMAL: float = 2.0**-1074 # ≈ 4.9406564584124654e-324
## Maximum positive 64-bit floating-point subnormal number (min possible value in binary exponent).
## [br]0x000FFFFFFFFFFFFF
const FLOAT64_MAX_SUBNORMAL: float = 2.0**-1022 - 2.0**-1074 # ≈ 2.2250738585072009e-308
## Minimum positive 64-bit floating-point normalized number (no leading 0 in binary significand).
## [br]0x0010000000000000
const FLOAT64_MIN_NORMAL: float = 2.0**-1022 # ≈ 2.2250738585072014e-308
## Maximum positive 64-bit floating-point number < 1 (≈ 0.9999999999999998889776975375).
## [br]0x3FEFFFFFFFFFFFFF
const FLOAT64_MAX_BELOW_1: float = 1 - 2.0**-53 # ≈ 0.9999999999999998889776975375
## Minimum positive 64-bit floating-point number > 1 (≈ 1.000000000000000222044604925).
## [br]0x3FF0000000000001
const FLOAT64_MIN_ABOVE_1: float = 1 + 2.0**-52 # ≈ 1.000000000000000222044604925
## Maximum positive 64-bit floating-point finite number.
## [br]0x7FEFFFFFFFFFFFFF
const FLOAT64_MAX: float = 2.0**1023 * (2 - 2.0**-52) # ≈ 1.7976931348623157e308

## Minimum positive 32-bit floating-point number > 0.
## [br]0x00000001
const FLOAT32_MIN_SUBNORMAL: float = 2.0**-149 # ≈ 1.4012984643e-45
## Maximum positive 32-bit floating-point subnormal number (min possible value in binary exponent).
## [br]0x007FFFFF
const FLOAT32_MAX_SUBNORMAL: float = 2.0**-126 - 2.0**-149 # ≈ 1.1754942107e-38
## Minimum positive 32-bit floating-point normalized number (no leading 0 in binary significand).
## [br]0x00800000
const FLOAT32_MIN_NORMAL: float = 2.0**-126 # ≈ 1.1754943508e-38
## Maximum positive 32-bit floating-point number < 1 (= 0.999999940395355224609375).
## [br]0x3F7FFFFF
const FLOAT32_MAX_BELOW_1: float = 1 - 2.0**-24 # = 0.999999940395355224609375
## Minimum positive 32-bit floating-point number > 1 (= 1.00000011920928955078125).
## [br]0x3F800001
const FLOAT32_MIN_ABOVE_1: float = 1 + 2.0**-23 # = 1.00000011920928955078125
## Maximum positive 32-bit floating-point finite number.
## [br]0x7F7FFFFF
const FLOAT32_MAX: float = 2.0**127 * (2 - 2.0**-23) # ≈ 3.4028234664e38

## Minimum positive 16-bit floating-point number > 0.
## [br]0x0001
const FLOAT16_MIN_SUBNORMAL: float = 2.0**-24 # = 0.000000059604644775390625
## Maximum positive 16-bit floating-point subnormal number (min possible value in binary exponent).
## [br]0x03FF
const FLOAT16_MAX_SUBNORMAL: float = 2.0**-14 - 2.0**-24 # = 0.000060975551605224609375
## Minimum positive 16-bit floating-point normalized number (no leading 0 in binary significand).
## [br]0x0400
const FLOAT16_MIN_NORMAL: float = 2.0**-14 # = 0.00006103515625
## Maximum positive 16-bit floating-point number < 1.
## [br]0x3BFF
const FLOAT16_MAX_BELOW_1: float = 1 - 2.0**-11 # = 0.99951171875
## Minimum positive 16-bit floating-point number > 1.
## [br]0x3C01
const FLOAT16_MIN_ABOVE_1: float = 1 + 2.0**-10 # = 1.0009765625
## Maximum positive 16-bit floating-point finite number.
## [br]0x7BFF
const FLOAT16_MAX: float = 2.0**15 * (2 - 2.0**-10) # = 65504

## True only if compiled with [code]precision=double[/code].
## This means floats in data structures such as Vector2 and Vector3 are 64-bit instead of 32-bit.
const IS_DOUBLE_PRECISION: bool = Vector2(1e39, 0).x != INF

## Minimum positive number > 0 used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MIN_SUBNORMAL: float = (
	FLOAT64_MIN_SUBNORMAL if IS_DOUBLE_PRECISION else FLOAT32_MIN_SUBNORMAL
)
## Maximum positive subnormal number used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MAX_SUBNORMAL: float = (
	FLOAT64_MAX_SUBNORMAL if IS_DOUBLE_PRECISION else FLOAT32_MAX_SUBNORMAL
)
## Minimum positive normalized number used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MIN_NORMAL: float = (
	FLOAT64_MIN_NORMAL if IS_DOUBLE_PRECISION else FLOAT32_MIN_NORMAL
)
## Maximum positive number < 1 used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MAX_BELOW_1: float = (
	FLOAT64_MAX_BELOW_1 if IS_DOUBLE_PRECISION else FLOAT32_MAX_BELOW_1
)
## Minimum positive number > 1 used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MIN_ABOVE_1: float = (
	FLOAT64_MIN_ABOVE_1 if IS_DOUBLE_PRECISION else FLOAT32_MIN_ABOVE_1
)
## Maximum positive finite number used in engine floats. See IS_DOUBLE_PRECISION.
const FLOAT_MAX: float = (
	FLOAT64_MAX if IS_DOUBLE_PRECISION else FLOAT32_MAX
)

## Maximum negative 64-bit signed integer number. Its positive cannot be represented in 64 bits.
## [br]0x8000000000000000
const INT64_NEGATIVE_LIMIT: int = -9223372036854775808
## Maximum positive 64-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7FFFFFFFFFFFFFFF
const INT64_MAX: int = 9223372036854775807

## Maximum negative 32-bit signed integer number. Its positive cannot be represented in 32 bits.
## [br]0x80000000
const INT32_NEGATIVE_LIMIT: int = -2147483648
## Maximum positive 32-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7FFFFFFF
const INT32_MAX: int = 2147483647
## Maximum 32-bit unsigned integer number.
## [br]0xFFFFFFFF
const UINT32_MAX: int = 4294967295

## Maximum negative 16-bit signed integer number. Its positive cannot be represented in 16 bits.
## [br]0x8000
const INT16_NEGATIVE_LIMIT: int = -32768
## Maximum positive 16-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7FFF
const INT16_MAX: int = 32767
## Maximum 16-bit unsigned integer number.
## [br]0xFFFF
const UINT16_MAX: int = 65535

## Maximum negative 8-bit signed integer number. Its positive cannot be represented in 8 bits.
## [br]0x80
const INT8_NEGATIVE_LIMIT: int = -128
## Maximum positive 8-bit signed integer number. Use a minus to obtain its negative.
## [br]0x7F
const INT8_MAX: int = 127
## Maximum 8-bit unsigned integer number.
## [br]0xFF
const UINT8_MAX: int = 255


static func is_compatibility_renderer() -> bool:
	var rendering_method: String = (
		ProjectSettings["rendering/renderer/rendering_method"]
	)
	return rendering_method == "gl_compatibility"


static func get_inertia(body: RigidBody3D) -> Vector3:
	var state := PhysicsServer3D.body_get_direct_state(body.get_rid())
	return state.inverse_inertia.inverse()


static func is_web_browser() -> bool:
	return OS.get_name() == "Web"


static func get_default_gravity() -> float:
	return ProjectSettings.get_setting("physics/3d/default_gravity")


static func get_files_recursive(path: String) -> Array[String]:
	return _get_files_recursive(path, [])


static func _get_files_recursive(
	path: String, files: Array[String] = []
) -> Array[String]:
	var dir := DirAccess.open(path)
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			var file_path := dir.get_current_dir().path_join(file_name)
			if dir.current_is_dir():
				files = _get_files_recursive(file_path, files)
			else:
				files.append(file_path)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access %s" % path)
	return files


# Like Node3D.look_at but won't error
static func safe_look_at(
	node: Node3D, target: Vector3, use_model_front: bool = false
) -> void:
	var p : Vector3 = node.global_transform.origin
	if p.is_equal_approx(target):
		return
	var v := p.direction_to(target)
	var ws := [Vector3.UP, Vector3.FORWARD, Vector3.LEFT]
	for w: Vector3 in ws:
		var is_parallel := is_equal_approx(absf(v.dot(w)), 1.0)
		if not w.cross(target - p).is_zero_approx() and not is_parallel:
			node.look_at(target, w, use_model_front)


# Point is global
static func get_point_velocity(body: RigidBody3D, point: Vector3) -> Vector3:
	return (
		body.linear_velocity
		+ body.angular_velocity.cross(point - body.global_transform.origin)
	)


static func get_ticks_sec() -> float:
	return Time.get_ticks_msec() / 1000.0


static func get_vector3_xz(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)


static func vector_3_to_dictionary(v: Vector3) -> Dictionary:
	return { "x": v.x, "y": v.y, "z": v.z }


static func dictionary_to_vector_3(d: Dictionary) -> Vector3:
	var x: float = d.x
	var y: float = d.y
	var z: float = d.z
	return Vector3(x, y, z)


static func is_graph_connected(pairs: Array) -> bool:
	if pairs.size() == 0:
		return true

	var graph := {}
	for pair: Array in pairs:
		var a: Variant = pair[0]
		var b: Variant = pair[1]
		if not graph.has(a):
			graph[a] = []
		if not graph.has(b):
			graph[b] = []
		var a_arr: Array = graph[a]
		var b_arr: Array = graph[b]
		a_arr.append(b)
		b_arr.append(a)

	var visited := {}
	var nodes := graph.keys()
	var stack := [nodes[0]]
	visited[nodes[0]] = true

	while stack.size() > 0:
		var node: Variant = stack.pop_back()
		for neighbor: Variant in graph[node]:
			if not visited.has(neighbor):
				visited[neighbor] = true
				stack.append(neighbor)

	return visited.size() == nodes.size()


static func direction_to_quaternion(direction: Vector3) -> Quaternion:
	var forward := Vector3(0.0, 0.0, 1.0)
	var dot := forward.dot(direction)
	var cross := forward.cross(direction).normalized()
	var angle := acos(dot)
	if is_zero_approx(angle):
		return Quaternion.IDENTITY
	return Quaternion(cross, angle)


static func get_children_recursive(
	node: Node, include_internal := false
) -> Array[Node]:
	var nodes: Array[Node] = []
	for child in node.get_children(include_internal):
		nodes.append(child)
		if child.get_child_count(include_internal) > 0:
			nodes.append_array(get_children_recursive(child, include_internal))
	return nodes


static func sample_curve_tangent(curve: Curve, offset: float) -> float:
	var px := 1.0 / curve.point_count
	return (curve.sample(offset + px) - curve.sample(offset - px)) / (2.0 * px)


static func object_to_dict(object: Object) -> Dictionary:
	var script: Script = object.get_script()
	var result := { "_script_path": script.get_path() }
	for property in object.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var name: String = property.name
			result[property.name] = object.get(name)
	return result


static func dict_to_object(dict: Dictionary) -> Variant:
	var path: String = dict._script_path
	var script: Script = load(path)
	@warning_ignore("unsafe_method_access")
	var instance: Object = script.new()
	for key: String in dict.keys():
		if key != "_script_path":
			instance.set(key, dict[key])
	return instance


## Like [method CanvasItem.draw_arc] except filled instead of outlined.
static func draw_arc_filled(
	canvas_item: CanvasItem,
	center: Vector2,
	radius: float, 
	start_angle: float, 
	end_angle: float, 
	point_count: int,
	color: Color,
) -> void:
	var points_arc := PackedVector2Array()
	points_arc.push_back(center)
	var colors := PackedColorArray([color])
	for i in range(point_count + 1):
		var angle_point := (
			end_angle + i * (start_angle - end_angle) / point_count - TAU / 4.0
		)
		points_arc.push_back(
			center + Vector2(cos(angle_point), sin(angle_point)) * radius
		)
	canvas_item.draw_polygon(points_arc, colors)
