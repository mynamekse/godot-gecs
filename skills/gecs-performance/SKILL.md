---
name: gecs-performance
description: Use when profiling, diagnosing low FPS, or optimizing GECS games — SoA column iteration, entity pooling (enable/disable), query cache statistics, GDScript overhead ceiling, and v9 benchmarks
---

# GECS Performance & Optimization in Godot 4.3+

Maximize simulation throughput in GECS v9. Because GDScript runs on a dynamic bytecode VM with function call overhead (~0.6 µs per call), high-performance ECS in Godot relies on archetype SoA column arrays, query caching, and entity pooling.

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-systems** for SoA `iterate()`, **gecs-queries** for query speed tiers.

---

## 1. The GDScript Ceiling & Architecture

In native C/C++ ECS engines (like FLECS), millions of entities can be updated per frame. In GDScript, the engine overhead is bound by Variant dispatch (~1.5–3 µs per entity/system):

| Scale | Entity Count | Performance Target | Recommended Strategy |
|---|---|---|---|
| **Small** | 100–500 | 60+ FPS | Any standard pattern |
| **Medium** | 500–2,000 | 60 FPS | Use `iterate()`, avoid `get_component()` in loops |
| **Large** | 2,000–10,000 | 60 FPS | Entity pooling, change detection `.changed()`, batch `cmd` |
| **Massive** | 10,000+ | 30–60 FPS | Throttle system tick rates, split heavy logic into C# / GDExtension |

---

## 2. Optimization Golden Rules

### 1. Batch SoA with `iterate()`
Always fetch column arrays using `.iterate([Components])` in `query()`. This eliminates per-entity dictionary lookup overhead.

### 2. Batch Structural Mutations
Instead of calling `add_component()` multiple times, batch them in a single call:
```gdscript
# ❌ Slower: 2 separate archetype transitions
entity.add_component(C_A.new())
entity.add_component(C_B.new())

# ✅ 66% Faster: 1 combined archetype transition
entity.add_components([C_A.new(), C_B.new()])
```

### 3. Entity Pooling via `enable_entity()` / `disable_entity()`
Allocating and freeing nodes churns the scene tree. Pooling disabled entities retains their components and archetype assignment:
* **Benchmark:** Pooling is **~6× faster** than full instantiate + `add_entity` + `queue_free` cycles (17.6 ms vs 97.7 ms for 1k entities).

---

## 3. Entity Pool Implementation

See template at [`examples/entity_pool.gd`](./examples/entity_pool.gd).

```gdscript
class_name EntityPool
extends RefCounted

var _pool: Array[Entity] = []

func acquire() -> Entity:
	if _pool.is_empty():
		var entity := Entity.new()
		# Add components once
		ECS.world.add_entity(entity, [C_Bullet.new()])
		return entity
	
	var entity := _pool.pop_back()
	ECS.world.enable_entity(entity)
	return entity

func release(entity: Entity) -> void:
	ECS.world.disable_entity(entity)
	_pool.append(entity)
```

---

## 4. Query Cache Monitoring

Inspect cache efficiency at runtime:

```gdscript
var stats = ECS.world.get_cache_stats()
print("Cache hits: ", stats.get("cache_hits", 0))
print("Cache misses: ", stats.get("cache_misses", 0))

# Opt-in performance instrumentation:
ECS.world.perf_instrumentation = true
var frame_metrics = ECS.world.perf_get_frame_metrics()
```

See [`references/benchmarks-v9.md`](./references/benchmarks-v9.md) for detailed performance tables comparing GECS v8 vs v9.

