extends Node2D
## Main game controller for Gravity Guardians
##
## Manages game initialization, restart functionality, and coordinates
## between game state and player ships.

# Initial spawn positions (captured from scene at start)
var ship1_initial_spawn: Vector2
var ship2_initial_spawn: Vector2

# Node references
@onready var ship1: Ship = $Players/Ship1
@onready var ship2: Ship = $Players/Ship2
@onready var hud: HUD = $HUD


func _ready() -> void:
	# Capture initial spawn positions from the scene
	if ship1:
		ship1_initial_spawn = ship1.global_position
		print("Ship1 initial spawn: %s" % ship1_initial_spawn)
	
	if ship2:
		ship2_initial_spawn = ship2.global_position
		print("Ship2 initial spawn: %s" % ship2_initial_spawn)
	
	print("Main game controller ready")


func _unhandled_input(event: InputEvent) -> void:
	# Handle restart input
	if Input.is_action_just_pressed("restart_game"):
		restart_game()
		get_viewport().set_input_as_handled()


func restart_game() -> void:
	"""Soft reset - resets game state and respawns ships without reloading scene"""
	print("=== GAME RESTART REQUESTED ===")
	
	# Hide game over screen
	if hud:
		hud.hide_game_over_screen()
	
	# Reset game state (kills, game over flag)
	GameState.reset_game()
	
	# Clear all active bullets from the scene
	var bullet_count := get_tree().get_nodes_in_group("bullets").size()
	get_tree().call_group("bullets", "queue_free")
	if bullet_count > 0:
		print("Cleared %d bullets" % bullet_count)
	
	# Respawn both ships at their initial positions
	if ship1:
		ship1.respawn(ship1_initial_spawn)
		print("Ship1 respawned at initial position")
	
	if ship2:
		ship2.respawn(ship2_initial_spawn)
		print("Ship2 respawned at initial position")
	
	print("=== GAME RESTARTED ===")
