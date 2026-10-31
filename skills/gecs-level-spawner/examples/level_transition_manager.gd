class_name LevelTransitionManager
extends Node

## Manages persistent ECS World across level scene changes.

@onready var world: World = $World
var current_level_node: Node = null


func switch_level(new_level_scene: PackedScene) -> void:
	# 1. Despawn all transient (non-persistent) entities
	var transient_entities := world.query.with_none([C_Persistent]).execute()
	for entity in transient_entities:
		world.remove_entity(entity)

	# 2. Reclaim empty archetype storage
	world.compact()

	# 3. Swap the visual level environment
	if current_level_node != null:
		current_level_node.queue_free()

	current_level_node = new_level_scene.instantiate()
	add_child(current_level_node)

	# 4. Spawners in current_level_node can now register new entities directly into world

