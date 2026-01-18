extends RigidBody2D
class_name Ship
## Player ship with thrust, rotation, shooting, and fuel management
##
## Handles physics-based movement, fuel consumption, combat,
## and respawning mechanics for the player ship.

# Signals
signal fuel_changed(new_fuel: float, max_fuel: float)
signal ship_destroyed(victim_id: int, killer_id: int)

# Export variables
@export var player_id: int = 1  # 1 or 2
@export var thrust_force: float = 1500.0
@export var rotation_speed: float = 180.0  # degrees per second
@export var max_fuel: float = 100.0
@export var fuel_consumption_rate: float = 10.0  # per second
@export var shoot_cooldown: float = 0.4
@export var max_velocity: float = 600.0

# State variables
var fuel: float = 100.0
var can_shoot: bool = true
var is_invulnerable: bool = false
var is_alive: bool = true

# Input action names (set in _ready based on player_id)
var input_thrust: String = ""
var input_rotate_ccw: String = ""
var input_rotate_cw: String = ""
var input_shoot: String = ""

# Preloaded scenes
const Bullet := preload("res://scenes/weapons/bullet.tscn")

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var shoot_point: Marker2D = $ShootPoint
@onready var thrust_particles: CPUParticles2D = $ThrustParticles
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer
@onready var shoot_cooldown_timer: Timer = $ShootCooldownTimer


func _ready() -> void:
	# Set up input action names
	input_thrust = "p%d_thrust" % player_id
	input_rotate_ccw = "p%d_rotate_ccw" % player_id
	input_rotate_cw = "p%d_rotate_cw" % player_id
	input_shoot = "p%d_shoot" % player_id
	
	# Load correct sprite for player
	if sprite and player_id == 2:
		sprite.texture = load("res://assets/sprites/placeholders/ship_p2.svg")
	
	# Initialize fuel
	fuel = max_fuel
	fuel_changed.emit(fuel, max_fuel)
	
	# Register with GameState
	GameState.register_ship(player_id, self)
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	invulnerability_timer.timeout.connect(_on_invulnerability_timeout)
	shoot_cooldown_timer.timeout.connect(_on_shoot_cooldown_timeout)
	GameState.ship_respawned.connect(_on_ship_respawned)
	
	print("Ship %d initialized at position %s" % [player_id, global_position])


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# Handle rotation
	var rotate_input := 0.0
	if Input.is_action_pressed(input_rotate_ccw):
		rotate_input -= 1.0
	if Input.is_action_pressed(input_rotate_cw):
		rotate_input += 1.0
	
	# Apply rotation using angular velocity (works with RigidBody2D physics)
	if rotate_input != 0.0:
		angular_velocity = deg_to_rad(rotation_speed) * rotate_input
	else:
		angular_velocity = 0.0  # Stop rotation when no input
	
	# Handle thrust
	var is_thrusting := false
	if Input.is_action_pressed(input_thrust) and fuel > 0.0:
		is_thrusting = true
		# Apply thrust force in facing direction
		var thrust_direction := Vector2.UP.rotated(rotation)
		apply_central_force(thrust_direction * thrust_force)
		
		# Consume fuel
		fuel = max(0.0, fuel - fuel_consumption_rate * delta)
		fuel_changed.emit(fuel, max_fuel)
	
	# Visual thrust feedback
	if thrust_particles:
		thrust_particles.emitting = is_thrusting
	
	# Handle shooting
	if Input.is_action_just_pressed(input_shoot) and can_shoot:
		shoot()
	
	# Clamp velocity to max speed
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
	
	# Visual invulnerability feedback (flashing)
	if sprite and is_invulnerable:
		sprite.modulate.a = 0.5 + sin(Time.get_ticks_msec() * 0.01) * 0.3


func shoot() -> void:
	"""Spawn a bullet from the ship"""
	if not is_alive:
		return
	
	var bullet := Bullet.instantiate()
	get_tree().root.add_child(bullet)
	
	# Position bullet at shoot point
	bullet.global_position = shoot_point.global_position
	
	# Calculate bullet velocity (ship velocity + bullet speed in facing direction)
	var shoot_direction := Vector2.UP.rotated(rotation)
	bullet.velocity = linear_velocity + shoot_direction * bullet.speed
	bullet.shooter_id = player_id
	bullet.rotation = rotation
	
	# Start cooldown
	can_shoot = false
	shoot_cooldown_timer.start(shoot_cooldown)
	
	print("Player %d fired!" % player_id)


func take_damage(killer_id: int) -> void:
	"""Called when ship is hit by a bullet"""
	if not is_alive or is_invulnerable:
		return
	
	print("Player %d destroyed by Player %d" % [player_id, killer_id])
	die(killer_id)


func die(killer_id: int = -1) -> void:
	"""Handle ship destruction"""
	if not is_alive:
		return
	
	is_alive = false
	visible = false
	set_physics_process(false)
	
	# Determine killer (terrain = self-destruction)
	var actual_killer := killer_id if killer_id > 0 else player_id
	
	# Emit death signal
	ship_destroyed.emit(player_id, actual_killer)
	
	# Report to game state
	GameState.report_kill(actual_killer, player_id)
	
	# Request respawn after short delay
	await get_tree().create_timer(1.0).timeout
	GameState.respawn_ship(player_id)


func respawn(spawn_position: Vector2) -> void:
	"""Respawn ship at given position"""
	print("Player %d respawning at %s" % [player_id, spawn_position])
	
	# Reset state
	global_position = spawn_position
	rotation = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	fuel = max_fuel
	fuel_changed.emit(fuel, max_fuel)
	
	# Enable invulnerability
	is_invulnerable = true
	invulnerability_timer.start(2.0)
	
	# Re-enable ship
	is_alive = true
	visible = true
	set_physics_process(true)
	
	# Reset sprite opacity
	if sprite:
		sprite.modulate.a = 1.0


func refuel(amount: float) -> void:
	"""Add fuel to the ship (called by landing pad)"""
	if not is_alive:
		return
	
	var old_fuel := fuel
	fuel = min(max_fuel, fuel + amount)
	
	if fuel != old_fuel:
		fuel_changed.emit(fuel, max_fuel)


func _on_body_entered(body: Node) -> void:
	"""Handle collision with terrain (instant death)"""
	if not is_alive or is_invulnerable:
		return
	
	# Check if we hit terrain (layer 1)
	if body.collision_layer & 1:  # Terrain layer
		print("Player %d hit terrain!" % player_id)
		die(player_id)  # Self-destruction, no kill points


func _on_invulnerability_timeout() -> void:
	"""End invulnerability period"""
	is_invulnerable = false
	if sprite:
		sprite.modulate.a = 1.0
	print("Player %d invulnerability ended" % player_id)


func _on_shoot_cooldown_timeout() -> void:
	"""Re-enable shooting after cooldown"""
	can_shoot = true


func _on_ship_respawned(respawned_player_id: int, spawn_position: Vector2) -> void:
	"""Handle respawn signal from GameState"""
	if respawned_player_id == player_id:
		respawn(spawn_position)


func get_fuel_percentage() -> float:
	"""Get fuel as percentage (0-100)"""
	return (fuel / max_fuel) * 100.0
