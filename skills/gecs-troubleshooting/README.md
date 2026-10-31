# GECS Troubleshooting Guide

## Installation Issues

### Plugin Not Found
- Initialize submodule: `git submodule update --init --recursive`
- Enable in Project Settings > Plugins (search "GECS")
- Requires Godot 4.6+

### Version Compatibility
- GECS v8.0.0+ requires Godot 4.6+
- Godot 4.5 and earlier: incompatible performance monitor code
- Solution: Upgrade Godot to 4.6 or newer

## Entity Component Issues

### Component Not Found
**Cause:** Component not added before adding to world
**Solution:**
```gdscript
var entity = Entity.new()
entity.add_component(C_Health.new())
ECS.world.add_entity(entity)
```

### Missing Default Values
**Cause:** @export variables without defaults
**Solution:** Always provide defaults:
```gdscript
@export var max_health: int = 100  # ← Required
```

## System Issues

### System Not Processing
**Cause:** System not registered or _process() not called
**Solution:**
```gdscript
ECS.world.add_system(MovementSystem.new())
func _process(delta): ECS.process(delta)  # Must call
```

### Query Not Matching
**Cause:** Too broad/narrow query conditions
**Solution:** Use specific `with_all()` queries, check property filters

## Performance Issues

### Low FPS
- Too many systems per frame
- Expensive operations in process()
- Use SystemTimer to throttle
- Profile with Debug Viewer

### Stale Query Cache
- Ensure proper entity addition/removal
- Call `query.execute()` after modifications

## Relationship Issues

### Relationship Not Working
**Cause:** Relationship type mismatch or target not in world
**Solution:**
```gdscript
var rel = Relationship.new(C_AllyTo.new())
player.add_relationship(rel, target_entity)
ECS.world.add_entity(target_entity)
```

## Serialization Issues

### Save/Load Fails
**Cause:** Transient components or missing defaults
**Solution:** Only serialize necessary components, ensure @export defaults

### Data Corruption
**Cause:** State changes between save/load
**Solution:** Re-establish relationships after load, test cycles thoroughly

## Getting Help

### Issue Report Checklist
- GECS version
- Godot version
- Full error message
- Minimal reproduction steps
- Project entity/component structure
- Recent changes before issue

### Community
- Discord: [discord.gg/eB43XU2tmn](https://discord.gg/eB43XU2tmn)
- GitHub Discussions: [questions](https://github.com/csprance/gecs/discussions)
- GitHub Issues: [bug reports](https://github.com/csprance/gecs/issues)

## Quick Checklist

| Issue | Check |
|-------|-------|
| Plugin enabled? | □ |
| Godot 4.6+? | □ |
| Component defaults? | □ |
| Entities in world? | □ |
| Systems registered? | □ |
| Queries correct? | □ |
| Debug Viewer on? | □ |