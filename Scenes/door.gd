
extends LockableObject

@onready var prompt_label: Label3D = $PromptLabel
var lock_view_3d = preload("res://Scenes/lock_view_3d.tscn")
var current_lock_instance = null

func display_prompt():
	prompt_label.visible = true
	
func hide_prompt():
	prompt_label.visible = false

func interact():
	if is_locked:
		show_lock_view()
	else:
		print("Opening " + object_name)

func show_lock_view():
	# Find the SubViewportContainer
	var viewport_container = get_tree().get_first_node_in_group("lock_ui")
	if not viewport_container:
		print("Error: Could not find lock_ui container")
		return
	
	# Get the SubViewport (first child)
	var sub_viewport = viewport_container.get_child(0)
	if not sub_viewport is SubViewport:
		print("Error: First child is not a SubViewport")
		return
	
	# Clear any existing lock scenes
	for child in sub_viewport.get_children():
		child.queue_free()
	
	# Instantiate and add the lock scene
	current_lock_instance = lock_view_3d.instantiate()
	sub_viewport.add_child(current_lock_instance)
	
	# Enable the viewport container and set update mode
	viewport_container.visible = true
	
	# Capture mouse for lock interaction
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	print("Lock view displayed successfully")

func hide_lock_view():
	var viewport_container = get_tree().get_first_node_in_group("lock_ui")
	if viewport_container:
		var sub_viewport = viewport_container.get_child(0)
		
		# Hide container and stop updates
		viewport_container.visible = false

		
		# Clear the lock scene
		if current_lock_instance:
			current_lock_instance.queue_free()
			current_lock_instance = null
		
		# Release mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
