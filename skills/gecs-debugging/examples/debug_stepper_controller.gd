class_name DebugStepperController
extends RefCounted

## Utility controller for interacting with GECS Stepper API.


static func setup_combat_break(target_entity: Entity) -> void:
	var world := ECS.world
	world.debug_pause()

	# Break whenever C_Dead component is attached
	world.debug_add_breakpoint({
		"kind": "component_added",
		"component": C_Dead
	})

	# Step until next system
	world.debug_step(GECSStepper.Kind.SYSTEM)

