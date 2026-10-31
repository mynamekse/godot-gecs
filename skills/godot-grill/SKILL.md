---
name: godot-grill
description: Use when designing GECS state machines or ECS systems — interrogates open design decisions in batched rounds, scope first, each question with a recommended answer, and records the answers before any design or code. Triggers on "grill me", "ask me first", "question me on the design", "what do I need to decide before building". Not for choosing between Node types or API signatures, and not for bug fixes.
---

# Godot Grill

Settle the decisions only the developer can make, before anyone designs a scene tree or writes
code. The output is a **decision record**, not a design.

> **Related skills:** **gecs-core** for primitives, **gecs-systems** for `cmd` CommandBuffer mutations, **gecs-queries** for state filtering, **gecs-observers** for `.on_match()`/`.on_unmatch()` state enter/exit triggers.

## 1. Decisions, not facts

Ask only what **only the user knows**: intent, constraints, priorities, taste.

Node types, API signatures, and version differences are **facts**. Look them up
(`godot-brainstorming/references/node-selection.md`, the domain skills), decide, and record the
choice. Never spend a question on one.

Architecture choices — data home, state representation, save format — are decided **from** the
user's answers, not asked as technology picks. Ask the constraint behind them ("will designers
edit items in the Inspector?"), then map the answer to Resource `.tres` yourself.

| Question | Verdict |
|---|---|
| "Property-based state enum or component-swapping states?" | Decision — ask |
| "Should the player be a `CharacterBody2D` or a `RigidBody2D`?" | Fact — decide, record it for GECS |
| "When two clients disagree, who is right?" | Decision — ask |
| "Can a `Tween` chain steps in 4.3?" | Fact — never ask |

## 2. The seeded dependency tree

Four roots have no prerequisites:

| Root | Options |
|---|---|
| **Scope** | throwaway slice / one feature / a system others build on |
| **Dimension** | 2D / 3D / 2.5D |
| **Language** | GDScript / C# / both |
| **State Model** | property-based / component-swapping / layered / orthogonal |
| **Authority** | single-player / networked (and if networked, who is authoritative) |

| Settling this… | …unblocks |
|---|---|
| Scope | prunes branches: a throwaway slice skips persistence, data home, networking, and testing |
| State Model | system gating (which systems query which state components); archetype transition cost |
| Dimension | physics model; camera model |
| Language | interop boundary, when the answer is "both" |
| Scope + State Model | entity model: which components exist per entity |
| State Model + Entity model | persistence boundary; save format |
| Entity model | data home (Resource `.tres` / autoload / node-local `@export`); communication (signals up, calls down / EventBus / DI) |
| Authority + State Model | networked replication strategy; which state is source of truth |
| Data home + Persistence | save format (ConfigFile / JSON / Resource serialization) |

The right-hand column names what an answer lets **you** decide; ask the user the constraint
behind it, never the technology. The tree is a **seed, not a script**. Answers grow it — "networked" creates branches a
single-player answer never does. Skip any root the request or the project already answers
(`project.godot`, existing scripts). Most sessions visit few nodes.

## 3. Rounds

**Before round 1**, read where the project keeps decision records, checking in order: the user's
instructions or the project's agent instructions file (`CLAUDE.md`, `AGENTS.md`, …); then an
existing decisions or ADR directory. A recorded decision is a settled prerequisite: never re-ask
it; start the frontier past it.

The **frontier** is every open decision whose prerequisites are settled. Ask the whole frontier
in one message, numbered, each with a recommended answer:

```text
❓ **Q1** — **<title>**: <the question, with its options>

➡️ <recommended answer, and why in one clause>
```

Then stop and wait. A question whose prerequisite is still open belongs to a later round.
Everything you ask is in the numbered list: no closing "also, what genre…?" after it. Anything
worth asking gets a number and a ➡️; anything else waits for the next round.

**Round 1 is small and settles scope first** — scope prunes the most tree. A "throwaway slice"
answer commonly ends the session at round 2.

After each round, re-derive the frontier from the answers. If an answer contradicts a recorded
decision, say so and ask whether to reopen it — never overwrite a record silently.

## 4. Ending the grill

The grill ends when the frontier is empty, or on the **off-ramp**: "just build it" / "skip the
questions" / "stop grilling", in any round, including the first message. Then stop asking, and
**list every assumption you are now making** for the open decisions, where the user can scan
and overrule them.

**On the off-ramp there are no confirmation or approval gates:** list the assumptions, write the
record, and build — with the matching domain skill, or `godot-brainstorming` from Step 2 without
its per-section check-ins.

**When the frontier empties**, write the record (§5), confirm shared understanding in one
message, and wait. Then hand off:

- it needs a scene tree, signal map, or plan → `gecs-brainstorming`, from Step 2
- it is a single known change → the matching domain skill

## 5. The decision record

GodotPrompter has no decisions folder of its own. Write the record where this project keeps
them, checking in order: the user's instructions or the project's agent instructions file
(`CLAUDE.md`, `AGENTS.md`, …); then an existing decisions or ADR directory. If none applies, ask
the user, suggesting `docs/decisions/`, or use `docs/decisions/` when you cannot ask (a subagent
or non-interactive run). Name the file `YYYY-MM-DD-<topic>.md`. The path must stay stable: the
next grill reads it back.

```markdown
# <Topic> — decisions

| Decision | Choice | Why | Revisit when |
|---|---|---|---|
| State model | Property-based enum | Rapid state transitions, minimal archetype churn | a component-swapping system is wanted |
| Data home | Component `@export` | Per-entity state, no global singletons | a global state system is needed |

## Open / deferred
- Networked replication strategy — deferred to a later pass.
- Save slots — **assumed** 1 (off-ramp); revisit before shipping.
```

`Revisit when` keeps a decision reopenable, not binding. Off-ramp assumptions go under
**Open / deferred**, marked **assumed**. If you cannot write files, put the record in your final
message instead.

## 6. Anti-patterns

| Anti-pattern | Why it is wrong | Instead |
|---|---|---|
| One question at a time | Order fixed in advance; questions arrive before their prerequisites; more turns | Ask the whole frontier |
| Asking a fact | Spends the user's attention on the model's job | Look it up, decide, record |
| A question with no recommendation | The user answers in a vacuum; rounds slow down | Every question gets ➡️ |
| A trailing question outside the numbered list | It has no recommendation and is easy to miss when answering by number | Number it, or hold it for the next round |
| Grilling a bug fix or an explicit ask | The over-correction this skill must not become | Route to the domain skill |
| Re-asking a recorded decision | Feels like amnesia; wastes the record | Read where the project keeps decision records first |
| Coding after the last answer | Skips the shared-understanding check | Confirm, then hand off |

## Checklist

- [ ] Read existing decision records before round 1
- [ ] Round 1 settled scope first
- [ ] Every question is a decision — numbered, with a recommended answer
- [ ] Whole frontier per round; waited after each
- [ ] Off-ramp taken → assumptions listed
- [ ] Record written (or in the final message when files cannot be written)
- [ ] Frontier emptied → user confirmed before design or code; off-ramp → no gates, built on the listed assumptions
