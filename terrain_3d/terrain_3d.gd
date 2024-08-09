@tool
class_name Terrain3D
extends Node3D

const _height_map_resource := preload("res://terrain_3d/height_map.tres")
const _material := preload("res://terrain_3d/material.tres")
@export var length := 100
@export var mesh_subdivisions := 200
@export var min_initial_height := 3.0
@export var max_initial_height := 5.0
@export var max_height := 5.0
@export var max_dig_depth := 3.0


var _image_width: int:
	get:
		return mesh_subdivisions + 2


var _initial_height_map_image: Image
var _height_map_image: Image
var _height_map_texture: ImageTexture


@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D


@export var do_regen: bool:
	set(value):
		do_regen = false
		if value:
			regen()


@export var do_dig: bool:
	set(value):
		do_dig = false
		if value:
			dig(Vector3(20.0, 0.0, 10.0), 1.2, 1.0)


func regen() -> void:
	await get_tree().process_frame
	_mesh.scale = Vector3(length, 1.0, length);
	var plane: PlaneMesh = _mesh.mesh
	plane.subdivide_width = mesh_subdivisions
	plane.subdivide_depth = mesh_subdivisions
	_material.set_shader_parameter("height_scale", max_height)
	_collision_shape.scale = length / float(mesh_subdivisions + 1) * Vector3.ONE
	_height_map_image = _height_map_resource.get_image()
	# .get_image() should return a copy of the data according to the docs but it
	# seems to return a reference so we use use get_region to actually copy
	_height_map_image = _height_map_image.get_region(
		_height_map_image.get_used_rect()
	)
	_height_map_image.resize(
		_image_width,
		_image_width,
		Image.Interpolation.INTERPOLATE_CUBIC
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
	var data := _height_map_image.get_data().to_float32_array()
	for i in data.size():
		data[i] *= max_height / _collision_shape.scale.x
	var height_map_shape: HeightMapShape3D = _collision_shape.shape
	height_map_shape.map_width = _image_width
	height_map_shape.map_depth = _image_width
	height_map_shape.map_data = data
	_height_map_texture = ImageTexture.create_from_image(_height_map_image)
	_material.set_shader_parameter("texture_height", _height_map_texture)
	_initial_height_map_image = _height_map_image.get_region(
		_height_map_image.get_used_rect()
	)


func dig(point: Vector3, radius: float, dig_depth: float) -> void:
	var a := length / 2.0
	var point_image := Vector2(
		remap(point.x, -a, a, 0.0, _image_width),
		remap(point.z, -a, a, 0.0, _image_width)
	)
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
			#var new_height := old_height - smoothed_dig_depth
			var new_r := new_height / max_height
			_height_map_image.set_pixel(x, y, Color(new_r, 0.0, 0.0, 1.0))
			var data_index := (_image_width) * y + x
			map_data[data_index] = new_height / _collision_shape.scale.x
	_height_map_texture.update(_height_map_image)
	height_map_shape.map_data = map_data


func get_height_at_position(pos: Vector3) -> float:
	var a := length / 2.0
	var image_x := remap(pos.x, -a, a, 0.0, _image_width)
	var image_y := remap(pos.z, -a, a, 0.0, _image_width)
	var r := _height_map_image.get_pixel(floori(image_x), floori(image_y)).r
	return r * max_height
