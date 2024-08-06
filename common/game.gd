extends Node
class_name Game

signal restarted
const _GROUNDWATER_SCENE := preload("res://common/groundwater.tscn")
var _paused := false
var _desired_mouse_mode := Input.MOUSE_MODE_VISIBLE
var _mouse_mode_mismatch_count := 0
var _time := 0.0
@onready var _container: Node3D = $Container
@onready var _main_menu: MainMenu = %MainMenu
@onready var _menu_container: Control = %MenuContainer
@onready var _player: KinematicFpsController = %Player
@onready var _terrain: Terrain = %Terrain
@onready var _groundwater_container: Node3D = %GroundwaterContainer


func _ready() -> void:
	_main_menu.resumed.connect(_unpause)
	_main_menu.restarted.connect(restarted.emit)
	_player.effect_created.connect(_on_effect_created)
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for i in 100:
		var groundwater: Groundwater = _GROUNDWATER_SCENE.instantiate()
		groundwater.position.x = randf_range(
			-_terrain.width / 2.0, _terrain.width / 2.0
		)
		groundwater.position.y = _terrain.position.y + randf_range(0.1, 0.9)
		groundwater.position.z = randf_range(
			-_terrain.width / 2.0, _terrain.width / 2.0
		)
		_groundwater_container.add_child(groundwater)


func _process(delta: float) -> void:
	# Deal with the bullshit that can happen when the browser takes away the
	# game's pointer lock
	if (
		_desired_mouse_mode == Input.MOUSE_MODE_CAPTURED
		and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED
	):
		_mouse_mode_mismatch_count += 1
	else:
		_mouse_mode_mismatch_count = 0
	if _mouse_mode_mismatch_count > 10:
		_pause()
	for groundwater: Groundwater in _groundwater_container.get_children():
		var id := groundwater.get_instance_id()
		# db varies between -40.0 and 0.0 see
		# https://www.desmos.com/calculator/ldvrpomret
		var db :=  -20 + 20.0 * pow(sin(100.0 * id + TAU / 8.0 * _time), 1.2)
		if is_nan(db):
			db = -40.0
		groundwater.muffled_trickle_asp.volume_db = db
		groundwater.trickle_asp.volume_db = db
	_time += delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _paused:
			# In a browser, we can only capture the mouse on a mouse click
			# event, so we only let the user unpause by clicking the resume
			# buttom
			if OS.get_name() != "Web":
				_unpause()
		else:
			_pause()


func _pause() -> void:
	_paused = true
	_container.process_mode = Node.PROCESS_MODE_DISABLED
	_menu_container.visible = true
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unpause() -> void:
	_paused = false
	_container.process_mode = Node.PROCESS_MODE_INHERIT
	_menu_container.visible = false
	_main_menu.settings_open = false
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_effect_created(effect: Node3D) -> void:
	_container.add_child(effect)


func set_mouse_mode(mode: Input.MouseMode) -> void:
	_desired_mouse_mode = mode
	Input.mouse_mode = mode
