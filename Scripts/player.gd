extends CharacterBody3D
class_name Player

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D

@export var speed: float = 1.0
var target_rotation_angle: float = 0
var current_interactable = null


func _physics_process(_delta: float) -> void:
	if !navigation_agent_3d.is_target_reached() and navigation_agent_3d.is_target_reachable() and !navigation_agent_3d.is_navigation_finished():
		var point = navigation_agent_3d.get_next_path_position()
		var local_point = point - global_position
		var direction = local_point.normalized()
		rotatePlayer(direction)
		
		velocity = direction * speed
		rotation.y = target_rotation_angle
		move_and_slide()
	else:
		velocity = Vector3.ZERO
	
	check_for_interactables()

func setMoveTarget(next_target: Vector3) -> void:
	next_target.y = global_position.y
	var direction = (next_target - global_position).normalized()
	rotatePlayer(direction)
	navigation_agent_3d.target_position = next_target

func rotatePlayer(direction: Vector3) -> void:
	target_rotation_angle = atan2(direction.x,direction.z)

func check_for_interactables():
	ray_cast_3d.force_raycast_update()
	
	var hit_object = null
	if ray_cast_3d.is_colliding():
		hit_object = ray_cast_3d.get_collider()
	# If we're looking at something different
	if hit_object != current_interactable:
		# Hide prompt from old object
		if current_interactable and current_interactable.is_in_group("interactables"):
			current_interactable.hide_prompt()
		
		# Update to new object
		current_interactable = hit_object
		
		# Show prompt for new object
		if current_interactable and current_interactable.is_in_group("interactables"):
			current_interactable.display_prompt()

func _input(event):
	if event.is_action_pressed("interact"):  # Make sure you have "interact" input mapped to E key
		if current_interactable and current_interactable.is_in_group("interactables"):
			current_interactable.interact()
			
	if event.is_action_pressed("ui_cancel"):  # ESC key
			if current_interactable and current_interactable.has_method("hide_lock_view"):
				current_interactable.hide_lock_view()
	
