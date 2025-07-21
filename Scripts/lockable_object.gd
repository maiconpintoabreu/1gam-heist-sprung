extends StaticBody3D
class_name LockableObject

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var prompt_label: Label3D = $PromptLabel

@export var object_name: String = "Door"
@export var is_locked: bool = true
@export var lock_pins: int = 4


# NEW: Configurable lock scene - set this in the editor!
@export var lock_scene: PackedScene

var current_lock_instance = null

func display_prompt() -> void:
	if prompt_label:
		prompt_label.visible = true

func hide_prompt() -> void:
	if prompt_label:
		prompt_label.visible = false

func interact():
	if is_locked:
		show_lock_view()


func show_lock_view():
	# Use the exported lock_scene, fallback to default if not set
	var lock_to_load = lock_scene
	if not lock_to_load:
		lock_to_load = preload("res://Scenes/lock_view_3d.tscn")
		print("Warning: No lock scene set, using default")
	
	# Find the SubViewportContainer
	var viewport_container = get_tree().get_first_node_in_group("lock_ui")
	var sub_viewport = viewport_container.get_child(0)
	
	# Clear any existing lock scenes
	for child in sub_viewport.get_children():
		child.queue_free()
	
	# Instantiate and add the lock scene
	current_lock_instance = lock_to_load.instantiate()
	sub_viewport.add_child(current_lock_instance)
	
	# Try to connect to lock completion signal
	_connect_lock_signals()
		
	# Enable the viewport container
	viewport_container.visible = true
	
	# Capture mouse for lock interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	print("Lock view displayed for " + object_name)

func _connect_lock_signals():
	# Look for Lock3D node and connect signals
	var lock_3d = current_lock_instance.get_node("Lock3DDoor")
	if lock_3d:
		# Connect to existing signals or create new ones
		if lock_3d.has_signal("lock_opened"):
			lock_3d.lock_opened.connect(_on_lock_opened)
		elif lock_3d.has_method("check_lock_status"):
			# If no signal exists, we could poll or add one
			print("Lock has check_lock_status method")
	else:
		print("Warning: Could not find Lock3D node")

func hide_lock_view():
	var viewport_container = get_tree().get_first_node_in_group("lock_ui")
	if viewport_container:
		viewport_container.visible = false
		
		# Clear the lock scene
		if current_lock_instance:
			current_lock_instance.queue_free()
			current_lock_instance = null
		
		# Release mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_lock_opened():
	print("Lock successfully picked! Opening " + object_name)
	is_locked = false
	hide_lock_view()
	_trigger_unlock_behavior()

# Virtual method - override in inherited scenes for specific behavior
func _trigger_unlock_behavior():
	if animation_player and animation_player.has_animation("opening"):
		animation_player.play("opening")
	else:
		print("No opening animation found for " + object_name)
