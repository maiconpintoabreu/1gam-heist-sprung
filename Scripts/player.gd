extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@export var speed: float = 1.0
var target_rotation_angle: float = 0
var next_target: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if !navigation_agent_3d.is_target_reached() and navigation_agent_3d.is_target_reachable() and !navigation_agent_3d.is_navigation_finished():
		var point = navigation_agent_3d.get_next_path_position()
		var local_point = point - global_position
		var direction = local_point.normalized()
		
		velocity = direction * speed
		rotation.y = target_rotation_angle
	else:
		velocity = Vector3.ZERO
	move_and_slide()

func setMoveTarget(next_target: Vector3) -> void:
	next_target.y = global_position.y
	var direction = (global_position - next_target).normalized()
	target_rotation_angle = atan2(direction.x,direction.z)
	navigation_agent_3d.target_position = next_target
