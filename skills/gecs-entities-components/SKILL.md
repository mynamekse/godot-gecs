---
name: gecs-entities-components
description: Use when designing GECS entities and pure-data component resources, scene glue, component configuration, naming, lifecycle hooks, or aliases.
---

# GECS Entities and Components

## Components

Components extend `Component` and contain exported data only. `_init()` parameters must all have default values because GECS may instantiate components reflectively.

```gdscript
class_name C_Health
extends Component

@export var current: float = 100.0
@export var maximum: float = 100.0

func _init(max_health: float = 100.0) -> void:
    maximum = max_health
    current = max_health
```

Never put movement, damage, death, or other gameplay behavior in a Component. Keep engine resources and Node references out of Components unless the project's serialization contract explicitly permits scene glue elsewhere.

## Entities

Prefer composition over inheritance. Add components through `define_components()`, Inspector `component_resources`, or world creation APIs.

```gdscript
class_name Player
extends Entity

func define_components() -> Array:
    return [C_Health.new(100), C_Velocity.new()]
```

Use scene-based Entities only when child Nodes are genuinely needed as spatial or visual glue. Systems synchronize data between Components and scene Nodes.

## Naming and organization

- Components: `C_Health`, file `c_health.gd`
- Entities: `Player`, file `e_player.gd`
- Systems: `MovementSystem`, file `s_movement.gd`
- Keep folders grouped by gameplay concern

## v9 identity

- Use integer `entity.id` as identity.
- Use `entity.alias = &"player"` only as a lookup name.
- Do not rely on insertion order after removals; world removal uses swap-remove semantics.

Reference: `docs/CORE_CONCEPTS.md`, `docs/BEST_PRACTICES.md`, `docs/MIGRATION_V9.md`
