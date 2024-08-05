extends Node
class_name Start

@onready var main_menu: MainMenu = %MainMenu
@onready var _pivot: Node3D = %Pivot


func _ready() -> void:
	_process(0.0)


func _process(_delta: float) -> void:
	_pivot.rotation.y = 0.05 * Util.get_ticks_sec()
	_pivot.rotation.x = 0.2 * sin(0.05 * Util.get_ticks_sec())
