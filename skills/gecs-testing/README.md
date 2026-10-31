# GECS Testing Guide

> **Testing ECS systems, components, and architectures**

## Test Types

### 1. Component Tests
Validate component defaults and state:
```gdscript
func test_component_defaults():
    var c = C_Health.new()
    assert c.max_health == 100
    assert c.current_health == 100
```

### 2. System Tests
Verify systems process correct entities:
```gdscript
func test_movement_system():
    var e = Entity.new()
    e.add_component(C_Position.new(Vector2(0,0)))
    e.add_component(C_Velocity.new(Vector2(10,0)))
    ECS.world.add_entity(e)
    
    var sys = MovementSystem.new()
    ECS.world.add_system(sys)
    ECS.process(delta=1.0)
    
    var pos = e.get_component(C_Position).position
    assert pos.x == 10.0
```

### 3. Query Tests
Test component filtering:
```gdscript
func test_with_all_matches():
    var e1 = Entity.new()
    e1.add_component(C_Health.new())
    e1.add_component(C_Position.new())
    ECS.world.add_entity(e1)
    
    var q = ECS.world.query.with_all([C_Health, C_Position])
    var results = q.execute()
    assert results.size() == 1
```

### 4. Property Filter Tests
```gdscript
func test_low_health_filter():
    var e = Entity.new()
    e.add_component(C_Health.new())
    e.get_component(C_Health).current_health = 20
    ECS.world.add_entity(e)
    
    var q = ECS.world.query.with_all([{C_Health: {"current": {"_lt": 50}}}])
    var results = q.execute()
    assert results.size() == 1
```

### 5. Integration Tests
Full pipeline: create → process → verify:
```gdscript
func test_full_pipeline():
    var player = Entity.new()
    player.add_component(C_Health.new(100))
    player.add_component(C_Position.new(Vector2.ZERO))
    player.add_component(C_Velocity.new(Vector2(5,0)))
    ECS.world.add_entity(player)
    
    var sys = MovementSystem.new()
    ECS.world.add_system(sys)
    ECS.process(delta=1.0)
    
    var pos = player.get_component(C_Position).position
    assert pos.x == 5.0
```

## Test Utilities

### Setup Helper
```gdscript
func _setup_entities():
    var player = Entity.new()
    player.add_component(C_Health.new(100))
    player.add_component(C_Position.new(Vector2(0,0)))
    player.add_component(C_Velocity.new(Vector2(5,0)))
    ECS.world.add_entity(player)
    
    var enemy = Entity.new()
    enemy.add_component(C_Health.new(50))
    enemy.add_component(C_Position.new(Vector2(100,0)))
    enemy.add_component(C_Velocity.new(Vector2(-5,0)))
    ECS.world.add_entity(enemy)
    
    return {"player": player, "enemy": enemy}
```

### Cleanup
```gdscript
func _cleanup():
    ECS.world.entities.clear()
```

### Assertions
```gdscript
func assert_health(ent, max_val, current_val):
    var h = ent.get_component(C_Health) as C_Health
    assert h.max_health == max_val
    assert h.current_health == current_val

func assert_pos(ent, x, y):
    var p = ent.get_component(C_Position) as C_Position
    assert p.position.x == x
    assert p.position.y == y
```

## Testing Best Practices

| Practice | Description |
|----------|-------------|
| **Isolate tests** | Each test sets up/cleans up own state |
| **Test edge cases** | Empty arrays, boundary values, no matches |
| **Meaningful names** | `test_movement_correct()` not `test1()` |
| **Cover key areas** | Components, queries, systems, performance |
| **Run on CI** | Fail build on test failures |

## Reference

- [Component Queries](gecs-queries) - Filtering patterns
- [Best Practices](gecs-best-practices) - Code organization
- [Core Concepts](gecs-core) - ECS architecture