extends Node3D
class_name Pin3D

signal pin_state_changed

@onready var spring_pin: Node3D = $SpringPin
@onready var pin_hole: Node3D = $PinHole
@onready var spring_collision: Area3D = $SpringPin/SM_spring_pin2/SpringCollision
@onready var pin_hole_detection: Area3D = $PinHole/PinHoleDetection

# New: Reference to the actual spring mesh
@onready var spring_model: Node3D = $SpringPin/SM_spring_pin2  # Adjust path if needed
@export var spring_mesh_name: String = ""  # In case we need to find it dynamically

@export var pinstack_movement: float = 2.0
@export var movement_axis: Vector3 = Vector3(0, 1, 0)
@export var spring_compression_factor: float = 0.5  # How much the spring compresses
@export var pin_travel_distance: float = 0  # How far the pin itself moves

var current_pin_position: float = 0.0
var original_spring_position: Vector3
var original_spring_scale: Vector3
var is_in_sweet_spot: bool = false

func _ready():
	original_spring_position = spring_pin.position

	
	if spring_model:
		original_spring_scale = spring_model.scale

func move_pin(delta_y: float) -> void:
	current_pin_position += delta_y
	current_pin_position = clamp(current_pin_position, -100.0, 100.0)
	
	# Apply spring scaling based on direction
	if spring_model:
		var new_scale = original_spring_scale
		
		# Normalize position to -1.0 to 1.0 range
		var normalized_position = current_pin_position / 100.0
		
		if normalized_position > 0:
			# Positive = pulling down = spring extends
			new_scale.y = original_spring_scale.y * (1.0 - normalized_position * spring_compression_factor)
		else:
			# Negative = pushing up = spring compresses  
			new_scale.y = original_spring_scale.y * (1.0 - normalized_position * spring_compression_factor)
		
		# Prevent spring from scaling to 0 or negative
		new_scale.y = max(new_scale.y, original_spring_scale.y * 0.1)
		
		spring_model.scale = new_scale
	
	# Move the pin slightly for positioning
	var pin_movement = movement_axis * current_pin_position * pin_travel_distance * 0.01
	spring_pin.position = original_spring_position + pin_movement

func _on_pin_hole_detection_area_entered(area: Area3D) -> void:
	if area == spring_collision:
		is_in_sweet_spot = true
		print(name + ": Entered Sweet Spot!")
		pin_state_changed.emit()

func _on_pin_hole_detection_area_exited(area: Area3D) -> void:
	if area == spring_collision:
		is_in_sweet_spot = false
		print(name + ": Exited Sweet Spot!")
		pin_state_changed.emit()

func set_selected(selected: bool) -> void:
	if selected:
		# Scale the entire spring pin slightly for selection feedback
		spring_pin.scale = Vector3(1.1, 1.1, 1.1)
	else:
		spring_pin.scale = Vector3(1.0, 1.0, 1.0)

func is_unlocked() -> bool:
	return is_in_sweet_spot

func reset_pin() -> void:
	current_pin_position = 0.0
	spring_pin.position = original_spring_position
	
	# Reset spring scale
	if spring_model:
		spring_model.scale = original_spring_scale
	
	is_in_sweet_spot = false
