extends StaticBody2D
class_name LandingPad
## Landing pad that refuels ships when they land safely
##
## Detects soft landings (low velocity + upright orientation) and
## gradually refuels ships that meet the landing criteria.

# Export variables
@export var refuel_rate: float = 20.0  # fuel per second
@export var safe_landing_velocity: float = 50.0  # pixels/sec
@export var safe_landing_angle: float = 20.0  # degrees from upright

# State variables
var is_occupied: bool = false
var landing_ship: Ship = null
var ships_on_pad: Array[Ship] = []

# Node references
@onready var landing_zone: Area2D = $LandingZone
@onready var refuel_label: Label = $RefuelLabel


func _ready() -> void:
	# Connect signals
	landing_zone.body_entered.connect(_on_landing_zone_body_entered)
	landing_zone.body_exited.connect(_on_landing_zone_body_exited)
	
	# Hide refuel label initially
	if refuel_label:
		refuel_label.visible = false
	
	# Register with GameState
	GameState.register_landing_pad(self)
	
	print("Landing pad registered: %s at %s" % [name, global_position])


func _process(delta: float) -> void:
	# Refuel any ships that are safely landed
	for ship in ships_on_pad:
		if ship and is_instance_valid(ship) and ship.is_alive:
			if check_safe_landing(ship):
				# Ship is safely landed, refuel it
				ship.refuel(refuel_rate * delta)
				
				# Show refuel indicator
				if refuel_label:
					refuel_label.visible = true
			else:
				# Ship is on pad but not safely landed (moving too fast or tilted)
				if refuel_label:
					refuel_label.visible = false
	
	# Hide label if no ships on pad
	if ships_on_pad.is_empty() and refuel_label:
		refuel_label.visible = false


func _on_landing_zone_body_entered(body: Node2D) -> void:
	"""Detect when a ship enters the landing zone"""
	if body is Ship:
		var ship := body as Ship
		if ship not in ships_on_pad:
			ships_on_pad.append(ship)
			print("Ship %d entered landing pad: %s" % [ship.player_id, name])
			
			# Check if it's a safe landing
			if check_safe_landing(ship):
				print("Ship %d landed safely!" % ship.player_id)


func _on_landing_zone_body_exited(body: Node2D) -> void:
	"""Detect when a ship leaves the landing zone"""
	if body is Ship:
		var ship := body as Ship
		if ship in ships_on_pad:
			ships_on_pad.erase(ship)
			print("Ship %d left landing pad: %s" % [ship.player_id, name])


func check_safe_landing(ship: Ship) -> bool:
	"""Check if ship meets safe landing criteria"""
	if not ship or not is_instance_valid(ship) or not ship.is_alive:
		return false
	
	# Check velocity (must be slow)
	var velocity_magnitude: float = ship.linear_velocity.length()
	if velocity_magnitude > safe_landing_velocity:
		return false
	
	# Check orientation (must be upright within tolerance)
	var angle_degrees: float = rad_to_deg(ship.rotation)
	# Normalize angle to -180 to 180
	while angle_degrees > 180:
		angle_degrees -= 360
	while angle_degrees < -180:
		angle_degrees += 360
	
	var angle_from_upright: float = abs(angle_degrees)
	if angle_from_upright > safe_landing_angle:
		return false
	
	return true


func is_available() -> bool:
	"""Check if pad is available for respawning (not occupied)"""
	# Pad is available if no ships are currently on it
	return ships_on_pad.is_empty()


func get_spawn_position() -> Vector2:
	"""Get the position where ships should spawn on this pad"""
	# Spawn slightly above the pad
	return global_position - Vector2(0, 40)
