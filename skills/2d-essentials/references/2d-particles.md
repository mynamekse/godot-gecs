# 2D Particle Systems

## GPU vs CPU

- `GPUParticles2D`: high-count effects driven by GPU
- `CPUParticles2D`: lower-cost control or compatibility for unsupported GPU paths

Both need an intentional lifetime, emission shape, visibility rect, and cleanup strategy.

## GECS Integration

Particle Nodes belong under Entity prefab Scenes when the effect follows a gameplay object. Cache them on the Entity root.

Use Components only when Systems need to control or query emission:

```gdscript
class_name C_EmitsParticles
extends Component

@export var active: bool = false
@export var amount_scale: float = 1.0
```

```gdscript
class_name ParticleSyncSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_EmitsParticles])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    for entity in entities:
        var state := entity.get_component(C_EmitsParticles) as C_EmitsParticles
        var particles := entity.get_node_or_null("Body/Particles") as GPUParticles2D
        if particles:
            particles.emitting = state.active
```

For one-shot world effects, an Entity or pooled scene instance may be appropriate. Spawn via World APIs and remove/disable after completion according to the lifecycle model.
