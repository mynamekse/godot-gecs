# GECS UI Architecture & Data Flow Patterns

Guide for connecting GECS runtime data to Godot Control nodes.

---

## 1. Data Flow Architecture

```text
[ GECS World Simulation ]
        │
        ▼ (Property Changed / emit_event)
[ Observer / Event Bridge ]
        │
        ▼ (Direct Typed Method Call or Signal)
[ CanvasLayer (UI Controller) ]
        │
        ▼ (Control Properties)
[ ProgressBar / Label / InventoryGrid ]
```

---

## 2. Invariants & Rules

1. **One-Way Flow:** Game logic never waits for UI. UI observes state and displays it.
2. **No Per-Frame Polling:** Never query ECS inside `_process()` of a `Control` node. UI updates must be event-driven.
3. **CanvasLayer Isolation:** UI nodes must live in a `CanvasLayer`, completely isolated from spatial coordinates and gameplay scene hierarchies.

