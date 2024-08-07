extends CharacterBody3D
class_name Lizard

enum State { IDLE, ATTACK, RETURN_HOME }
var nav_update_target_cooldown := 0.0
var finished_attacking_player_cooldown := 0.0
var state := State.IDLE
var safe_velocity := Vector3.ZERO
var footstep_distance_remaining := 0.0
var roar_cooldown := 0.0
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var step_asp: AudioStreamPlayer3D = $StepASP
@onready var roar_asp: AudioStreamPlayer3D = $RoarASP
@onready var home := global_position
