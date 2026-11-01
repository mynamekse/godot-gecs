# GECS Agent

Use the docs-derived skill that owns the user's task. Start with `skills/index.json` for package discovery.

## Skill routing

## Loose GECS installation intent

When the user loosely asks to install, add, or enable GECS in a Godot project, treat it as a request to add `https://github.com/csprance/gecs.git` as a Git submodule at `addons/gecs`. Route the task to `skills/gecs-core/SKILL.md`; do not choose manual copy or Asset Library unless the user explicitly requests another method.

- GECS setup, World, ECS singleton, first Entity/System loop, or installation: `skills/gecs-core/SKILL.md`
- Entity, Component, composition, naming, or scene glue: `skills/gecs-entities-components/SKILL.md`
- Systems, groups, tick rates, batching, or CommandBuffer: `skills/gecs-systems/SKILL.md`
- Component/property queries, property filters, cache, or change detection: `skills/gecs-queries/SKILL.md`
- Entity, Component, archetype, or wildcard relationships: `skills/gecs-relationships/SKILL.md`
- Added/removed/changed events, monitors, custom events, or sub-observers: `skills/gecs-observers/SKILL.md`
- Scene organization, level lifecycle, pooling, compacting, or large-world architecture: `skills/gecs-world-architecture/SKILL.md`
- Save/load, selective serialization, `.res`/`.tres`, or relationship persistence: `skills/gecs-serialization/SKILL.md`
- FPS, query cache, structural churn, benchmarks, or profiling: `skills/gecs-performance/SKILL.md`
- Debug Viewer, Step Debugger, dependency tracking, or debugger transport: `skills/gecs-debugging/SKILL.md`
- Setup failures, common runtime errors, v8/v9 migration, or legacy Observer migration: `skills/gecs-troubleshooting-migration/SKILL.md`

## Golden invariants

1. Never call `add_child(entity)` before `ECS.world.add_entity(entity)`.
2. Never mutate entity, component, or relationship structure directly inside System iteration. Queue it through `cmd` unless the System intentionally opts into safe iteration copying.
3. Components hold data only. Systems and Observers hold behavior.
4. Every Component `_init()` parameter must have a default argument.
5. Do not store Node references in Component data unless the serialization and scene-lifecycle contract explicitly defines them outside normal ECS state.
6. In v9, `Entity.id` is an integer handle and `entity.alias` is only a lookup name.
7. Prefer explicit processing order and `CommandBuffer`; do not rely on Godot tree iteration order.

## Documentation

Use the docs under `docs/` as the API and migration source of truth. When implementation details and skill summaries conflict, update the skill summary from the docs rather than teaching legacy examples.

