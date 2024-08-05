@tool
extends Node3D
class_name ItemViewer

enum ItemType { NONE, CUBE, SPHERE, TORUS }


@export var item_type := ItemType.CUBE:
	set(value):
		item_type = value
		if not is_node_ready():
			await ready
		_cube.visible = item_type == ItemType.CUBE
		_sphere.visible = item_type == ItemType.SPHERE
		_torus.visible = item_type == ItemType.TORUS


@onready var _cube: Node3D = %Cube
@onready var _sphere: Node3D = %Sphere
@onready var _torus: Node3D = %Torus


func _ready() -> void:
	item_type = item_type
