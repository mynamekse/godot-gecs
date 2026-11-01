---
name: gecs-world-architecture
description: Use when organizing World, System groups, Entity scenes, level switching, entity pooling, lifecycle cleanup, compacting archetypes, or large-mass rendering.
---

# GECS World Architecture

## Recommended flow

1. Put the World and ECS-facing System scene nodes under the game's root or bootstrap scene.
2. Assign `ECS.world` before spawning entities.
3. Process groups in explicit order.
4. Keep UI observers on an appropriate scene path and avoid per-frame UI polling.
5. Switch levels without bootstrapping the World unless the project truly requires a full reset.

## Processing groups

Common groups in the docs are `run-first`, `input`, `gameplay`, `physics`, `ui`, `debug`, and `run-last`. Treat names as project configuration, not mandatory built-ins.

## Lifecycle and churn

- Do not destroy Entity Nodes directly when `World.remove_entity()` or `cmd.remove_entity()` defines the lifecycle.
- Pool high-churn entities through enable/disable where pooling rules fit.
- Empty archetypes are retained for transition-edge reuse in v9.
- Call `world.compact()` at a quiet point, such as a level transition, to reclaim retained resources.
- Do not rely on stable `world.entities` order after removals.

## Scene-tree scale

For thousands of simple visual entities, prefer rendering authority in `MultiMesh` or `RenderingServer`/`PhysicsServer` while retaining simulation data in ECS components. Do not create one physics or presentation Node per entity solely as a default architecture.

Reference: `docs/BEST_PRACTICES.md`, `docs/ENTITY_LIFECYCLE_PERFORMANCE.md`, `docs/PERFORMANCE.md`
