class_name Rels
extends RefCounted

## Static helper factory for common relationships.

# Define Relation Components
class R_Attacks extends Component: pass
class R_Targeting extends Component: pass
class R_ChildOf extends Component: pass
class R_Buff extends Component: pass
class R_Debuff extends Component: pass

# Pre-allocated Wildcard Templates
static var any_attacks: Relationship = Relationship.new(R_Attacks.new(), null)
static var any_buff: Relationship = Relationship.new(R_Buff.new(), null)
static var any_debuff: Relationship = Relationship.new(R_Debuff.new(), null)


static func attacks(target: Entity) -> Relationship:
	return Relationship.new(R_Attacks.new(), target)


static func child_of(parent: Entity) -> Relationship:
	return Relationship.new(R_ChildOf.new(), parent)


static func targeting(target: Entity) -> Relationship:
	return Relationship.new(R_Targeting.new(), target)

