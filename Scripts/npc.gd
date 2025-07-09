extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var nav_timer: Timer = $NavTimer
@onready var look_around_timer: Timer = $LookAroundTimer

@export var nav_mesh: NavigationRegion3D

@export var speed: float = 1.0
var target_rotation_angle: float = 0
var next_target: Vector3 = Vector3.ZERO
var player_target: bool = false

var time_walking:float = 0

func _ready() -> void:
	generate_next_target()

func _on_nav_timer_timeout() -> void:
	generate_next_target()
	
func _physics_process(delta: float) -> void:
	if !navigation_agent_3d.is_target_reached() and navigation_agent_3d.is_target_reachable() and !navigation_agent_3d.is_navigation_finished():
		time_walking += delta
		var point = navigation_agent_3d.get_next_path_position()
		var local_point = point - global_position
		var direction = local_point.normalized()
		rotateNPC(direction)
		rotation.y = lerp_angle(rotation.y, target_rotation_angle, 100 * delta)
		velocity = direction * speed
		# Reset if too long walking
		if time_walking > 10:
			generate_next_target()
	else:
		time_walking = 0
		velocity = Vector3.ZERO
		if nav_timer.is_stopped():
			nav_timer.start(randf_range(1,2))
	move_and_slide()

func _on_look_around_timer_timeout() -> void:
	generate_next_target()

func generate_next_target() -> void:
	next_target = global_position + Vector3(randf_range(-2.2, 2.2), 0, randf_range(-2.2, 2.2))
	var direction = (next_target - global_position).normalized()
	navigation_agent_3d.target_position = next_target
	rotateNPC(direction)

func rotateNPC(direction: Vector3) -> void:
	target_rotation_angle = atan2(direction.x,direction.z)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		print("Player Found!!!")
