---
name: gecs-observers
description: Use when implementing reactive GECS observers, match/unmatch monitors, component property events, relationship events, custom world events, or sub-observers.
---

# GECS Observers and Events

An Observer is event-driven logic. Systems should handle recurring simulation work; Observers should react to lifecycle and membership transitions.

## Basic observer

```gdscript
class_name HealthObserver
extends Observer

func query() -> QueryBuilder:
    return q.with_all([C_Health]).on_added().on_removed()

func each(event: Variant, entity: Entity, payload: Variant) -> void:
    match event:
        Observer.Event.ADDED:
            pass
        Observer.Event.REMOVED:
            pass
```

## Available reactive axes

- Component add/remove/change
- Full query match/unmatch
- Relationship add/remove
- Named custom World events

## Property changes

`on_changed()` requires the Component to emit `Component.property_changed` through a setter or explicit notification. Direct assignment does not dispatch automatically.

```gdscript
@export var hp: int = 100 : set = set_hp

func set_hp(value: int) -> void:
    if hp == value:
        return
    var old_value: int = hp
    hp = value
    property_changed.emit(self, &"hp", value, old_value)
```

## Safety

- Route structural cascades through `cmd` when handling events.
- Do not create unbounded observer loops.
- Use `on_match`/`on_unmatch` for state membership rather than polling.
- Broadcast custom events with `null` entities only when every subscriber is designed for broadcasts.

Reference: `docs/OBSERVERS.md`, `docs/MIGRATION_LEGACY_OBSERVER.md`
