# Spawning, Removal and Pooling

## Spawn

```gdscript
@export var projectile_prefab: PackedScene

func spawn_projectile(position: Vector3) -> Entity:
    var projectile := projectile_prefab.instantiate() as Entity
    projectile.global_position = position
    ECS.world.add_entity(projectile)
    return projectile
```

## Deferred Removal in a System

```gdscript
class_name LifetimeSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_Lifetime])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    for entity in entities:
        var lifetime := entity.get_component(C_Lifetime) as C_Lifetime
        lifetime.remaining -= delta
        if lifetime.remaining <= 0.0:
            cmd.remove_entity(entity)
```

## Pooling Decision

Pool only when spawn/despawn costs and reset costs are understood. A pooled Entity retains identity, memory and Component state; reset all gameplay and SceneTree fields intentionally.

```gdscript
func reset_projectile(projectile: Entity, position: Vector3) -> void:
    ECS.world.enable_entity(projectile)
    projectile.global_position = position
    projectile.get_component(C_Velocity).value = Vector3.ZERO
    projectile.get_component(C_Lifetime).remaining = 2.0
```

For normal deletion, use the GECS removal API and allow lifecycle cleanup. Do not use pooling and removal interchangeably.
