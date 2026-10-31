class_name PendingDeleteSystem
extends System

## System that handles delayed removal of entities (e.g. death delays, particles).


func query() -> QueryBuilder:
	return q.with_all([C_IsPendingDelete])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var pending := entity.get_component(C_IsPendingDelete) as C_IsPendingDelete
		if pending == null:
			continue

		pending.delay -= delta
		if pending.delay <= 0.0:
			cmd.remove_entity(entity)

