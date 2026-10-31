# GECS QueryBuilder Operator Specifications

This reference provides the syntax rules and internal evaluation model of `QueryBuilder` property comparisons.

---

## 1. Syntax Format

Property queries are expressed as nested Dictionaries inside `with_all()` or `with_any()` arrays:

```gdscript
q.with_all([
    { ComponentClass: { "field_name": { "_operator": value } } }
])
```

Multiple fields on the same component can be checked concurrently:

```gdscript
q.with_all([
    { C_Stats: {
        "stamina": { "_gte": 10 },
        "mana": { "_gte": 25 }
    }}
])
```

---

## 2. Operator Reference Table

| Operator | Type Expected | Description |
|---|---|---|
| `_eq` | `Variant` | Evaluates `field == value`. |
| `_ne` | `Variant` | Evaluates `field != value`. |
| `_gt` | `int`, `float`, `String` | Evaluates `field > value`. |
| `_lt` | `int`, `float`, `String` | Evaluates `field < value`. |
| `_gte` | `int`, `float`, `String` | Evaluates `field >= value`. |
| `_lte` | `int`, `float`, `String` | Evaluates `field <= value`. |
| `_in` | `Array` | Evaluates `value.has(field)`. |
| `_nin` | `Array` | Evaluates `not value.has(field)`. |
| `func` | `Callable` | Evaluates `value.call(field) == true`. |

---

## 3. Change Detection Invariants (v9)

When `.changed([ComponentType])` is invoked:
* The query checks each matched archetype's change tick against the caller's last run tick.
* Archetypes whose write ticks precede the last evaluation are skipped in bulk.
* If modifying component data directly (e.g., `health.current -= 5` without an emitting setter), you must call `entity.mark_changed(health)` to notify the archetype change table.

