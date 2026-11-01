---
name: gecs-debugging
description: Use when diagnosing GECS runtime behavior with the Debug Viewer, Step Debugger, breakpoints, system/entity diffs, dependency tracking, or debugger transport.
---

# GECS Debugging

## Start points

- Debug Viewer / GECS Explorer for systems, entities, relationships, and refresh state.
- Step Debugger for frame, group, system, archetype, and entity granularity.
- Dependency tracker to correlate queries executed by functions.
- Debugger transport status when editor and game session communication is involved.

## Workflow

1. Verify ECS is assigned to a World and systems are being processed.
2. Confirm entities exist in the World and contain the exact component types queried.
3. Inspect a system's query result independently.
4. Pause after structural changes rather than assuming queued mutations already flushed.
5. Step through the exact system/group boundary that owns the behavior.
6. Compare before/after diffs for entity and component state.
7. Profile separately from correctness debugging because debug payloads can add noise.

## Common traps

- Passing a component instance instead of its class to membership queries.
- Mutating structure inside an archetype loop without `cmd`.
- Expecting direct property assignment to emit change observers.
- Expecting entity order to be stable.
- Running `ECS.process()` on one group while systems are registered under another.

Reference: `docs/DEBUG_VIEWER.md`, `docs/STEP_DEBUGGER.md`, `docs/DEBUGGER_TRANSPORT.md`, `docs/DEPENDENCY_TRACKING.md`
