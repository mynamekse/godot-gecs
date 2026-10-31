# GECS World Processing Lifecycle Specifications

The `World` node serves as the central hub of an active ECS simulation.

---

## 1. System Group Execution Order

Systems placed under `World` are organized into named `SystemGroup` nodes:

| Group Name | Execution Context | Recommended Systems |
|---|---|---|
| `run-first` | `_process()` | State initialization, tick resets, buffer clearing |
| `input` | `_process()` | Translating Godot InputEvents into ECS component state |
| `gameplay` | `_process()` | Weapons, combat, inventory, AI decisions |
| `physics` | `_physics_process()` | Velocity integration, CharacterBody collisions, raycasts |
| `ui` | `_process()` | HUD synchronization, health bars, inventory screens |
| `debug` | `_physics_process()` | Gizmos, raycast debug drawing, metrics |
| `run-last` | `_process()` | `PendingDeleteSystem`, actions cleanup |

---

## 2. World Memory Maintenance

* **Archetype Retention:** Empty archetypes are kept alive during frames to prevent dynamic reallocation thrashing.
* **`world.compact()`:** Trims empty archetype columns and optimizes transition edges.
* **`world.purge()`:** Removes all active entities cleanly, notifying registered observers with `UNMATCH` and `REMOVED`.

