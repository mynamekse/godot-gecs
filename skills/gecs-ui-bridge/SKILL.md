---
name: gecs-ui-bridge
description: Use when bridging GECS simulation data to Godot Control/UI nodes (HUD, health bars, inventory UI, ammo counters) — decoupling UI from ECS using World Events (emit_event), Reactive Observers (o_*), CanvasLayer architecture, and preventing per-frame polling
---

# GECS UI Bridge in Godot 4.3+

Connect runtime ECS data (player health, ammo, scores, cooldowns) to Godot `Control` nodes without tight coupling or spaghetti code. In traditional game development, developers often make the mistake of having UI nodes poll ECS components every frame in `_process()`, or worse, storing Godot UI nodes inside ECS `Component` resources. 

This skill establishes clean, event-driven bridges using **GECS World Events (`emit_event`)** and **Reactive Observers (`o_*`)** targeting a decoupled `CanvasLayer` HUD.

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-observers** for reactive observers, **gecs-entities-components** for reactive property setters, **gecs-core** for setup.

---

## 1. UI Integration Dilemma: What to Avoid

| Anti-Pattern | Why It Breaks Down | The GECS Solution |
|---|---|---|
| **Per-Frame UI Polling** | `HealthBar._process()` calling `get_component(C_Health)` every frame wastes CPU when HP doesn't change | **Event-Driven:** Update only when HP actually mutates |
| **Control Nodes in Components** | Storing `@export var health_bar: ProgressBar` in `C_Health` breaks resource purity & serialization | **Pure Data:** Components stay pure data; Observers bridge to UI |
| **Direct Entity Lookup in UI** | UI reaching deep into the World tree causes tight coupling and breaks when scene reloads | **Event Bridge:** UI listens to typed signals or World Events |

---

## 2. Approach 1: Reactive Observer Bridge (Recommended for Single-Entity HUD)

Use an `Observer` to watch component mutations and forward them to a dedicated UI Manager or `CanvasLayer`.

### Step 1: Emitting Setter on Component (`c_health.gd`)
Observers watching `.on_changed([&"current"])` require the property setter to emit `property_changed`:

```gdscript
class_name C_Health
extends Component

@export var maximum: float = 100.0
@export var current: float = 100.0:
	set(val):
		var old := current
		current = clampf(val, 0.0, maximum)
		if not is_equal_approx(old, current):
			property_changed.emit(self, &"current", old, current)
```

### Step 2: The UI Observer (`o_player_hud_observer.gd`)
See [`examples/o_player_hud_observer.gd`](./examples/o_player_hud_observer.gd).

```gdscript
class_name PlayerHUDObserver
extends Observer

@export var hud_canvas: CanvasLayer


func query() -> QueryBuilder:
	# Only watch the Player entity's health mutations
	return q.with_all([C_Player, C_Health]).on_changed([&"current"])


func each(event: Variant, _entity: Entity, payload: Variant) -> void:
	if event == Observer.Event.CHANGED and hud_canvas != null:
		var new_val: float = payload.new_value
		var max_val: float = payload.component.maximum
		hud_canvas.set_health(new_val, max_val)
```

---

## 3. Approach 2: World Events (`emit_event()`) (Recommended for Global UI)

For global UI notifications (e.g. score popups, kill feed, floating combat text, game over dialogs), use `world.emit_event()`.

### Step 1: Emitting from Any System
```gdscript
# Inside DamageSystem when damage occurs
ECS.world.emit_event(&"combat_text", target_entity, {
	"amount": damage_amount,
	"position": target_entity.global_position,
	"is_crit": true
})
```

### Step 2: Listening in the UI Controller (`ui_bridge_controller.gd`)
See [`examples/ui_bridge_controller.gd`](./examples/ui_bridge_controller.gd).

```gdscript
extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var floating_text_spawner: Node2D = $FloatingTextSpawner


func _ready() -> void:
	# Subscribe to custom world events
	# (Can also be received by an Observer using .on_event(&"combat_text"))
	pass


func display_damage_number(pos: Vector2, amount: float, is_crit: bool) -> void:
	var label := Label.new()
	label.text = str(roundi(amount))
	label.modulate = Color.YELLOW if is_crit else Color.WHITE
	label.global_position = pos
	add_child(label)
	
	# Animate float-up and fade-out
	var tween := create_tween()
	tween.tween_property(label, "position:y", pos.y - 40.0, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)
```

---

## 4. Architectural Layout: HUD in Scene Hierarchy

Keep UI separated from gameplay entities using Godot's `CanvasLayer`:

```text
Main.tscn
├── World (World)                         ← Active ECS simulation
│   └── Systems (Node)
│       ├── gameplay (SystemGroup)
│       └── observers (Node)
│           └── PlayerHUDObserver (Observer) ← Wired via @export to HUD CanvasLayer
├── Level (Node2D/Node3D)                 ← Gameplay terrain & visual entities
└── HUD (CanvasLayer)                     ← Isolated UI Control tree
    └── MarginContainer
        ├── HealthBar (ProgressBar)
        ├── AmmoCounter (Label)
        └── ScoreLabel (Label)
```

---

## 5. Anti-Patterns & Fixes

### Anti-Pattern 1: UI Script Polling ECS Components Every Frame

```gdscript
# ❌ BAD: Running every frame in _process() wastes CPU and creates tight coupling
func _process(_delta: float) -> void:
	var player = ECS.world.get_entity_by_alias(&"player")
	if player and player.has_component(C_Health):
		health_bar.value = player.get_component(C_Health).current


# ✅ GOOD: Observer only updates when property_changed fires!
func each(event: Variant, _entity: Entity, payload: Variant) -> void:
	if event == Observer.Event.CHANGED:
		health_bar.value = payload.new_value
```

---

### Anti-Pattern 2: Putting `Control` Node Exports in Components

```gdscript
# ❌ BAD: Breaks Resource separation and causes errors when saving/reloading scenes
class_name C_Health extends Component
@export var health_bar_widget: ProgressBar # NEVER store UI widgets in Components!


# ✅ GOOD: Component holds pure numbers; Observer routes to UI widget
class_name C_Health extends Component
@export var current: float = 100.0
@export var maximum: float = 100.0
```

