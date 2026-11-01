---
name: gecs-troubleshooting-migration
description: Use when diagnosing common GECS setup failures or migrating code and saves from legacy Observer APIs and v8 behavior to GECS v9.
---

# GECS Troubleshooting and Migration

## Diagnosis order

1. Verify `ECS.world` points to a live World.
2. Verify `ECS.process(delta, group)` is called from the active scene loop.
3. Verify entities were added after the World assignment.
4. Verify queries use component classes, not component instances.
5. Verify every component required by `with_all()` exists on the entity.
6. Verify system group registration and tick setup.
7. Measure query/cache/perf only after the control-flow path is correct.

## v9 migration

- Replace String entity IDs with integer `Entity.id` plus optional `alias` names.
- Replace direct iteration mutation with `cmd` when mutation happens in systems.
- Set `safe_iteration = true` only for systems that intentionally need copied arrays.
- Do not rely on `world.entities` insertion order.
- Preserve empty archetypes between churn cycles; call `compact()` at quiet boundaries.
- Replace legacy observer patterns with fluent `.on_added()`, `.on_removed()`, `.on_changed()`, `.on_match()`, or `.on_unmatch()` modifiers.
- Property filters require setters that emit `property_changed` for reactive change detection.
- Update relationship and serialization identity assumptions from UUID strings to integer handles.

## Legacy saves

The migration docs note that old String UUID saves can be shimmed through load-time handle mapping. Preserve relationship resolution during deserialization and test old saves explicitly.

Reference: `docs/TROUBLESHOOTING.md`, `docs/MIGRATION_V9.md`, `docs/MIGRATION_LEGACY_OBSERVER.md`
