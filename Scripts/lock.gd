extends Node2D
class_name Lock

var pins: Array[SinglePin] = []
var selected_pin: SinglePin = null
var selected_pin_index: int = 0
var mouse_sensitivity: float = 0.5
var pin_switch_threshold: float = 50.0  # How much X movement needed to switch pins
var accumulated_x_movement: float = 0.0


func _ready():
	# Capture mouse for lock interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Collect all SinglePin children
	collect_pins()
	
	# Select first pin by default
	if pins.size() > 0:
		select_pin(0)

func collect_pins():
	pins.clear()
	# Lock has LockCylinder1,2,3,4. Each LockCylinder has a SinglePin child
	for child in get_children():
		if "LockCylinder" in child.name:
			# Find the SinglePin child in this LockCylinder
			for grandchild in child.get_children():
				if grandchild is SinglePin:
					pins.append(grandchild)
					break
		else:
			print("couldn't find LockCylinder")
			
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		handle_mouse_movement(event)
	
	# ESC to release mouse
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func handle_mouse_movement(event: InputEventMouseMotion):
	# Accumulate X movement for pin switching
	accumulated_x_movement += event.relative.x
	
	# Check if we should switch pins
	if abs(accumulated_x_movement) >= pin_switch_threshold:
		var direction = sign(accumulated_x_movement)
		switch_pin(direction)
		accumulated_x_movement = 0.0  # Reset accumulator
	
	# Move selected pin based on Y position
	if selected_pin:
		selected_pin.move_pin(event.relative.y * mouse_sensitivity)

func switch_pin(direction: int):
	if pins.size() <= 1:
		return
	
	# Calculate new pin index
	var new_index = selected_pin_index + direction
	new_index = clamp(new_index, 0, pins.size() - 1)
	
	# Select new pin if different
	if new_index != selected_pin_index:
		select_pin(new_index)

func select_pin(index: int):
	if index < 0 or index >= pins.size():
		return
	
	# Deselect current pin (you can add visual feedback here)
	if selected_pin:
		deselect_current_pin()
	
	# Select new pin
	selected_pin_index = index
	selected_pin = pins[index]
	highlight_selected_pin()
	

func highlight_selected_pin():
	# Add visual feedback for selected pin
	# For example, you could change the spring color or add an outline
	if selected_pin and selected_pin.spring:
		selected_pin.spring.modulate = Color.YELLOW

func deselect_current_pin():
	# Remove visual feedback from previously selected pin
	if selected_pin and selected_pin.spring:
		selected_pin.spring.modulate = Color.WHITE
