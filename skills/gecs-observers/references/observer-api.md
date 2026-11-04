# GECS Observer API Summary

## Query Declaration

Every reactive Observer starts with `query()` and must chain at least one event modifier.

```gdscript
func query() -> QueryBuilder:
    return q.with_all([C_Health]).on_added().on_removed().on_changed([&"current"])
```

## Event Modifiers

| Modifier | Meaning |
|---|---|
| `.on_added()` | Component added |
| `.on_removed()` | Component removed |
| `.on_changed([&"name"])` | Setter-emitted property change |
| `.on_match()` | Query membership begins |
| `.on_unmatch()` | Query membership ends |
| `.on_relationship_added([type])` | Relationship added |
| `.on_relationship_removed([type])` | Relationship removed |
| `.on_event(&"name")` | Named World event |

## Payload

- Added and removed payloads are the Component/Relationship instance where documented.
- Changed payload is `{component, property, new_value, old_value}`.
- Match/unmatch and some custom events can use null payload or caller-provided data.

## Observer Callback

```gdscript
func each(event: Variant, entity: Entity, payload: Variant) -> void:
    match event:
        Observer.Event.ADDED: pass
        Observer.Event.REMOVED: pass
        Observer.Event.CHANGED: pass
        Observer.Event.MATCH: pass
        Observer.Event.UNMATCH: pass
```

## Registration

Observers can be added manually through `world.add_observer()` or placed under the Systems scene tree node for automatic registration.

## Dependencies

`GECSTracker.track()` reports executed queries and Component reads. Convert query and read dependencies into Observer subscriptions, then retrack when the derived computation can change its dependency signature.
