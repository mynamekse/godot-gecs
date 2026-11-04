---
name: gecs-relationships
description: Implement and debug GECS relationships, wildcards and relationship queries. Use for entity-to-entity links, Component or archetype targets, component-property matching, limited removal, and target cleanup.
---

# GECS Relationships

Use `RELATIONSHIPS.md` as the source of truth. Relationships are first-class links with a source Entity, a relation Component, and an Entity, Component instance, or class target.

## Activation Scope

- Add or remove relationships
- Link Entities through relation Components
- Query exact targets or wildcards
- Match relation/target properties
- Remove limited numbers or all matching relationships
- Build status effects, inventories, targeting, ownership and damage links

## Relationship Forms

```gdscript
# Entity target
entity.add_relationship(Relationship.new(C_Likes.new(), alice))

# Component instance target
entity.add_relationship(Relationship.new(C_Damaged.new(), C_FireDamage.new(50)))

# Class/archetype target
entity.add_relationship(Relationship.new(C_Likes.new(), Food))
```

## Query Modes

Type matching ignores Component property values:

```gdscript
q.with_relationship([
    Relationship.new(C_Likes.new(), alice)
])
```

Wildcard matching uses `ECS.wildcard` or `null` where the docs specify it:

```gdscript
q.with_relationship([
    Relationship.new(C_Likes.new(), ECS.wildcard)
])
```

Property matching uses dictionaries for relation and target data:

```gdscript
q.with_relationship([
    Relationship.new(
        { C_Damaged: { "amount": { "_gte": 50 } } },
        { C_FireDamage: { "duration": { "_gt": 5.0 } } }
    )
])
```

## Workflow

1. Choose the target kind: Entity, Component instance, or Entity class/type.
2. Use a relation Component to identify the link's meaning.
3. Use relation data only when the link carries real varying state.
4. Choose exact type matching for normal gameplay lookup.
5. Use Component property dictionaries only for value-specific matching.
6. Add relationships outside hot iteration or queue them with `cmd` when inside a System.
7. Remove targets and relationships in an order that preserves lifecycle and observer correctness.

## Limited Removal

```gdscript
entity.remove_relationship(Relationship.new(C_Poison.new(), null), 1)
entity.remove_relationship(Relationship.new(C_Buff.new(), null), 3)
entity.remove_relationship(Relationship.new(C_Damage.new(), null), -1)
```

A positive limit removes at most that many matches. A negative or default limit removes all matches for the relationship pattern.

## Safety Rules

- Do not remove relationships by mutating a live array without considering swap-remove behavior.
- Use `cmd` for relationship removal during a System iteration.
- Reuse immutable relationship query patterns when practical.
- Use `without_relationship()` to exclude a link explicitly.
- Verify wildcard intent before broad queries; wildcard edges match many entities.
- Entity removal can interact with target cleanup and relationship archetypes; run lifecycle and relationship suites after framework changes.

## References

- [Relationship API summary](references/relationship-api.md)
- [Relationship system example](examples/status-effect.md)
