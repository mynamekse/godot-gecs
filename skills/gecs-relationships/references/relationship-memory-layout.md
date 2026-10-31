# GECS Relationship Memory & Archetype Layout

GECS implements relationships as first-class entity links stored directly in archetype signatures.

---

## 1. Storage Model

1. **Exact Pairs (Source, Relation, Target):**
   - When an entity gains a relationship with an explicit target entity (`Relationship.new(R_Attacks.new(), target_entity)`), the target entity's ID forms part of the archetype key.
   - Exact pair queries are resolved in **O(1)** through archetype hash-maps.

2. **Wildcards (`ECS.wildcard`):**
   - Wildcards omit either the relation or target.
   - Wildcard matching cannot use a single direct archetype lookup and must scan archetypes containing that relation prefix.
   - **Optimization Rule:** Always narrow wildcard queries by combining with `with_all([C_Alive])`.

---

## 2. Cleanup Policy on Deletion

When an entity is destroyed:
* Any relationship where the entity was the **Source** is destroyed.
* Any relationship where the entity was the **Target** is cleaned up automatically via the `REMOVE` policy across the world.
* This guarantees zero dangling entity handles across relationship links.

