@tool
class_name Terrain
extends Node3D

# TODO: specify noise texture resolution as export - maybe generate
# terrain_height_map_texture.tres in memory
# TODO: fix bug where heightmap is slightly off shader verts
# TODO: make terrain look less flat (better normals?)
# TODO: generate shader material at runtime so it doesn't get saved in git
# TODO: should i handle case where terrain is not centered?
const terrain_height_map := preload(
	"res://common/terrain_height_map_texture.tres"
)
const terrain_material := preload("res://common/terrain_material.tres")
@export var width := 100
@export var mesh_resolution := 100
@export var min_initial_height := 3.0
@export var max_initial_height := 5.0
@export var max_height := 5.0
@export var max_dig_depth := 0.5
var _initial_height_map_image: Image = null
@onready var _mesh: MeshInstance3D = $MeshInstance3D
@onready var _shape: CollisionShape3D = $CollisionShape3D


@export var do_regen: bool:
	set(value):
		do_regen = false
		if value:
			regen()


@export var do_dig: bool:
	set(value):
		do_dig = false
		if value:
			dig(Vector3(20.0, 0.0, 10.0), 1, 1.0)


func regen() -> void:
	await get_tree().process_frame
	_mesh.scale = Vector3.ONE * width

	var plane: PlaneMesh = _mesh.mesh
	plane.subdivide_width = mesh_resolution - 1
	plane.subdivide_depth = mesh_resolution - 1

	var material: ShaderMaterial = plane.material
	material.set_shader_parameter(
		"height_scale", max_height / float(mesh_resolution)
	)

	_shape.scale = Vector3.ONE * float(width) / float(mesh_resolution)

	var src := terrain_height_map.get_image()
	var image := Image.create_from_data(
		src.get_width(),
		src.get_height(),
		src.has_mipmaps(),
		src.get_format(),
		src.get_data()
	)
	var s := mesh_resolution + 1
	image.resize(s, s)
	image.convert(Image.FORMAT_RF)

	# Scale height map to fit within the range
	# [min_initial_height, max_initial_height]
	for x in image.get_width():
		for y in image.get_height():
			var old_pixel_r := image.get_pixel(x, y).r
			var pixel_height_world := (
				min_initial_height
				+ old_pixel_r * (max_initial_height - min_initial_height)
			)
			var new_pixel_r := pixel_height_world / max_height
			image.set_pixel(x, y, Color(new_pixel_r, 0.0, 0.0, 1.0))

	_initial_height_map_image = image.get_region(image.get_used_rect())
	var rdata := image.get_data()
	var data := rdata.to_float32_array()
	for i in data.size():
		data[i] *= max_height

	var h: HeightMapShape3D = _shape.shape
	h.map_width = s
	h.map_depth = s
	h.map_data = data

	var image_texture := ImageTexture.create_from_image(image)
	terrain_material.set_shader_parameter("height_map", image_texture)


func dig(position_world: Vector3, radius: float, dig_depth: float) -> void:
	var old_texture: Texture2D = terrain_material.get_shader_parameter(
		"height_map"
	)
	var image := old_texture.get_image()
	var m := width / 2.0
	var position_image := Vector2(
		remap(position_world.x, -m, m, 0.0, image.get_width()),
		remap(position_world.z, -m, m, 0.0, image.get_width())
	)
	var radius_image := remap(radius, 0.0, width, 0.0, image.get_width())
	var pixel_x_range := range(
		floori(position_image.x - radius_image / 2.0),
		ceili(position_image.x + radius_image / 2.0)
	)
	var pixel_y_range := range(
		floori(position_image.y - radius_image / 2.0),
		ceili(position_image.y + radius_image / 2.0)
	)
	for x: int in pixel_x_range:
		for y: int in pixel_y_range:
			var old_r := image.get_pixel(x, y).r
			var initial_r := _initial_height_map_image.get_pixel(x, y).r
			var old_height := old_r * max_height
			var initial_height := initial_r * max_height
			var new_height := maxf(
				old_height - dig_depth,
				initial_height - max_dig_depth
			)
			var new_r := new_height / max_height
			image.set_pixel(x, y, Color(new_r, 0.0, 0.0, 1.0))
			var height_map_shape: HeightMapShape3D = _shape.shape
			height_map_shape.map_data[image.get_width() * y + x] = new_height
	var image_texture := ImageTexture.create_from_image(image)
	terrain_material.set_shader_parameter("height_map", image_texture)


func get_height_at_position(pos: Vector3) -> float:
	var texture: Texture2D = terrain_material.get_shader_parameter(
		"height_map"
	)
	var m := width / 2.0
	var image := texture.get_image()
	var image_x := remap(pos.x, -m, m, 0.0, image.get_width())
	var image_y := remap(pos.z, -m, m, 0.0, image.get_width())
	var r := image.get_pixel(floori(image_x), floori(image_y)).r
	return r * max_height
