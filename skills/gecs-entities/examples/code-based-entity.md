# Code-Based Entity Example

```gdscript
# e_timer.gd
class_name GameTimer
extends Entity

func define_components() -> Array:
    return [C_Timer.new(30.0), C_Enabled.new()]
```

```gdscript
func create_timer() -> GameTimer:
    var timer := GameTimer.new()
    ECS.world.add_entity(timer)
    return timer
```

Use this form for simulation-only entities that do not need a Godot-owned visual or physics Node. If a timer later needs an animation or scene child, prefer a scene-based Entity or cache that child only as documented glue.
