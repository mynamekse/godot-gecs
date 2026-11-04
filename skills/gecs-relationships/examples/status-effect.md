# Status Effect Relationship Example

```gdscript
class_name C_Damaged
extends Component

class_name C_FireDamage
extends Component

@export var amount: int = 0
@export var duration: float = 0.0

func _init(damage_amount: int = 0, duration_seconds: float = 0.0) -> void:
    amount = damage_amount
    duration = duration_seconds
```

```gdscript
var target := Entity.new()
ECS.world.add_entity(target)
target.add_relationship(Relationship.new(
    C_Damaged.new(),
    C_FireDamage.new(50, 5.0)
))
```

```gdscript
class_name FireDamageSystem
extends System

func query() -> QueryBuilder:
    return q.with_relationship([
        Relationship.new(
            C_Damaged.new(),
            { C_FireDamage: { "amount": { "_gte": 50 } } }
        )
    ])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    for entity in entities:
        pass
```
