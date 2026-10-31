---
name: gecs-world-architecture
description: Use when setting up GECS World architecture, execution groups (run-first, input, gameplay, physics, ui, debug, run-last), scene tree layout, level switching, world.compact(), and world.purge()
---

# GECS World Architecture in Godot 4.3+

Structure production Godot projects using GECS v9 World and System Groups. The `World` coordinates system execution orders, manages archetype caches, controls generational IDs, and handles level transitions via `compact()` and `purge()`.

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-core** for setup, **gecs-systems** for system authoring, **gecs-performance** for archetype compaction.

---

## 1. Recommended Scene Architecture

Separate your systems, visual levels, and entities into a clean node structure:

```text
Main.tscn
├── World (World)                         ← Active GECS World
│   └── Systems (Node)
│       ├── run-first (SystemGroup)       ← Initialization & input reset
│       ├── input     (SystemGroup)       ← Player input collection
│       ├── gameplay  (SystemGroup)       ← Movement, weapons, AI, combat
│       ├── physics   (SystemGroup)       ← Physics resolution & collision
│       ├── ui        (SystemGroup)       ← UI sync & HUD updates
│       ├── debug     (SystemGroup)       ← Gizmos & debug text
│       └── run-last  (SystemGroup)       ← PendingDelete cleanup & actions
├── Level (Node3D/Node2D)                 ← Tilemaps, terrain, static geometry
└── Entities (Node3D/Node2D)              ← Entities spawned into the world
```

---

## 2. Process Group Execution Loop

Instead of ticking all systems uniformly in `_process()`, split execution by domain between `_process` and `_physics_process`:

```gdscript
extends Node

@onready var world: World = $World

func _ready() -> void:
	ECS.world = world

func _process(delta: float) -> void:
	world.process(delta, "run-first")
	world.process(delta, "input")
	world.process(delta, "gameplay")
	world.process(delta, "ui")
	world.process(delta, "run-last")

func _physics_process(delta: float) -> void:
	world.process(delta, "physics")
	world.process(delta, "debug")
```

---

## 3. Level Switching & Memory Management

In GECS v9, empty archetypes are **retained** during gameplay to ensure archetype transition graphs remain warm. During level changes, reclaim memory explicitly:

### 1. `world.compact()`
Reclaims empty, unused archetypes and resets archetype transition edges.
* **When to call:** Between levels, after major entity despawns, or during loading screens.

### 2. `world.purge()`
Instantly removes and cleans up all entities from the world.
* **When to call:** When unloading a game level or resetting to the main menu.

### Level Transition Pattern:
```gdscript
func load_new_level(level_scene: PackedScene) -> void:
	# 1. Purge all existing ECS entities
	ECS.world.purge()

	# 2. Compact archetypes to reclaim memory
	ECS.world.compact()

	# 3. Swap level scene tree nodes
	current_level_instance.queue_free()
	current_level_instance = level_scene.instantiate()
	add_child(current_level_instance)
```

