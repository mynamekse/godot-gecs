# PowerShell Script for Godot 4 GECS Project Setup
Write-Host "🚀 Starting GECS Project Scaffolding..." -ForegroundColor Green

# 1. List of Directories to Create
$directories = @(
    "addons",
    "assets/audio",
    "assets/sprites",
    "common/constants",
    "common/helpers",
    "common/singletons",
    "components/core",
    "components/movement",
    "components/input",
    "components/combat",
    "components/ai",
    "components/rendering",
    "components/tags",
    "entities/enemies",
    "entities/players",
    "entities/projectiles",
    "observers",
    "resources/presets",
    "resources/weapons",
    "scenes",
    "systems/combat",
    "systems/gameplay",
    "systems/input",
    "systems/physics",
    "systems/run_last"
)

# 2. Create Folders
foreach ($dir in $directories) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  [+] Created directory: $dir" -ForegroundColor Cyan
    }
}

# Copy the GECS folder into addons
Copy-Item -LiteralPath "\\wsl.localhost\Ubuntu\home\gecs" -Destination "addons" -Recurse -Force
Write-Host "  [+] Copied GECS folder to: addons\gecs" -ForegroundColor Cyan

# 3. Create Key Placeholder Files with Default GDScript Content

# main.gd
$mainGdContent = @"
class_name Main
extends Node2D

@onready var default_systems: Node2D = `$DefaultSystems

func _ready() -> void:
	print("GECS World Initialized")

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
"@
Set-Content -Path "main.gd" -Value $mainGdContent -Encoding UTF8
Write-Host "  [+] Created file: main.gd" -ForegroundColor Yellow

# common/singletons/bootstrap.gd
$bootstrapContent = @"
extends Node

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
"@
Set-Content -Path "common/singletons/bootstrap.gd" -Value $bootstrapContent -Encoding UTF8
Write-Host "  [+] Created file: common/singletons/bootstrap.gd" -ForegroundColor Yellow

# components/common/c_health.gd
$cHealthContent = @"
class_name CHealth
extends Resource

@export var max_hp: int = 100
@export var current_hp: int = 100
"@
Set-Content -Path "components/common/c_health.gd" -Value $cHealthContent -Encoding UTF8
Write-Host "  [+] Created file: components/common/c_health.gd" -ForegroundColor Yellow

# systems/physics/s_movement.gd
$sMovementContent = @"
class_name SMovement
extends Node

func _process(delta: float) -> void:
	pass
"@
Set-Content -Path "systems/physics/s_movement.gd" -Value $sMovementContent -Encoding UTF8
Write-Host "  [+] Created file: systems/physics/s_movement.gd" -ForegroundColor Yellow

# Empty Placeholders to keep directory structure intact
$placeholders = @(
    "common/constants/collision_layers.gd",
    "common/helpers/math_utils.gd",
    "components/common/c_transform.gd",
    "components/input/c_player_input.gd",
    "components/physics/c_movement.gd",
    "components/physics/c_velocity.gd",
    "components/rendering/c_sprite.gd",
    "components/relationships/rels.gd",
    "entities/enemies/e_enemy.gd",
    "entities/players/e_player.gd",
    "entities/projectiles/e_bullet.gd",
    "observers/o_damage_listener.gd",
    "systems/combat/s_combat.gd",
    "systems/combat/s_death.gd",
    "systems/gameplay/s_weapon.gd",
    "systems/gameplay/s_health.gd",
    "systems/input/s_player_input.gd",
    "systems/physics/s_friction.gd",
    "systems/run_last/s_pending_delete.gd"
)

foreach ($file in $placeholders) {
    if (-not (Test-Path -Path $file)) {
        New-Item -ItemType File -Path $file -Force | Out-Null
        Write-Host "  [+] Created placeholder: $file" -ForegroundColor Gray
    }
}

Write-Host "`n✅ GECS Project Structure setup complete!" -ForegroundColor Green