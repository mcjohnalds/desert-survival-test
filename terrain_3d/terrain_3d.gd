@tool
class_name Terrain3D
extends Node3D

signal loaded
const _HEIGHT_MAP := preload("res://terrain_3d/height_map.tres")
const _MATERIAL := preload("res://terrain_3d/material.tres")


@export var length := 100:
	set(value):
		length = value
		if is_node_ready():
			_regen()


@export var mesh_subdivisions := 1000:
	set(value):
		mesh_subdivisions = value
		if is_node_ready():
			_regen()


@export var min_initial_height := 3.0:
	set(value):
		min_initial_height = value
		if is_node_ready():
			_regen()


@export var max_initial_height := 5.0:
	set(value):
		max_initial_height = value
		if is_node_ready():
			_regen()


@export var max_height := 5.0:
	set(value):
		max_height = value
		if is_node_ready():
			_regen()


@export var max_dig_depth := 3.0


var _image_width: int:
	get:
		return mesh_subdivisions + 2


var _initial_height_map_image: Image
var _height_map_image: Image
var _height_map_texture: ImageTexture
var _collision_shape: CollisionShape3D


func _ready() -> void:
	_regen()


func _regen() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var plane := PlaneMesh.new()
	plane.size = Vector2.ONE
	plane.subdivide_width = mesh_subdivisions
	plane.subdivide_depth = mesh_subdivisions
	var mesh := MeshInstance3D.new()
	mesh.scale = Vector3(length, 1.0, length)
	# Prevent mesh disappearing when player is deep underground
	mesh.extra_cull_margin = 16384.0
	mesh.mesh = plane
	# Duplicate material so we don't end up persisting the height texture in git
	var material: ShaderMaterial = _MATERIAL.duplicate()
	mesh.material_override = material
	add_child(mesh)
	material.set_shader_parameter("height_scale", max_height)
	_height_map_image = _HEIGHT_MAP.get_image()
	# .get_image() should return a copy of the data according to the docs but it
	# seems to return a reference so we use use get_region to actually copy
	_height_map_image = _height_map_image.get_region(
		_height_map_image.get_used_rect()
	)
	_height_map_image.resize(
		_image_width,
		_image_width,
		Image.Interpolation.INTERPOLATE_LANCZOS
	)
	_height_map_image.convert(Image.FORMAT_RF)
	for x in _image_width:
		for y in _image_width:
			var r_old := _height_map_image.get_pixel(x, y).r
			var height := remap(
				r_old, 0.0, 1.0, min_initial_height, max_initial_height
			)
			var r_new := height / max_height
			_height_map_image.set_pixel(x, y, Color(r_new, 0.0, 0.0, 1.0))
	_collision_shape = CollisionShape3D.new()
	_collision_shape.scale = length / float(mesh_subdivisions + 1) * Vector3.ONE
	var map_data := _height_map_image.get_data().to_float32_array()
	for i in map_data.size():
		map_data[i] *= max_height / _collision_shape.scale.x
	var height_map_shape := HeightMapShape3D.new()
	height_map_shape.map_width = _image_width
	height_map_shape.map_depth = _image_width
	height_map_shape.map_data = map_data
	_collision_shape.shape = height_map_shape
	add_child(_collision_shape)
	_height_map_texture = ImageTexture.create_from_image(_height_map_image)
	material.set_shader_parameter(
		"texture_height", _height_map_texture
	)
	_initial_height_map_image = _height_map_image.get_region(
		_height_map_image.get_used_rect()
	)
	await loaded


func get_height_at_position(point: Vector3) -> float:
	var point_image := _world_space_to_image_space(point)
	var r := _height_map_image.get_pixelv(point_image.floor()).r
	return r * max_height


func dig(point: Vector3, radius: float, dig_depth: float) -> void:
	var point_image := _world_space_to_image_space(point)
	var radius_image := remap(radius, 0.0, length, 0.0, _image_width)
	var x_min_image := floori(point_image.x - radius_image)
	var x_max_image := ceili(point_image.x + radius_image)
	var y_min_image := floori(point_image.y - radius_image)
	var y_max_image := ceili(point_image.y + radius_image)
	var height_map_shape: HeightMapShape3D = _collision_shape.shape
	var map_data := height_map_shape.map_data
	for x: int in range(x_min_image, x_max_image):
		for y: int in range(y_min_image, y_max_image):
			var point_dist := (Vector2i(x, y) - Vector2i(point_image)).length()
			if point_dist > radius_image:
				continue
			var smoothed_dig_depth := dig_depth * smoothstep(
				0.0, 1.0, 1.0 - float(point_dist) / float(radius_image)
			)
			var old_r := _height_map_image.get_pixel(x, y).r
			var initial_r := _initial_height_map_image.get_pixel(x, y).r
			var old_height := old_r * max_height
			var initial_height := initial_r * max_height
			var new_height := maxf(
				old_height - smoothed_dig_depth,
				initial_height - max_dig_depth
			)
			var new_r := new_height / max_height
			_height_map_image.set_pixel(x, y, Color(new_r, 0.0, 0.0, 1.0))
			var data_index := (_image_width) * y + x
			map_data[data_index] = new_height / _collision_shape.scale.x
	_height_map_texture.update(_height_map_image)
	height_map_shape.map_data = map_data


func _world_space_to_image_space(v: Vector3) -> Vector2:
	return Vector2(
		remap(v.x, -length / 2.0, length / 2.0, 0.0, _image_width),
		remap(v.z, -length / 2.0, length / 2.0, 0.0, _image_width),
	)
