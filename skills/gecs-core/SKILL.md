---
name: gecs-core
description: Use when setting up GECS, wiring the ECS singleton and World, creating the first Entity/Component/System, or applying the v9 foundational lifecycle rules in Godot 4.3+.
---

# GECS Core

Use this skill for project setup and the first working ECS loop.

## Rules

1. Enable the GECS addon and expose the ECS singleton as an Autoload.
2. Assign the World to `ECS.world` before processing systems.
3. Call `ECS.process(delta, group)` or `world.process(delta, group)` from the expected Godot loop.
4. Add entities through `ECS.world.add_entity(entity)` or `add_entity(entity, components)`.
5. Never call `add_child(entity)` before `add_entity`; the World owns entity placement.
6. Entities hold data, systems hold behavior.
7. In GECS v9, entity identity is an integer handle; aliases are names, not identities.

## Minimal setup

```gdscript
extends Node

@onready var world: World = $World

func _ready() -> void:
    ECS.world = world

func _process(delta: float) -> void:
    ECS.process(delta)
```

## First implementation path

- Create a data-only `Component` Resource.
- Create an `Entity` subclass or scene Entity root and implement `define_components()` when needed.
- Add components before or during `world.add_entity(...)`.
- Create a `System` with `query()` and `process(...)`.
- Register systems in scene hierarchy and choose explicit processing groups.
- Add entities only after the World is assigned.

## Reference docs

- `docs/GETTING_STARTED.md`
- `docs/CORE_CONCEPTS.md`
- `docs/BEST_PRACTICES.md`
- `docs/MIGRATION_V9.md`
