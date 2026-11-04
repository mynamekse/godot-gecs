---
name: gecs-observers
description: Implement GECS reactive logic and migrate legacy observers. Use for added/removed/changed events, query membership monitors, custom events, sub-observers, dependency tracking and v7 observer migration.
---

# GECS Observers

Observers subscribe declaratively to world changes through `QueryBuilder` event modifiers. A plain query with no event modifier is intentionally a no-op.

## Activation Scope

- Component lifecycle events
- Property changes
- `MATCH` / `UNMATCH` membership monitors
- Relationship and custom events
- Multiple reactive axes in one Observer
- Dependency tracking for reactive caches
- Migration from legacy v7 `watch()` / callback APIs

## Source Documents

- `docs/OBSERVERS.md`
- `docs/DEPENDENCY_TRACKING.md`
- `docs/MIGRATION_LEGACY_OBSERVER.md`

## Observer Template

```gdscript
class_name HealthObserver
extends Observer

func query() -> QueryBuilder:
    return q.with_all([C_Health]).on_added().on_removed().on_changed([&"current"])

func each(event: Variant, entity: Entity, payload: Variant) -> void:
    match event:
        Observer.Event.ADDED:
            handle_added(entity, payload)
        Observer.Event.REMOVED:
            handle_removed(entity, payload)
        Observer.Event.CHANGED:
            handle_changed(entity, payload)
```

A changed Component setter must emit:

```gdscript
@export var current: float = 100.0 : set = set_current

func set_current(value: float) -> void:
    var old_value := current
    current = value
    if current != old_value:
        property_changed.emit(self, "current", old_value, current)
```

## Event Reference

- `.on_added()` dispatches an ADDED event with the added Component instance.
- `.on_removed()` dispatches a REMOVED event with the removed Component instance.
- `.on_changed([&"property"])` dispatches CHANGED with a payload Dictionary.
- `.on_match()` / `.on_unmatch()` track complete query membership transitions.
- `.on_relationship_added([C_Relation])` and `.on_relationship_removed([C_Relation])` track links.
- `.on_event(&"name")` subscribes to `world.emit_event()` custom events.

## Membership Monitors

```gdscript
func query() -> QueryBuilder:
    return q.with_all([C_Alive, C_InCombat]).on_match().on_unmatch()
```

`MATCH` fires once when the full query begins matching. `UNMATCH` fires once when it stops matching, including world removal. Intermediate mutations that preserve membership are silent.

## Sub-Observers

```gdscript
func sub_observers() -> Array[Array]:
    return [
        [q.with_all([C_Health]).on_added().on_removed(), _on_health],
        [q.with_all([C_Player]).on_event(&"damage_dealt"), _on_damage],
    ]
```

Use separate tuples for distinct reactive axes instead of branching on unrelated event sources inside one callback.

## Structural Mutation

Use `cmd` inside callbacks that trigger further structural changes. It breaks synchronous event cascades and avoids stale-cache observation.

```gdscript
func each(event, entity, payload):
    if event == Observer.Event.REMOVED:
        cmd.remove_entity(get_child_entity(entity))
```

`PER_CALLBACK` flushes after each callback by default where that mode is available. `MANUAL` requires an explicit world command-buffer flush.

## Dependency Tracking

`GECSTracker.track()` discovers executed queries and Component reads while a callable runs. Map discovered dependencies to Observer subscriptions, then re-track and resubscribe if the dependency signature changes.

## Legacy Migration

- Replace `watch()` and `match()` with one filter-rich `query()`.
- Replace callback methods with one `each(event, entity, payload)`.
- Use event branches instead of separate lifecycle methods.
- Chain an event modifier; otherwise the Observer never fires.
- Preserve helper methods and call them from matching `each()` branches.
- Replacing membership inference with `.on_match()` / `.on_unmatch()` is recommended.

## References

- [Observer API summary](references/observer-api.md)
- [Migration example](examples/v7-to-v8.md)
