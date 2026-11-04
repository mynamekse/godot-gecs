# GECS Debug Checklist

## World Setup

- `ECS.world` is assigned before processing and entity addition.
- The World is a valid World node and remains in the SceneTree.
- Main loop calls `ECS.process(delta)` or the intended group.
- Scene reload restores `ECS.world` assignment.

## Entities and Components

- Entity belongs to the World.
- Component class exists through global `class_name`.
- Component was added through Inspector resources or code before query execution.
- `get_component()` and `has_component()` receive the Component class, not an instance.

## Queries

- `with_all`, `with_any` and `with_none` express the intended boolean logic.
- Property names are exported/script properties on the actual Component instance.
- Property operators and values match runtime types.
- Relationship target/type/wildcard matching is intentional.

## Systems

- System is registered and not paused.
- System is in the group being processed.
- Query has at least one match.
- Tick rate or dependencies do not delay the expected run.
- Structural mutation is deferred through `cmd` when iterating.

## Observer

- Observer is registered.
- Query chains an event modifier.
- `active` and `paused` are false/true as expected.
- Changed setters emit `property_changed`.
- Membership filters are complete and correctly enforce transitions.

## Debugger

- GECS debug mode is enabled for live inspection.
- A running game/session is selected.
- Hidden views stop polling while not visible.
- ECS pause does not imply a Godot SceneTree/physics pause.
- Step granularity is known: ARCHEtype is closest to live call structure; ENTITY steps modify call structure.
