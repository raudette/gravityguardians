# AGENTS.md - Gravity Guardians Development Guide

This document provides essential information for AI coding agents working on the Gravity Guardians Godot project.

## Project Overview

Gravity Guardians is a game built with Godot Engine using GDScript. This guide ensures consistency and quality across all code contributions.

## Build, Run, and Test Commands

### Running the Game
```bash
# Run the project from command line
godot --path . --debug

# Export the project (requires export template)
godot --export "Linux/X11" ./build/gravityguardians.x86_64
godot --export "Windows Desktop" ./build/gravityguardians.exe
```

### Testing
```bash
# Run all tests (if using GUT - Godot Unit Testing)
godot --path . -s addons/gut/gut_cmdln.gd

# Run a single test file
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_player.gd

# Run a specific test method
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/test_player.gd -gunit_test_name=test_player_movement
```

### Linting/Static Analysis
```bash
# Use gdlint if available (install with: pip install gdtoolkit)
gdlint scripts/**/*.gd

# Format code with gdformat
gdformat scripts/**/*.gd

# Check specific file
gdlint scripts/player/player.gd
```

## Project Structure

```
/
├── project.godot          # Project configuration
├── scenes/                # .tscn scene files
├── scripts/               # .gd script files
├── assets/                # Art, audio, fonts
│   ├── sprites/
│   ├── audio/
│   └── fonts/
├── resources/             # .tres resource files
├── addons/                # Plugins and extensions
├── tests/                 # Unit tests (if using GUT)
└── autoload/              # Autoload singletons
```

## Code Style Guidelines

### File Organization

1. **Script Template**
```gdscript
extends Node
## Brief description of what this script does
##
## Detailed description if needed.
## Can span multiple lines.

# Signals
signal health_changed(new_health: int)
signal died

# Enums
enum State {IDLE, MOVING, ATTACKING}

# Constants
const MAX_SPEED := 200.0
const JUMP_FORCE := 400.0

# Exported variables (Inspector-visible)
@export var speed: float = 100.0
@export var health: int = 100

# Public variables
var velocity := Vector2.ZERO
var current_state: State = State.IDLE

# Private variables (prefixed with underscore)
var _timer: float = 0.0
var _is_ready: bool = false

# Onready variables
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
    pass


func _process(delta: float) -> void:
    pass


# Public methods
func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)
    if health <= 0:
        die()


func die() -> void:
    died.emit()
    queue_free()


# Private methods (prefixed with underscore)
func _calculate_movement(delta: float) -> Vector2:
    return Vector2.ZERO
```

### Naming Conventions

- **Files**: `snake_case.gd` (e.g., `player_controller.gd`, `enemy_spawner.gd`)
- **Classes**: `PascalCase` (e.g., `class_name PlayerController`)
- **Functions**: `snake_case` (e.g., `func calculate_damage()`)
- **Variables**: `snake_case` (e.g., `var player_health: int`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `const MAX_HEALTH := 100`)
- **Signals**: `snake_case` (e.g., `signal player_died`)
- **Enums**: `PascalCase` for enum name, `UPPER_SNAKE_CASE` for values
- **Private**: Prefix with underscore (e.g., `var _internal_state`, `func _update_internal()`)

### Type Hints

Always use type hints for better code clarity and error detection:

```gdscript
# Variables
var health: int = 100
var name: String = "Player"
var items: Array[Item] = []
var position: Vector2 = Vector2.ZERO

# Function parameters and return types
func calculate_damage(base_damage: int, multiplier: float) -> int:
    return int(base_damage * multiplier)

# Use inferred typing with := when type is obvious
const SPEED := 100.0  # inferred as float
var velocity := Vector2.ZERO  # inferred as Vector2
```

### Imports and Dependencies

```gdscript
# Use class_name to make scripts globally accessible
class_name Player
extends CharacterBody2D

# Preload resources at the top (after class_name)
const Bullet := preload("res://scenes/bullet.tscn")
const DamageEffect := preload("res://scripts/damage_effect.gd")
```

### Comments and Documentation

```gdscript
## Use double-hash for documentation comments (shows in editor)
## This function calculates the player's damage based on stats.
func calculate_damage(base: int) -> int:
    # Use single-hash for implementation comments
    # Apply strength modifier
    var modified_damage := base * strength_modifier
    return int(modified_damage)
```

### Error Handling

```gdscript
# Check for null/invalid states
func get_target() -> Node:
    var target := get_node_or_null("../Target")
    if target == null:
        push_error("Target node not found")
        return null
    return target

# Use assert for debugging (removed in release builds)
func set_health(value: int) -> void:
    assert(value >= 0, "Health cannot be negative")
    health = value

# Validate input parameters
func deal_damage(amount: int) -> void:
    if amount < 0:
        push_warning("Damage amount should be positive")
        return
    health -= amount
```

### Signals and Callbacks

```gdscript
# Define signals at the top
signal health_changed(new_health: int, max_health: int)
signal item_collected(item: Item)

# Connect in _ready
func _ready() -> void:
    health_changed.connect(_on_health_changed)
    $Button.pressed.connect(_on_button_pressed)

# Use _on prefix for signal handlers
func _on_health_changed(new_health: int, max_health: int) -> void:
    print("Health: %d/%d" % [new_health, max_health])

func _on_button_pressed() -> void:
    print("Button pressed")
```

## Best Practices

1. **Prefer composition over inheritance** - Use Node composition when possible
2. **Use static typing** - Always use type hints for better performance and error detection
3. **Keep scenes small** - Break complex scenes into smaller subscenes
4. **Use autoloads sparingly** - Only for truly global systems
5. **Avoid circular dependencies** - Restructure code if circular references occur
6. **Test edge cases** - Especially for physics and input handling
7. **Use @export for tweakable values** - Make variables adjustable in the Inspector
8. **Profile before optimizing** - Use Godot's built-in profiler
9. **Handle cleanup** - Use `queue_free()` and disconnect signals properly
10. **Version control scenes as text** - Set project.godot to use text-based scene format

## Common Patterns

### Singleton Pattern (Autoload)
```gdscript
# autoload/game_manager.gd
extends Node

var score: int = 0
var player: Player = null

func add_score(amount: int) -> void:
    score += amount

# Access via: GameManager.add_score(10)
```

### State Machine
```gdscript
enum State {IDLE, WALK, JUMP, FALL}
var current_state: State = State.IDLE

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            _handle_idle(delta)
        State.WALK:
            _handle_walk(delta)
```

## Resources

- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)
- [GUT Testing Framework](https://github.com/bitwes/Gut)
