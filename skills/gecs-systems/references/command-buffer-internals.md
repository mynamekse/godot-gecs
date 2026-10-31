# CommandBuffer Internals & Flush Modes

The `CommandBuffer` (`cmd`) is the structural mutation buffer attached to every `System` and `Observer` in GECS.

---

## 1. Why CommandBuffer is Necessary

In traditional ECS or OOP programming, removing or adding elements to an array currently being iterated leads to subtle bugs:
- Indices shift, causing elements to be skipped.
- Iterators crash with out-of-bounds exceptions.
- In Archetype ECS, adding or removing a component transitions the entity to a completely different archetype array, immediately invalidating memory pointers.

`CommandBuffer` queues these mutations as lightweight command tokens (`Command`), deferring their execution until the current iteration is safely finished.

---

## 2. Flush Modes

Systems provide an exported enum `command_buffer_flush_mode`:

| Flush Mode | When Flushed | Best Used For |
|---|---|---|
| `FlushMode.PER_SYSTEM` (Default) | Immediately after the system's `process()` completes | Standard systems with independent logic. |
| `FlushMode.PER_GROUP` | After all systems in the current `SystemGroup` finish | Systems that communicate via component flags within the same tick. |
| `FlushMode.MANUAL` | Only on explicit call: `ECS.world.flush_command_buffers()` | Tight batching or deterministic networked rollback. |

---

## 3. Coalescing Archetype Moves

In GECS v9, when a CommandBuffer is flushed, multiple mutations on the same entity are **coalesced**:
- If a system queues `cmd.remove_component(e, C_Attacking)` and `cmd.add_component(e, C_Fleeing)`, GECS calculates the target archetype directly and performs **a single archetype transition**.
- This reduced archetype transition churn by **66%** in v9 benchmarks.

