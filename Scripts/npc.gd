extends CharacterBody3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var nav_timer: Timer = $NavTimer
@onready var look_around_timer: Timer = $LookAroundTimer

@export var nav_mesh: NavigationRegion3D

@export var speed: float = 1.0
var target_rotation_angle: float = 0
var next_target: Vector3 = Vector3.ZERO
var is_rotating: bool = false
var player_target: bool = false

var time_walking:float = 0
var elapse:float = 0.0

func _ready() -> void:
	is_rotating = true
	generate_next_target()

func _on_nav_timer_timeout() -> void:
	navigation_agent_3d.target_position = next_target
	is_rotating = false
	
func _physics_process(delta: float) -> void:
	if is_rotating:
		look_around(delta)
		return
	if !navigation_agent_3d.is_target_reached() and navigation_agent_3d.is_target_reachable() and !navigation_agent_3d.is_navigation_finished():
		time_walking += delta
		var point = navigation_agent_3d.get_next_path_position()
		var local_point = point - global_position
		var direction = local_point.normalized()
		rotateNPC(direction)
		rotation.y = target_rotation_angle
		velocity = direction * speed
		# Reset if too long walking
		if time_walking > 10:
			generate_next_target()
	else:
		time_walking = 0
		elapse = 0
		velocity = Vector3.ZERO
		is_rotating = true
		look_around_timer.start((randf_range(0.1,0.3)))
	move_and_slide()

func look_around(delta: float) -> void:
	#Check if between acceptable value
	if target_rotation_angle +.03 < rotation.y or target_rotation_angle -.03 > rotation.y:
		print(target_rotation_angle)
		print(rotation.y)
		rotation.y = lerp_angle(rotation.y, target_rotation_angle, elapse)
		elapse += delta
	elif look_around_timer.is_stopped() and nav_timer.is_stopped():
		nav_timer.start(randf_range(0.1,0.3))

func _on_look_around_timer_timeout() -> void:
	generate_next_target()

func generate_next_target() -> void:
	next_target = global_position + Vector3(randf_range(-.2, .2), 0, randf_range(-.2, .2))
	var direction = (next_target - global_position).normalized()
	rotateNPC(direction)

func rotateNPC(direction: Vector3) -> void:
	target_rotation_angle = atan2(direction.z,direction.x)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		print("Player Found!!!")
