---
name: gecs-queries
description: Use when building GECS queries, component property filters, cached queries, pre-narrowed arrays, relationship filtering, or v9 change detection.
---

# GECS Queries

## Composition

```gdscript
q.with_all([C_Player, C_Alive])
q.with_any([C_Melee, C_Ranged])
q.with_none([C_Dead])
```

Use classes for component membership. A component instance is a configuration object or runtime value, not the class filter itself.

## Property filters

```gdscript
q.with_all([
    {C_Health: {"current": {"_lt": 20}}}
])
```

Supported operators include `_eq`, `_ne`, `_gt`, `_lt`, `_gte`, `_lte`, `_in`, `_nin`, and `"func"` callables. Property filters are not supported with `with_none`; exclude component types there instead.

## Change detection

```gdscript
func query() -> QueryBuilder:
    return q.with_all([C_Position, C_Velocity]).changed([C_Position])
```

`changed()` skips untouched archetypes and receives entities whose listed component columns changed since the System's last run. Direct property mutation requires `entity.mark_changed(component)` when no setter emits `property_changed`.

## Cache behavior

- Reuse System query builders instead of constructing disconnected dynamic queries.
- Check cache stats during profiling, not as a general correctness mechanism.
- Structural changes can invalidate or incrementally update query cache membership.

Reference: `docs/COMPONENT_QUERIES.md`, `docs/DEPENDENCY_TRACKING.md`, `docs/PERFORMANCE.md`, `docs/MIGRATION_V9.md`
