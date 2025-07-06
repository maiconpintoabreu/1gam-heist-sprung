extends Node3D
class_name Pin3D

signal pin_state_changed

# Editor-assigned node references
@onready var spring_pin: Node3D = $SpringPin
@onready var pin_hole: Node3D = $PinHole
@onready var spring_collision: CollisionShape3D = $SpringPin/CollisionShape3D
@onready var pin_hole_detection: Area3D = $PinHole/PinHoleDetection
@onready var spring_model: Node3D = $SpringPin/SM_spring_pin2
@onready var tool_detector: Area3D = $SpringPin/SM_spring_pin2/ToolDetector

# Export variables - all configurable in editor
@export var pinstack_movement: float = 2.0
@export var movement_axis: Vector3 = Vector3(0, 1, 0)
@export var spring_compression_factor: float = 0.5
@export var pin_travel_distance: float = 0
@export var tool_force_multiplier: float = 20.0
@export var tool_force_threshold: float = 0.1

var current_pin_position: float = 0.0
var original_spring_position: Vector3
var original_spring_scale: Vector3
var is_in_sweet_spot: bool = false
var tool_contact_force: float = 0.0
var tool_in_contact: bool = false
var current_tool: LockPickTool = null

func _ready():
	original_spring_position = spring_pin.position
	
	if spring_model:
		original_spring_scale = spring_model.scale

# REFACTORED: Shared spring compression logic - no more duplication!
func update_spring_compression():
	if spring_model:
		var new_scale = original_spring_scale
		var normalized_position = current_pin_position / 100.0
		
		# Spring compresses based on how far pin has moved
		new_scale.y = original_spring_scale.y * (1.0 - abs(normalized_position) * spring_compression_factor)
		new_scale.y = max(new_scale.y, original_spring_scale.y * 0.1)
		
		spring_model.scale = new_scale

func move_pin_by_force(force_amount: float):
	current_pin_position += force_amount
	current_pin_position = clamp(current_pin_position, -100.0, 100.0)
	
	# Apply spring compression effect only (no vertical movement)
	update_spring_compression()

func move_pin(delta_y: float) -> void:
	current_pin_position += delta_y
	current_pin_position = clamp(current_pin_position, -100.0, 100.0)
	
	# Apply spring compression effect only (no vertical movement)
	update_spring_compression()

# Rest of your existing functions remain the same...
func _on_tool_entered(body: Node3D):
	if body is LockPickTool:
		tool_in_contact = true
		current_tool = body
		print(name + ": Tool contact detected")

func _on_tool_exited(body: Node3D):
	if body is LockPickTool:
		tool_in_contact = false
		tool_contact_force = 0.0
		current_tool = null
		print(name + ": Tool contact lost")

func _physics_process(delta: float):
	if tool_in_contact and current_tool:
		calculate_tool_force()
		apply_tool_physics(delta)

func calculate_tool_force():
	if current_tool and current_tool.linear_velocity:
		var tool_velocity = current_tool.linear_velocity
		var velocity_y = tool_velocity.y
		
		if abs(velocity_y) > tool_force_threshold:
			tool_contact_force = velocity_y * tool_force_multiplier
		else:
			tool_contact_force = 0.0

func apply_tool_physics(delta: float):
	if tool_contact_force != 0.0:
		var movement_amount = tool_contact_force * delta
		move_pin_by_force(movement_amount)

func _on_pin_hole_detection_body_entered(body:RigidBody3D) -> void:
	if body == spring_pin:
		is_in_sweet_spot = true
		print(name + ": Entered Sweet Spot!")
		pin_state_changed.emit()

func _on_pin_hole_detection_body_exited(body:RigidBody3D) -> void:
	if body == spring_pin:
		is_in_sweet_spot = false
		print(name + ": Exited Sweet Spot!")
		pin_state_changed.emit()

func set_selected(selected: bool) -> void:
	if selected:
		spring_pin.scale = Vector3(1.1, 1.1, 1.1)
	else:
		spring_pin.scale = Vector3(1.0, 1.0, 1.0)

func is_unlocked() -> bool:
	return is_in_sweet_spot

func reset_pin() -> void:
	current_pin_position = 0.0
	spring_pin.position = original_spring_position
	tool_contact_force = 0.0
	tool_in_contact = false
	
	if spring_model:
		spring_model.scale = original_spring_scale
	
	is_in_sweet_spot = false
