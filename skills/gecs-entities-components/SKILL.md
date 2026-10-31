---
name: gecs-entities-components
description: Use when designing GECS Entities (e_*.gd) or Components (c_*.gd) — Entity scene glue pattern, pure data components with @export, default _init arguments, spatial root casting, singleton alias handles, and reactive setters
---

# GECS Entities & Components in Godot 4.3+

Design decoupled data containers and spatial scene bridges using GECS v9. In ECS, **Entities** represent *identity and scene-tree integration*, while **Components** represent *pure data*.

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-core** for setup & basics, **gecs-systems** for processing logic, **gecs-queries** for filtering components, **gecs-observers** for reactive property change detection.

---

## 1. Design Principles: Entity Glue vs Component Data

| Trait | Entity (`e_*.gd` extends `Entity`) | Component (`c_*.gd` extends `Component`) |
|---|---|---|
| **Base Class** | `Entity` (inherits `Node`) | `Component` (inherits `Resource`) |
| **Role** | Glue between SceneTree and ECS World | Pure data container |
| **Methods** | Allowed: Node cache, lifecycle callbacks | **Forbidden:** zero game logic or behavior |
| **Node References** | Keeps references to child nodes (`Sprite2D`, `CollisionShape2D`, etc.) | **Never** store node references |
| **Persistence** | Instantiated via scenes or code | `@export` variables automatically serialized |
| **Queryable** | Grouped into archetypes | Used as archetype filter tokens |

---

## 2. Component Design Rules

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                       COMPONENT INVARIANTS IN GECS                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. Must extend Component (Resource).                                        │
│ 2. Must only contain data attributes (@export). Zero game logic methods.    │
│ 3. All arguments in _init() MUST have default values.                       │
│    Reason: GECS dynamically instantiates components during queries & load.  │
│ 4. Name with C_ prefix (e.g., class_name C_Health, c_health.gd).            │
│ 5. Use property setters emitting property_changed if observers watch it.    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Component Example with Reactive Setter (`c_health.gd`)
See template at [`examples/c_health.gd`](./examples/c_health.gd).

```gdscript
class_name C_Health
extends Component

## Maximum possible health points
@export var maximum: float = 100.0

## Current health points. Emits property_changed on change for observers.
@export var current: float = 100.0:
	set(new_value):
		var old_value := current
		current = clampf(new_value, 0.0, maximum)
		if not is_equal_approx(old_value, current):
			property_changed.emit(self, &"current", old_value, current)


func _init(max_hp: float = 100.0, cur_hp: float = -1.0) -> void:
	maximum = max_hp
	current = max_hp if cur_hp < 0.0 else cur_hp
```

---

## 3. Entity Design & The Scene Glue Pattern

An `Entity` bridges Godot's visual scene tree with the ECS world. It should act as **scene glue**: caching references to its own child nodes so systems can interact with the engine without searching the scene tree every frame.

### Entity Rules:
1. **Name with PascalCase entity name and `e_` prefix on script:** `Player` in `e_player.gd`.
2. **Implement `define_components()`:** Returns the default component array attached when spawned.
3. **Cache Child Nodes:** Use `@onready` variables for child components (`Sprite2D`, `AnimationPlayer`, `CollisionShape2D`).
4. **Lifecycle Hooks:**
   - `define_components() -> Array`: Returns initial component list.
   - `on_ready()`: Sync spatial state (e.g. `c_transform.transform = global_transform`).
   - `on_destroy()`: Trigger local cleanup before world removes the entity.
   - `on_enable()` / `on_disable()`: Entity pooling triggers.

### Entity Example with Scene Glue (`e_character.gd`)
See template at [`examples/e_character.gd`](./examples/e_character.gd).

```gdscript
class_name CharacterEntity
extends Entity

## Scene Glue: direct child node references cached locally
@onready var animation_player: AnimationPlayer = get_node_or_null(^"AnimationPlayer")
@onready var sprite: Sprite2D = get_node_or_null(^"Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node_or_null(^"CollisionShape2D")


func define_components() -> Array:
	return [
		C_Health.new(100.0),
		C_Velocity.new(Vector2.ZERO, 150.0)
	]


func on_ready() -> void:
	# Components are registered; sync visual nodes if needed
	pass


func on_destroy() -> void:
	# Prepare for deletion or return to pool
	pass
```

---

## 4. Entity Spatial Casting in Systems

`Entity extends Node`. Because Godot's GDScript static type checker enforces strict node hierarchies, follow these casting rules in systems:

### Rule 1: One Cast Covers Both ECS & Scene Root
When the scene root script extends `Entity` and is attached to a `Node2D` or `Node3D`, casting to your entity subclass gives access to both `get_component()` and spatial properties:

```gdscript
for i in entities.size():
	var character := entities[i] as CharacterEntity
	if character == null:
		continue
	# ECS API:
	var health := character.get_component(C_Health) as C_Health
	# Scene Glue API:
	var anims := character.animation_player
	# Node2D/Node3D API:
	character.global_position += Vector2.RIGHT * 10.0 * delta
```

### Rule 2: Sibling Casts Require Node Upcast
`Entity` and `CharacterBody3D` (or `CharacterBody2D`) are siblings under `Node`. A direct cast (`entity as CharacterBody3D`) returns null. Upcast to `Node` first:

```gdscript
# Sibling cast pattern
var node: Node = entities[i]
var body := node as CharacterBody2D
if body:
	body.velocity = vel.direction * vel.speed
	body.move_and_slide()
```

---

## 5. Entity Identifiers in v9: Generational Handles & Aliases

In GECS v9, entity IDs are **64-bit generational integers**, not v8 string UUIDs:

```gdscript
# 1. Inspecting handle
print("Entity handle: ", entity.id) # 0 before being added to World!

# 2. Singleton / Named Entities
# DO NOT set entity.id = "player" (Legacy v8)
entity.alias = &"player" # v9 correct

# 3. Looking up entities
var player = ECS.world.get_entity_by_alias(&"player")
var specific = ECS.world.get_entity_by_id(handle)

# 4. Checking if handle is alive (O(1) generational check)
if ECS.world.is_alive(handle):
	pass
```

---

## 6. Anti-Patterns & Fixes

### Anti-Pattern 1: Storing Child Nodes inside Components

```gdscript
# ❌ BAD: Storing engine Node references in Resource breaks serialization and cache
class_name C_Visual extends Component
@export var sprite: Sprite2D # Never store scene nodes in components!


# ✅ GOOD: Put node reference on Entity as Scene Glue; Component only stores pure data
class_name C_Visual extends Component
@export var texture_path: String = "res://icon.svg"
@export var modulate: Color = Color.WHITE
```

---

### Anti-Pattern 2: Missing Default Values in Component `_init`

```gdscript
# ❌ BAD: Crash when GECS instantiates component reflectively
class_name C_Stats extends Component
@export var attack: int

func _init(atk: int): # Crashes with "Too few arguments"
	attack = atk


# ✅ GOOD: All arguments have default fallback values
class_name C_Stats extends Component
@export var attack: int = 10

func _init(atk: int = 10):
	attack = atk
```

