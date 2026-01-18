extends CanvasLayer
class_name HUD
## Main heads-up display for Gravity Guardians
##
## Displays scores and fuel levels for both players at the bottom of the screen.
## Connects player displays to their respective ships.

# Node references
@onready var player1_display: PlayerDisplay = $Panel/MarginContainer/HBoxContainer/Player1Display
@onready var player2_display: PlayerDisplay = $Panel/MarginContainer/HBoxContainer/Player2Display


func _ready() -> void:
	# Wait a frame for ships to register with GameState
	await get_tree().process_frame
	
	# Set up player displays with their ships
	setup_player_displays()
	
	# Listen for ship respawns to reconnect signals
	GameState.ship_respawned.connect(_on_ship_respawned)
	
	print("HUD initialized")


func setup_player_displays() -> void:
	"""Connect player displays to their ships"""
	var ship1 = GameState.ships.get(1)
	var ship2 = GameState.ships.get(2)
	
	if ship1:
		player1_display.set_player_ship(ship1)
	else:
		push_warning("Ship 1 not found in GameState")
	
	if ship2:
		player2_display.set_player_ship(ship2)
	else:
		push_warning("Ship 2 not found in GameState")


func _on_ship_respawned(respawned_player_id: int, spawn_position: Vector2) -> void:
	"""Reconnect to ship after respawn (in case reference changed)"""
	var ship = GameState.ships.get(respawned_player_id)
	
	if not ship:
		push_warning("Respawned ship %d not found in GameState" % respawned_player_id)
		return
	
	# Reconnect the appropriate player display
	if respawned_player_id == 1:
		player1_display.set_player_ship(ship)
	elif respawned_player_id == 2:
		player2_display.set_player_ship(ship)
	
	print("HUD reconnected to respawned ship %d" % respawned_player_id)
