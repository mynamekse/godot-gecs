# GECS Code Review Audit Output Template

Use this format when presenting a code review of GECS code:

```markdown
## GECS Architecture Review Summary

### 1. Invariants & Critical Safety
- [PASS / FAIL] Component Pure Data Invariant
- [PASS / FAIL] CommandBuffer cmd Iteration Safety
- [PASS / FAIL] Default Arguments in Component _init()
- [PASS / FAIL] Scene Glue vs Component Separation

### 2. Performance & Cache Locality
- [PASS / FAIL] SoA Batching via iterate()
- [PASS / FAIL] Avoidance of with_group() in Hot Paths
- [PASS / FAIL] Change Detection on High-Frequency Reads

### 3. Detected Anti-Patterns & Recommendations
[List line numbers, code snippets, and exact fixes]
```

