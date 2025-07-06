extends Node3D
class_name Lock3D

# Editor-assigned reference - add LockPickTool as child in editor!
@onready var lock_pick_tool: LockPickTool = $LockPickTool

# Export variables - configure in editor inspector
@export var mouse_sensitivity: float = 0.5
@export var pin_switch_threshold: float = 50.0

var pins: Array[Pin3D] = []
var selected_pin: Pin3D = null
var selected_pin_index: int = 0
var accumulated_x_movement: float = 0.0
var pin_selection_mode: bool = false
var tool_mode: bool = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	collect_pins()
	connect_pin_signals()
	
	if pins.size() > 0:
		select_pin(0)
	
	# Verify tool exists (set up in editor)
	if lock_pick_tool:
		print("Lock pick tool found and ready")
	else:
		print("Warning: No LockPickTool child found. Add one in the editor!")

func collect_pins():
	pins.clear()
	for child in get_children():
		if child is Pin3D:
			pins.append(child)
			print("Found pin: ", child.name)
	
	print("Total pins collected: ", pins.size())

func connect_pin_signals():
	for pin in pins:
		pin.pin_state_changed.connect(_on_pin_state_changed)

func _on_pin_state_changed():
	check_lock_status()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			pin_selection_mode = event.pressed
		
		if event.keycode == KEY_T and event.pressed:
			tool_mode = !tool_mode
			print("Tool mode: ", "ON" if tool_mode else "OFF")
			
	elif event is InputEventMouseMotion:
		if tool_mode and lock_pick_tool:
			handle_tool_movement(event)
		else:
			handle_direct_pin_movement(event)

func handle_tool_movement(event: InputEventMouseMotion):
	if pin_selection_mode:
		accumulated_x_movement += -event.relative.x
		if abs(accumulated_x_movement) >= pin_switch_threshold:
			var direction = sign(accumulated_x_movement)
			switch_pin(direction)
			accumulated_x_movement = 0.0
	else:
		var movement_input = Vector2(-event.relative.x, -event.relative.y) * mouse_sensitivity
		lock_pick_tool.apply_movement_input(movement_input)

func handle_direct_pin_movement(event: InputEventMouseMotion):
	if pin_selection_mode:
		accumulated_x_movement += -event.relative.x
		if abs(accumulated_x_movement) >= pin_switch_threshold:
			var direction = sign(accumulated_x_movement)
			switch_pin(direction)
			accumulated_x_movement = 0.0
	else:
		if selected_pin:
			selected_pin.move_pin(-event.relative.y * mouse_sensitivity)

func switch_pin(direction: int):
	if pins.size() <= 1:
		return
	
	var new_index = selected_pin_index + direction
	new_index = clamp(new_index, 0, pins.size() - 1)
	
	if new_index != selected_pin_index:
		select_pin(new_index)

func select_pin(index: int):
	if index < 0 or index >= pins.size():
		return
	
	if selected_pin:
		selected_pin.set_selected(false)
	
	selected_pin_index = index
	selected_pin = pins[index]
	selected_pin.set_selected(true)
	
	print("Selected pin: ", selected_pin.name)

func check_lock_status():
	var unlocked_count = 0
	for pin in pins:
		if pin.is_unlocked():
			unlocked_count += 1
	
	print("Unlocked pins: ", unlocked_count, "/", pins.size())
	
	if unlocked_count == pins.size():
		print("🔓 LOCK OPENED! 🔓")
		return true
	return false

func reset_lock():
	for pin in pins:
		pin.reset_pin()
	
	if lock_pick_tool:
		lock_pick_tool.reset_position()
