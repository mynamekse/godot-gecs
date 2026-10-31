extends Node2D

## Main scene controller for bootstrapping GECS World and running the main loop.

@onready var world: World = $World


func _ready() -> void:
	# 1. Register active World instance to ECS singleton
	ECS.world = world

	# 2. Spawn initial player entity
	_spawn_player()


func _process(delta: float) -> void:
	# Ticks the GECS world systems
	ECS.process(delta)


func _spawn_player() -> void:
	var player := Entity.new()
	player.name = "Player"
	player.position = Vector2(250.0, 250.0)

	var sprite := Sprite2D.new()
	sprite.texture = preload("res://icon.svg")
	player.add_child(sprite)

	var velocity := C_Velocity.new(Vector2.RIGHT, 120.0)

	# CRITICAL RULE: add_entity handles scene tree placement.
	# Do NOT call add_child(player) before add_entity()!
	ECS.world.add_entity(player, [velocity])

