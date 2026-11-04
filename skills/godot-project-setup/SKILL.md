---
name: godot-project-setup
description: Scaffold the folder structure of a Godot 4 project that uses the GECS (Godot Entity Component System) addon, with c_* components, e_* entities, s_* systems and o_* observers. Use when the user starts a new GECS project or asks to create the GECS folder structure.
---

# Godot GECS Project Setup

Scaffold and configure a Godot 4.x project optimized for **GECS Framework** (Godot Entity Component System). This setup enforces strict separation between **Data** (Components), **Logic** (Systems), and **Prefabs** (Entities).

---



## 1. Directory Structure Standard

When initializing or organizing a GECS project, establish the following folder hierarchy:

```text
res://
├── addons/
│   └── gecs/                          # Core GECS Framework plugin
├── assets/
│   ├── audio/                         # SFX and Music
│   ├── sprites/                       # Textures and Spritesheets
│   └── shaders/                       # Shader Visual Effects
├── common/                            # Reusable utilities and singletons
│   ├── constants/                     # Global constants (e.g., collision_layers.gd)
│   ├── helpers/                       # Helper functions (e.g., math_utils.gd)
│   └── singletons/                    # Autoload scripts (e.g., bootstrap.gd)
├── components/                        # Pure Data Resources (Inherit Resource, named c_*.gd)
│   ├── core/                          # c_transform.gd, c_health.gd, c_lifetime.gd, c_team.gd
│   ├── movement/                      # c_velocity.gd, c_move_speed.gd, c_friction.gd, c_facing.gd
│   ├── input/                         # c_player_input.gd, c_intent.gd (move_dir, wants_attack)
│   ├── combat/                        # c_weapon.gd, c_cooldown.gd, c_hurtbox.gd, c_damage_event.gd
│   ├── ai/                            # c_ai_state.gd, c_path.gd, c_perception.gd
│   ├── rendering/                     # c_sprite.gd, c_animation_state.gd
│   ├── relationships/                 # r_equips.gd, rels.gd (Static Factory สื่อสารความสัมพันธ์)
│   └── tags/
├── entities/                          # Entity Prefabs (.tscn) and Glue Scripts (named e_*.gd)
│   ├── enemies/                       # e_enemy.tscn, e_enemy.gd
│   ├── players/                       # e_player.tscn, e_player.gd
│   ├── props/                         # e_crate.tscn, e_chest.tscn
│   └── projectiles/                   # e_bullet.tscn, e_bullet.gd
├── observers/                         # Reactive event listeners (named o_*.gd)
│   └── o_damage_listener.gd
├── resources/                         # Custom Resource presets and configurations (.tres)
│   ├── presets/                       # Initial stats presets (e.g., player_stats.tres)
│   └── weapons/                       # Weapon / Bullet specs
├── scenes/                            # Core game scenes
│   ├── default_systems.tscn           # System Groups container (run-first, input, gameplay, physics, run-last)
│   └── main.tscn                      # Main entry scene
├── systems/                           # Game logic derived from System and divided by phase (names start with s_*.gd)
│   ├── input/                         # Translate input into intent: s_player_input.gd, s_intent_translator.gd
│   ├── ai/                            # AI decisions and pathfinding: s_ai_decision.gd, s_pathfinding.gd
│   ├── gameplay/                      # Main game logic and character state: s_combat.gd, s_cooldown.gd, s_health.gd
│   ├── physics/                       # Movement and physics: s_movement.gd, s_friction.gd
│   └── run_last/                      # End-of-frame cleanup: s_pending_delete.gd
└── main.gd                            # Root controller managing ECS.world tick

## How to run (follow exactly)

The scaffold script is bundled with this skill:
`<skill_dir>/scripts/setup_gecs_project.ps1`
(`<skill_dir>` = the folder that contains this SKILL.md.)

Use the script for all project scaffolding operations. The AI agent must not directly create, update, rename, or delete any files or folders, and must not use any other file-operation method for scaffolding.

Do NOT write, rewrite or edit the script.

Steps:

1. Ask the user: 2D or 3D? (default: 2D)
2. Make sure the current directory is the Godot project root (it contains `project.godot`). If it is not found, STOP and ask the user whether to continue without `project.godot`; only continue if the user explicitly confirms.
3. Run:
`powershell -ExecutionPolicy Bypass -File "<skill_dir>/scripts/setup_gecs_project.ps1" -Mode <2D|3D>`
4. List the created folders to verify.
5. Report the result to the user.

Rules:

- If the script fails or the result looks wrong: STOP. Show the user the error output. Do not edit the script and do not retry with changes.
- Running the script twice is safe. It skips existing folders and never touches files.
- Never delete or overwrite existing files.
- Never modify anything inside `addons/gecs/`.
