---
name: gecs-serialization
description: Use when implementing save/load systems, level export, or entity persistence in GECS — ECS.serialize(), ECS.save(), ECS.deserialize(), GECSSerializeConfig, binary .res vs text .tres, and duplicate node name pitfalls
---

# GECS Serialization in Godot 4.3+

Persist and restore game state using GECS v9 serialization. Convert matching query results to serialized `GecsData`, save to disk in text (`.tres`) or compact binary (`.res`) formats, and restore entities with relationships and components intact.

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-core** for components, **gecs-queries** for serialization queries.

---

## 1. Quick Start: Save & Load

```gdscript
# 1. Save all persistent entities
func save_game(filepath: String = "user://savegame.tres") -> bool:
	var query := ECS.world.query.with_all([C_Persistent])
	var data: GecsData = ECS.serialize(query)
	return ECS.save(data, filepath, false) # false = .tres, true = binary .res

# 2. Load entities and restore into world
func load_game(filepath: String = "user://savegame.tres") -> void:
	ECS.world.purge() # Clear existing entities
	var entities: Array[Entity] = ECS.deserialize(filepath)
	for entity in entities:
		ECS.world.add_entity(entity)
```

---

## 2. Format Comparison: `.tres` vs `.res`

| Feature | Text Format (`.tres`) | Binary Format (`.res`) |
|---|---|---|
| **Inspection** | Human readable (plain text) | Binary (compact) |
| **Version Control** | Diffable in Git | Binary blob |
| **File Size** | Larger | Significantly smaller |
| **Load Speed** | Slower (parsing overhead) | Fast |
| **Best For** | Development, modding, debugging | Production releases, mobile |

---

## 3. Configuration with `GECSSerializeConfig`

Control which components and relationships are saved:

```gdscript
var config := GECSSerializeConfig.new()
config.include_all_components = false
config.components = [C_Health, C_Inventory, C_Transform]
config.include_relationships = true
config.include_related_entities = false # Avoid pulling in external targets

var data = ECS.serialize(ECS.world.query.with_all([C_Player]), config)
```

---

## 4. Critical Gotchas

### 1. Duplicate Scene Tree Node Names
* Godot auto-renames nodes with duplicate names in the SceneTree (e.g. `"Player"` becomes `"@Node@194"`).
* If you serialize entities with duplicate names, their saved names will be corrupted.
* **Fix:** For pure data entities, set `add_to_tree = false` when adding:
  ```gdscript
  world.add_entity(entity, null, false)
  ```

### 2. ID Collision on Load
* In GECS v9, when an entity with an existing ID is loaded into the world, it replaces the old entity, and any relationships pointing to the old entity are cleanly removed by the `REMOVE` policy.

