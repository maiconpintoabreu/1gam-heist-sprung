extends Node3D
class_name SimpleRoof

@onready var detection_area: Area3D = $DetectionArea

# Array to hold all roof mesh instances
var roof_meshes: Array[MeshInstance3D] = []

func _ready():
	# Connect the area signals
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)
	
	# Collect all MeshInstance3D children
	collect_roof_meshes()
	
	# Make sure all roofs start visible
	set_roof_visibility(true)

func collect_roof_meshes():
	roof_meshes.clear()
	
	# Find all MeshInstance3D children (not just direct children)
	for child in get_children():
		if child is MeshInstance3D:
			roof_meshes.append(child)
			print("Found roof mesh: ", child.name)
	
	print("Total roof meshes found: ", roof_meshes.size())

func set_roof_visibility(visible: bool):
	for mesh in roof_meshes:
		if mesh:
			mesh.visible = visible

func _on_player_entered(body: Node3D):
	if body is Player:
		print("Player entered room - hiding roof")
		set_roof_visibility(false)

func _on_player_exited(body: Node3D):
	if body is Player:
		print("Player exited room - showing roof")
		set_roof_visibility(true)
