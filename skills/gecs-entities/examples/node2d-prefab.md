# Node2D Entity Prefab Example

Scene structure:

```text
└── Player (Node2D, script Player extends Entity)
    ├── Sprite2D
    ├── CollisionShape2D
    └── AnimationPlayer
```

```gdscript
# e_player.gd
class_name Player
extends Entity

func define_components() -> Array:
    return [C_Player.new(), C_Health.new(100.0), C_Velocity2D.new()]

func on_ready() -> void:
    var transform_component := get_component(C_Transform2D) as C_Transform2D
    if transform_component:
        transform_component.value = global_transform
```

Instantiation:

```gdscript
@export var player_prefab: PackedScene

func spawn_player(position: Vector2) -> Player:
    var player := player_prefab.instantiate() as Player
    player.global_position = position
    ECS.world.add_entity(player)
    return player
```

The Components own ECS state; child Nodes remain scene-owned glue/visual state and should not duplicate queried gameplay data unless there is a synchronization contract.
