extends Node2D
class_name SinglePin

@onready var pin_stack: Node2D = $PinStack
@onready var spring: ColorRect = $PinStack/Spring
@onready var driver_pin: ColorRect = $PinStack/DriverPin
@onready var shear_line: Area2D = $PinStack/ShearLine
@onready var key_pin: ColorRect = $PinStack/KeyPin

@export var pinstack_movement: float = 2.0
var current_pin_position: float = 0.0

func _ready():
	# Mouse handling removed - will be handled by parent Lock node
	pass

# Method to move this specific pin
func move_pin(delta_y: float) -> void:
	current_pin_position += delta_y
	current_pin_position = clamp(current_pin_position, -100.0, 100.0)
	pin_stack.position.y = current_pin_position * pinstack_movement

# Method to get pin bounds for selection
func get_pin_bounds() -> Rect2:
	return Rect2(global_position.x - 50, global_position.y - 100, 100, 200)
