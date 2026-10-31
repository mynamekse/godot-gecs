class_name CharacterEntity
extends Entity

## Example character entity showing Scene Glue pattern and initial component registration.

@onready var sprite: Sprite2D = get_node_or_null(^"Sprite2D")
@onready var animation_player: AnimationPlayer = get_node_or_null(^"AnimationPlayer")


func define_components() -> Array:
	return [
		C_Health.new(100.0),
		C_Velocity.new(Vector2.ZERO, 160.0)
	]


func on_ready() -> void:
	# Called after entity is added to the World and components are mapped
	pass


func on_destroy() -> void:
	# Called right before removal from World
	pass

