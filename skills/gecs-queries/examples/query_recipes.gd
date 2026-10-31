class_name QueryRecipes
extends RefCounted

## Cookbook of common GECS QueryBuilder recipes.


## Recipe 1: Retrieve all living players
static func get_living_players() -> Array[Entity]:
	return ECS.world.query \
		.with_all([C_Player, C_Health]) \
		.with_none([C_Dead]) \
		.enabled() \
		.execute()


## Recipe 2: Find all enemies below 20% health
static func get_critically_injured_enemies() -> Array[Entity]:
	return ECS.world.query \
		.with_all([
			C_Enemy,
			{C_Health: {"current": {"_lte": 20.0}}}
		]) \
		.execute()


## Recipe 3: Find a specific singleton by alias (v9)
static func get_player_singleton() -> Entity:
	return ECS.world.get_entity_by_alias(&"player")


## Recipe 4: Custom callable filter
static func get_even_level_entities() -> Array[Entity]:
	return ECS.world.query.with_all([
		{C_Level: {"level": {"func": func(val: int) -> bool: return val % 2 == 0}}}
	]).execute()

