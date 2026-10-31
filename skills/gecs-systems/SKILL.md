---
name: gecs-systems
description: Use when implementing GECS Systems (s_*.gd) — process() loop, fast SoA batching via iterate(), sub-systems, CommandBuffer (cmd) deferred mutations, tick rate scheduling, and dependency ordering
---

# GECS Systems in Godot 4.3+

Implement game logic in GECS v9 systems. Systems query matching archetypes and iterate through entities using fast Structure-of-Arrays (SoA) column access. All structural mutations (adding/removing entities or components) are deferred through `cmd: CommandBuffer` to ensure zero-copy iteration safety.

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-core** for setup, **gecs-queries** for complex query filtering, **gecs-performance** for optimization benchmarks.

---

## 1. System Anatomy

A system inherits from `System` (`Node`).

```gdscript
class_name SimpleMovementSystem
extends System

## 1. Define query criteria
func query() -> QueryBuilder:
	return q.with_all([C_Velocity]).iterate([C_Velocity])

## 2. Process matching entities each frame
func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var velocities: Array = components[0] # Aligned SoA column array

	for i in entities.size():
		var entity := entities[i]
		var vel := velocities[i] as C_Velocity
		entity.position += vel.direction * vel.speed * delta
```

---

## 2. Fast SoA Batching with `iterate()`

In GECS v9, avoid calling `entity.get_component(C_X)` inside hot loops. Instead, use `.iterate([C_A, C_B])` in your `query()`:

```gdscript
func query() -> QueryBuilder:
	# Fetches C_Transform and C_Velocity columns directly from archetype memory
	return q.with_all([C_Transform, C_Velocity]).iterate([C_Transform, C_Velocity])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var transforms: Array = components[0] # Aligned with entities array
	var velocities: Array = components[1] # Aligned with entities array

	for i in entities.size():
		transforms[i].position += velocities[i].direction * velocities[i].speed * delta
```

* **Why?** Calling `entity.get_component()` costs ~0.6 µs per call in GDScript due to dictionary lookups. `iterate()` provides direct array index access, running **3–5× faster**.

---

## 3. Structural Changes via `cmd: CommandBuffer`

GECS v9 iteration defaults to `safe_iteration = false` for zero-copy speed. Modifying the world or entities directly during iteration will corrupt the array traversal.

### Safe Mutation Rules:
```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                       COMMAND BUFFER INVARIANTS                             │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. NEVER call ECS.world.remove_entity(entity) during process() iteration.   │
│ 2. ALWAYS use cmd.remove_entity(entity).                                    │
│ 3. ALWAYS use cmd.add_component(entity, component).                         │
│ 4. ALWAYS use cmd.remove_component(entity, component).                      │
│ 5. Flushes execute safely after iteration completes, automatically         │
│    coalescing archetype transitions (e.g. remove + add = 1 archetype move). │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Sub-Systems (Multiple Queries in One System)

Group related logic into a single system node using `sub_systems()`. Return an array of `[QueryBuilder, Callable, Optional Timer]`:

```gdscript
class_name CombatSystem
extends System

func sub_systems() -> Array[Array]:
	return [
		[q.with_all([C_Health, C_Damage]), _apply_damage],
		[q.with_all([C_Health]).with_none([C_Dead]).iterate([C_Health]), _regenerate_health],
	]

func _apply_damage(entities: Array[Entity], _components: Array, _delta: float) -> void:
	for entity in entities:
		var health := entity.get_component(C_Health) as C_Health
		var damage := entity.get_component(C_Damage) as C_Damage
		health.current -= damage.amount
		cmd.remove_component(entity, damage)
		if health.current <= 0.0:
			cmd.add_component(entity, C_Dead.new())

func _regenerate_health(entities: Array[Entity], components: Array, delta: float) -> void:
	var healths: Array = components[0]
	for i in entities.size():
		healths[i].current = minf(healths[i].current + 2.0 * delta, healths[i].maximum)
```

---

## 5. System Scheduling & Dependencies

### Tick Rate Control
Run expensive systems (such as AI or pathfinding) at reduced frequencies instead of every frame:

```gdscript
func setup() -> void:
	# Run once every 0.25 seconds (4 times per second)
	set_tick_rate(0.25)

	# Or single shot timer:
	# set_tick_rate(5.0, true)
```

### Dependency Ordering
Define explicit execution dependencies using `deps()`:

```gdscript
func deps() -> Dictionary[int, Array]:
	return {
		Runs.After: [MovementSystem, CollisionSystem],
		Runs.Before: [RenderSyncSystem]
	}
```

---

## 6. The PendingDelete Pattern

For entities that require an animation, sound cue, or delay before removal:

See full script at [`examples/s_pending_delete.gd`](./examples/s_pending_delete.gd).

```gdscript
class_name PendingDeleteSystem
extends System

func query() -> QueryBuilder:
	return q.with_all([C_IsPendingDelete])

func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var pending := entity.get_component(C_IsPendingDelete) as C_IsPendingDelete
		pending.delay -= delta
		if pending.delay <= 0.0:
			cmd.remove_entity(entity)
```

