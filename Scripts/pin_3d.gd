extends Node3D
class_name Pin3D

signal pin_state_changed

# Editor-assigned node references
@onready var spring_pin: RigidBody3D = $SpringPin
@onready var pin_hole: Node3D = $PinHole
@onready var pin_hole_detection: Area3D = $PinHole/PinHoleDetection
@onready var spring_model: Node3D = $SpringPin/SM_spring_pin2
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Export variables - all configurable in editor
@export var spring_force_strength: float = 20.0  # How hard spring pulls back to rest
@export var spring_compression_factor: float = 0.7  # Visual compression amount
@export var max_compression_distance: float = 1.0  # Distance for full visual compression

var original_spring_position: Vector3
var original_spring_scale: Vector3
var is_in_sweet_spot: bool = false

func _ready():
	original_spring_position = spring_pin.position
	
	if spring_model:
		original_spring_scale = spring_model.scale

func _physics_process(delta: float):
	# Always apply spring force to pull pin back to rest position
	apply_spring_restoration_force()
	
	# Update visual compression based on current position
	update_visual_compression()

func apply_spring_restoration_force():
	
	if is_in_sweet_spot:
		return  # Pin stays locked in position!
	# Calculate force needed to return to original position
	var displacement = spring_pin.position - original_spring_position
	var restoration_force = -displacement * spring_force_strength
	
	# Only apply Y-axis force (up/down movement)
	restoration_force.x = 0
	restoration_force.z = 0
	
	spring_pin.apply_force(restoration_force)

func update_visual_compression():
	if spring_model:
		# Calculate how far we've moved from the original position
		var displacement = spring_pin.position.y - original_spring_position.y
		
		# Convert displacement to compression ratio (0 to 1)
		var compression_ratio = clamp(abs(displacement) / max_compression_distance, 0.0, 1.0)
		
		# Apply visual compression
		var new_scale = original_spring_scale
		new_scale.y = original_spring_scale.y * (1.0 - compression_ratio * spring_compression_factor)
		new_scale.y = max(new_scale.y, original_spring_scale.y * 0.1)
		
		spring_model.scale = new_scale

# Sweet spot detection (unchanged)
func _on_pin_hole_detection_body_entered(body: RigidBody3D) -> void:
	if body == spring_pin:
		is_in_sweet_spot = true
		print(name + ": Entered Sweet Spot!")
		audio_stream_player.play()
		pin_state_changed.emit()

func _on_pin_hole_detection_body_exited(body: RigidBody3D) -> void:
	if body == spring_pin:
		is_in_sweet_spot = false
		print(name + ": Exited Sweet Spot!")
		pin_state_changed.emit()

func is_unlocked() -> bool:
	return is_in_sweet_spot

func reset_pin() -> void:
	spring_pin.position = original_spring_position
	spring_pin.linear_velocity = Vector3.ZERO
	spring_pin.angular_velocity = Vector3.ZERO
	
	if spring_model:
		spring_model.scale = original_spring_scale
	
	is_in_sweet_spot = false
