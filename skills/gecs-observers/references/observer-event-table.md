# GECS Observer Event Dispatch Specifications

GECS Observers receive lifecycle and transition notifications through the `each(event, entity, payload)` callback.

---

## 1. Event Payloads Reference

| Event Name | Event Value | Payload Contents |
|---|---|---|
| `ADDED` | `Observer.Event.ADDED` | The `Component` instance just attached. |
| `REMOVED` | `Observer.Event.REMOVED` | The `Component` instance just removed (Entity is still alive). |
| `CHANGED` | `Observer.Event.CHANGED` | `Dictionary`: `{ "component": Component, "property": StringName, "old_value": Variant, "new_value": Variant }` |
| `MATCH` | `Observer.Event.MATCH` | `null` |
| `UNMATCH` | `Observer.Event.UNMATCH` | `null` |
| `RELATIONSHIP_ADDED` | `Observer.Event.RELATIONSHIP_ADDED` | The `Relationship` instance added. |
| `RELATIONSHIP_REMOVED` | `Observer.Event.RELATIONSHIP_REMOVED` | The `Relationship` instance removed. |
| Custom Event | `StringName` | The data `Variant` passed to `world.emit_event()`. |

---

## 2. Invariants & Lifecycle Rules

1. **Setter Requirement for `CHANGED`:**
   - Observers watching `.on_changed()` **require** the watched property setter to emit `property_changed.emit(self, property_name, old_val, new_val)`.
   - Modifying fields without an emitting setter will not trigger `CHANGED`.
2. **`yield_existing`:**
   - Setting `@export var yield_existing: bool = true` retroactively dispatches `ADDED` and `MATCH` events for all entities that already match the query at observer registration time.
   - Defaults to `false` for performance.

