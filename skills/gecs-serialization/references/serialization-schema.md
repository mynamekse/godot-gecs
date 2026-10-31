# GECS Serialization Schema & Invariants

GECS serialization packages entities, components, and relationships into `GecsData` resources.

---

## 1. Export Property Invariant

Only `@export` variables defined on `Component` resources are serialized. Unexported member variables (`var _temp_state`) are ignored during save operations and reset to defaults upon deserialization.

---

## 2. Backward Compatibility Shim

GECS v9 save and load routines automatically convert legacy v8 string UUIDs into generational int64 handles on load, maintaining full backward compatibility with older save files.

