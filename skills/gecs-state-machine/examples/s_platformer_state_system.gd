class_name PlatformerStateSystem
extends System

## System resolving state transitions for platformer character entities.


func query() -> QueryBuilder:
	return q.with_all([C_CharacterState, C_Velocity])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var state := entity.get_component(C_CharacterState) as C_CharacterState
		var vel := entity.get_component(C_Velocity) as C_Velocity
		state.state_time += delta

		# Transition rules
		match state.current:
			C_CharacterState.State.IDLE:
				if not is_zero_approx(vel.direction.x):
					state.change_state(C_CharacterState.State.RUNNING)
				elif vel.direction.y < 0.0:
					state.change_state(C_CharacterState.State.JUMPING)

			C_CharacterState.State.RUNNING:
				if is_zero_approx(vel.direction.x):
					state.change_state(C_CharacterState.State.IDLE)
				elif vel.direction.y < 0.0:
					state.change_state(C_CharacterState.State.JUMPING)

			C_CharacterState.State.JUMPING:
				if vel.direction.y >= 0.0:
					state.change_state(C_CharacterState.State.FALLING)

			C_CharacterState.State.FALLING:
				if is_zero_approx(vel.direction.y):
					state.change_state(C_CharacterState.State.IDLE)

