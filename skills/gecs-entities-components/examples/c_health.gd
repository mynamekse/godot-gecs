class_name C_Health
extends Component

## Maximum health value
@export var maximum: float = 100.0

## Current health points. Emits property_changed so Observers receive CHANGED events.
@export var current: float = 100.0:
	set(new_value):
		var old_value := current
		current = clampf(new_value, 0.0, maximum)
		if not is_equal_approx(old_value, current):
			property_changed.emit(self, &"current", old_value, current)


func _init(max_hp: float = 100.0, cur_hp: float = -1.0) -> void:
	maximum = max_hp
	current = max_hp if cur_hp < 0.0 else cur_hp

