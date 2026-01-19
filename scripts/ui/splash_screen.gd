extends CanvasLayer
class_name SplashScreen
## Splash screen for Gravity Guardians
##
## Displays game title, win condition, controls, and instructions.
## Pressing any key transitions to the main game scene.

# Node references
@onready var press_any_key_label: Label = $CenterContainer/VBoxContainer/PressAnyKeyLabel

# Animation control
var _tween: Tween = null


func _ready() -> void:
	# Start pulsing animation for "Press any key" text
	_start_pulse_animation()
	print("Splash screen loaded")


func _input(event: InputEvent) -> void:
	# Detect any key press to start the game
	if event is InputEventKey and event.pressed and not event.echo:
		_start_game()


func _start_pulse_animation() -> void:
	"""Create pulsing fade animation for the press any key label"""
	if not press_any_key_label:
		return
	
	# Create looping tween for alpha fade
	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_property(press_any_key_label, "modulate:a", 0.3, 0.75)
	_tween.tween_property(press_any_key_label, "modulate:a", 1.0, 0.75)


func _start_game() -> void:
	"""Transition to the main game scene"""
	print("Starting game...")
	
	# Stop the pulsing animation
	if _tween:
		_tween.kill()
	
	# Load the main game scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")
