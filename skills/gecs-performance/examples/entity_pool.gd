class_name BulletPool
extends RefCounted

## Generic Entity Pool demonstrating high-performance entity reuse via enable/disable.

var _available: Array[Entity] = []


func get_entity() -> Entity:
	if _available.is_empty():
		var bullet := Entity.new()
		bullet.name = "PooledBullet"
		ECS.world.add_entity(bullet, [C_Velocity.new(), C_Lifetime.new()])
		return bullet

	var bullet := _available.pop_back()
	ECS.world.enable_entity(bullet)
	return bullet


func return_entity(bullet: Entity) -> void:
	ECS.world.disable_entity(bullet)
	_available.append(bullet)

