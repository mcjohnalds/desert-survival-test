extends Node
class_name Game

signal restarted

var _paused := false
var _desired_mouse_mode := Input.MOUSE_MODE_VISIBLE
var _mouse_mode_mismatch_count := 0
@onready var _container: Node3D = $Container
@onready var _main_menu: MainMenu = %MainMenu
@onready var _menu_container: Control = %MenuContainer


func _ready() -> void:
	_main_menu.resumed.connect(_unpause)
	_main_menu.restarted.connect(restarted.emit)
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta: float) -> void:
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


func set_mouse_mode(mode: Input.MouseMode) -> void:
	_desired_mouse_mode = mode
	Input.mouse_mode = mode
