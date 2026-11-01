---
name: gecs-performance
description: Use when profiling GECS FPS, query cache behavior, structural churn, entity pooling, change detection, benchmarks, or scaling a GDScript ECS workload.
---

# GECS Performance

## Model

GECS uses hybrid archetypes with dense entity arrays and SoA component columns. Cached queries resolve matching archetypes, while structural changes remain the expensive ECS operation.

## Fast paths

- Batch entity processing with `iterate()` columns.
- Use cached component queries and with_none filters instead of custom per-entity group scans.
- Use `changed([C_Type])` to skip unchanged work.
- Batch CommandBuffer operations for spawn/churn and state transitions.
- Enable/disable entities instead of repeatedly allocating them for pooling scenarios.
- Preserve empty archetypes during churn; compact at quiet boundaries.

## Avoid

- Calling a query or allocating callbacks once per entity in a hot loop.
- Direct structural mutation from each iteration turn.
- One Node, collision shape, and Godot callback per mass unit when a server-backed or MultiMesh representation is sufficient.
- Treating debug instrumentation or benchmark numbers from old GECS versions as current v9 measurements.

## Profiling

1. Measure `get_cache_stats()` and `perf_get_*` metrics when instrumentation is enabled.
2. Profile with Godot's built-in profiler.
3. Compare the same benchmark scenario and Godot version.
4. Use warmup plus median runs for new benchmarks.
5. Guard cached query execution, component lookup, hot iteration, and relationship queries against regression.

Reference: `docs/PERFORMANCE.md`, `docs/PERFORMANCE_OPTIMIZATION.md`, `docs/PERFORMANCE_TESTING.md`, `docs/ENTITY_LIFECYCLE_PERFORMANCE.md`
