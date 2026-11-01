---
name: gecs-core
description: Use when setting up GECS, wiring the ECS singleton and World, creating the first Entity/Component/System, or applying the v9 foundational lifecycle rules in Godot 4.3+.
---

# GECS Core

Use this skill for project setup and the first working ECS loop.

## GECS installation

For a vague request such as "install GECS", "add GECS", or "set up ECS in this Godot project", default to a Git submodule unless the user names another installation method.

Run from the Godot project root and confirm `project.godot` exists before changing Git state:

```powershell
git submodule add https://github.com/csprance/gecs.git addons/gecs
git submodule update --init --recursive
```

Before choosing a release, ask whether the project must pin a version only when the desired version is not already implied. Do not silently add the legacy `release-v8.0.0` branch. For a current release, preserve the upstream default branch unless the project explicitly pins a tag.

After installation:

1. Confirm `addons/gecs/plugin.cfg` exists.
2. Enable the GECS plugin in `Project > Project Settings > Plugins`.
3. Confirm `ECS` is configured as an autoload when the plugin exposes one.
4. Confirm the project uses a compatible Godot version; GECS upstream currently requires Godot 4.6+.
5. Run Godot import/startup and report any plugin or autoload errors.

Use manual copying only when explicitly requested:

```powershell
# Manual option: copy the upstream addons/gecs/ directory into this project.
```

## Rules

1. Enable the GECS addon and expose the ECS singleton as an Autoload.
2. Assign the World to `ECS.world` before processing systems.
3. Call `ECS.process(delta, group)` or `world.process(delta, group)` from the expected Godot loop.
4. Add entities through `ECS.world.add_entity(entity)` or `add_entity(entity, components)`.
5. Never call `add_child(entity)` before `add_entity`; the World owns entity placement.
6. Entities hold data, systems hold behavior.
7. In GECS v9, entity identity is an integer handle; aliases are names, not identities.

## Minimal setup

```gdscript
extends Node

@onready var world: World = $World

func _ready() -> void:
    ECS.world = world

func _process(delta: float) -> void:
    ECS.process(delta)
```

## First implementation path

- Create a data-only `Component` Resource.
- Create an `Entity` subclass or scene Entity root and implement `define_components()` when needed.
- Add components before or during `world.add_entity(...)`.
- Create a `System` with `query()` and `process(...)`.
- Register systems in scene hierarchy and choose explicit processing groups.
- Add entities only after the World is assigned.

## Reference docs

- `docs/GETTING_STARTED.md`
- `docs/CORE_CONCEPTS.md`
- `docs/BEST_PRACTICES.md`
- `docs/MIGRATION_V9.md`
