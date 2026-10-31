# GECS Best Practices Guide

> **Write maintainable, performant ECS code with GECS**

## Component Design Principles

### Keep Components Data-Only
- Components should contain **only data**, no logic or methods
- Avoid @export with complex expressions
- Use simple types: int, float, Vector2, Vector3, bool, String, ResourceRef

### Meaningful Component Names
- Prefix with `C_`: `C_Health`, `C_Position`, `C_Velocity`
- Singular nouns describe state: `C_Health` not `C_HealthSystem`
- Avoid duplicating system logic in components

### Component Default Values
```gdscript
# Good - has default
@export var max_health: int = 100

# Bad - no default (will error on export)
@export var max_health: int
```

## System Design Principles

### Single Responsibility Principle
- Each system should handle **one concern**
- Good: `MovementSystem`, `CollisionSystem`, `HealthSystem`
- Bad: System that handles movement, combat, and UI updates

### Focused Queries
```gdscript
# Good - specific query
func query() -> QueryBuilder:
    return q.with_all([C_Position, C_Velocity])

# Bad - overly broad query
func query() -> QueryBuilder:
    return q.with_all([C_Entity, C_Anything])
```

### Process Efficiency
- Access components once, cache if needed
- Use `delta` parameter for frame-independent movement
- Avoid expensive operations in `_process()`

## Entity Management

### Entity Prefabs over Runtime Creation
- Create scene files with Entity root node
- Save as `.tscn` files for reuse
- Include visualization children separately from ECS data

### Consistent Naming Conventions
- **Class names**: `ClassCase` (e.g., `Player`, `Enemy`, `C_Health`)
- **Files**: `c_component_name.gd` or `s_system_name.gd`
- **Entities**: `e_entity_name.gd` or scene name matching class

### Lifecycle Management
- Initialize components in `define_components()` or constructor
- Use `on_ready()` for scene sync, not component logic
- Cleanup in `on_destroy()` if needed

## Query Optimization

### Cache Query Results
- Queries are automatically cached by component combination
- Avoid creating same query multiple times in same process cycle
- Use `with_all()`, `with_any()`, `with_none()` appropriately

### Property-Based Filtering
```gdscript
# Filter by component property values
var low_health = ECS.world.query.with_all([
    {C_Health: {"current": {"_lt": 20}}}
]).execute()
```

### Order Independence
```gdscript
# These yield identical results:
ECS.world.query.with_all([C_Health, C_Position])
ECS.world.query.with_all([C_Position, C_Health])
```

## System Organization

### Use System Groups
Organize systems by execution order:
```
run-first:   Initialization systems
input:       Input handling  
gameplay:    Game logic
physics:     Physics calculations
ui:          UI updates
run-last:    Cleanup systems
```

### Register in Scenes
- Create `default_systems.tscn` scene with SystemGroup nodes
- Drag systems into appropriate groups in Godot editor
- Easy reordering and configuration via inspector

## Serialization

### Persistent Components
- Mark components that need saving with proper defaults
- Use `ECS.serialize()` and `ECS.save()/load()` for game state
- Consider versioning for component structure changes

### Non-Persistent Components
- Components transient by default
- Reset on game reload if needed
- Don't include in serialization unless required

## Debugging & Performance

### Use Debug Viewer
- Enable real-time performance monitoring
- Inspect entity-component-archetype relationships
- Profile system execution times

### Step Debugger
- Pause ECS forward one step at a time
- Track mutation log for changes
- Visualize entity relationship graph

### Profile Before Optimizing
- Use Performance Optimization guide metrics
- Identify hotspots with profiler
- Optimize critical systems only

## Common Pitfalls to Avoid

| Anti-Pattern | Better Approach |
|-------------|----------------|
| Systems with broad queries | Specific `with_all()` queries |
| Components with logic/methods | Data-only components + separate systems |
| Runtime entity creation without prefabs | Scene-based entity prefabs |
| Expensive operations in `_process()` | Move to physics/tick-rate systems |
| No system organization | Use system groups with clear order |
| Inconsistent component naming | Follow `C_` prefix convention |
| Serializing all components | Only serialize necessary state |
| Skipping debug tools | Use Debug Viewer & Step Debugger |

## Checklist Before Commit

- [ ] Components are data-only (no logic)
- [ ] System has single responsibility
- [ ] Query is specific and efficient
- [ ] Entity naming follows conventions
- [ ] System registered in appropriate group
- [ ] Default values set for all @export variables
- [ ] No duplicate component functionality
- [ ] Performance considerations addressed
- [ ] Debug tools enabled for testing

---

**Reference Guides:**
- [Core Concepts](gecs-core) - ECS architecture fundamentals
- [Component Queries](gecs-queries) - Advanced filtering
- [Relationships](gecs-relationships) - Entity linking
- [Performance Optimization](gecs-performance) - Profiling tips
- [Best Practices](gecs-best-practices) - This guide

*Following these practices ensures your GECS codebase remains maintainable, performant, and scalable as your game grows.*