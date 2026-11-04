# Legacy Observer Migration Example

## Legacy v7

```gdscript
class_name HealthObserver
extends Observer

func watch() -> Resource:
    return C_Health

func on_component_added(entity: Entity, component: Resource) -> void:
    update_ui(entity)

func on_component_changed(entity: Entity, component: Resource, property: String, new_value, old_value) -> void:
    if property == "current":
        update_ui(entity)
```

## GECS v8 or Later

```gdscript
class_name HealthObserver
extends Observer

func query() -> QueryBuilder:
    return q.with_all([C_Player, C_Health]).on_added().on_changed([&"current"])

func each(event: Variant, entity: Entity, payload: Variant) -> void:
    if event == Observer.Event.ADDED or event == Observer.Event.CHANGED:
        update_ui(entity)

func update_ui(entity: Entity) -> void:
    pass
```

For membership semantics, use `.on_match().on_unmatch()` and remember that they fire once per transition, not once per internal Component mutation.
