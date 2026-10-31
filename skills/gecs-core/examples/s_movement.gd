class_name MovementSystem
extends System

## System that translates entities according to their C_Velocity component.


func query() -> QueryBuilder:
	# Using iterate([C_Velocity]) passes the component column array directly in components[0]
	return q.with_all([C_Velocity]).iterate([C_Velocity])


func process(entities: Array[Entity], components: Array, delta: float) -> void:
	var velocities: Array = components[0]

	for i in entities.size():
		var entity := entities[i]
		var vel := velocities[i] as C_Velocity
		entity.position += vel.direction * vel.speed * delta

