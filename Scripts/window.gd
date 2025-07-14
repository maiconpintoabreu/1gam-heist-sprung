extends LockableObject
class_name WindowTest

# Door-specific behavior can be added here
func _ready():
	# Set door-specific defaults
	object_name = "Window"

# Override this for door-specific unlock behavior
func _trigger_unlock_behavior():
	print("Window is opening...")
	
	# Play door-specific opening animation
	if animation_player and animation_player.has_animation("door_opening"):
		animation_player.play("door_opening")
	else:
		# Fallback to parent behavior
		super._trigger_unlock_behavior()
	
	# Add door-specific effects
	# play_door_sound()
	# trigger_door_physics()

# Door-specific methods can be added here
func close_door():
	if animation_player and animation_player.has_animation("door_closing"):
		animation_player.play("door_closing")
		
func lock_door():
	is_locked = true
	print("Door has been locked")
