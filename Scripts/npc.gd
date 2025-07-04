extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@export var speed: float = 1.0

func _on_nav_timer_timeout() -> void:
	var random_position := Vector3(randf_range(-5.0, 5.0), 0, randf_range(-5.0, 5.0))
	navigation_agent_3d.target_position = random_position
	
func _physics_process(delta: float) -> void:
	if !navigation_agent_3d.is_target_reached() and navigation_agent_3d.is_target_reachable():
		var point = navigation_agent_3d.get_next_path_position()
		var local_point = point - global_position
		var direction = local_point.normalized()
		look_at(point, Vector3.UP,false)
		
		velocity = direction * speed
	else:
		velocity = Vector3.ZERO
	move_and_slide()
