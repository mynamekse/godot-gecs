# Node3D/CharacterBody Entity Prefab Example

A scene may use a Node3D or CharacterBody3D root. Verify the GECS/project-supported inheritance pattern before combining `Entity` with another script class hierarchy.

```text
└── Enemy (Node3D or CharacterBody3D-compatible Entity script)
    ├── MeshInstance3D
    ├── CollisionShape3D
    └── NavigationAgent3D
```

```gdscript
class_name Enemy
extends Entity

func define_components() -> Array:
    return [C_Enemy.new(), C_Health.new(50.0), C_Velocity3D.new()]

func on_ready() -> void:
    var transform_component := get_component(C_Transform3D) as C_Transform3D
    if transform_component:
        transform_component.value = global_transform
```

If the root truly uses a Node3D class, cache NavigationAgent3D/CollisionShape3D as stable scene-child glue on the Entity only if Systems do not query the child as ECS state. If physics APIs require CharacterBody3D, use the project-established inheritance composition pattern rather than duplicating transform data across Components and Nodes.
