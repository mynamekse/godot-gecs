---
name: gecs-systems
description: Use when implementing GECS systems, processing groups, tick rates, SoA iteration, sub-systems, dependency ordering, or deferred structural changes with CommandBuffer.
---

# GECS Systems

## Standard shape

```gdscript
class_name MovementSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_Position, C_Velocity])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    for entity in entities:
        var velocity = entity.get_component(C_Velocity) as C_Velocity
        var position = entity.get_component(C_Position) as C_Position
        position.value += velocity.value * delta
```

## Structural mutation

Never mutate entity/component/relationship structure directly during an iteration loop unless a system intentionally opts into safe copying. Use `cmd` for deferred mutations.

```gdscript
cmd.remove_entity(entity)
cmd.add_component(entity, C_Stunned.new())
cmd.remove_component(entity, C_Burning)
```

## v9 rules

- Deferred iteration is the default; do not assume zero-copy arrays are mutation-safe.
- Prefer `iterate()` for whole-column batching when high entity counts are involved.
- Use `set_tick_rate()` or `SystemTimer` patterns for throttled work.
- Coalesce related state transitions into one CommandBuffer flush where possible.
- Keep each System focused on one responsibility.

## Processing order

Use explicit groups such as `run-first`, `input`, `gameplay`, `physics`, `ui`, `debug`, and `run-last` only when they exist in the host project.

Reference: `docs/BEST_PRACTICES.md`, `docs/CORE_CONCEPTS.md`, `docs/MIGRATION_V9.md`
