# GECS Relationship API Summary

A relationship has:

- Source: the Entity holding the relationship
- Relation: a Component defining its type and optional data
- Target: another Entity, Component instance, or class/type

```gdscript
entity.add_relationship(Relationship.new(relation_component, target))
entity.remove_relationship(Relationship.new(relation_component, target), limit)
entity.has_relationship(Relationship.new(relation_component, target))
```

## Relationship Queries

```gdscript
q.with_relationship([Relationship.new(C_Likes.new(), alice)])
q.with_relationship([Relationship.new(C_Likes.new(), ECS.wildcard)])
q.without_relationship([Relationship.new(C_FleesFrom.new(), player)])
```

## Matching Modes

Type matching uses Component types and ignores relation/target property values. Component dictionaries match properties by operators such as `_gte`, `_lt`, `_in`, and `func`.

## Wildcards

`ECS.wildcard` or the documented null form matches an unspecified relation or target slot. Broad wildcard queries should be justified by the gameplay lookup because they match more entities.

## Performance and Lifecycle

- Reuse query relationship patterns when practical.
- Entity removal must clean relationship references correctly.
- Relationship mutation inside systems should use `cmd` during iteration.
- Relationship and lifecycle suites are necessary when changing framework removal internals.
