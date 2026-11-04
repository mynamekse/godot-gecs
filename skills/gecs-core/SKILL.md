---
name: gecs-core
description: Implement and review GECS core GDScript architecture. Use for Component, System, QueryBuilder, CommandBuffer logic, naming conventions, save/load, and migration to GECS v9.
---

# GECS Core

Use the GECS documentation as the source of truth. Do not add undocumented APIs. Verify installed-project conventions when call signatures differ from examples.

## Source Documents

- `docs/GETTING_STARTED.md`
- `docs/CORE_CONCEPTS.md`
- `docs/BEST_PRACTICES.md`
- `docs/COMPONENT_QUERIES.md`
- `docs/SERIALIZATION.md`
- `docs/MIGRATION_V9.md`

## Activation Scope

Use this skill for:

- Component and System design or implementation
- QueryBuilder, property queries, groups, relationships, iteration
- Structural changes and `CommandBuffer`
- GECS naming and folder organization
- Save/load and selective serialization
- GECS v8-to-v9 migration

## Workflow

1. Identify independent varying data; represent each item as a data-only Component.
2. Keep gameplay behavior in one-responsibility Systems.
3. Delegate Entity SceneTree roots, prefabs, spawning, lifecycle and removal to the `gecs-entities` skill.
4. Declare the System query in `query()` and use `iterate()` only when batch component columns help.
5. Queue structural mutations through `cmd` during iteration.
6. Configure system groups/dependencies for deterministic processing order.
7. Add serialization exports and migration checks only for data that must persist.

## Core Rules

- Components extend `Component`, contain data, and expose persisted state with `@export`.
- Component constructor parameters must have default values.
- Component class names use `C_ClassName`; files usually use `c_snake_case.gd`.
- System class names usually end in `System`; files usually use `s_snake_case.gd`.
- Use `gecs-entities` for Entity class/file names, SceneTree roots, prefab registration and lifecycle ownership.
- Use Component classes in queries. Use Component instances to construct or add data.
- Do not execute `.from(...)` queries in `System.query()`, `sub_systems()`, `Observer.query()` or `sub_observers()`.

## Minimal Setup

```gdscript
extends Node

@onready var world: World = $World

func _ready() -> void:
    ECS.world = world

func _process(delta: float) -> void:
    ECS.process(delta)
```

## System Template

```gdscript
class_name MovementSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_Position, C_Velocity]).with_none([C_Frozen])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    for entity in entities:
        var position := entity.get_component(C_Position)
        var velocity := entity.get_component(C_Velocity)
        position.value += velocity.value * delta
```

## CommandBuffer

Use `cmd` for structural mutations during iteration:

```gdscript
cmd.add_component(entity, C_Dead.new())
cmd.remove_component(entity, C_Health)
cmd.remove_entity(entity)
```

GECS v9 deferred iteration makes direct structural mutation inside `process()` unsafe for forward iteration unless the System explicitly opts into copying behavior.

## Queries

```gdscript
q.with_all([C_Player, C_Health])
q.with_any([C_Player, C_Enemy])
q.with_none([C_Dead])
q.with_all([{ C_Health: { "current": { "_lt": 20.0 } } }])
q.enabled()
q.with_relationship([relationship])
q.iterate([C_Position, C_Velocity])
```

Property operators include `_eq`, `_ne`, `_gt`, `_lt`, `_gte`, `_lte`, `_in`, `_nin`, and `func`. Property queries are not supported with `with_none`; exclude Component types instead.

## Serialization

```gdscript
var query := ECS.world.query.with_all([C_Persistent])
var data := ECS.serialize(query)
ECS.save(data, "user://savegame.tres", true)

var entities := ECS.deserialize("user://savegame.tres")
for entity in entities:
    ECS.world.add_entity(entity)
```

Before changing serialization, distinguish runtime Node references from resource-safe exported data and decide relationship inclusion explicitly.

## GECS v9 Checklist

- Entity ID and alias migration belongs to the `gecs-entities` skill.
- Route structural mutation through `cmd` during iteration.
- Call `world.compact()` only at quiet points to reclaim retained empty archetypes.
- Use `changed([C_Type])` only with setters that emit `property_changed`, or `mark_changed(component)` for direct mutations.

## References

- [Entity SceneTree and lifecycle skill](../gecs-entities/SKILL.md)
- [Core API summary](references/core-api.md)
- [Implementation example](examples/basic-system.md)
