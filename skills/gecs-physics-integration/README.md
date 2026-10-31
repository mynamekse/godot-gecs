# GECS Physics Integration Guide

> **Using ECS with Godot Physics**

## Components (data-only)

```gdscript
# Velocity
class_name C_Velocity extends Component
@export var linear: Vector3 = Vector3.ZERO
@export var angular: Vector3 = Vector3.ZERO

# Mass
class_name C_Mass extends Component
@export var mass: float = 1.0

# Force (accumulated)
class_name C_Force extends Component
@export var accumulated: Vector3 = Vector3.ZERO
```

## Integrate Physics System

```gdscript
class_name IntegratePhysicsSystem extends System

func query() -> QueryBuilder:
    return q.with_all([C_Mass, C_Velocity, C_Force])

func process(entities, components, delta):
    var masses = components.get(C_Mass)
    var velocities = components.get(C_Velocity)
    var forces = components.get(C_Force)
    
    for i, e in enumerate(entities):
        var m = masses[i].mass
        var v = velocities[i].linear
        var f = forces[i].accumulated
        var a = f / m if m > 0 else Vector3.ZERO
        v += a * delta
        forces[i].accumulated = Vector3.ZERO
        e.get_node("PhysicsBody3D").linear_velocity = v
```

## Apply Forces System

```gdscript
class_name ApplyForceSystem extends System

func query() -> QueryBuilder:
    return q.with_all([C_Force])

func process(entities, components, delta):
    var forces = components.get(C_Force)
    for f in forces:
        f.accumulated += Vector3(0, -9.8, 0) * delta  # gravity
```

## System Ordering

```gdscript
ECS.world.add_system(ApplyForceSystem.new(), group="input")
ECS.world.add_system(IntegratePhysicsSystem.new(), group="physics")
ECS.world.add_system(CollisionSystem.new(), group="collision")
# Order: input → physics → collision
```

## 2D Physics

### 2D Components

```gdscript
class_name C_Velocity2D extends Component
@export var linear: Vector2 = Vector2.ZERO

class_name C_Mass2D extends Component
@export var mass: float = 1.0

class_name C_Gravity2D extends Component
@export var gravity: float = -9.8
```

### 2D Integrate System

```gdscript
class_name IntegratePhysics2DSystem extends System

func query() -> QueryBuilder:
    return q.with_all([C_Mass2D, C_Velocity2D, C_Gravity2D])

func process(entities, components, delta):
    for (i, e) in enumerate(entities):
        var m = components.get(C_Mass2D)[i].mass
        var v = components.get(C_Velocity2D)[i].linear
        var g = components.get(C_Gravity2D)[i].gravity
        v.y += g * delta
        var pos = components.get(C_Position)[i]
        pos.position += v * delta
```

## Common Patterns

### Kinematic (mass=0)

```gdscript
var player = Entity.new()
player.add_component(C_Mass.new(0))
player.add_component(C_Velocity.new())
# Control via command buffer
func _input(event):
    if event.is_action_pressed("ui_left"):
        ECS.command_buffer.add_force(player, Vector3(-10,0,0))
```

### Dynamic Body

```gdscript
var box = Entity.new()
box.add_component(C_Mass.new(1.0))
box.add_component(C_Velocity.new())
box.add_component(C_CollisionShape3D.new())
# System integrates each frame
```

### Trigger Zones

```gdscript
var trigger = Entity.new()
trigger.add_component(C_CollisionShape3D.new())
trigger.add_component(C_IsTrigger.new())
# System handles body_entered signals
```

## Debugging

### Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Falls through world | Missing PhysicsBody3D | Add as child of Entity |
| Jittery | Large delta | Cap delta/fixed timestep |
| Forces ignored | Wrong system group | Register in "input" first |
| Velocity stuck | Forgetting to clear forces | Clear accumulated after integrate |

## Best Practices

1. Separate: Components=data, Systems=logic, Nodes=physics bodies
2. Fixed order: input → integrate → collision → cleanup
3. CommandBuffer: Queue forces during input
4. Performance: Only integrate physics entities
5. Network: Replicate position/velocity only