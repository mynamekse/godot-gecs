class_name PlayerHUDObserver
extends Observer

## Bridges player C_Health property mutations to the UI CanvasLayer.

@export var ui_bridge: UIBridgeController


func query() -> QueryBuilder:
	return q.with_all([C_Player, C_Health]).on_changed([&"current"])


func each(event: Variant, _entity: Entity, payload: Variant) -> void:
	if event == Observer.Event.CHANGED and ui_bridge != null:
		var current_hp: float = payload.new_value
		var max_hp: float = payload.component.maximum
		ui_bridge.update_health(current_hp, max_hp)

