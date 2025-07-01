extends Area2D

@export var unlock_position: float = 0.0
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	collision_shape_2d.position.y = -27 - unlock_position


func _on_area_entered(area: Area2D) -> void:
	print("Entered Sweet Spot")


func _on_area_exited(area: Area2D) -> void:
	print("Exited Sweet Spot")
