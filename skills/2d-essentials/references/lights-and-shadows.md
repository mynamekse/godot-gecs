# 2D Lights and Shadows

## Nodes

- `PointLight2D`: localized light
- `DirectionalLight2D`: global directional light
- `LightOccluder2D`: shadow geometry source
- `CanvasModulate`: ambient/world tint

## GECS Data Flow

Components should describe gameplay-visible light state only:

```gdscript
class_name C_LightState
extends Component

@export var enabled: bool = true
@export var energy: float = 1.0
@export var color: Color = Color.WHITE
```

A System reads this data and updates the prefab-owned `PointLight2D` or `DirectionalLight2D`. Cache fixed Light nodes on the Entity when it is a stable child.

## Performance and Masks

Configure light and shadow cull masks to prevent unrelated background geometry from receiving light work. Add LightOccluder2D only to shapes that should affect shadows.

Node references belong in Entity glue, not in Components.
