---
name: gecs-entities
description: Design and manage GECS Entity nodes in the Godot SceneTree. Use for Entity subclasses, Node/Node2D/Node3D roots, .tscn prefabs, component_resources, define_components, spawning, removal, pooling, lifecycle hooks and v9 entity IDs/aliases.
---

# GECS Entities

Use this skill when Entity design depends on the Godot SceneTree rather than only ECS data and Systems.

## Source Documents

- `docs/GETTING_STARTED.md`
- `docs/CORE_CONCEPTS.md`
- `docs/BEST_PRACTICES.md`
- `docs/MIGRATION_V9.md`
- `docs/ENTITY_LIFECYCLE_PERFORMANCE.md`

## GECS Entity Creation Flow: SceneTree First

This is the primary architecture for scene-based game Entities.

1. **Entity is glue code.** The Entity root script caches stable references to its own physics/spatial child nodes so Systems can access those nodes directly without searching the SceneTree every frame.
2. **Components are pure data.** Components are Resource instances extending `Component` and store serializable properties only. They do not implement gameplay logic or hold Node references.
3. **SceneTree isolation.** The `.tscn` prefab owns geometry, visuals and physics hierarchy. Systems own systemic logic and process matching Entities externally.

## Activation Scope

- Create a code-based Entity or Entity scene/prefab
- Choose Entity root class: `Node`, `Node2D`, `Node3D`, or a spatial subtype
- Assign Components through `component_resources` or `define_components()`
- Instantiate and register `.tscn` prefabs
- Place spawned Entities in the SceneTree safely
- Implement `on_ready()`, `on_destroy()`, enable/disable, pooling and removal
- Handle v9 entity IDs and aliases

## Decision Workflow

1. For a game Entity that needs Godot visuals/physics, create the `.tscn` hierarchy first, attach the Entity script to the root, and cache fixed child Nodes as glue.
2. Choose a code-based `Entity.new()` when it is pure simulation data.
3. Keep spatial Node glue on the Entity only when the Node is owned by that entity and not queried by presence/type.
4. Put simulation behavior in Systems; keep Entity methods for lifecycle and SceneTree glue.
5. Configure Components in `component_resources` for stable authored composition or in `define_components()` for code-controlled composition.
6. Register the Entity through `world.add_entity()`.
7. Use removal/pooling based on identity, reset, relationship, callback and memory requirements.

## Code-Based Entity

```gdscript
class_name Pickup
extends Entity

func define_components() -> Array:
    return [C_Pickup.new(), C_Position.new()]
```

```gdscript
var pickup := Pickup.new()
ECS.world.add_entity(pickup)
```

The `Entity` root itself is a plain Node unless the scene roots through Node2D/Node3D or an inheriting class such as CharacterBody3D.

## Scene-Based Entity Prefab

Create scene-based Entities before adding Entity-level ECS data.

### Scene Hierarchy

```text
e_player.tscn
└── Player (Node2D or Node3D, script Player extends Entity)
    └── Body (CharacterBody2D or CharacterBody3D)
        ├── Sprite2D or MeshInstance3D
        └── CollisionShape2D or CollisionShape3D
```

2D and 3D variants follow the same ownership rule:

```text
Player (Node2D)
└── Body (CharacterBody2D)

Player (Node3D)
└── Body (CharacterBody3D)
```

The physics body belongs to the prefab hierarchy. The Entity root remains the ECS registration Node and caches the physics body as stable glue.

### Entity Glue Code

```gdscript
class_name Player
extends Entity

# Cache the entity-owned physics node once. Systems read it directly.
@onready var body: CharacterBody2D = $Body

func define_components() -> Array:
    return [
        C_PlayerInput.new(),
        C_Movement.new(300.0),
        C_Health.new(100.0)
    ]
```

For 3D, use the same pattern with `CharacterBody3D`:

```gdscript
class_name Player3D
extends Entity

@onready var body: CharacterBody3D = $Body

func define_components() -> Array:
    return [C_PlayerInput.new(), C_Movement.new(300.0), C_Health.new(100.0)]
```

Stable authored Components may also be assigned through `component_resources`. Use `define_components()` for code-controlled initial composition. It is valid to use both only when the resulting Component list has no accidental duplicate types that should be unique.

`@onready` references are appropriate when:

- The Node is owned by this Entity prefab.
- It remains fixed at runtime and is not queried as ECS data.
- It cannot serialize safely as a Component Resource.

Do not cache every child, scene-node lookup, or mutable gameplay concept by default. Use Components when Systems need to query or mutate data independently.

## SceneTree Registration

For GECS versions documented by this repository, `World.add_entity()` owns registration and places the Entity in the SceneTree by default (`add_to_tree = true`):

```gdscript
var player := player_prefab.instantiate() as Player
player.global_position = spawn_position
ECS.world.add_entity(player)
```

Do not call `get_tree().current_scene.add_child(player)` before `add_entity()` in that workflow. If the installed addon exposes `add_entity(..., add_to_tree=false)` or requires an explicitly parented Node for custom scene ownership, inspect that version before choosing placement.

When code must preserve a legacy/custom parent, check the local implementation and use the supported overload explicitly instead of inventing registration steps.

## Spawning from a PackedScene

```gdscript
@export var enemy_prefab: PackedScene

func spawn_enemy(position: Vector3) -> Enemy:
    var enemy := enemy_prefab.instantiate() as Enemy
    enemy.global_position = position
    ECS.world.add_entity(enemy)
    return enemy
```

Use a `PackedScene` registry only when several prefab types need stable lookup. Preload single reusable prefabs locally when one spawn path owns the type.

## Removal and Pooling

Removal semantics depend on the operation type:

- `remove_entity()` for normal world removal and managed lifecycle.
- `CommandBuffer.remove_entity()` for deferred removal during System iteration.
- `purge()` for a world reset.
- Pooling only when retain identity, state, memory and reset costs fit the game.

Do not treat enable/disable pooling as removal. Use `.enabled()`/.disabled queries where disabled pooled Entities must be excluded.

Pooling requires explicit reset of gameplay state that the pool retains, including transforms, timers, ownership, relationships, visuals, physics state and child-node behavior.

## Lifecycle

Expected lifecycle concepts:

1. Entity initialization
2. Load `component_resources` or call `define_components()`
3. `on_ready()` for SceneTree/child-node setup and transform synchronization
4. World enable/disable lifecycle as applicable
5. `on_destroy()` or removal cleanup before teardown

Keep heavy gameplay decisions in Systems. Entity hooks should synchronize SceneTree/Component glue or call established entity lifecycle APIs.

## Root-Type Guardrails

- Plain `Node` Entity: no `global_position`, `position`, `global_transform`, or spatial scene APIs.
- Scene-prefab root should usually be `Node2D`/`Node3D` when the Entity itself represents a spatial object.
- Physics should normally live on the root or on a dedicated `CharacterBody2D`/`CharacterBody3D` child, not be scattered across every visual child.
- The physics body is glue code. Do not put `CharacterBody` Node references inside Components unless the addon/project explicitly supports it; use pure data Components for movement state and cache Nodes on the Entity.
- `Node2D` Entity: 2D `global_position`, transform and visual children apply.
- `Node3D` Entity: 3D `global_position`, transform and visual/physics children apply.
- A CharacterBody3D root can inherit Entity data through a GECS-supported script pattern, but verify the exact inheritance pattern in the addon/project rather than assuming every Node subtype can combine with `Entity`.

## v9 Identity

- `Entity.id` is a generation-aware integer handle, not a String UUID.
- `entity.alias` is a string lookup name and not an identity.
- Same-alias add behavior replaces the existing Entity according to alias rules.
- Set a nonzero pre-assigned ID before `add_entity()` for replication/deserialization.
- Check stale handles with `world.is_alive(handle)` before reuse.

## Review Checklist

- Root Node type matches use of spatial APIs.
- Entity has only SceneTree glue and lifecycle logic beyond ECS state.
- The root has an appropriate Node/Node2D/Node3D spatial type for its hierarchy.
- Physics, visual and collision children are isolated inside the prefab.
- Fixed Node references are cached on the Entity with `@onready`, not searched for in every System frame.
- Components contain pure data and no Node references or gameplay methods.
- Component composition comes from `component_resources`, `define_components()`, or a documented hybrid.
- Spawn sets authored transform before or immediately after World registration as required by the installed addon.
- No manual `add_child()` precedes a managed `add_entity()` without a documented compatibility reason.
- Removal uses lifecycle-safe APIs; not direct array mutation.
- Pool reset restores all retained gameplay and SceneTree state.
- v9 code uses integer IDs and aliases for name lookup.

## References

- [Entity API summary](references/entity-api.md)
- [SceneTree lifecycle](references/scene-tree-lifecycle.md)
- [Prefab and spawning](references/prefabs-spawning.md)
- [GECS v9 entity identity](references/migration-v9.md)

## Examples

- [Code-based Entity](examples/code-based-entity.md)
- [Node2D prefab](examples/node2d-prefab.md)
- [Node3D/CharacterBody prefab](examples/node3d-characterbody-prefab.md)
- [Spawning, removal and pooling](examples/spawn-removal-pooling.md)
