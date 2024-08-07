extends CharacterBody3D
class_name Lizard

enum State { IDLE, ATTACK, RETURN_HOME }
var nav_update_target_cooldown := 0.0
var finished_attacking_player_cooldown := 0.0
var state := State.IDLE
var safe_velocity := Vector3.ZERO
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var home := global_position
