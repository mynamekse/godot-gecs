# Basic GECS System

```gdscript
# c_lifetime.gd
class_name C_Lifetime
extends Component

@export var remaining: float = 1.0

func _init(seconds: float = 1.0) -> void:
    remaining = seconds
```

```gdscript
# s_lifetime.gd
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

```gdscript
# main.gd
extends Node

@onready var world: World = $World

func _ready() -> void:
    ECS.world = world
    var projectile := Entity.new()
    ECS.world.add_entity(projectile, [C_Lifetime.new(0.5)])

func _process(delta: float) -> void:
    ECS.process(delta, "gameplay")
```
