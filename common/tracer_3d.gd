extends Node3D
class_name Tracer3D
## Bullet tracer.
##
## Usage:
## [codeblock]
## var tracer := Tracer3D.SCENE.instantiate()
## tracer.start = _bullet_start.global_position + velocity * delta
## tracer.end = bullet_end
## add_child(tracer)
## [/codeblock]

const SCENE := preload("res://common/tracer_3d.tscn")
@export var min_length := 2.0
@export var max_length := 10.0
@export var min_lifetime := 0.05
@export var speed := 250.0
var start: Vector3
var end: Vector3
var _trail_start_distance := 0.0
var _trail_end_distance := 0.0
var _lifetime := 0.0


func _enter_tree() -> void:
	_trail_end_distance = minf(min_length, start.distance_to(end))
	_update()


func _process(delta: float) -> void:
	if _trail_start_distance >= start.distance_to(end):
		queue_free()
	elif _trail_end_distance >= start.distance_to(end):
		# Shrinking
		if _lifetime > min_lifetime:
			_trail_start_distance += speed * delta
			_trail_end_distance = start.distance_to(end)
	elif _trail_end_distance - _trail_start_distance < max_length:
		# Growing
		_trail_start_distance = 0.0
		_trail_end_distance += speed * delta
	else:
		# Travelling
		_trail_start_distance += speed * delta
		_trail_end_distance += speed * delta
	_update()
	_lifetime += delta


func _update() -> void:
	global_position = start + _trail_start_distance * start.direction_to(end)
	Util.safe_look_at(self, end, true)
	scale.z = _trail_end_distance - _trail_start_distance
