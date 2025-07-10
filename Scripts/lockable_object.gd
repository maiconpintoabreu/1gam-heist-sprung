extends RigidBody3D

class_name LockableObject


@export var object_name: String = "Door"
@export var is_locked: bool = true
@export var lock_pins: int = 4
@export var lock_difficulty: float = 1.0


func display_prompt() -> void:
	print("Press E to Interact with " + object_name)

func hide_prompt() -> void:
	print("Hiding Prompt")
