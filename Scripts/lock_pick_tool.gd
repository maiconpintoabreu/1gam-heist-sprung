extends RigidBody3D
class_name LockPickTool

# Export variables - set these in the editor inspector
@export var movement_sensitivity: float = 0.1
@export var max_force: float = 50.0

# Editor-assigned references - no more creating nodes in code!
@onready var tool_mesh: CSGBox3D = $ToolMesh
@onready var tool_collision: CollisionShape3D = $ToolCollision
@onready var tool_tip: RigidBody3D = $ToolTip

var original_position: Vector3
var input_accumulator: Vector2 = Vector2.ZERO

func _ready():
	# Store the starting position
	original_position = global_position
	
	# All physics properties should be set in editor now!
	# No more setting gravity_scale, freeze, etc. in code

func _integrate_forces(state: PhysicsDirectBodyState3D):
	# Clear any forces on X axis to ensure tool only moves on Y/Z
	var current_velocity = state.linear_velocity
	current_velocity.x = 0
	state.linear_velocity = current_velocity
	
	# Apply input-based movement
	if input_accumulator.length() > 0:
		var force = Vector3(0, input_accumulator.y, input_accumulator.x) * max_force
		state.apply_central_force(force)
		input_accumulator = Vector2.ZERO

func apply_movement_input(mouse_delta: Vector2):
	input_accumulator += mouse_delta * movement_sensitivity

func reset_position():
	global_position = original_position
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
