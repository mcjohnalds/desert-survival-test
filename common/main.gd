extends Node
class_name Main

const _FADE_DURATION = 0.15
const _LOADER_SCENE := preload("res://common/loader.tscn")
const _START_SCENE := preload("res://common/start.tscn")
const _GAME_SCENE := preload("res://common/game.tscn")
const _HEIGHT_MAP := preload("res://terrain_3d/height_map.tres")
var _game: Game
var _fade_out_started_at := -1000.0
var _fade_in_started_at := -1000.0
@onready var _container: Node = %Container
@onready var _fps_counter: Label = %FpsCounter
@onready var _transition: ColorRect = %Transition


func _ready() -> void:
	if not OS.is_debug_build():
		var loader: Loader = _LOADER_SCENE.instantiate()
		_container.add_child(loader)
		await loader.compile_shaders()
		await _fade_out()
		loader.queue_free()
		await loader.tree_exited
		var start: Start = _START_SCENE.instantiate()
		_container.add_child(start)
		await _fade_in()
		await start.main_menu.started
		await _fade_out()
		start.queue_free()
		await start.tree_exited
	# Terrain3D will error if added to scene before the height map has loaded
	await _HEIGHT_MAP.changed
	_restart()


func _process(_delta: float) -> void:
	_fps_counter.text = "%s FPS " % Engine.get_frames_per_second()
	if Util.get_ticks_sec() - _fade_out_started_at < _FADE_DURATION:
		_transition.color.a = smoothstep(
			0.0,
			1.0,
			Util.get_ticks_sec() - _fade_out_started_at / _FADE_DURATION
		)
	if Util.get_ticks_sec() - _fade_in_started_at < _FADE_DURATION:
		_transition.color.a = smoothstep(
			0.0,
			1.0,
			1.0 - (Util.get_ticks_sec() - _fade_in_started_at) / _FADE_DURATION
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fps_counter"):
		_fps_counter.visible = not _fps_counter.visible


func _restart() -> void:
	if _game:
		await _fade_out()
		_game.queue_free()
		await _game.tree_exited
	_game = _GAME_SCENE.instantiate()
	_container.add_child(_game)
	_game.restarted.connect(_restart)
	await _fade_in()


func _fade_out() -> void:
	_fade_out_started_at = Util.get_ticks_sec()
	await get_tree().create_timer(_FADE_DURATION).timeout
	_transition.color.a = 1.0


func _fade_in() -> void:
	_fade_in_started_at = Util.get_ticks_sec()
	await get_tree().create_timer(_FADE_DURATION).timeout
	_transition.color.a = 0.0
