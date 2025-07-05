extends Camera3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D


var mouse_position: Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		mouse_position = get_viewport().get_mouse_position()
		ray_cast_3d.target_position = project_local_ray_normal(mouse_position) * 100
		ray_cast_3d.force_raycast_update()
		
		if ray_cast_3d.is_colliding():
			%Player.setMoveTarget(ray_cast_3d.get_collision_point())
