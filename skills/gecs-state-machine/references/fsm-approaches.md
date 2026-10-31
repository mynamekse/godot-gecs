# GECS State Machine Architectural Decision Matrix

Guide for choosing between state representation strategies in GECS v9.

---

## 1. Decision Matrix

| Requirement | Recommended Approach | Implementation Detail |
|---|---|---|
| **High frequency transitions (10–60 Hz)** | Property-Based State | `C_CharacterState` enum variable. Avoids archetype moves. |
| **Gating entire systems** | Component-Swapping State | `cmd.add_component(e, C_Stunned.new())`. Systems filter via `.with_none([C_Stunned])`. |
| **One-off Enter/Exit effects** | Observers / Monitors | `.on_match().on_unmatch()` on the state component. |
| **Independent axes (Move + Attack)** | Orthogonal Components | Separate `C_LocomotionState` and `C_CombatState`. |

---

## 2. Coalesced Archetype Transitions in v9

When swapping states via CommandBuffer:
```gdscript
cmd.remove_component(entity, c_old_state)
cmd.add_component(entity, c_new_state)
```
GECS v9 computes the final signature when flushing at system end, executing the swap in **a single archetype transition** rather than two distinct array reallocations.

