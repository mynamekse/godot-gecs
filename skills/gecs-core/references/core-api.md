# GECS Core API Summary

## Entity

Entities are Nodes. Scene roots should be Node3D, Node2D or plain Node according to the feature.

```gdscript
class_name Player
extends Entity

func define_components() -> Array:
    return [C_Player.new(), C_Health.new(100.0)]
```

Lifecycle hooks documented by GECS: initialization, `define_components()`, `on_ready()`, `on_destroy()`, `on_disable()` and `on_enable()`.

## Component

Components extend `Component` and hold serializable data.

```gdscript
class_name C_Health
extends Component

@export var current: float = 100.0
@export var maximum: float = 100.0

func _init(max_health: float = 100.0) -> void:
    maximum = max_health
    current = max_health
```

## System

```gdscript
class_name HealthSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_Health])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    pass
```

System lifecycle: `setup()`, `query()`, `process(...)`. Tick with `set_tick_rate(seconds)`.

## World

```gdscript
ECS.world = $World
ECS.process(delta)
ECS.process(delta, "physics")
ECS.world.add_entity(entity)
ECS.world.remove_entity(entity)
ECS.world.purge()
ECS.world.compact()
```

## QueryBuilder

```gdscript
q.with_all([C_A, C_B])
q.with_any([C_A, C_B])
q.with_none([C_C])
q.enabled()
q.disabled()
q.iterate([C_A])
q.execute()
q.execute_one()
q.matches(entity_list)
q.combine(other_query)
```

## Serialization

`ECS.serialize(query, config)` returns `GecsData`, `ECS.save(data, path, binary)` writes it and `ECS.deserialize(path)` loads Entity instances.

Only exported Component fields serialize. Use `GECSSerializeConfig` for selective components and relationship inclusion.
