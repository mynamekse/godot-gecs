# GECS Performance Reference

## Profiling Inputs

Record these together for every result:

- Godot executable and version
- Debug build versus export build
- Headless versus running game
- GECS debug mode
- Entity scale and composition
- Warmup count and sample count
- Git HEAD and patch/commit for uncommitted changes

## Query Cache

Use `world.get_cache_stats()` and `world.reset_cache_stats()` in controlled measurement loops. A cached query should normally show high cache hit rates; low cache hit rates can indicate excessive structural mutations or short-lived builders.

## Change Detection

```gdscript
q.with_all([C_Position]).changed([C_Position])
```

Change detection skips work for unchanged archetypes only after Component setters emit `property_changed`. Use `entity.mark_changed(component)` when a direct mutation bypasses the setter contract.

## Lifecycle

Four lifecycle profiles distinguish:

- Plain Godot Node baseline
- Empty GECS Entity
- Attached two-component Entity
- Resource-template initialization

Lifecycle timing is not frame timing. Churn cycles include allocation, add, remove and the next frame boundary according to the suite.

## Framework Versus Game Work

If add dominates, compare empty, attached and resource-template profiles. If removal grows with relationship population, profile relationship cleanup. If scene callbacks dominate, replace synthetic Nodes with the real prefab factory, observers, relationship population and resident entities.
