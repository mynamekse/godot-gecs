# GECS Entity Prefabs and Spawning

## Prefab Structure

A scene Entity is recommended for gameplay objects with Godot-owned Nodes:

```text
e_enemy.tscn
└── Enemy (Enemy extends Entity / Node3D)
    ├── MeshInstance3D
    ├── CollisionShape3D
    └── AnimationPlayer
```

Keep simulation data in Components; cache Node references as entity glue only if they are stable, private to the Entity, never queried, and not resource-safe.

## Component Sources

1. Inspector `component_resources` for stable authored composition.
2. `define_components()` for programmatic composition.
3. Hybrid: Inspector for core data, lifecycle/code for conditional Components.

## Basic Spawn

```gdscript
@export var enemy_prefab: PackedScene

func spawn_enemy(position: Vector3) -> Entity:
    var enemy := enemy_prefab.instantiate() as Entity
    enemy.global_position = position
    ECS.world.add_entity(enemy)
    return enemy
```

For a subclass-specific API, cast to the Entity class rather than stripping it to `Entity` if methods should remain available.

## Custom Parent/Placement

Modern documented GECS placement is managed by `world.add_entity()`. If an addon overload supports explicit `add_to_tree=false`, use that only to preserve a parent/Node owner managed by custom code. Then add the Entity under a known parent and maintain ownership consistently.

## Spawn Systems

Spawn and enqueue structural mutations inside a System. Use `cmd` where removal/addition should be deferred safely. Batch the spawn setup outside frame iteration when exact timing and performance are critical.

## Debugging Spawn Issues

- Verify prefab root has an Entity-compatible script/class.
- Verify `ECS.world` exists before instantiation/addition.
- Verify Components are loaded after registration.
- Verify `global_position` is valid for the actual root type.
- Verify alias replacement and stale IDs in v9.
- Verify entity removal does not race with deferred `queue_free` or the next iteration.
