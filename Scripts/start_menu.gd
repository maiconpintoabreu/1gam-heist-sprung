extends Control

@onready var play_button: Button = $MenuContainer/PlayButton
@onready var quit_button: Button = $MenuContainer/QuitButton
@onready var game_title: Label = $MenuContainer/GameTitle

func _ready():
	# Ensure mouse is visible in menu
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Style the title
	if game_title:
		game_title.add_theme_font_size_override("font_size", 32)
	
	# Style buttons
	style_button(play_button)
	style_button(quit_button)

func style_button(button: Button):
	if button:
		button.add_theme_font_size_override("font_size", 18)
		button.custom_minimum_size = Vector2(200, 50)

func _on_play_button_pressed():
	print("Starting game...")
	# Load the main house scene
	get_tree().change_scene_to_file("res://Scenes/house.tscn")

func _on_quit_button_pressed():
	print("Quitting game...")
	get_tree().quit()

# Handle ESC key in menu
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_quit_button_pressed()
