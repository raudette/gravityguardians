extends HBoxContainer
class_name PlayerDisplay
## Displays score and fuel for a single player
##
## Shows kill count progress (X/5) and fuel bar with low fuel warning.
## Connects to ship signals for real-time updates.

# Signals
signal fuel_critically_low(player_id: int)

# Export variables
@export var player_id: int = 1
@export var player_color: Color = Color.RED
@export var low_fuel_threshold: float = 25.0
@export var low_fuel_color: Color = Color(1.0, 0.42, 0.0)  # Orange

# State variables
var ship: Ship = null
var normal_fuel_color: Color

# Node references
@onready var score_label: Label = $ScoreLabel
@onready var fuel_container: VBoxContainer = $FuelContainer
@onready var fuel_label: Label = $FuelContainer/FuelLabel
@onready var fuel_bar: ProgressBar = $FuelContainer/FuelBar


func _ready() -> void:
	# Store normal fuel color
	normal_fuel_color = player_color
	
	# Initialize score label
	update_score_display(0)
	
	# Connect to GameState signals
	GameState.kill_scored.connect(_on_kill_scored)
	
	# Initialize with current score
	var current_kills := GameState.get_kills(player_id)
	update_score_display(current_kills)
	
	# Set up fuel bar
	fuel_bar.min_value = 0.0
	fuel_bar.max_value = 100.0
	fuel_bar.value = 100.0
	fuel_bar.show_percentage = false
	
	# Apply player color to UI elements
	apply_player_colors()


func set_player_ship(new_ship: Ship) -> void:
	"""Connect to a ship instance for fuel updates"""
	# Disconnect from old ship if exists
	if ship and is_instance_valid(ship):
		if ship.fuel_changed.is_connected(_on_fuel_changed):
			ship.fuel_changed.disconnect(_on_fuel_changed)
	
	ship = new_ship
	
	if ship:
		# Connect to new ship
		ship.fuel_changed.connect(_on_fuel_changed)
		
		# Initialize with current fuel
		_on_fuel_changed(ship.fuel, ship.max_fuel)
		
		print("PlayerDisplay %d connected to ship" % player_id)


func _on_fuel_changed(new_fuel: float, max_fuel: float) -> void:
	"""Update fuel bar when ship fuel changes"""
	var fuel_percentage := (new_fuel / max_fuel) * 100.0
	fuel_bar.value = fuel_percentage
	
	# Update fuel bar color based on threshold
	update_fuel_bar_color(fuel_percentage)


func _on_kill_scored(scored_player_id: int, new_kill_count: int) -> void:
	"""Update score display when any player scores"""
	if scored_player_id == player_id:
		update_score_display(new_kill_count)


func update_score_display(kills: int) -> void:
	"""Update the score label text"""
	score_label.text = "P%d: %d/%d" % [player_id, kills, GameState.KILLS_TO_WIN]


func update_fuel_bar_color(fuel_percentage: float) -> void:
	"""Change fuel bar color when fuel is low"""
	var target_color: Color
	
	if fuel_percentage <= low_fuel_threshold:
		target_color = low_fuel_color
		
		# Emit warning signal on first drop below threshold
		if fuel_bar.value > low_fuel_threshold:
			fuel_critically_low.emit(player_id)
	else:
		target_color = normal_fuel_color
	
	# Update fuel bar color via modulate
	fuel_bar.modulate = target_color


func apply_player_colors() -> void:
	"""Apply player color scheme to UI elements"""
	# Score label gets player color
	score_label.add_theme_color_override("font_color", player_color)
	
	# Fuel label stays white/light gray
	fuel_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	
	# Fuel bar starts with player color
	fuel_bar.modulate = player_color
