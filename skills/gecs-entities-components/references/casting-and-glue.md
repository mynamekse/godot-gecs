# GECS Entity Casting & Scene Glue Specifications

In Godot, `Entity` extends `Node`. This architecture allows entities to live directly within the Godot SceneTree while having their data processed in high-performance ECS archetype storage.

---

## 1. Scene Glue Pattern

A common ECS dilemma is: *Where should scene tree nodes (like RayCast3D, Camera3D, or AudioStreamPlayer) live?*

### The Rules:
1. **Never create components solely to wrap Node references.**
   Components must remain pure data (Resources). Wrapping nodes inside resources causes resource leakages and breaks serialization.
2. **Keep Engine Nodes as Children of the Entity.**
   Place child nodes in the entity scene tree.
3. **Cache References on the Entity Subclass.**
   Use `@onready var` on your `class_name MyEntity extends Entity` script to expose direct typed access for systems.

---

## 2. Casting Hierarchy in GDScript

```text
       Node (Godot Engine Base)
        /                    \
     Entity (GECS)       CharacterBody2D/3D (Engine Physics)
       |
  PlayerEntity
```

### Type Invariants:
* `Entity` and `CharacterBody2D` are siblings. Direct casting will return `null`.
* If a system processes entities whose roots are different node types, upcast to `Node` before inspecting:
  ```gdscript
  func process(entities: Array[Entity], _components: Array, _delta: float) -> void:
      for i in entities.size():
          var node: Node = entities[i]
          var body := node as CharacterBody2D
          if body:
              body.move_and_slide()
              continue
          var spatial := node as Node2D
          if spatial:
              spatial.position += Vector2.RIGHT
  ```

