---
name: gecs-queries
description: Use when constructing GECS entity queries — QueryBuilder fluent chaining with with_all(), with_any(), with_none(), component property queries (_eq, _lt), .from() pre-narrowed arrays, and v9 .changed() change detection
---

# GECS Queries in Godot 4.3+

Filter and retrieve entities in GECS v9 using the fluent `QueryBuilder` API. GECS queries are evaluated against archetypes and heavily cached, with execution times ranging from 0.1–0.4 ms over 10,000 entities.

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-systems** for running queries in systems, **gecs-relationships** for relationship queries, **gecs-performance** for cache optimization.

---

## 1. Fluent Query API

Construct queries using `ECS.world.query` or the `q` helper inside systems:

```gdscript
var query = ECS.world.query \
	.with_all([C_Position, C_Velocity]) \
	.with_any([C_Player, C_Enemy]) \
	.with_none([C_Dead, C_Frozen]) \
	.enabled()
```

### Execution Methods:
* `query.execute() -> Array[Entity]`: Returns all matching active entities.
* `query.execute_one() -> Entity`: Returns the first matching entity, or `null`.
* `query.matches(existing_array) -> Array[Entity]`: Filters an existing array against the query criteria.

---

## 2. Component Property Queries

In addition to filtering by component type, GECS allows filtering by **internal values** of component fields:

```gdscript
# Query entities whose C_Health.current is less than 25
var low_health_query = ECS.world.query.with_all([
	{C_Health: {"current": {"_lt": 25.0}}}
])

# Query enemies in "patrol" state
var patrolling_query = ECS.world.query.with_all([
	{C_AIState: {"state": {"_eq": "patrol"}}}
])
```

### Supported Comparison Operators:

| Operator | Meaning | Example |
|---|---|---|
| `_eq` | Equal to | `{"state": {"_eq": "idle"}}` |
| `_ne` | Not equal to | `{"team": {"_ne": 1}}` |
| `_gt` | Greater than | `{"level": {"_gt": 10}}` |
| `_lt` | Less than | `{"hp": {"_lt": 20.0}}` |
| `_gte` | Greater than or equal | `{"mana": {"_gte": 50}}` |
| `_lte` | Less than or equal | `{"cooldown": {"_lte": 0.0}}` |
| `_in` | Included in array | `{"element": {"_in": ["fire", "lightning"]}}` |
| `_nin` | Not in array | `{"element": {"_nin": ["water"]}}` |
| `func` | Custom Callable filter | `{"hp": {"func": func(v): return v % 2 == 0}}` |

> **Rule:** Component property queries are **not supported in `with_none()`**. Filtering absence on property values is logically undefined in archetype ECS.

---

## 3. Change Detection (GECS v9)

In GECS v9, `.changed([ComponentType])` allows systems to process only entities whose component data was mutated since the last system tick:

```gdscript
class_name TransformSyncSystem
extends System

func query() -> QueryBuilder:
	# Only returns entities whose C_Transform was modified since last tick
	return q.with_all([C_Transform]).changed([C_Transform])

func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	for entity in entities:
		var transform := entity.get_component(C_Transform) as C_Transform
		entity.global_position = transform.position
```

* **Benchmark:** Untouched archetypes are skipped via an integer tick comparison. This was measured **13.8× faster** for a 1% write rate across 10,000 entities.
* **Direct Mutations:** If you mutate a component field directly without an emitting setter, call `entity.mark_changed(component)` to flag the archetype dirty.

---

## 4. Querying Pre-Narrowed Arrays with `.from()`

If you already maintain a narrowed subset of entities (e.g. spatial grid cells or faction lists):

```gdscript
var faction_units: Array[Entity] = faction_manager.get_red_team()
var wounded = ECS.world.query \
	.from(faction_units) \
	.with_all([{C_Health: {"current": {"_lt": 50.0}}}]) \
	.execute()
```

### Rules for `.from()`:
1. Supports `.execute()` and `.execute_one()`.
2. **Never return `.from()` from `System.query()` or `Observer.query()`.** Systems and observers rely on reactive archetype indexing, which `.from()` does not participate in.

---

## 5. Query Performance Ranking (10,000 Entities)

| Query Type | Typical Execution | Recommendation |
|---|---|---|
| `.enabled()` / `.disabled()` | 0.1 ms | **Fastest (O(1) bitset)** |
| `.with_all([Components])` | 0.2 ms | **Excellent (Archetype cache)** |
| `.with_any([Components])` | 0.3 ms | **Good** |
| `.changed([Components])` | 0.05–0.1 ms | **Superior for low-frequency writes** |
| `.with_group(["godot_group"])` | 13.6 ms | **AVOID in hot paths** (Uses SceneTree traversal) |

See [`references/query-operators.md`](./references/query-operators.md) for full syntax and complex condition grouping.

