# Custom Drawing with CanvasItem

## Lifecycle

Override `_draw()` on a Node2D, Control, or other CanvasItem subclass. Do not call `_draw()` manually. Call `queue_redraw()` when rendering state changes.

```gdscript
func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2.ZERO, 32.0, Color.WHITE)

func update_radius(value: float) -> void:
    radius = value
    queue_redraw()
```

## GECS Integration

Keep ECS queries out of `_draw()`. A System should derive presentation state and synchronize it to the custom drawing Node.

```gdscript
class_name C_RadarState
extends Component

@export var sweep_angle: float = 0.0
@export var active: bool = true
```

A cached custom-draw Node can expose one setter such as `set_radar_state()` and call `queue_redraw()`. This preserves a clear one-way data flow from ECS Component to rendering Node.

For batched game rendering, prefer `MultiMeshInstance2D` or tile/custom server data only after profiling proves custom CanvasItem drawing is a bottleneck.
