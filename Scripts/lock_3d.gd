extends Node3D
class_name Lock3D
signal lock_opened

# Editor-assigned reference - add LockPickTool as child in editor!
@onready var lock_pick_tool: LockPickTool = $LockPickTool

# Export variables - configure in editor inspector
@export var mouse_sensitivity: float = 0.2
@export var pin_switch_threshold: float = 50.0

# NEW: Random pin system
@export var number_of_pins: int = 4
@export var pin_variant_scenes: Array[PackedScene] = []
@export var randomize_on_ready: bool = true

var pins: Array[Pin3D] = []
var selected_pin: Pin3D = null
var selected_pin_index: int = 0
var accumulated_x_movement: float = 0.0
var pin_selection_mode: bool = false
var tool_mode: bool = true

# Standard pin positions
var pin_positions = [
	Vector3(-3, 0, -12),
	Vector3(-3, 0, -8),
	Vector3(-3, 0, -4),
	Vector3(-3, 0, 0),
	Vector3(-3, 0, 4),
	Vector3(-3, 0, 8),
]

func _ready():
	if randomize_on_ready and pin_variant_scenes.size() > 0:
		spawn_random_pins()
	else:
		collect_pins()
	
	connect_pin_signals()
	
	# Verify tool exists (set up in editor)
	if lock_pick_tool:
		print("Lock pick tool found and ready")
	else:
		print("Warning: No LockPickTool child found. Add one in the editor!")

func spawn_random_pins():
	"""Spawn random pin variants"""
	# Clear existing pins first
	clear_existing_pins()
	
	pins.clear()
	
	for i in range(number_of_pins):
		# Pick random variant
		var random_variant = pin_variant_scenes[randi() % pin_variant_scenes.size()]
		
		# Spawn pin
		var pin_instance = random_variant.instantiate() as Pin3D
		if pin_instance:
			add_child(pin_instance)
			
			# Position pin
			if i < pin_positions.size():
				pin_instance.position = pin_positions[i]
			else:
				# If we need more positions, just space them out
				pin_instance.position = Vector3(-1.8, 1.6344, -1.23079 + (i * 1.2))
			
			pin_instance.name = "Pin3D_%d" % i
			pins.append(pin_instance)
			
			print("Spawned random pin variant %d at position %s" % [i, pin_instance.position])

func clear_existing_pins():
	"""Remove all existing Pin3D children"""
	var children_to_remove = []
	for child in get_children():
		if child is Pin3D:
			children_to_remove.append(child)
	
	for child in children_to_remove:
		child.queue_free()

func collect_pins():
	"""Fallback: collect manually placed pins"""
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
		
		# NEW: Press R to respawn with new random variants
		if event.keycode == KEY_R and event.pressed:
			print("Respawning with new random variants...")
			spawn_random_pins()
			connect_pin_signals()
			
	elif event is InputEventMouseMotion:
		if tool_mode and lock_pick_tool:
			handle_tool_movement(event)

func handle_tool_movement(event: InputEventMouseMotion):
	if pin_selection_mode:
		accumulated_x_movement += -event.relative.x
		if abs(accumulated_x_movement) >= pin_switch_threshold:
			#var direction = 
			sign(accumulated_x_movement)
			accumulated_x_movement = 0.0
	else:
		var movement_input = Vector2(-event.relative.x, -event.relative.y) * mouse_sensitivity
		lock_pick_tool.apply_movement_input(movement_input)

func check_lock_status():
	var unlocked_count = 0
	for pin in pins:
		if pin.is_unlocked():
			unlocked_count += 1
	
	print("Unlocked pins: ", unlocked_count, "/", pins.size())
	
	if unlocked_count == pins.size():
		print("🔓 LOCK OPENED! 🔓")
		lock_opened.emit()
		return true
	return false

func reset_lock():
	for pin in pins:
		pin.reset_pin()
	
	if lock_pick_tool:
		lock_pick_tool.reset_position()

# PUBLIC: Change settings and respawn
func set_pin_count(count: int):
	number_of_pins = count
	if pin_variant_scenes.size() > 0:
		spawn_random_pins()
		connect_pin_signals()

func respawn_random()->void:
	spawn_random_pins()
	connect_pin_signals()

func setup_lock(in_number_of_pins):
	number_of_pins = in_number_of_pins
