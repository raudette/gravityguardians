extends Area2D
class_name Bullet
## Bullet projectile that travels in a straight line
##
## Bullets are NOT affected by gravity and despawn after a set lifetime.
## They damage ships on contact and are destroyed when hitting terrain.

# Export variables
@export var speed: float = 400.0
@export var lifetime: float = 4.0

# State variables
var velocity: Vector2 = Vector2.ZERO
var shooter_id: int = -1  # Which player shot this bullet

# Node references
@onready var lifetime_timer: Timer = $LifetimeTimer


func _ready() -> void:
	# Add to bullets group for easy cleanup
	add_to_group("bullets")
	
	# Start lifetime countdown
	lifetime_timer.wait_time = lifetime
	lifetime_timer.start()
	
	# Connect signals
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	print("Bullet spawned by Player %d" % shooter_id)


func _physics_process(delta: float) -> void:
	# Move bullet (NO GRAVITY - manual movement)
	position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	"""Handle collision with bodies (ships or terrain)"""
	# Check if we hit a ship
	if body is Ship:
		var ship := body as Ship
		# Don't hit our own ship
		if ship.player_id != shooter_id:
			print("Bullet from Player %d hit Player %d!" % [shooter_id, ship.player_id])
			ship.take_damage(shooter_id)
			queue_free()
	# Check if we hit terrain (layer 1)
	elif body.collision_layer & 1:
		print("Bullet hit terrain")
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	"""Handle collision with areas (landing pads, etc.)"""
	# Bullets don't interact with landing pads, just pass through
	pass


func _on_lifetime_timeout() -> void:
	"""Despawn bullet after lifetime expires"""
	print("Bullet despawned (lifetime expired)")
	queue_free()
