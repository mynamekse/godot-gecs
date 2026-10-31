class_name C_Velocity
extends Component

## Movement direction vector (normalized)
@export var direction: Vector2 = Vector2.ZERO

## Movement speed in pixels/units per second
@export var speed: float = 200.0


func _init(dir: Vector2 = Vector2.ZERO, spd: float = 200.0) -> void:
	direction = dir
	speed = spd

