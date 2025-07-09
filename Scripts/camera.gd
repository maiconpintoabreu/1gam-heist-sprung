extends Camera3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D


var mouse_position: Vector2
var space_state
var query

func _ready() -> void:
		space_state = get_world_3d().direct_space_state
		query = PhysicsRayQueryParameters3D.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		mouse_position = get_viewport().get_mouse_position()
		var from := project_ray_origin(mouse_position)
		var to := from + project_ray_normal(mouse_position) * 100
		query.from = from
		query.to = to

		var result: Dictionary = space_state.intersect_ray(query)
		if not result.is_empty():
			%Player.setMoveTarget(result.position)
	position.x = %Player.global_position.x
	position.z = %Player.global_position.z
