---
name: gecs-code-review
description: Use when reviewing GDScript GECS code — checklist of best practices, common ECS anti-patterns, CommandBuffer safety, pure data invariants, and performance pitfalls
---

# GECS Code Review Checklist for Godot 4.3+

Structured review guide for GDScript code utilizing GECS v9. Use this checklist to audit entity-component-system architectures against common performance bottlenecks, race conditions, and runtime traps.

> **Related skills:** **gecs-core** for core invariants, **gecs-performance** for optimization guidelines.

---

## 1. Component Review Checklist

- [ ] Extends `Component` (`Resource`).
- [ ] Contains **zero** game logic methods or state machines.
- [ ] Every member variable is typed and annotated with `@export`.
- [ ] All arguments in `_init()` have default fallback values.
- [ ] No engine `Node` references (e.g. `Sprite2D`, `CollisionShape2D`) are stored in the component.
- [ ] Any property watched by observers with `.on_changed()` uses an emitting setter calling `property_changed.emit(self, property, old, new)`.

---

## 2. System Review Checklist

- [ ] Extends `System` (`Node`).
- [ ] Implements `query() -> QueryBuilder` with explicit criteria.
- [ ] Uses `.iterate([Components])` for batch SoA column access in hot paths.
- [ ] **Zero direct world mutations during iteration:** all additions, removals, and component swaps route through `cmd: CommandBuffer`.
- [ ] Heavy systems (AI, pathfinding) use `set_tick_rate()` instead of running every visual frame.
- [ ] Cross-system dependencies are declared via `deps() -> { Runs.After: [...], Runs.Before: [...] }`.

---

## 3. Entity Review Checklist

- [ ] Extends `Entity` (`Node`).
- [ ] Scene-tree children are cached locally on the entity subclass using `@onready` (Scene Glue pattern).
- [ ] `add_child(entity)` is **never** called before `ECS.world.add_entity(entity)`.
- [ ] Spatial casts in systems avoid sibling cast errors (`Entity as CharacterBody3D` returns null; upcasts to `Node` first).
- [ ] Singletons use `entity.alias = &"name"` (v9), never string UUIDs (v8 legacy).

---

## 4. Observer Review Checklist

- [ ] Extends `Observer` (`Node`).
- [ ] Chained at least one event modifier (`.on_added()`, `.on_removed()`, `.on_changed()`, `.on_match()`, `.on_unmatch()`, `.on_event()`) in `query()`.
- [ ] Observer callbacks that trigger further entity/component mutations use `cmd` to prevent recursive cascade loops.

See [`references/review-checklist.md`](./references/review-checklist.md) for full audit output templates.

