# GECS Networking Guide

> **Multiplayer synchronization for GECS entities**

## Quick Start

### Install Network Addon
```bash
# Core GECS
git submodule add -b release-v8.0.0 https://github.com/csprance/gecs.git addons/gecs

# Network addon
git submodule add -b release-v1.0.0 https://github.com/csprance/gecs_network.git addons/gecs_network
```

### Enable Plugins
- Enable "GECS" and "GECS Network" in Project Settings > Plugins

## Core Concepts

### NetAdapter Abstraction
Connects GECS to transport providers:
- **ENet** - UDP-based, lightweight
- **Steam** - Steam Native SDK
- **Custom** - Your backend

### Replicated Components
Only marked components sync over network:
```gdscript
class_name C_Health extends Component
@export var current_health: int = 100  # Auto-synced
```

## Configuration

### NetAdapter Initialize
```gdscript
var net = ECS_NetAdapterENet.new()
net.initialize("res://network_config.json")
```

### Config (network_config.json)
```json
{
  "transport": "enet",
  "host_type": "server",
  "port": 8080,
  "max_players": 4
}
```

## Replication Patterns

### Interest-Based
```gdscript
# Sync to all clients
player.add_component(C_ReplicateToAll.new())

# Sync only near clients
item.add_component(C_ReplicateInRadius.new(radius: 50.0))

# Server authoritative only
ai.add_component(C_AuthoritativeOnly.new())
```

### Command Buffer
Queue structural changes during processing:
```gdscript
func process(entities, components, delta):
    var cmd = ECS.command_buffer
    for entity in entities:
        if should_delete:
            cmd.delete_entity(entity)
    cmd.flush(FlushMode.PER_SYSTEM)
```

### Flush Modes
- `PER_SYSTEM` - After each system
- `PER_GROUP` - After each group  
- `MANUAL` - Explicit call

## Client-Server

### Server Authority
- Server controls entity state
- Clients receive updates only
- Client prediction for latency compensation

### Scene Sync
```gdscript
# Server spawns
var e = ECS.world.create_entity()
e.add_component(C_Position.new(Vector3(100,0,0)))
net.spawn_entity(e, connection_id)
```

## Interest Management

### View Radius
```gdscript
net.set_view_radius(connection_id, 100.0)
var interested = net.get_interested_entities(connection_id)
```

## Common Issues

### Entity Out of Sync
- Ensure changes go through replication
- Flush at correct level (PER_SYSTEM/PER_GROUP)
- Check command buffer usage

### Late Joiner
- Server sends initial state on connect
- Or use ECS.save()/load() for snapshots

### Packet Loss
- Set replicate_when threshold
- Use reliable transport for critical data

## Debugging

### Enable Logging
```gdscript
ECS_NetAdapter.set_debug_mode(true)
# Check Godot Console
```

### Key Commands
```gdscript
net.is_connected()
net.get_connected_players()
net.get_synced_entities()
```

## Best Practices

1. **Minimize replicated components** - Only essential state
2. **Appropriate flush levels** - PER_SYSTEM for action games
3. **Handle connection states** - connected/waiting_for_host/error
4. **Test with latency** - Simulate 100ms+ latency
5. **Version components** - Include version numbers

## Reference

- GECS Network Addon: [github.com/csprance/gecs_network](https://github.com/csprance/gecs_network)
- Core ECS: skills/gecs-core
- Performance: skills/gecs-performance