class_name CombatMonitor
extends Observer

## Monitor that tracks when an entity enters or exits combat status.


func query() -> QueryBuilder:
	return q.with_all([C_Player, C_InCombat]).on_match().on_unmatch()


func each(event: Variant, entity: Entity, _payload: Variant) -> void:
	match event:
		Observer.Event.MATCH:
			print("Target entered combat: ", entity.name)
		Observer.Event.UNMATCH:
			print("Target exited combat: ", entity.name)

