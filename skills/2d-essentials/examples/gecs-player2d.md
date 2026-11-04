# GECS 2D Player Prefab Example

## Scene

```text
e_player.tscn
└── Player (Node2D, script extends Entity)
    └── Body (CharacterBody2D)
        ├── Sprite2D
        ├── CollisionShape2D
        ├── Camera2D
        └── GPUParticles2D
```

## Entity Glue

```gdscript
class_name Player
extends Entity

@onready var body: CharacterBody2D = $Body
@onready var sprite: Sprite2D = $Body/Sprite2D
@onready var particles: GPUParticles2D = $Body/GPUParticles2D

func define_components() -> Array:
    return [
        C_Player.new(),
        C_Input2D.new(),
        C_Velocity2D.new(),
        C_MovementSpeed.new(300.0),
        C_Render2D.new(),
    ]
```

## Movement System

```gdscript
class_name PlayerMovementSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_Player, C_Input2D, C_Velocity2D, C_MovementSpeed])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    for entity in entities:
        var input := entity.get_component(C_Input2D) as C_Input2D
        var velocity := entity.get_component(C_Velocity2D) as C_Velocity2D
        var speed := entity.get_component(C_MovementSpeed) as C_MovementSpeed
        var body := entity.body as CharacterBody2D

        body.velocity = input.direction.normalized() * speed.value
        body.move_and_slide()
        velocity.value = body.velocity
```

## Render Sync System

```gdscript
class_name PlayerRenderSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_Player, C_Velocity2D, C_Render2D])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    for entity in entities:
        var velocity := entity.get_component(C_Velocity2D) as C_Velocity2D
        var render_state := entity.get_component(C_Render2D) as C_Render2D
        entity.sprite.flip_h = velocity.value.x < 0.0
        entity.sprite.visible = render_state.visible
        entity.sprite.modulate = render_state.modulation
        entity.sprite.z_index = render_state.z_index
```

The Entity caches body/sprite nodes once. The Systems own movement and synchronization behavior, while the Components own queryable data and render state.
