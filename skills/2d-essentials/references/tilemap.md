# TileMapLayer and TileSet

## Modern Setup

Use one `TileMapLayer` per layer in Godot 4.3+ and configure it through an external `TileSet` resource.

Recommended structure:

```text
World (Node2D)
├── Ground (TileMapLayer)
├── Decor (TileMapLayer)
└── Hazard (TileMapLayer)
```

Each TileSet atlas can provide:

- atlas textures and alternative tiles
- terrain rules
- physics layers
- navigation
- custom data
- scene collection tiles

## GECS Mapping

Choose custom data for tile-authored gameplay properties. Use ECS Components/Systems for runtime state that Entities need to query.

```gdscript
# Tile custom data -> runtime System logic
var tile_data := tilemap.get_cell_tile_data(cell)
var damage := tile_data.get_custom_data("damage") if tile_data else 0.0
```

Do not duplicate every tile as a Node or Entity unless scene-instance behavior requires it. Scene collection tiles are appropriate for tile-located scenes that need child physics, visuals, animation, or independent lifecycle.

## Terrain and Painting

- Use terrains for biome/platform edge consistency.
- Enable texture padding in TileSets where bleeding appears at texture borders.
- Use custom data for one-off gameplay tags.
- Keep collision on TileSet physics layers rather than manual CollisionShape2D nodes for painted tiles.

## System Workflow

1. Query Entities with position, body, health, or interaction Components.
2. Read the TileMapLayer at their world/grid position.
3. Apply Component mutations through the normal System/World flow.
4. Use `cmd` when the tile result must add/remove Components or Entities safely.
