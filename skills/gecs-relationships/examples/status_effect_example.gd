class_name StatusEffectExample
extends RefCounted

## Demonstrates applying and cleansing stacked status effects with GECS relationships.

class R_HasEffect extends Component: pass

class C_FireEffect extends Component:
	@export var damage_per_second: float = 10.0
	@export var duration: float = 5.0
	func _init(dps: float = 10.0, dur: float = 5.0) -> void:
		damage_per_second = dps
		duration = dur


## Applies fire effect to an entity
static func apply_burn(target: Entity, dps: float = 15.0, duration: float = 6.0) -> void:
	var effect := C_FireEffect.new(dps, duration)
	target.add_relationship(Relationship.new(R_HasEffect.new(), effect))


## Cleanses all effects
static func cleanse_all(target: Entity) -> void:
	target.remove_relationship(Relationship.new(R_HasEffect.new(), null), -1)


## Cleanses a limited number of stacks
static func cleanse_stacks(target: Entity, count: int) -> void:
	target.remove_relationship(Relationship.new(R_HasEffect.new(), null), count)

