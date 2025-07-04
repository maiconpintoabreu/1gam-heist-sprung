extends Node3D
class_name Lock3D

var pins: Array[Pin3D] = []
var selected_pin: Pin3D = null
var selected_pin_index: int = 0
@export var mouse_sensitivity: float = 0.5
@export var pin_switch_threshold: float = 50.0
var accumulated_x_movement: float = 0.0
var pin_selection_mode: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	collect_pins()
	connect_pin_signals()  # ADD THIS
	
	if pins.size() > 0:
		select_pin(0)

func collect_pins():
	pins.clear()
	for child in get_children():
		if child is Pin3D:
			pins.append(child)
			print("Found pin: ", child.name)
	
	print("Total pins collected: ", pins.size())

func connect_pin_signals():  # ADD THIS FUNCTION
	for pin in pins:
		pin.pin_state_changed.connect(_on_pin_state_changed)

func _on_pin_state_changed():  # ADD THIS FUNCTION
	check_lock_status()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			pin_selection_mode = event.pressed
			
	elif event is InputEventMouseMotion:
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
