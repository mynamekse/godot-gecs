---
name: gecs-relationships
description: Use when linking entities, components, or archetypes, querying relation pairs and wildcards, stacking effects, or removing relationship stacks safely.
---

# GECS Relationships

A relationship has a source entity, a relation component, and a target entity, component instance, or type.

## Add links

```gdscript
e_bob.add_relationship(Relationship.new(C_Likes.new(), e_alice))
entity.add_relationship(Relationship.new(C_Damaged.new(), C_FireDamage.new(50)))
entity.add_relationship(Relationship.new(C_Likes.new(), Food))
```

## Query links

```gdscript
world.query.with_relationship([
    Relationship.new(C_Likes.new(), e_alice)
])

world.query.with_relationship([
    Relationship.new(C_Damaged.new(), null)
])
```

Use `ECS.wildcard` or `null` where the API documents wildcard matching. Component relationship targets may be matched by type or property filter.

## Removal

```gdscript
entity.remove_relationship(Relationship.new(C_Buff.new(), null), 3)
entity.remove_relationship(Relationship.new(C_Buff.new(), null), -1)
```

A positive count removes up to that many stacked matches. The negative/default form removes all matching relationships.

## Invariants

- Add/remove relationship structure through the normal entity or World APIs.
- During systems, queue structural relationship changes with `cmd`.
- Do not treat a relationship Component target as a plain entity/component assignment without checking the target kind.

Reference: `docs/RELATIONSHIPS.md`
