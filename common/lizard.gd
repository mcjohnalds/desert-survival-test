extends CharacterBody3D
class_name Lizard

enum AIState { IDLE, ATTACK, RETURN_HOME, EXPLORE }
enum AttackState { READY, CHARGE, FLYING, RECHARGING }
var nav_update_target_cooldown := 0.0
var finished_attacking_player_cooldown := 0.0
var ai_state := AIState.IDLE
var attack_state := AttackState.READY
var safe_velocity := Vector3.ZERO
var footstep_distance_remaining := 0.0
var roar_cooldown := 0.0
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var step_asp: AudioStreamPlayer3D = $StepASP
@onready var roar_asp: AudioStreamPlayer3D = $RoarASP
@onready var home := global_position
@onready var animation_player: AnimationPlayer = $Lizard/AnimationPlayer
@onready var skeleton_ik: SkeletonIK3D = %SkeletonIK3D
@onready var ik_target: Node3D = $IKTarget
@onready var skeleton: Skeleton3D = $Lizard/Armature/Skeleton3D
