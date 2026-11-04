# GECS Entity SceneTree Lifecycle

## Managed Registration

With `add_to_tree=true`, `world.add_entity()` places a Node-based Entity in the SceneTree according to the World implementation. Do not manually `add_child()` before the managed registration unless the addon/version specifically requires it or you intentionally use an unmanaged scene Entity workflow.

## Initialization Order

1. Instance/instantiate the Entity Node.
2. Load Inspector and scene-owned child state.
3. Register Entity in the World.
4. Load `component_resources`.
5. Call `define_components()` for programmatic Components.
6. Perform Entity ready/glue initialization such as syncing scene transforms into Components.

The exact callback ordering depends on `World.initialize()` and SceneTree enter-tree timing. Implement behavior in framework-defined hooks; avoid assuming engine `_ready()` timing from a different addon version.

## Removal

Normal gameplay removal should use GECS World/CommandBuffer APIs so query caches, observers, relationships, IDs and deferred deletion remain coherent.

While iterating a System, queue removal:

```gdscript
cmd.remove_entity(entity)
```

Outside an iteration, inspect the local world API and remove at the lifecycle boundary. A removal should trigger cleanup and relationship teardown according to the addon implementation.

## Enable and Disable

Use `enable_entity`/`disable_entity` when pooling or temporary activation is supported. Disabled entities preserve identity and Components but should be excluded with `.enabled()` or `.disabled()` filters where required.

## Pooling

A pool does not replace lifecycle removal automatically. Reset:

- transform and velocity
- timers and cooldowns
- ownership and teams
- relationships
- visual state
- collision/physics state
- child Node state
- alias/name where needed

## Scene Ownership

The main Scene owns instantiated Nodes; the World owns ECS registration and lifetime. Keep ownership explicit by choosing one API to add, remove and free an Entity.

Do not call both `add_child()` and `queue_free()` ambiguously around World removal without understanding whether the addon performs deferred deletion.
