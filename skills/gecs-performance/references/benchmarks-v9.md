# GECS Performance Benchmarks (v8 vs v9 @ 10,000 Entities)

Measured on Windows debug build, Godot 4.6+:

| Benchmark Test | v8 (Legacy) | v9 (Current) | Improvement |
|---|---|---|---|
| State Transition (remove + add) | 1,255 ms | 427 ms | **−66%** |
| Bulk Spawn (10k, one composition) | 2,061 ms | 598 ms | **−71%** |
| Spawn/Despawn Churn (1k cycle) | 240 ms | 89 ms | **−63%** |
| Monitor Transitions (20k) | 3,555 ms | 284 ms | **−92%** |
| Backwards Bulk Removal | 1,272 ms | 127 ms | **−90%** |
| Change Detection (`.changed()`, 1% writes, 60 frames) | 900 ms | 65 ms | **13.8× faster** |

