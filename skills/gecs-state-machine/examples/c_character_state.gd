class_name C_CharacterState
extends Component

## Property-based character state component.

enum State {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	DASHING,
	STUNNED
}

@export var current: State = State.IDLE
@export var state_time: float = 0.0


func _init(initial: State = State.IDLE) -> void:
	current = initial
	state_time = 0.0


func change_state(new_state: State) -> void:
	if current != new_state:
		current = new_state
		state_time = 0.0

