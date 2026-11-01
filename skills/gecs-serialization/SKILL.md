---
name: gecs-serialization
description: Use when implementing GECS save/load, level export, selective component serialization, binary resource files, or entity relationship persistence.
---

# GECS Serialization

## Basic save/load

```gdscript
var query := ECS.world.query.with_all([C_Persistent])
var data := ECS.serialize(query)
ECS.save(data, "user://savegame.tres", true)

var entities := ECS.deserialize("user://savegame.tres")
for entity in entities:
    ECS.world.add_entity(entity)
```

`binary = true` writes a binary `.res`; pass the `.tres` path shown by the docs because loading auto-detects `.res` first.

## Component data

Only serialized fields declared as `@export` are persisted. Runtime caches and engine Node references are not save data unless explicitly designed into the serialization contract.

## Selective serialization

```gdscript
var config := GECSSerializeConfig.new()
config.include_all_components = false
config.components = [C_Health, C_Inventory]
config.include_relationships = true
config.include_related_entities = false

var data := ECS.serialize(
    ECS.world.query.with_all([C_Player]),
    config
)
```

Set a world-level `default_serialize_config` when persistent defaults apply globally. Individual `entity.serialize_config` values override it.

## Invariants

- Clear or purge existing state before loading when the operation is a full restore.
- Add deserialized entities back through the World.
- Serialize relationships and targets intentionally; `include_related_entities` may pull extra entities into the save.
- Give scene children unique node names before prefab save/load scenarios.

Reference: `docs/SERIALIZATION.md`, `docs/MIGRATION_V9.md`
