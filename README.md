# 🚀 Gravity Guardians

A 2-player physics-based combat game inspired by Gravity Force 2 (Amiga). Battle your opponent in a side-scrolling arena where gravity pulls your ship down, fuel is limited, and precision flying is key to victory!

## 🎮 Game Overview

**Genre**: 2D Physics Combat  
**Players**: 2 (Local Multiplayer)  
**Engine**: Godot 4.x  
**Controls**: Keyboard

## 📋 Game Rules

- **Objective**: First player to achieve 5 kills wins
- **Ships**: Physics-based with rotation and thrust controls
- **Gravity**: Constantly pulls ships downward (but NOT bullets!)
- **Fuel System**: Limited fuel depletes during thrust
- **Landing Pads**: Land safely to refuel your ship
- **Combat**: Shoot your opponent while managing fuel and gravity
- **Respawn**: Ships respawn on random landing pads after destruction

## 🕹️ Controls

### Player 1
- **W**: Thrust
- **A**: Rotate Counter-Clockwise
- **D**: Rotate Clockwise
- **Space**: Shoot

### Player 2
- **Up Arrow**: Thrust
- **Left Arrow**: Rotate Counter-Clockwise
- **Right Arrow**: Rotate Clockwise
- **Enter**: Shoot

### General
- **R**: Restart game (after game over)

## 🎯 Gameplay Mechanics

### Ship Physics
- Gravity constantly pulls ships downward at 980 pixels/sec²
- Thrust applies force in the ship's facing direction
- Fuel depletes at 10 units/sec while thrusting (10 seconds total)
- Out of fuel = no thrust (but can still rotate and shoot)
- Ships have slight air resistance for realistic feel

### Landing System
- **Soft Landing Required**: Ship must be moving slowly (< 50 px/sec) and upright (±20°)
- Landing pads refuel ships at 20 units/sec (5 seconds for full tank)
- Ships spawn on landing pads at game start
- After destruction, ships respawn on random available pads

### Combat
- Bullets travel in straight lines (NO gravity effect)
- Bullets inherit ship's velocity + bullet speed
- Shooting cooldown: 0.4 seconds
- Bullet lifetime: 4 seconds before despawning
- Hit detection: Bullet vs ship collision = kill
- Brief invulnerability after respawn (2 seconds)

### Death Conditions
- Hit by enemy bullet → Killer gets +1 kill
- Collision with terrain (any speed) → Death (no kill points awarded)
- Self-destruction → No kill points awarded

### Win Condition
- First player to reach 5 kills wins
- Game over screen displays winner
- Press R to restart match

## 📁 Project Structure

```
gravityguardians/
├── project.godot              # Godot 4.x project configuration
├── AGENTS.md                  # AI development guide
├── README.md                  # This file
│
├── scenes/                    # Scene files (.tscn)
│   ├── main.tscn              # Main game scene
│   ├── player/                # Player ship scenes
│   ├── weapons/               # Bullet scenes
│   ├── environment/           # Landing pads, terrain
│   └── ui/                    # HUD and game over screen
│
├── scripts/                   # GDScript files (.gd)
│   ├── player/                # Ship logic
│   ├── weapons/               # Bullet behavior
│   ├── environment/           # Landing pad logic
│   ├── core/                  # Game manager, camera
│   └── ui/                    # UI controllers
│
├── autoload/                  # Global singletons
│   └── game_state.gd          # Game state management
│
└── assets/                    # Art and audio
    └── sprites/
        └── placeholders/      # Placeholder sprites
```

## 🛠️ Development Status

### ✅ Phase 1: Project Foundation (COMPLETE)
- [x] Godot 4.x project initialized
- [x] Folder structure created
- [x] Input mapping configured (both players)
- [x] Collision layers set up
- [x] Physics settings configured (gravity: 980 px/s²)
- [x] GameState singleton created

### ✅ Phase 2: Placeholder Assets (COMPLETE)
- [x] Ship sprites (red/blue triangles)
- [x] Bullet sprite (circle)
- [x] Landing pad sprite (green rectangle)
- [x] Terrain texture

### ✅ Phase 3: Ship Implementation (COMPLETE)
- [x] RigidBody2D physics with gravity
- [x] Rotation and thrust controls
- [x] Fuel management system
- [x] Terrain collision detection
- [x] Visual thrust particles
- [x] Player-specific sprites

### ✅ Phase 4: Combat System (COMPLETE)
- [x] Bullet spawning and shooting
- [x] Bullet physics (NO gravity!)
- [x] Bullet lifetime (4 seconds)
- [x] Shooting cooldown (0.4 sec)
- [x] Hit detection and kill system
- [x] Ship death and respawn

### ✅ Phase 5: Landing Pads (COMPLETE)
- [x] Safe landing detection (velocity + angle)
- [x] Gradual refueling (20 units/sec)
- [x] Visual refueling indicator
- [x] Multi-ship support
- [x] Spawn position management

### ✅ Phase 6: Game Manager & Scoring (COMPLETE)
- [x] Kill tracking (first to 5 wins)
- [x] Win condition checking
- [x] Random pad respawn system
- [x] Post-respawn invulnerability (2 sec)
- [x] Self-destruction handling
- [x] Complete game flow

### ✅ PLAYABLE PROTOTYPE READY!
**The game is now fully functional with all core mechanics!**

### 📅 Upcoming Phases
- Phase 7: Level Design (enhanced terrain)
- Phase 8: Camera System (dual-ship tracking)
- Phase 9: UI Implementation (HUD, game over screen)
- Phase 10: Polish & Balance (effects, tuning)
- Phase 11: Testing & Refinement

## 🎨 Art Style

Currently using simple geometric placeholder sprites:
- **Ships**: Triangular shapes (red for P1, blue for P2)
- **Bullets**: Small circles
- **Landing Pads**: Green rectangles
- **Terrain**: Gray polygons

## ⚙️ Technical Specifications

### Physics Parameters
- **Gravity**: 980 pixels/sec² (downward)
- **Thrust Force**: 500 N
- **Rotation Speed**: 180°/sec
- **Max Velocity**: 600 pixels/sec

### Fuel System
- **Max Fuel**: 100 units
- **Consumption Rate**: 10 units/sec (10 sec max thrust)
- **Refuel Rate**: 20 units/sec (5 sec to refill)

### Combat Parameters
- **Bullet Speed**: 400 pixels/sec
- **Bullet Lifetime**: 4 seconds
- **Shooting Cooldown**: 0.4 seconds
- **Respawn Invulnerability**: 2 seconds

### Collision Layers
1. **Terrain**: Static world geometry
2. **Ships**: Player ships
3. **Bullets**: Projectiles
4. **Landing Pads**: Refueling stations

## 🚀 Running the Game

### Prerequisites
- Godot Engine 4.x installed
- Git (optional, for version control)

### Instructions
1. Open Godot Engine 4.x
2. Click "Import" and navigate to this project folder
3. Select `project.godot`
4. Click "Import & Edit"
5. Press F5 or click "Run Project" to start the game

Alternatively, run from command line:
```bash
godot --path . --debug
```

## 🧪 Testing

Run tests (if using GUT framework):
```bash
godot --path . -s addons/gut/gut_cmdln.gd
```

## 📝 Code Style

This project follows the [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html). See `AGENTS.md` for detailed coding conventions.

## 🐛 Known Issues

None currently identified. Core mechanics are functional and tested.

## 🔮 Future Enhancements

- Audio system (sound effects for thrust, shooting, explosions)
- Better visual effects (particles, explosions)
- Multiple level layouts
- Power-ups (shields, fuel boosts, rapid fire)
- AI opponent for single-player
- Menu system
- Online multiplayer

## 📄 License

This project is for educational/personal use.

## 🙏 Credits

Inspired by **Gravity Force 2** (Jens Andersson, Kingsoft, 1993)

---

**Status**: ✅ Playable Prototype (Phases 1-6 Complete)  
**Version**: 0.3.0-alpha  
**Last Updated**: January 18, 2026  
**See**: `IMPLEMENTATION_SUMMARY.md` for detailed build notes
