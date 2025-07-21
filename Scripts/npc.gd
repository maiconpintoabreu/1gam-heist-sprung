extends CharacterBody3D
enum NPCState {
	WalkPointInterest,
	WalkRandom
}

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $Archie_animation_cyc/AnimationPlayer
@onready var change_timer: Timer = $ChangeTimer
@onready var random_nav_timer: Timer = $RandomNavTimer

@export var nav_mesh: NavigationRegion3D
@export var points_of_interest: Array[Vector3]

@export var speed: float = 1.0
var target_rotation_angle: float = 0
var next_target: Vector3 = Vector3.ZERO
var player_target: bool = false
var state: NPCState = NPCState.WalkRandom

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
		animation_player.play("archie_walk")
		# Reset if too long walking
		if time_walking > 20 and state == NPCState.WalkRandom:
			generate_next_target()
	else:
		time_walking = 0
		velocity = Vector3.ZERO
		state = NPCState.WalkRandom
		animation_player.play("Archie_idle_breathing")
		if random_nav_timer.is_stopped():
			random_nav_timer.start(randf_range(1,2))
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
		call_deferred("safe_return")

func safe_return() ->void:
		get_tree().change_scene_to_file("res://Scenes/start_menu.tscn")
func _on_change_timer_timeout() -> void:
	if state == NPCState.WalkPointInterest:
		state = NPCState.WalkRandom
		generate_next_target()
	else:
		state = NPCState.WalkPointInterest
		generate_next_point_interest()
		

func generate_next_point_interest() -> void:
	var point:Vector3 = points_of_interest.pick_random()
	next_target = global_position + Vector3(point.x, 0, point.z)
	var direction = (next_target - global_position).normalized()
	navigation_agent_3d.target_position = next_target
	rotateNPC(direction)
