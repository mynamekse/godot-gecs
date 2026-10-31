# GECS Debug Viewer Protocol & Stepper Internals

The GECS Debug Viewer operates as a companion window over an internal memory transport.

---

## 1. Stepper Log Operations

| Operation Name | Code Meaning |
|---|---|
| `prop_set` | Property changed through an emitting setter (`property_changed.emit`). |
| `sweep_set` | Property changed by direct assignment without an emitting setter (diff sweep). |
| `comp_add` / `comp_remove` | Component added to / removed from an entity. |
| `rel_add` / `rel_remove` | Relationship added to / removed from an entity. |
| `entity_add` / `entity_remove` | Entity spawned into / removed from the World. |
| `entity_enabled` | Entity active state changed via `enable_entity` / `disable_entity`. |
| `event` | Custom event dispatched via `world.emit_event()`. |

---

## 2. Limits and Safety

* ECS Snapshot restoration is designed as an interactive debugging aid, not a production save system.
* Maximum snapshot restore payload: 1,000 entities and 128 changed fields per entity.

