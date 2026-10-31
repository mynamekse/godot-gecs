class_name DamageSystem
extends System

## Demonstrates sub-systems grouping damage resolution and passive regeneration.


func sub_systems() -> Array[Array]:
	return [
		[q.with_all([C_Health, C_Damage]), _process_damage],
		[q.with_all([C_Health]).with_none([C_Dead]).iterate([C_Health]), _process_regen]
	]


func _process_damage(entities: Array[Entity], _components: Array, _delta: float) -> void:
	for entity in entities:
		var health := entity.get_component(C_Health) as C_Health
		var damage := entity.get_component(C_Damage) as C_Damage
		health.current -= damage.amount
		cmd.remove_component(entity, damage)

		if health.current <= 0.0:
			cmd.add_component(entity, C_Dead.new())


func _process_regen(entities: Array[Entity], components: Array, delta: float) -> void:
	var healths: Array = components[0]
	for i in entities.size():
		var health := healths[i] as C_Health
		health.current = minf(health.current + 1.0 * delta, health.maximum)

