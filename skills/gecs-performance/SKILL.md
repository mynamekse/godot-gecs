---
name: gecs-performance
description: Profile, benchmark and optimize GECS games. Use for query cache tuning, iterate batching, entity lifecycle churn, threshold selection, benchmark commands, regression comparison and identifying ECS versus game-work bottlenecks.
---

# GECS Performance

Profile before optimizing. Separate synthetic ECS work, rendered/game callback work, and frame-rate measurements; do not present one as another.

## Activation Scope

- Query optimization
- System and archetype iteration
- Component and entity spawn/removal cost
- Benchmark thresholds
- Performance regression testing
- Pool versus spawn/despawn decisions
- Lifecycle churn reports
- Debug-viewer performance metrics

## Entity Routing

For Entity spawn, prefab lifecycle, pooling reset semantics and SceneTree ownership, use the `gecs-entities` skill. Keep this skill focused on timing, benchmarks and threshold interpretation.

## Source Documents

- `docs/PERFORMANCE.md`
- `docs/PERFORMANCE_OPTIMIZATION.md`
- `docs/PERFORMANCE_TESTING.md`
- `docs/ENTITY_LIFECYCLE_PERFORMANCE.md`

## Optimization Order

1. Measure the current workload and establish a baseline.
2. Enable GECS debug only when inspecting, but profile the final build with debug off for timing comparisons.
3. Optimize broad queries and structural churn before micro-optimizing GDScript arithmetic.
4. Prefer component-only specificity over broad type branches.
5. Use `.iterate([...])` for zero-copy component column batch access where appropriate.
6. Use `changed([...])` only for meaningful component writes detected by emitting setters.
7. Group system work with dependencies or groups, not manual `_process` crossings.
8. Repeat the same hardware, Godot executable, scale, debug setting, and label.

## Query Guidance

- `enabled()` / `disabled()` filters are useful for active entity buckets.
- `with_all` and property queries are preferable to a broad `with_all` followed by class branching.
- Split legitimate OR behavior only when the split simplifies logic; `with_any` is valid for real OR semantics.
- Avoid group queries for performance-critical hot paths; prefer Component markers.
- Build and execute queries through the System query declaration, not a manually constructed query per entity loop.

## Structural Guidance

- Batch operations when group semantics allow it.
- Use `cmd` for safe deferred mutation during System iteration.
- Avoid assuming a CommandBuffer speeds up pure spawn/remove work; it stages the same per-entity lifecycle work and coalesces some costs.
- Retained empty archetypes can preserve transition edges; call `world.compact()` only at quiet level boundaries.
- Pool entities only when reset identity/state, memory and game callback contracts are understood.
- Never share mutable Component instances to improve benchmark creation costs if independence is required.

## Documented Test Thresholds

The historical suite documents these pass/fail targets:

- 100 entities: creation < 10 ms
- 1,000 entities: creation < 50 ms; world add < 100 ms
- 100 component adds < 10 ms; 1,000 component adds < 75 ms
- Simple query at 100/1,000/10,000 entities: < 5/20/100 ms
- Complex query: < 50 ms
- 1,000 entity system processing: < 30 ms
- 10,000 entity system processing: < 150 ms
- Realistic 1,000-entity game loop: < 16 ms for a 60 FPS target

Use these as the suite's local targets, not universal production hardware guarantees. Lifecycle profile tests document no hardware-dependent pass/fail thresholds.

## Benchmark Commands

```bash
# Windows/GdUnit suite
addons/gdUnit4/runtest.cmd -a res://addons/gecs/tests/performance/performance_test_master.gd
```

Lifecycle benchmark:

```bash
GECS_PERF_LABEL=lifecycle-baseline EXTRA_GODOT_ARGS=--no-gecs-debug \
  tools/run_tests.sh -t 180 \
  res://addons/gecs/tests/performance/test_entity_lifecycle_perf.gd
```

Run a comparison report with distinct labels and retain the patch or commit because Git HEAD alone does not describe uncommitted changes.

## Regression Workflow

1. Establish the baseline and save raw results.
2. Change one workload or implementation slice.
3. Re-run at small, medium and large scales when applicable.
4. Require repeated regression passes and inspect median/p95/max rather than only averages.
5. Alert at greater than roughly 20% degradation only after confirming the same environment and workload.
6. Confirm correctness suites, observers, relationships, IDs and lifecycle callbacks still pass.

## References

- [Performance API and tactics](references/performance-api.md)
- [Benchmark workflow example](examples/benchmark-workflow.md)
