# 2 seconds break
# Look to a random direction
# 1 second break
# Walk forward until the target
extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var nav_timer: Timer = $NavTimer
@onready var look_around_timer: Timer = $LookAroundTimer

@export var speed: float = 1.0
var target_rotation_angle: float = 0
var next_target: Vector3 = Vector3.ZERO
var is_rotating: bool = false

func _ready() -> void:
	is_rotating = true
	generate_next_target()

func _on_nav_timer_timeout() -> void:
	navigation_agent_3d.target_position = next_target
	is_rotating = false
	
func _physics_process(delta: float) -> void:
	if !navigation_agent_3d.is_target_reached() and navigation_agent_3d.is_target_reachable() and !navigation_agent_3d.is_navigation_finished():
		var point = navigation_agent_3d.get_next_path_position()
		var local_point = point - global_position
		var direction = local_point.normalized()
		
		velocity = direction * speed
	else:
		velocity = Vector3.ZERO
		if !is_rotating:
			is_rotating = true
			look_around_timer.start(2)
		look_around(delta)
	move_and_slide()

func look_around(delta: float) -> void:
	#Check if between acceptable value
	if target_rotation_angle +.01 < rotation.y or target_rotation_angle -.01 > rotation.y:
		rotation.y = lerp_angle(rotation.y, target_rotation_angle, 1 * delta)
	elif look_around_timer.is_stopped() and nav_timer.is_stopped():
		nav_timer.start(1)

func _on_look_around_timer_timeout() -> void:
	generate_next_target()

func generate_next_target() -> void:
	next_target = Vector3(randf_range(-5.0, 5.0), 0, randf_range(-5.0, 5.0))
	var direction = (global_position - next_target).normalized()
	target_rotation_angle = atan2(direction.x,direction.z)
