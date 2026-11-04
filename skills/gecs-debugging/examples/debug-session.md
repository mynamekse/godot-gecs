# GECS Debug Session Example

## Diagnose an Empty Query

```gdscript
func debug_query() -> void:
    print("world: ", ECS.world != null)
    print("entities: ", ECS.world.entities.size())
    print("health entities: ", ECS.world.query.with_all([C_Health]).execute().size())

    for entity in ECS.world.entities:
        if entity:
            print(entity.name, ": health=", entity.has_component(C_Health))
```

## Diagnose a Missing System

- Confirm `ECS.process(delta, "gameplay")` runs while the game is alive.
- Sort/inspect the System in Explorer and verify active state, group and entity/archetype counts.
- Pause before the suspected System and step one System unit.
- Check the step log for `comp_*`, `entity_*`, `rel_*`, `prop_set`, `sweep_set` or `event` entries.

## Pause and Breakpoint

```gdscript
var world := ECS.world
world.debug_pause()
world.debug_set_sweep(true)
world.debug_add_breakpoint({ "kind": "system", "system_name": "CombatSystem" })
world.debug_resume()
```

When the breakpoint stops the game loop, open the entity/System/relationship view, inspect the cause column, then step by SYSTEM, ARCHETYPE or ENTITY to isolate the mutation or query transition.
