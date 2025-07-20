extends RigidBody3D
class_name SpringForceDetector

signal force_applied(force_magnitude: float, force_direction: Vector3)

@export var compression_sensitivity: float = 2.0  # How much visual compression per position change
@export var min_scale: float = 0.3  # Minimum scale (30% of original)

var original_position: Vector3
var original_scale_y: float

func _ready():
	# Store original position and scale
	original_position = global_position
	original_scale_y = scale.y

func _physics_process(delta: float):
	# Check how much the spring has moved upward from its original position
	var position_change = global_position.y - original_position.y
	
	# Only compress if spring has moved up (positive position_change)
	if position_change > 0:
		# Calculate compression based on how much the spring has been pushed up
		var compression_ratio = position_change * compression_sensitivity
		compression_ratio = clamp(compression_ratio, 0.0, 1.0 - min_scale)
		
		# Apply visual compression
		var new_scale = original_scale_y * (1.0 - compression_ratio)
		scale.y = max(new_scale, min_scale)
		
		print("Spring moved up: ", position_change, " | Scale.y: ", scale.y)
	else:
		# Spring is at or below original position - no compression
		scale.y = original_scale_y
