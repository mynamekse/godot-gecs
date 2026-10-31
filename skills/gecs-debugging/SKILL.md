---
name: gecs-debugging
description: Use when debugging GECS projects — GECS Explorer (Debug Viewer) window, Step Debugger API (FRAME, GROUP, SYSTEM, ARCHETYPE, ENTITY steps), diff sweep, breakpoints, and GECSTracker dependency tracking
---

# GECS Debugging in Godot 4.3+

Debug and profile GECS v9 games at runtime. Inspect entities and live archetype storage through the **GECS Explorer** companion window, pause and step through execution granularities with the **Step Debugger**, catch untracked property edits with **Diff Sweep**, and trace reactive derivations using `GECSTracker`.

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-core** for setup, **gecs-systems** for systems execution, **gecs-performance** for metrics.

---

## 1. GECS Explorer (Debug Viewer)

### Enabling the Explorer:
1. Go to **Project → Project Settings → GECS → Debug Mode** (set to true).
2. Run the game (F5 or F6).
3. The GECS Explorer companion window launches automatically alongside the game.

> **Production Warning:** Always disable Debug Mode in release export builds.

### Key Explorer Surfaces:
* **Entities Browser:** Expand rows to view live components and relationships.
* **Property Inspector:** Edit live component values and apply them back to the active game.
* **Relationship Graph:** Interactive visual neighborhood showing connections between entities.
* **Queries Scratchpad:** Test custom fluent queries interactively with syntax highlighting.
* **Systems Profiler:** View timing metrics (`Last ms`, `Min`, `Max`, `Avg`, `Entity count`).

---

## 2. Step Debugger API

The Step Debugger pauses only ECS processing while leaving engine physics and rendering active:

```gdscript
var world := ECS.world

# 1. Pause ECS processing
world.debug_pause()

# 2. Step by granularity
world.debug_step(GECSStepper.Kind.SYSTEM)     # Step next system
world.debug_step(GECSStepper.Kind.ARCHETYPE)  # Step one archetype batch
world.debug_step(GECSStepper.Kind.FRAME)      # Step full frame

# 3. Resume normal continuous ticking
world.debug_resume()
```

### Step Granularities:

| Granularity (`Kind`) | What Executes |
|---|---|
| `FRAME` | One complete frame across all process groups |
| `GROUP` | Rest of the current `SystemGroup` including group flush |
| `SYSTEM` | Next single system in the active group |
| `ARCHETYPE` | Next archetype batch within the active system |
| `ENTITY` | One individual entity (from debug step set) |

---

## 3. Breakpoints

Pause the simulation automatically when specific conditions occur:

```gdscript
# Break before a specific system runs:
world.debug_add_breakpoint({ "kind": "system", "system_name": "CombatSystem" })

# Break when a component type is added:
world.debug_add_breakpoint({ "kind": "component_added", "component": C_Dead })

# Break when a specific entity is modified:
world.debug_add_breakpoint({ "kind": "entity", "entity": player_entity })
```

---

## 4. Diff Sweep

When paused, the stepper diffs all component script variables after each step to detect direct field mutations that didn't go through emitting setters (detecting unreported edits as `sweep_set` operations in the log).

---

## 5. Dependency Tracking with `GECSTracker`

Measure which queries and component types are read during an operation:

```gdscript
var deps = GECSTracker.track(func():
	var player = ECS.world.query.with_all([C_Player]).execute_one()
	return player.get_component(C_Health).current if player else null
)

print("Return value: ", deps.result)
print("Queries executed: ", deps.queries)
print("Component types read: ", deps.reads)
```

See [`references/debugger-protocol.md`](./references/debugger-protocol.md) for details on remote debugging packets and inspector synchronization.

