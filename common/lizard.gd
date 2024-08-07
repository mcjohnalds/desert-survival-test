extends CharacterBody3D
class_name Lizard

enum State { IDLE, ATTACK }
var nav_cooldown := 0.0
var state := State.IDLE
var safe_velocity := Vector3.ZERO
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
