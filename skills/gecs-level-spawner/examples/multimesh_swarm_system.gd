class_name MultiMeshSwarmSystem
extends System

## Updates MultiMeshInstance2D buffer directly from ECS C_Transform2D components.

@export var multimesh_node: MultiMeshInstance2D


func query() -> QueryBuilder:
	return q.with_all([C_Transform2D, C_SwarmUnit]).enabled().iterate([C_Transform2D])


func process(entities: Array[Entity], components: Array, _delta: float) -> void:
	if multimesh_node == null:
		return

	var transforms: Array = components[0]
	var count: int = entities.size()
	var mm: MultiMesh = multimesh_node.multimesh

	# Resize buffer if entity count changed
	if mm.instance_count != count:
		mm.instance_count = count

	# Write transforms in high-speed loop
	for i in count:
		var t := transforms[i] as C_Transform2D
		var transform_2d := Transform2D(0.0, t.position)
		mm.set_instance_transform_2d(i, transform_2d)

