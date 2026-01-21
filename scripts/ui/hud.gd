extends CanvasLayer
class_name HUD
## Main heads-up display for Gravity Guardians
##
## Displays scores and fuel levels for both players at the bottom of the screen.
## Connects player displays to their respective ships.

# Node references
@onready var player1_display: PlayerDisplay = $Panel/MarginContainer/HBoxContainer/Player1Display
@onready var player2_display: PlayerDisplay = $Panel/MarginContainer/HBoxContainer/Player2Display
@onready var notification_label: Label = $NotificationLabel

# State variables
var is_showing_game_over: bool = false


func _ready() -> void:
	# Wait a frame for ships to register with GameState
	await get_tree().process_frame
	
	# Set up player displays with their ships
	setup_player_displays()
	
	# Listen for ship respawns to reconnect signals
	GameState.ship_respawned.connect(_on_ship_respawned)
	
	# Listen for game over
	GameState.game_over.connect(_on_game_over)
	
	print("HUD initialized")


func setup_player_displays() -> void:
	"""Connect player displays to their ships"""
	var ship1 = GameState.ships.get(1)
	var ship2 = GameState.ships.get(2)
	
	if ship1:
		player1_display.set_player_ship(ship1)
		# Connect to ship destroyed signal for notifications
		ship1.ship_destroyed.connect(_on_ship_destroyed)
	else:
		push_warning("Ship 1 not found in GameState")
	
	if ship2:
		player2_display.set_player_ship(ship2)
		# Connect to ship destroyed signal for notifications
		ship2.ship_destroyed.connect(_on_ship_destroyed)
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


func show_notification(message: String, duration: float = 2.0, persistent: bool = false) -> void:
	"""Display a centered notification message"""
	if not notification_label:
		return
	
	notification_label.text = message
	notification_label.visible = true
	notification_label.modulate.a = 1.0
	
	# If persistent, don't fade out (used for game over screen)
	if persistent:
		return
	
	# Fade out after duration
	await get_tree().create_timer(duration).timeout
	
	# Don't fade if we're now showing game over
	if is_showing_game_over:
		return
	
	# Animate fade out
	var tween := create_tween()
	tween.tween_property(notification_label, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	notification_label.visible = false


func _on_ship_destroyed(victim_id: int, killer_id: int) -> void:
	"""Show notification when a ship is destroyed"""
	# Don't show kill notifications during game over
	if is_showing_game_over:
		return
	
	# Determine death cause
	if victim_id == killer_id:
		# Self-destruction (terrain collision)
		show_notification("PLAYER %d CRASHED!" % victim_id, 2.0)
	else:
		# Check if it was fuel death by checking fuel level
		var victim_ship = GameState.ships.get(victim_id)
		if victim_ship and victim_ship.fuel <= 0.0:
			show_notification("PLAYER %d OUT OF FUEL!\nPLAYER %d SCORES!" % [victim_id, killer_id], 2.5)
		else:
			# Bullet kill
			show_notification("PLAYER %d DESTROYED!\nPLAYER %d SCORES!" % [victim_id, killer_id], 2.5)


func _on_game_over(winner_id: int) -> void:
	"""Display game over screen when a player wins"""
	is_showing_game_over = true
	var message := "PLAYER %d WINS!\n\nPress R to Restart" % winner_id
	show_notification(message, 0.0, true)
	print("Game over screen displayed - Player %d wins" % winner_id)


func hide_game_over_screen() -> void:
	"""Hide the game over screen (called on restart)"""
	is_showing_game_over = false
	if notification_label:
		notification_label.visible = false
	print("Game over screen hidden")
