class_name HealthUIObserver
extends Observer

## Reactive observer updating health UI when C_Health changes.


func query() -> QueryBuilder:
	return q.with_all([C_Health, C_Player]).on_changed([&"current"])


func each(event: Variant, entity: Entity, payload: Variant) -> void:
	if event == Observer.Event.CHANGED:
		var new_val: float = payload.new_value
		var max_val: float = payload.component.maximum
		UIManager.update_player_health_bar(new_val, max_val)

