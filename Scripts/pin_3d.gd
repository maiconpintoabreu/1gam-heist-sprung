extends Node3D
class_name Pin3D
signal pin_state_changed

# Node references
@onready var shearline_object: RigidBody3D = $ShearLineObject
@onready var top_of_pin: StaticBody3D = $TopOfPin
@onready var spring_joint: SliderJoint3D = $SpringJoint
@onready var driver_pin: RigidBody3D = $DriverPin
@onready var key_pin: RigidBody3D = $KeyPin
@onready var spring_mesh: MeshInstance3D = $Model
@onready var shear_line: Area3D = $ShearLine
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Original positions
var original_spring_scale: Vector3
var original_key_position: Vector3      # KeyPin is now the reference point
var original_driver_position: Vector3   
var original_shearline_position: Vector3
var target_spring_scale: Vector3

# NEW: Locked position storage
var locked_key_position: Vector3        # Position where KeyPin was when unlocked
var locked_driver_position: Vector3     # Position where DriverPin was when unlocked
var locked_shearline_position: Vector3  # Position where ShearLineObject was when unlocked

# Offsets from KeyPin (calculated at startup)
var driver_to_key_offset: Vector3       # How far DriverPin is from KeyPin
var shearline_to_key_offset: Vector3    # How far ShearLineObject is from KeyPin

@export var spring_animation_speed: float = 20.0
@export var compression_distance: float = 3.0

var is_in_sweet_spot: bool = false

func _ready():
	setup_visual_spring()
	calculate_offsets()

func setup_visual_spring():
	if spring_mesh:
		original_spring_scale = spring_mesh.scale  
		target_spring_scale = spring_mesh.scale

func calculate_offsets():
	"""Calculate the offset relationships with KeyPin as the leader"""
	# Store original positions
	original_key_position = key_pin.position
	original_driver_position = driver_pin.position
	original_shearline_position = shearline_object.position
	
	# Calculate offsets from KeyPin to other components
	driver_to_key_offset = original_driver_position - original_key_position
	shearline_to_key_offset = original_shearline_position - original_key_position

func _physics_process(delta: float):
	if is_in_sweet_spot:
		# Pin is unlocked - keep everything frozen at locked positions
		freeze_at_locked_positions()
	else:
		# Pin is still locked - allow normal movement
		update_follower_positions()
	
	update_spring_visual()
	
	if spring_mesh and target_spring_scale:
		spring_mesh.scale = spring_mesh.scale.lerp(target_spring_scale, spring_animation_speed * delta)

func freeze_at_locked_positions():
	"""Keep all components frozen at their locked positions"""
	# Force KeyPin to stay at locked position
	key_pin.position = locked_key_position
	key_pin.linear_velocity = Vector3.ZERO
	key_pin.angular_velocity = Vector3.ZERO
	
	# Force followers to stay at their locked positions
	driver_pin.position = locked_driver_position
	driver_pin.linear_velocity = Vector3.ZERO
	driver_pin.angular_velocity = Vector3.ZERO
	
	shearline_object.position = locked_shearline_position
	shearline_object.linear_velocity = Vector3.ZERO
	shearline_object.angular_velocity = Vector3.ZERO

func update_follower_positions():
	"""Make DriverPin and ShearLineObject follow KeyPin movement (only when not locked)"""
	# Calculate how much the KeyPin has moved from its original position
	var key_displacement = key_pin.position - original_key_position
	
	# Update DriverPin position based on KeyPin movement
	var target_driver_position = original_driver_position + key_displacement
	driver_pin.position = target_driver_position
	
	# Update ShearLineObject position based on KeyPin movement
	var target_shearline_position = original_shearline_position + key_displacement
	shearline_object.position = target_shearline_position
	
	# Optional: Clear velocities to prevent drift
	driver_pin.linear_velocity = Vector3.ZERO
	shearline_object.linear_velocity = Vector3.ZERO

func update_spring_visual():
	if not spring_mesh:
		return
		
	# Calculate spring compression based on DriverPin position (since spring connects to it)
	var position_change = driver_pin.position.y - original_driver_position.y
	var movement_ratio = clamp(position_change / compression_distance, -1.0, 1.0)
	
	# Calculate target scale based on movement direction
	var new_scale = original_spring_scale
	new_scale.y = original_spring_scale.y * (1.0 - movement_ratio * 0.6)
	new_scale.y = clamp(new_scale.y, original_spring_scale.y * 0.3, original_spring_scale.y * 1.8)
	
	target_spring_scale = new_scale

# Sweet spot detection
func _on_shear_line_body_entered(body: RigidBody3D) -> void:
	if body == driver_pin or body == key_pin:
		check_unlock_condition()

func _on_shear_line_body_exited(body: RigidBody3D) -> void:
	if body == shearline_object:
		check_unlock_condition()

func check_unlock_condition():
	# If already unlocked, stay unlocked and frozen
	if is_in_sweet_spot:
		return
	
	var bodies_in_shear_line = shear_line.get_overlapping_bodies()
	
	for body in bodies_in_shear_line:
		if body == shearline_object:
			is_in_sweet_spot = true
			
			# STORE THE LOCKED POSITIONS - freeze everything here!
			locked_key_position = key_pin.position
			locked_driver_position = driver_pin.position
			locked_shearline_position = shearline_object.position
			
			print("Pin unlocked and FROZEN at position: ", locked_key_position)
			audio_stream_player.play()
			pin_state_changed.emit()
			return

func is_unlocked() -> bool:
	return is_in_sweet_spot
