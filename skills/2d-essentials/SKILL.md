---
name: 2d-essentials
description: Build GECS-based 2D games in Godot 4.3+. Use for 2D Entity prefabs, CanvasLayers, TileMapLayer, Parallax2D, 2D lights/shadows, particles, custom drawing, MeshInstance2D, pixel snapping, camera rendering and visual synchronization with Components and Systems.
---

# 2D Essentials for GECS

All examples target Godot 4.3+ with modern APIs. This skill combines Godot 2D rendering/physics with the GECS SceneTree-first architecture.

> Related skills: `gecs-entities` for Entity prefab/lifecycle, `player-controller` for CharacterBody2D movement, `animation-system` for sprite animation, `physics-system` for collisions/raycasting, `camera-system` for Camera2D, `particles-vfx` for effects, `gecs-performance` for ECS profiling.

## GECS 2D Architecture

Keep the ECS and rendering layers separate:

1. **Entity prefab `.tscn`** owns the visual/physics hierarchy: `Node2D` root, a recommended physics `Body` child, sprites, collision, particles, lights, and cameras owned by the Entity.
2. **Entity root script** is glue code only. Cache fixed child Nodes with `@onready`; do not search the SceneTree in Systems or each frame.
3. **Components are pure data.** Store position, velocity, input, animation state, light state, tile state, or render flags. Do not store Node references or methods when the data can be Resources.
4. **Systems execute behavior.** Movement, rendering synchronization, particle spawning, tile state, camera state, and cleanup are handled outside Entities.
5. **Rendering Nodes consume Component state.** Systems or thin Entity glue synchronize Component values to Node properties.

```text
e_player.tscn
└── Player (Node2D, script extends Entity)
    └── Body (CharacterBody2D)
        ├── Sprite2D
        ├── CollisionShape2D
        ├── GPUParticles2D
        └── PointLight2D
```

## Entity Types and Recommended 2D Body Roots

`EntityType` describes ECS/domain meaning. The recommended root column below means the **physics/interaction child under the Entity root**, not the ECS Entity registration root. The Entity prefab can still use `Node2D` at its root and cache the body child with `@onready var body`.

| EntityType | Recommended 2D Body Root | Reason EN | Reason TH | Group | Collision Layer |
|---|---|---|---|---|---|
| Player | CharacterBody2D | Player-controlled; movement uses input, gravity, and `move_and_slide()` | ผู้เล่นควบคุมเอง ต้องใช้ input, gravity และ `move_and_slide()` | Player | Layer 1: Player |
| Enemy / Monster / Boss | CharacterBody2D | AI-controlled; needs pathfinding and collision response | ศัตรูมี AI เดินไล่และชนฉากได้ | Enemy | Layer 2: Enemy |
| NPC Talking / Static | StaticBody2D | Idle NPC needs no movement; cheapest for a fixed body | NPC ยืนนิ่งคุย ใช้ StaticBody2D ถูกสุด | NPC | Layer 5: World |
| Projectile / Bullet / Arrow | Area2D | Fast movement usually needs overlap detection rather than full physics simulation | กระสุนวิ่งเร็ว ไม่ต้องคำนวณฟิสิกส์เต็มรูปแบบ แค่เช็คทับกัน | PlayerBullet / EnemyBullet | Layer 3 / 4 |
| Melee Hitbox / Sword / Punch | Area2D | Temporary overlap volume enabled/disabled by animation | Hitbox ชั่วคราว เปิด-ปิดตาม Animation | Hitbox | Layer 3 |
| Explosion / AOE | Area2D | Detect bodies or areas inside a radius | ระเบิดวงกว้าง เช็คตัวที่อยู่ในวง | Effect | Layer 3 |
| Wall / Building / House | StaticBody2D | Immovable world geometry with the lowest moving-body cost | กำแพง บ้าน อยู่กับที่ตลอดและคำนวณถูกสุด | World | Layer 5: World |
| Tree / Rock / Prop / Obstacle | StaticBody2D | Static decoration or obstacle; use AnimationPlayer separately for controlled sway | ต้นไม้ หิน เป็นพร็อพต้องชนและขยับโยกได้เมื่อจำเป็น | Obstacle | Layer 5: World |
| Pushable Crate / Barrel | RigidBody2D | Needs mass, gravity, impulses, and pushing response | กล่องผลักได้ ต้องมีแรงโน้มถ่วงและมวล | Pushable | Layer 5: World |
| Rolling Boulder / Ball / Ragdoll | RigidBody2D | Needs gravity, rolling, bouncing, and real rigid-body simulation | หินกลิ้ง ลูกบอล/Ragdoll ต้องคำนวณฟิสิกส์จริง | PhysicsProp | Layer 5: World |
| Moving Platform / Elevator / Door | AnimatableBody2D | AnimationPlayer/Tween moves it while it correctly pushes CharacterBody2D bodies | พื้นเลื่อน ลิฟต์ ประตูขยับตามอนิเมชั่นและดัน Player ได้ | MovingPlatform | Layer 5: World |
| Coin / Gem / Exp | Area2D | Overlap detection plus optional magnet attraction | เหรียญ เพชร Exp ตรวจการเก็บและอาจถูกดูด | Pickup | Layer 6: Pickup |
| Item / Weapon / Key | Area2D | Collectible Item with special interaction or pickup logic | ไอเทม อาวุธ กุญแจ เก็บแล้วมีผลเฉพาะ | Item | Layer 6: Pickup |
| Chest / Treasure | StaticBody2D | Fixed container; place an `Area2D` child for interaction detection | หีบสมบัติอยู่กับที่และใช้ `Area2D` ลูกทำ interaction | Interactable | Layer 5: World |
| Ladder / Vine | Area2D | Detect when a CharacterBody2D enters the climb zone | บันได เถาวัลย์ เช็คว่า Player เข้าสู่เขตปีน | Ladder | Layer 7: Trigger |
| Trigger / Quest Zone | Area2D | Detect `body_entered` and `body_exited`, then emit Gameplay/System events | เขต Trigger เควสใช้ event เวลาเดินเข้าและออก | Trigger | Layer 7: Trigger |
| Checkpoint / SpawnPoint | Area2D | Save/respawn trigger when the player enters | จุด Checkpoint/เกิด เซฟตำแหน่งเมื่อผู้เล่นเข้า | Checkpoint | Layer 7: Trigger |
| Visual Effect / Explosion / Dust / Blood | Node2D or GPUParticles2D | No collision; play, update visuals and remove when finished | Effect ไม่มีชน เล่นและลบเมื่อจบ | Effect | No Collision |
| Damage Number / Floating Text | Node2D | Float, fade and remove; Label-based presentation has no physics collision | ตัวเลขดาเมจลอยขึ้นและจาง ไม่มีฟิสิกส์ชน | VFX | No Collision |

### Body Selection Rules

- Use `CharacterBody2D` for direct player control, player-sized AI, and bodies that need `move_and_slide()` with gravity/platform collision.
- Use `RigidBody2D` only when real forces, mass, torque, bouncing and rolling are required.
- Use `StaticBody2D` for immovable world geometry and fixed interactables.
- Use `AnimatableBody2D` for Tween/AnimationPlayer-driven bodies that must push or carry bodies correctly.
- Use `Area2D` for overlap-only triggers, hitboxes, projectiles, pickups, zones and interactions.
- Use plain `Node2D`/`GPUParticles2D` for VFX with no physics.
- A `StaticBody2D` container such as a chest can have an `Area2D` child for interaction.
- Configure collision layers/masks by group intent; keep visual-only Node2D children outside physics-body ownership.

```gdscript
class_name Player
extends Entity

@onready var body: CharacterBody2D = $Body
@onready var sprite: Sprite2D = $Body/Sprite2D
@onready var particles: GPUParticles2D = $Body/GPUParticles2D
@onready var light: PointLight2D = $Body/PointLight2D

func define_components() -> Array:
    return [
        C_Player.new(),
        C_Velocity2D.new(),
        C_MovementSpeed.new(300.0),
        C_Health.new(100.0),
    ]
```

## Canvas Layers and Draw Order

Use scene-tree order for sibling draw ordering. Use `z_index` when order should not depend on tree placement.

```gdscript
z_index = 10
z_as_relative = false
```

CanvasLayers separate camera-independent content:

```text
Main
├── ParallaxBackground (CanvasLayer, layer = -1)
├── World (Node2D)
│   ├── TileMapLayer
│   └── Player Entities
└── HUD (CanvasLayer, layer = 1)
```

In GECS, keep HUD state in Components/Entities and synchronize UI Controls in a dedicated UI System. Do not put gameplay queries or physics logic in the HUD Script.

Use coordinate conversion only at integration boundaries:

```gdscript
var world_pos: Vector2 = get_global_transform() * local_pos
var screen_pos: Vector2 = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * local_pos
```

## TileMaps with GECS

Use `TileMapLayer` instead of deprecated `TileMap`. Store gameplay tile meaning in TileSet custom data or ECS Components; query ECS Entities by Component types, not by manually searching tile Nodes.

A tile may serve as a source that creates or mutates Entities. Keep the tile damage, loot, interaction, or biome data in custom data/Components and let Systems apply it.

```gdscript
class_name HazardSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_Position2D, C_Health])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    for entity in entities:
        var position := entity.get_component(C_Position2D)
        if is_hazard_tile(position.value):
            apply_hazard(entity)
```

Use collision via TileSet physics layers and scene collection tiles for scene instances. See [tilemap.md](references/tilemap.md).

## Parallax

Use `Parallax2D`, not the deprecated `ParallaxBackground`/`ParallaxLayer` pair.

```gdscript
var layer: Parallax2D = $Parallax2D
layer.scroll_scale = Vector2(0.35, 0.35)
layer.repeat_size = Vector2(1920, 1080)
layer.repeat_times = 2
```

For GECS, treat parallax layers as render-only infrastructure unless their state affects gameplay. Do not create ECS Components only for scrolling. See [parallax.md](references/parallax.md).

## Lights and Shadows

Use `PointLight2D` or `DirectionalLight2D` plus `LightOccluder2D` as prefab/scene children. Store gameplay-visible flags or intensity in Components only when Systems must query or change them.

```gdscript
class_name C_Torch
extends Component

@export var enabled: bool = true
@export var energy: float = 1.0
@export var color: Color = Color("ffb347")
```

```gdscript
class_name LightingSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_Torch]).iterate([C_Torch])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    var torches := components[0]
    for i in entities.size():
        var entity := entities[i]
        var glow := entity.get_node_or_null("Light") as PointLight2D
        if glow:
            glow.enabled = torches[i].enabled
            glow.energy = torches[i].energy
            glow.color = torches[i].color
```

Avoid Node references inside Components. Entity glue owns cached rendering Nodes. See [lights-and-shadows.md](references/lights-and-shadows.md).

## 2D Particles

Use `GPUParticles2D` for normal high-count effects and `CPUParticles2D` for low-count compatibility or platforms with less GPU support.

Particle Nodes should normally live under the Entity prefab. Systems trigger emissions through Component state or directly through cached Entity references.

```gdscript
class_name C_Burning
extends Component

@export var active: bool = false
```

```gdscript
func emit_for(entity: Entity, active: bool) -> void:
    var flame := entity.get_node_or_null("Body/Flame") as GPUParticles2D
    if flame:
        flame.emitting = active
```

Do not put high-frequency particle data into Components unless it is ECS-authoritative. Timers, ParticleProcessMaterial copies, and Node references belong to the scene/System boundary when not queried. See [2d-particles.md](references/2d-particles.md).

## Custom Drawing

Override `_draw()` only for rendering. Call `queue_redraw()` when Component state or System output changes; never call `_draw()` directly.

When using an Entity-owned custom Node, expose current values through an Entity/System synchronization path rather than performing ECS queries inside `_draw()`.

```gdscript
class_name Radar
extends Node2D

var sweep_angle: float = 0.0

func _draw() -> void:
    draw_arc(Vector2.ZERO, 48.0, 0.0, TAU, 32, Color.GREEN, 2.0, true)

func set_sweep(value: float) -> void:
    if !is_equal_approx(sweep_angle, value):
        sweep_angle = value
        queue_redraw()
```

A custom Node should not query GECS every frame for presentation if a System already updates its value. See [custom-drawing.md](references/custom-drawing.md).

## 2D Meshes

Use `MeshInstance2D` instead of a fully transparent Sprite2D rectangle for irregular, screen-sized, transparent-border-heavy sprites.

1. Select `Sprite2D`.
2. Run **Sprite2D → Convert to MeshInstance2D**.
3. Adjust growth and simplification.
4. Test fill rate and visual artifacting.

Keep mesh choice rendering-only. ECS Components describe whether the Entity is visible, damaged, selected, animated, or hidden, while the rendering Node choice remains a scene/prefab concern.

## 2D Antialiasing and Pixel Art

For selective smooth edges use the drawing method `antialiased` parameter.

```gdscript
draw_line(Vector2.ZERO, Vector2(100, 50), Color.WHITE, 2.0, true)
```

Line2D has no visible `antialiased` benefit in isolation; use MSAA or texture soft edges. MSAA 2D is unavailable in Compatibility.

For pixel art:

- Do not enable MSAA 2D.
- Use Snap 2D Transforms and/or vertices only when that visual style requires them.
- Never mix ECS transform authority with SceneTree position authority without a documented synchronization direction.

A suitable boundary is: `C_Transform2D` stores simulation data; Systems update the Entity/Body position; rendering children follow the physics body through normal parenting.

## GECS Component and System Examples

```gdscript
class_name C_Render2D
extends Component

@export var visible: bool = true
@export var z_index: int = 0
@export var flip_h: bool = false
@export var modulation: Color = Color.WHITE
```

```gdscript
class_name RenderSync2DSystem
extends System

func query() -> QueryBuilder:
    return q.with_all([C_Render2D])

func process(entities: Array[Entity], components: Array, delta: float) -> void:
    for entity in entities:
        var render_state := entity.get_component(C_Render2D) as C_Render2D
        var sprite := entity.get_node_or_null("Body/Sprite2D") as Sprite2D
        if not sprite:
            continue
        sprite.visible = render_state.visible
        sprite.z_index = render_state.z_index
        sprite.flip_h = render_state.flip_h
        sprite.modulate = render_state.modulation
```

Avoid this pattern if fixed render lookup can be cached in the Entity root. `@onready var sprite` is preferable for stable prefab-owned nodes; `get_node_or_null()` is appropriate when child presence is optional and no cache is guaranteed.

## Implementation Checklist

- [ ] Entity `.tscn` has an appropriate Node2D entity root and recommended 2D physics body hierarchy.
- [ ] Fixed visual, physics and collision nodes are cached on the Entity root when stable.
- [ ] The physics body root matches the Entity type table and is `CharacterBody2D`, `Area2D`, `StaticBody2D`, `RigidBody2D`, `AnimatableBody2D`, or plain `Node2D` where appropriate.
- [ ] Components store gameplay/render state without Node references or logic methods.
- [ ] Systems synchronize Components to Sprite2D, Camera2D, Light2D, particles, TileMapLayer and custom drawing.
- [ ] Physics uses TileSet physics layers rather than disconnected manual world geometry.
- [ ] `TileMapLayer`, `Parallax2D`, `CanvasLayer`, and `PointLight2D` use modern 4.3+ APIs.
- [ ] `Parallax2D.repeat_size` matches texture dimensions and camera zoom requirements.
- [ ] Particle effects have valid visibility/emission bounds.
- [ ] Custom drawing calls `queue_redraw()` instead of `_draw()` directly.
- [ ] Transparent mesh candidates use MeshInstance2D only after measured fill-rate benefit.
- [ ] Pixel-art snapping is intentional and transform authority is documented.

## References

- [TileMapLayer and TileSet](references/tilemap.md)
- [Parallax2D](references/parallax.md)
- [2D lights and shadows](references/lights-and-shadows.md)
- [2D particles](references/2d-particles.md)
- [Custom drawing](references/custom-drawing.md)

## Examples

- [GECS 2D player prefab and render sync](examples/gecs-player2d.md)
