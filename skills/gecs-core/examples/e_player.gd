class_name Player
extends Entity

## Example Entity demonstrating the Scene Glue pattern.

## Scene glue: References to child nodes are cached on the Entity, not in components.
@onready var sprite: Sprite2D = get_node_or_null(^"Sprite2D")


func define_components() -> Array:
	# Returns the initial component set attached when spawned into the World
	return [
		C_Velocity.new(Vector2.RIGHT, 150.0)
	]


func on_ready() -> void:
	# Called after components are loaded and entity is added to the World.
	# Perfect for initial spatial synchronization.
	pass


func on_destroy() -> void:
	# Called right before the entity is removed from the World.
	pass

