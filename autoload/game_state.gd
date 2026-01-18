extends Node
## GameState - Global singleton for managing game state, scores, and respawning
##
## This autoload manages the overall game state including kill tracking,
## win conditions, and coordinating ship respawns across landing pads.

# Signals
signal kill_scored(player_id: int, new_kill_count: int)
signal game_over(winner_id: int)
signal ship_respawned(player_id: int, spawn_position: Vector2)

# Constants
const KILLS_TO_WIN: int = 5

# Game state
var player1_kills: int = 0
var player2_kills: int = 0
var is_game_over: bool = false

# Node references
var landing_pads: Array[Node] = []
var ships: Dictionary = {}  # player_id -> Ship node


func _ready() -> void:
	print("GameState initialized")


## Register a landing pad for spawn/respawn system
func register_landing_pad(pad: Node) -> void:
	if pad not in landing_pads:
		landing_pads.append(pad)
		print("Landing pad registered: ", pad.name)


## Register a player ship
func register_ship(player_id: int, ship: Node) -> void:
	ships[player_id] = ship
	print("Ship registered - Player %d: %s" % [player_id, ship.name])


## Report a kill when one player destroys another
func report_kill(killer_id: int, victim_id: int) -> void:
	if is_game_over:
		return
	
	# Don't award points for self-destruction
	if killer_id == victim_id:
		print("Player %d self-destructed (no points)" % killer_id)
		return
	
	# Increment kill count
	if killer_id == 1:
		player1_kills += 1
		kill_scored.emit(1, player1_kills)
		print("Player 1 scores! Kills: %d" % player1_kills)
	elif killer_id == 2:
		player2_kills += 1
		kill_scored.emit(2, player2_kills)
		print("Player 2 scores! Kills: %d" % player2_kills)
	
	# Check win condition
	check_win_condition()


## Check if either player has reached the kill limit
func check_win_condition() -> void:
	if player1_kills >= KILLS_TO_WIN:
		trigger_game_over(1)
	elif player2_kills >= KILLS_TO_WIN:
		trigger_game_over(2)


## Trigger game over state
func trigger_game_over(winner_id: int) -> void:
	is_game_over = true
	game_over.emit(winner_id)
	print("GAME OVER! Player %d wins! Final score: %d - %d" % [winner_id, player1_kills, player2_kills])


## Get a random available landing pad for respawning
func get_random_spawn_pad() -> Node:
	if landing_pads.is_empty():
		push_error("No landing pads registered!")
		return null
	
	# Filter to available pads (not occupied)
	var available_pads: Array[Node] = []
	for pad in landing_pads:
		if pad.has_method("is_available") and pad.is_available():
			available_pads.append(pad)
	
	# If no pads are available, use any pad (edge case)
	if available_pads.is_empty():
		available_pads = landing_pads.duplicate()
	
	# Return random pad
	var random_index := randi() % available_pads.size()
	return available_pads[random_index]


## Request respawn for a player
func respawn_ship(player_id: int) -> void:
	if is_game_over:
		return
	
	var spawn_pad := get_random_spawn_pad()
	if spawn_pad == null:
		push_error("Cannot respawn - no landing pads available!")
		return
	
	# Use pad's spawn position method if available, otherwise use center
	var spawn_position: Vector2
	if spawn_pad.has_method("get_spawn_position"):
		spawn_position = spawn_pad.get_spawn_position()
	else:
		spawn_position = spawn_pad.global_position
	
	ship_respawned.emit(player_id, spawn_position)
	
	print("Player %d respawning at: %s" % [player_id, spawn_pad.name])


## Reset the game state (for restart)
func reset_game() -> void:
	player1_kills = 0
	player2_kills = 0
	is_game_over = false
	
	print("Game reset - starting new match")
	
	# Notify UI to update
	kill_scored.emit(1, 0)
	kill_scored.emit(2, 0)


## Get current kill count for a player
func get_kills(player_id: int) -> int:
	if player_id == 1:
		return player1_kills
	elif player_id == 2:
		return player2_kills
	return 0
