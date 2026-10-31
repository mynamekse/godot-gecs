---
name: gecs-observers
description: Use when building reactive event-driven logic in GECS — Observer nodes (o_*.gd), each() callback, .on_added(), .on_removed(), .on_changed(), monitors (.on_match(), .on_unmatch()), custom events, and breaking cascade loops with cmd
---

# GECS Observers in Godot 4.3+

Implement reactive, event-driven game logic using GECS v9 Observers. Unlike systems which tick every frame, an `Observer` activates only when specific lifecycle transitions occur (components added/removed, properties mutated, query match sets changed, or custom events dispatched).

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-core** for primitives, **gecs-systems** for frame-based logic, **gecs-queries** for query construction.

---

## 1. Anatomy of an Observer

An observer extends `Observer` (`Node`) and implements `query()` with event modifiers and the `each()` callback:

```gdscript
class_name HealthObserver
extends Observer

## 1. Define query and chain event modifiers
func query() -> QueryBuilder:
	return q.with_all([C_Health, C_Player]).on_added().on_removed()

## 2. Receive matching events
func each(event: Variant, entity: Entity, payload: Variant) -> void:
	match event:
		Observer.Event.ADDED:
			print("Health component added to: ", entity.name)
		Observer.Event.REMOVED:
			print("Health component removed from: ", entity.name)
```

> **Warning:** A query that returns `q.with_all([...])` without chaining any event modifiers will never fire. In editor builds, GECS will emit a `push_warning`.

---

## 2. Event Types & Modifiers

| Modifier | `Observer.Event` | When It Fires | `payload` Content |
|---|---|---|---|
| `.on_added()` | `ADDED` | Watched component added to entity | The component instance just added |
| `.on_removed()` | `REMOVED` | Watched component removed | The component instance just removed |
| `.on_changed([&"prop"])` | `CHANGED` | Emitting setter fired on watched component | Dictionary: `{component, property, old_value, new_value}` |
| `.on_match()` | `MATCH` | Entity transitions **into** query match set | `null` |
| `.on_unmatch()` | `UNMATCH` | Entity transitions **out of** query match set | `null` |
| `.on_relationship_added([C_X])`| `RELATIONSHIP_ADDED` | Watched relationship added | The `Relationship` instance |
| `.on_relationship_removed([C_X])`| `RELATIONSHIP_REMOVED` | Watched relationship removed | The `Relationship` instance |
| `.on_event(&"custom_name")` | `StringName` | Dispatched via `world.emit_event()` | Arbitrary data passed to emit |

---

## 3. Monitors: `.on_match()` and `.on_unmatch()`

Monitors track **state transitions**. They fire **exactly once** when an entity qualifies for the entire query filter, and **once** when it ceases to qualify (e.g. loses a component, is disabled, or is removed from the world).

See full script at [`examples/o_combat_monitor.gd`](./examples/o_combat_monitor.gd).

```gdscript
class_name CombatTargetMonitor
extends Observer

func query() -> QueryBuilder:
	return q.with_all([C_Player, C_Alive, C_InCombat]).on_match().on_unmatch()

func each(event: Variant, entity: Entity, _payload: Variant) -> void:
	match event:
		Observer.Event.MATCH:
			CombatManager.register_target(entity)
		Observer.Event.UNMATCH:
			CombatManager.unregister_target(entity)
```

---

## 4. Custom Events (`world.emit_event()`)

Dispatch one-off decoupling events across the entire world:

```gdscript
# 1. Emit an event (entity can be null for global broadcasts)
ECS.world.emit_event(&"damage_dealt", target_entity, {
	"amount": 25.0,
	"source": player_entity
})

# 2. Subscribe in an Observer
func query() -> QueryBuilder:
	return q.with_all([C_Alive]).on_event(&"damage_dealt")

func each(_event: Variant, entity: Entity, data: Variant) -> void:
	var health := entity.get_component(C_Health) as C_Health
	health.current -= data.amount
```

---

## 5. Multi-Axis Observers with `sub_observers()`

When a single node needs to watch different queries with distinct callbacks:

```gdscript
func sub_observers() -> Array[Array]:
	return [
		[q.with_all([C_Health]).on_added().on_removed(), _on_health_lifecycle],
		[q.with_all([C_Player, C_Alive]).on_match().on_unmatch(), _on_alive_state],
		[q.with_all([C_Player]).on_event(&"level_up"), _on_level_up]
	]

func _on_health_lifecycle(event: Variant, entity: Entity, payload: Variant) -> void:
	pass

func _on_alive_state(event: Variant, entity: Entity, _payload: Variant) -> void:
	pass
```

---

## 6. Breaking Mutation Cascades with `cmd`

If an observer callback modifies entities or components, **always use `cmd: CommandBuffer`** to defer mutations. This avoids recursive dispatch and stack overflow loops:

```gdscript
# ✅ GOOD: Safe deferred cleanup via cmd
func each(event: Variant, entity: Entity, _payload: Variant) -> void:
	if event == Observer.Event.REMOVED:
		for child in get_linked_children(entity):
			cmd.remove_entity(child)
```

