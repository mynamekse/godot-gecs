---
name: using-gecs
description: Bootstrap skill for GECS — master routing table, workflow guide, tool mappings, and how to select between GECS skills in Godot 4.x
---

# Using GECS Agent Skills

GECS Agent provides domain-specific knowledge for AI coding assistants working with **GECS v9 (Godot Entity Component System)** in Godot 4.3+.

> **Documentation authority:** Everything under [`docs/`](../../docs/) is the source of truth and must be treated as read-only. Do not edit or remove documentation files unless the user explicitly requests it.

---

## 1. Skill Routing Table

Before implementing or refactoring any GECS system, select the matching domain skill:

| What You Need to Build or Solve | Start with Skill |
|---|---|
| **World setup, AutoLoad, minimal scene skeleton, golden rules** | `gecs-core` |
| **Designing entities, pure data components, scene glue, @export** | `gecs-entities-components` |
| **Writing systems, SoA batching with iterate(), CommandBuffer (cmd)** | `gecs-systems` |
| **Querying entities, property filters (_eq, _lt), change detection** | `gecs-queries` |
| **Entity links, equipment, targeting, stacked buffs/debuffs** | `gecs-relationships` |
| **Reactive events, monitors (on_match/on_unmatch), custom events** | `gecs-observers` |
| **Scene tree organization, system groups, level switching, world.compact()** | `gecs-world-architecture` |
| **Save/load game state, GECSSerializeConfig, level export, .res/.tres** | `gecs-serialization` |
| **Fixing low FPS, entity pooling (enable/disable), query cache stats** | `gecs-performance` |
| **Debugging with GECS Explorer, Step Debugger API, breakpoints** | `gecs-debugging` |
| **Reviewing GDScript code for GECS anti-patterns and best practices** | `gecs-code-review` |
| **Character states, FSM, property states vs component swapping** | `gecs-state-machine` |
| **Level switching without World reboot, entity pooling, MultiMesh** | `gecs-level-spawner` |
| **Connecting ECS data to Godot Control/UI without polling** | `gecs-ui-bridge` |
| **Component design: data-only, naming conventions, default values** | `gecs-best-practices` |
| **Troubleshooting common GECS issues** | `gecs-troubleshooting` |
| **Multiplayer networking setup** | `gecs-networking` |
| **Unit testing ECS systems and components** | `gecs-testing` |
| **Physics integration (Godot PhysicsServer)** | `gecs-physics-integration` |
| **Navigation AI pathfinding** | `gecs-navigation-integration` |

---

## 2. GECS Golden Invariants (Quick Reference)

1. **Register entities with `ECS.world.add_entity(entity)`.** With node-based entities, `add_entity` places the entity in the scene tree by default. Choose either a pure-ECS or hybrid node approach consistently.
2. **Prefer `cmd: CommandBuffer` for structural changes during System iteration.** In v9, zero-copy iteration (`safe_iteration = false`) may skip entities when mutation is performed directly; opt in to copied iteration only with `safe_iteration = true` when needed.
3. **NEVER put game logic inside a `Component`.** Components are pure data (`Resource`). Logic belongs in `System` or `Observer`.
4. **ALWAYS provide default arguments in Component `_init()`.** Reflective instantiation will crash without default values.
5. **NEVER store engine `Node` references in Components.** Store child nodes on the `Entity` subclass as Scene Glue.
6. **Use `entity.alias = &"player"` for singletons (v9).** Do not use legacy v8 string UUIDs.

---

## 3. Tool Mapping

For details on how tools map across platforms (Google Antigravity, Claude Code, GitHub Copilot, Cursor):
* See [`references/antigravity-tools.md`](./references/antigravity-tools.md)
* See [`references/copilot-tools.md`](./references/copilot-tools.md)
