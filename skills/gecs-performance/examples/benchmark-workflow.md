# GECS Benchmark Workflow

## 1. Establish a Baseline

Use a distinct label, disable GECS debugger instrumentation for fair timing, and run the complete suite twice where practical.

```bash
GECS_PERF_LABEL=baseline-extra EXTRA_GODOT_ARGS=--no-gecs-debug \
  tools/run_tests.sh -t 180 \
  res://addons/gecs/tests/performance/test_entity_lifecycle_perf.gd
```

## 2. Record Metadata

- Executable
- Debug/export build
- Headless/editor run
- Scale and persistent resident count
- Warmups and samples
- Git HEAD and patch or commit label

## 3. Apply One Change

Examples:

- Replace a broad query with specific Component filters.
- Use `iterate()` for matching Component columns.
- Replace repeated structural mutation with a CommandBuffer batch.
- Replace group lookup with a Component marker.
- Add `changed()` after verifying setter-emitted property changes.

## 4. Compare

Inspect median, p95 and max. Use raw data and only compare runs that passed correctness tests and share the workload environment.

## 5. Validate Game Frame Cost

Synthetic ECS speed does not prove a rendered game frames in under 16 ms. Profile the real spawn/despawn rate, callback cost, rendering, physics, residents and debug setting.
