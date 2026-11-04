# GECS Entity v9 Migration

## Identity

GECS v8 used String UUID identity. GECS v9 uses a 64-bit generational integer handle in `Entity.id`.

- String identifiers for UI/logging should become aliases.
- Store and compare handles for world lookup and replication.
- Check handles against the current World before use.

```gdscript
var handle := player.id
if ECS.world.is_alive(handle):
    var player := ECS.world.get_entity_by_id(handle)
```

## Aliases

```gdscript
entity.alias = &"player"
var player := ECS.world.get_entity_by_alias(&"player")
```

An alias is a lookup name. Adding an Entity with the same alias replaces the existing Entity according to GECS alias replacement semantics; it does not give the new Entity the old generation's identity.

## Prefab Serialization

Old String IDs in saved data load through mapping/shim behavior and are remapped to fresh handles. Relationship target references are resolved after load according to GECS serialization implementation.

## Iteration

GECS v9 avoids zero-copy entity-array copies by default. Spawn/removal structural changes during System iteration should use the CommandBuffer. `safe_iteration=true` is an opt-in compatibility choice for Systems that depend on copied snapshots.
