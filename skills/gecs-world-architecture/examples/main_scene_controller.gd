extends Node

## Comprehensive Main Scene Controller managing GECS World groups and level transitions.

@onready var world: World = $World


func _ready() -> void:
	ECS.world = world


func _process(delta: float) -> void:
	world.process(delta, "run-first")
	world.process(delta, "input")
	world.process(delta, "gameplay")
	world.process(delta, "ui")
	world.process(delta, "run-last")


func _physics_process(delta: float) -> void:
	world.process(delta, "physics")
	world.process(delta, "debug")


func transition_to_level(new_level_packed: PackedScene) -> void:
	# Purge all current entities and compact archetypes
	world.purge()
	world.compact()

