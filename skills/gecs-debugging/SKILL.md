---
name: gecs-debugging
description: Diagnose GECS failures and inspect ECS execution. Use when systems do not run, queries return empty, components are missing, observers are silent, debug mode or the viewer fails, or stepping/breakpoints are needed.
---

# GECS Debugging

Start with the smallest observation that separates World setup, query matching, System activation, mutation, and debugger transport.

## Activation Scope

- World/ECS singleton setup
- Empty queries
- Missing components or null lookups
- Systems not running or wrong execution group
- Observer no-fire and duplicate-fire issues
- Debug Viewer connection and live values
- Breakpoints and stepping
- Snapshot export/restore behavior

## Entity Routing

For prefab root errors, spawn registration, lifecycle callbacks and removal/pooling state, route to the `gecs-entities` skill. Keep this skill focused on diagnosing runtime state, debugger transport, breakpoints and step execution.

## Source Documents

- `docs/TROUBLESHOOTING.md`
- `docs/DEBUG_VIEWER.md`
- `docs/STEP_DEBUGGER.md`

## First Diagnosis

```gdscript
# Verify World and processing loop
if ECS.world:
    ECS.process(delta)

# Verify Entity membership
print(ECS.world.entities.size())
print(entity.has_component(C_Health))
print(entity.get_component(C_Health))
print(ECS.world.query.with_all([C_Health]).execute().size())
```

Check these before changing implementation:

1. Is `ECS.world` assigned before processing/addition?
2. Is `ECS.process(delta, group)` called in the expected loop/group?
3. Is the Entity actually in the World?
4. Does the Entity carry every queried Component/type?
5. Are Component resources using the correct class reference in queries?
6. Is the System paused, timer-gated, inactive, or assigned to another group?
7. Did a structural mutation remove or move the Entity during iteration?

## Empty Query Checklist

- Query Component classes, not `C_X.new()` instances.
- Confirm `with_none` excludes no intended type.
- Confirm property names exist and setters use the expected values.
- Confirm `.enabled()`/`.disabled()` matches the Entity state.
- Confirm relationship targets/ types exactly match.
- Confirm Component queries use dictionaries with supported operators.
- Check cache freshness after structural mutation and World initialization.

## Null Component Checklist

```gdscript
if entity.has_component(C_Health):
    var health := entity.get_component(C_Health) as C_Health
    if health:
        health.current -= amount
```

Do not assume a stale Component reference survives replacement or removal. Re-read Components after structural operations when query membership changes.

## Observer Diagnostics

1. Confirm registration manually or under the Systems tree.
2. Chain at least one `.on_added()`, `.on_removed()`, `.on_changed()`, `.on_match()`, `.on_unmatch()` or custom event modifier.
3. Confirm `active` and `paused` state.
4. Confirm Component setter emits `property_changed` for CHANGED events.
5. Inspect group/enabled filters and membership transitions.
6. Use `cmd` when callbacks mutate structure.

## Debug Viewer

Enable GECS Debug Mode in Project Settings before expecting live data. Confirm the game is running and `ECS.world` exists. Explorer pages expose:

- System timings, counts and enable state
- Entity Components and relationships
- Property watches and staged edits
- Query results and saved queries
- Capture comparison and live activity
- Breakpoints and step controls

Live editor views refresh at bounded rates; hidden views stop polling. Debug mode can add overhead and should not be left enabled as the final production timing setup.

## Step Debugger

```gdscript
world.debug_pause()
world.debug_step(GECSStepper.Kind.SYSTEM)
world.debug_step(GECSStepper.Kind.ARCHETYPE)
world.debug_step(GECSStepper.Kind.ENTITY)
world.debug_resume()
```

Breakpoint examples:

```gdscript
world.debug_add_breakpoint({ "kind": "system", "system_name": "CombatSystem" })
world.debug_add_breakpoint({ "kind": "component_added", "component": C_Dead })
world.debug_add_breakpoint({ "kind": "entity", "entity": player })
```

Stepping pauses ECS processing only. SceneTree, physics, tweens, animations and Godot's own game loop continue unless separately paused.

## Journal Interpretation

- `prop_set`: setter-emitted property change
- `sweep_set`: direct property assignment detected while paused
- `comp_add` / `comp_remove`: structural Component changes
- `rel_add` / `rel_remove`: relationship changes
- `entity_add` / `entity_remove`: world membership changes
- `event`: custom World event

Use the cause/system columns to distinguish direct mutation, `cmd`, Observer callback, sweep, external game code, or a specific System.

## References

- [Debugging checklist](references/debug-checklist.md)
- [Debugger commands example](examples/debug-session.md)
