# GECS Entity API Summary

## Class and File Conventions

- Class: `Player`, `Enemy`, `PickupItem`
- File: `e_player.gd`, `e_enemy.gd`, `e_pickup_item.gd`
- Base: `extends Entity`

## Component Composition

```gdscript
func define_components() -> Array:
    return [C_Player.new(), C_Health.new(100.0)]
```

Stable Components may be authored in the scene Inspector through `component_resources`. The World loads them when the Entity is registered.

## Entity Operations

```gdscript
entity.add_component(C_Health.new(100.0))
entity.remove_component(C_Health)
entity.has_component(C_Health)
entity.get_component(C_Health)
```

Use Component classes for lookup/query operations and instances to construct/add data.

## Lifecycle Hooks

- `define_components()` provides programmatic initial composition.
- `on_ready()` performs Entity glue/setup after Components and SceneTree child state are ready.
- `on_destroy()` handles cleanup while the Entity is being removed.
- Enable/disable hooks handle reactivation/pooling behavior where the addon/version documents them.

## SceneRoot Compatibility

`Entity` itself is a Node. Spatial APIs exist only if the actual root or inherited class supplies them, such as Node2D, Node3D, CharacterBody2D/3D or another spatial subtype.

## Identifier API

In GECS v9:

```gdscript
var handle := entity.id
var alive := ECS.world.is_alive(handle)
var by_id := ECS.world.get_entity_by_id(handle)
var by_alias := ECS.world.get_entity_by_alias(&"player")
```

Aliases are lookup names, not entity identities. Same-alias registration replacement must be handled intentionally.
