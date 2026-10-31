# Nodeless Entities & MultiMesh Rendering Guide

When scaling Godot projects to tens of thousands of entities, the Godot SceneTree becomes the primary bottleneck rather than ECS itself.

---

## 1. The Cost of SceneTree Nodes

Every standard `Node2D` or `Node3D` introduces:
* Transform matrix propagation through parent-child chains.
* Visibility and rendering draw calls.
* Memory overhead of full engine `Object` instances.

---

## 2. Nodeless Entity Pattern (`add_to_tree = false`)

In GECS, an entity can exist purely inside the archetype data columns without being attached to the Godot SceneTree:

```gdscript
ECS.world.add_entity(entity, [C_Transform2D.new(), C_Velocity.new()], false)
```

### Benefits:
* **Zero SceneTree Overhead:** No node traversal, no tree enter/exit notifications.
* **Instant Allocation:** Thousands can be spawned with zero frame drop.
* **Render via MultiMesh:** A dedicated `System` writes entity positions into a single `MultiMesh` buffer, rendering 20,000 sprites in **1 draw call**.

