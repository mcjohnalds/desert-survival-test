@tool
class_name Terrain
extends Node3D

# TODO: specify noise texture resolution as export - maybe generate
# terrain_height_map_texture.tres in memory
# TODO: fix bug where heightmap is slightly off shader verts
# TODO: make terrain look less flat
# TODO: generate shader material at runtime so it doesn't get saved in git
@export var width := 100
@export var mesh_resolution := 100
@export var min_initial_height := 1.0
@export var max_initial_height := 3.0
@export var max_height := 3.0
const terrain_height_map := preload(
	"res://common/terrain_height_map_texture.tres"
)
const terrain_material := preload("res://common/terrain_material.tres")
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var shape: CollisionShape3D = $CollisionShape3D


@export var do_regen: bool:
	set(value):
		do_regen = false
		if value:
			_regen()


@export var do_dig: bool:
	set(value):
		do_dig = false
		if value:
			dig(Vector3(20.0, 0.0, 10.0), 1, 1.0)


func _ready() -> void:
	await get_tree().process_frame
	_regen()


func _regen() -> void:
	mesh.scale = Vector3.ONE * width

	var plane: PlaneMesh = mesh.mesh
	plane.subdivide_width = mesh_resolution - 1
	plane.subdivide_depth = mesh_resolution - 1

	var material: ShaderMaterial = plane.material
	material.set_shader_parameter(
		"height_scale", max_height / float(mesh_resolution)
	)

	shape.scale = Vector3.ONE * float(width) / float(mesh_resolution)

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
	for x in image.get_width():
		for y in image.get_height():
			var old_pixel_r := image.get_pixel(x, y).r
			var pixel_height_world := (
				min_initial_height
				+ old_pixel_r * (max_initial_height - min_initial_height)
			)
			var new_pixel_r := pixel_height_world / max_height
			image.set_pixel(x, y, Color(new_pixel_r, 0.0, 0.0, 1.0))
	var rdata := image.get_data()
	var data := rdata.to_float32_array()
	for i in data.size():
		data[i] *= max_height

	var h: HeightMapShape3D = shape.shape
	h.map_width = s
	h.map_depth = s
	h.map_data = data

	var image_texture := ImageTexture.create_from_image(image)
	terrain_material.set_shader_parameter("height_map", image_texture)


func dig(position_world: Vector3, radius: int, height: float) -> void:
	var old_texture: Texture2D = terrain_material.get_shader_parameter(
		"height_map"
	)
	var image := old_texture.get_image()
	var m := width / 2.0
	var position_image := Vector2(
		remap(position_world.x, -m, m, -0.5, image.get_width() + 0.5),
		remap(position_world.z, -m, m, -0.5, image.get_width() + 0.5)
	).round()
	for x in range(position_image.x - radius, position_image.x + radius):
		for y in range(position_image.y - radius, position_image.y + radius):
			var old_r := image.get_pixel(x, y).r
			var old_height := old_r * max_height
			var new_height := maxf(old_height - height, 0.0)
			var new_r := new_height / max_height
			image.set_pixel(x, y, Color(new_r, 0.0, 0.0, 1.0))
			var h: HeightMapShape3D = shape.shape
			h.map_data[image.get_width() * y + x] = new_height
	var image_texture := ImageTexture.create_from_image(image)
	terrain_material.set_shader_parameter("height_map", image_texture)
