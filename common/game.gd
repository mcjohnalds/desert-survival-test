extends Node
class_name Game

signal restarted
const _GROUNDWATER_SCENE := preload("res://common/groundwater.tscn")
const _LIZARD_SCENE := preload("res://common/lizard.tscn")
const _ENEMY_NAV_COOLDOWN_DURATION := 0.2
const _LIZARD_CHASE_DISTANCE := 15.0
const _LIZARD_ACCELERATION := 25.0
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
@onready var _lizard_container: Node3D = %LizardContainer


func _ready() -> void:
	_main_menu.resumed.connect(_unpause)
	_main_menu.restarted.connect(restarted.emit)
	_player.effect_created.connect(_on_effect_created)
	_player.attempted_spawn_enemy.connect(_on_attempted_spawn_enemy)
	_player.move_and_slide_collision.connect(
		_on_player_move_and_slide_collision
	)
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


func _physics_process(delta: float) -> void:
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
	for lizard: Lizard in _lizard_container.get_children():
		_update_lizard(lizard, delta)
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


func _on_attempted_spawn_enemy(collision: Dictionary) -> void:
	if not collision:
		return
	var lizard: Lizard = _LIZARD_SCENE.instantiate()
	lizard.position = collision.position
	_lizard_container.add_child(lizard)
	lizard.nav_agent.velocity_computed.connect(
		_on_enemy_velocity_computed.bind(lizard)
	)


func _on_enemy_velocity_computed(
	safe_velocity: Vector3, lizard: Lizard
) -> void:
	lizard.safe_velocity = safe_velocity


func _update_lizard(lizard: Lizard, delta: float) -> void:
	lizard.nav_cooldown -= delta
	var target_velocity_xz: Vector3
	match lizard.state:
		Lizard.State.IDLE:
			target_velocity_xz = _update_lizard_idle(lizard, delta)
		Lizard.State.ATTACK:
			target_velocity_xz = _update_lizard_attack(lizard, delta)
	if lizard.is_on_floor():
		var current_velocity_xz := Vector3(
			lizard.velocity.x, 0.0, lizard.velocity.z
		)
		var current_velocity_y := Vector3(0.0, lizard.velocity.y, 0.0)
		var accel := _LIZARD_ACCELERATION
		var new_velocity_xz := current_velocity_xz.move_toward(
			target_velocity_xz, accel * delta
		)
		lizard.velocity = new_velocity_xz + current_velocity_y
	lizard.velocity.y -= Util.get_default_gravity() * delta
	lizard.scale = Vector3.ONE
	var collided := lizard.move_and_slide()
	if lizard.is_on_floor():
		lizard.velocity.y = 0.0
	# Player collision handling
	if not collided:
		return
	var hit_player := false
	for collision in Util.get_character_body_3d_slide_collisions(lizard):
		if collision.collider == _player:
			hit_player = true
	if not hit_player:
		return
	_on_player_lizard_collision(lizard)


func _update_lizard_idle(lizard: Lizard, delta: float) -> Vector3:
	var close_to_player := (
		lizard.global_position.distance_to(_player.global_position)
		<= _LIZARD_CHASE_DISTANCE
	)
	if close_to_player:
		lizard.state = Lizard.State.ATTACK
		lizard.nav_cooldown = 0.0
	var target_velocity_xz := Vector3.ZERO
	return target_velocity_xz


func _update_lizard_attack(lizard: Lizard, delta: float) -> Vector3:
	var close_to_player := (
		lizard.global_position.distance_to(_player.global_position)
		<= _LIZARD_CHASE_DISTANCE
	)
	var lizard_xz := Util.get_vector3_xz(lizard.global_position)
	var player_xz := Util.get_vector3_xz(_player.global_position)
	var target_rotation_y := -lizard_xz.angle_to_point(player_xz) + 0.25 * TAU
	lizard.rotation.y = lerp_angle(
		lizard.rotation.y, target_rotation_y, 2.0 * delta
	)
	if lizard.nav_cooldown <= 0.0:
		lizard.nav_cooldown = _ENEMY_NAV_COOLDOWN_DURATION
		lizard.nav_agent.target_position = _player.global_position
	if not lizard.nav_agent.is_navigation_finished():
		var next := lizard.nav_agent.get_next_path_position()
		lizard.nav_agent.velocity = (
			lizard.nav_agent.max_speed
			* lizard.global_position.direction_to(next)
		)
	if not close_to_player:
		lizard.state = Lizard.State.IDLE
		lizard.nav_agent.target_position = lizard.global_position
	var safe_velocity_xz := Vector3(
		lizard.safe_velocity.x, 0.0, lizard.safe_velocity.z
	)
	var target_velocity_xz := (
		# TODO: do i need the minf?
		minf(lizard.nav_agent.max_speed, lizard.safe_velocity.length())
		* safe_velocity_xz.normalized()
	)
	return target_velocity_xz


func _on_player_move_and_slide_collision() -> void:
	var hit_lizard: Lizard = null
	for collision in Util.get_character_body_3d_slide_collisions(_player):
		if collision.collider is Lizard:
			hit_lizard = collision.collider
	if hit_lizard:
		_on_player_lizard_collision(hit_lizard)


func _on_player_lizard_collision(lizard: Lizard) -> void:
	_player.damage(20.0)
	var player_xz := Vector3(
		_player.global_position.x,
		0.0,
		_player.global_position.z
	)
	var lizard_xz := Vector3(
		lizard.global_position.x,
		0.0,
		lizard.global_position.z
	)
	lizard.velocity += player_xz.direction_to(lizard_xz) * 2.0
	lizard.velocity.y = 5.0


func set_mouse_mode(mode: Input.MouseMode) -> void:
	_desired_mouse_mode = mode
	Input.mouse_mode = mode
