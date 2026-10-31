class_name SaveLoadManager
extends RefCounted

## Utility class providing robust save and load flows for GECS projects.


static func save_player_state(slot: int = 1) -> bool:
	var query := ECS.world.query.with_all([C_Persistent])
	var config := GECSSerializeConfig.new()
	config.include_all_components = true
	config.include_relationships = true

	var data = ECS.serialize(query, config)
	var path := "user://save_slot_%d.res" % slot
	return ECS.save(data, path, true)


static func load_player_state(slot: int = 1) -> bool:
	var path := "user://save_slot_%d.res" % slot
	if not FileAccess.file_exists(path):
		return false

	ECS.world.purge()
	var entities := ECS.deserialize(path)
	for entity in entities:
		ECS.world.add_entity(entity)

	return true

