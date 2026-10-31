# GECS Navigation Integration Guide

> **Using ECS with Godot Navigation**

## Components

```gdscript
# Destination target
class_name C_NavDestination extends Component
@export var target_position: Vector3 = Vector3.ZERO

# Navigation status
class_name C_NavStatus extends Component
@export var status: int = 0  # 0=idle, 1=pathing, 2=reached
@export var error: String = ""

# Path data
class_name C_NavPath extends Component
@export var path_points: Array = []
@export var path_index: int = 0

# Agent config
class_name C_NavAgentConfig extends Component
@export var agent_radius: float = 0.5
@export var agent_height: float = 2.0
@export var agent_max_speed: float = 5.0
```

## Entity Setup

```gdscript
var ai = Entity.new()
ai.add_component(C_NavDestination.new())
ai.add_component(C_NavStatus.new())
ai.add_component(C_NavPath.new())
ai.add_component(C_NavAgentConfig.new())

# Add NavigationAgent3D as child node
ECS.world.add_entity(ai)
```

## Navigation Systems

### Update Navigation

```gdscript
class_name NavUpdateSystem extends System

func query() -> QueryBuilder:
    return q.with_all([C_NavDestination, C_NavStatus, C_NavAgentConfig])

func process(entities, delta):
    var destinations = components.get(C_NavDestination)
    var statuses = components.get(C_NavStatus)
    var configs = components.get(C_NavAgentConfig)
    
    for (i, e) in enumerate(entities):
        var agent = e.get_node("NavigationAgent3D")
        if agent == null:
            agent = NavigationAgent3D.new()
            e.add_child(agent)
        
        agent.radius = configs[i].agent_radius
        agent.height = configs[i].agent_height
        agent.max_speed = configs[i].agent_max_speed
        agent.target_position = destinations[i].target_position
        
        if agent.is_navigation_finished():
            statuses[i].status = 2  # Reached
        else:
            statuses[i].status = 1  # Pathing
```

### Request Path

```gdscript
class_name NavRequestPathSystem extends System

func query() -> QueryBuilder:
    return q.with_all([C_NavDestination, C_NavStatus])

func process(entities, delta):
    for (i, e) in enumerate(entities):
        var agent = e.get_node("NavigationAgent3D")
        if agent == null: continue
        
        var start = agent.position
        var end = destinations[i].target_position
        
        var path = NavigationServer3D.map_get_path("", start, end)
        if path:
            pathes[i].path_points = path
            statuses[i].error = ""
        else:
            statuses[i].error = "No path found"
```

### Follow Path

```gdscript
class_name NavFollowPathSystem extends System

func query() -> QueryBuilder:
    return q.with_all([C_NavPath, C_NavStatus, C_Position])

func process(entities, delta):
    for e in entities:
        var path = components.get(C_NavPath)[0]
        var status = components.get(C_NavStatus)[0]
        var pos = components.get(C_Position)[0]
        
        if path.path_points.size() == 0 or status.status == 2: return
        
        var next = path.path_points[path.path_index + 1] if path.path_index + 1 < path.path_points.size() else nil
        if next == nil: 
            status.status = 2; return
        
        var dir = (next - pos.position).normalized()
        pos.position += dir * 5.0 * delta
        
        var dist = pos.position.distance_to(next)
        if dist < 0.1:
            path.path_index += 1
            if path.path_index >= path.path_points.size() - 1:
                status.status = 2
```

## 2D Navigation

### 2D Components

```gdscript
class_name C_NavDestination2D extends Component
@export var target_position: Vector2 = Vector2.ZERO

class_name C_NavStatus2D extends Component
@export var status: int = 0

class_name C_NavPath2D extends Component
@export var points: Array = []
@export var index: int = 0

class_name C_NavAgent2DConfig extends Component
@export var agent_radius: float = 0.5
@export var agent_height: float = 1.0
```

### 2D Systems (same pattern as 3D, use NavigationAgent2D)

## Off-Mesh Links

```gdscript
class_name NavOffMeshSystem extends System

func query() -> QueryBuilder:
    return q.with_all([C_NavDestination, C_Position])

func process(entities, delta):
    for e in entities:
        var dest = e.get_component(C_NavDestination).target_position
        var offmesh = NavigationServer3D.is_position_off_nav_mesh(dest)
        if offmesh:
            var link = NavigationServer3D.get_nearest_off_mesh_link(dest)
            # Handle jump/climb
```

## Debugging

```gdscript
func _process(delta):
    var ents = ECS.world.get_entities_with([C_NavPath, C_Position])
    for e in ents:
        var path = e.get_component(C_NavPath) as C_NavPath
        var pos = e.get_component(C_Position) as C_Position
        for (i, p) in path.path_points:
            if i > 0: DebugDraw.line(prev, p, Color.BLUE)
```

## Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| No path found | Invalid NavMesh | Build NavMesh, check bounds |
| Agent stuck | Radius too large | Reduce radius, check carving |
| Not reaching destination | Off-mesh link | Handle explicitly |
| 2D fails | Missing NavigationRegion2D | Add to scene |

## Best Practices

1. Separate: Destination=where, Status=state, Path=points, Config=agent props
2. Throttle path requests (every 200ms+)
3. Combine navigation + local avoidance
4. Handle off-mesh links for ledges/jumps
5. Use NavigationRegion3D/2D in scene