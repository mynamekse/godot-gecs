---
name: ge cs-state-machine
description: Use when designing or implementing character states and finite state machines (FSM) in GECS — Property-Based States (enum/component), Component-Swapping States, layered/orthogonal states (locomotion + combat), and avoiding OOP Node-based FSMs
---

# GECS State Machine in Godot 4.3+

Implement character states and state transitions using GECS v9. In traditional Godot OOP, state machines are often implemented as hierarchies of Node children. In GECS, state is managed through **pure data**: either via **Property-Based States** (enums/strings in a component) or **Component-Swapping States** (adding/removing state components via `cmd`), taking advantage of archetype cache locality.

> **Addon:** GECS · version `v9` · Godot 4.3+ · MIT  
> **Related skills:** **gecs-core** for primitives, **gecs-systems** for `cmd` CommandBuffer mutations, **gecs-queries** for state filtering, **gecs-observers** for `.on_match()`/`.on_unmatch()` state enter/exit triggers.

---

## 1. State Pattern Comparison in ECS

| Pattern | How It Works | Archetype Transition | Best Suited For |
|---|---|---|---|
| **Property-Based State** | State stored as an enum/flag inside a single component (`C_CharacterState.state`) | **No** (Zero transition overhead) | Rapidly changing states (Idle, Run, Jump, Fall, Walk), platformer locomotion |
| **Component-Swapping State** | Entity gains/loses distinct state components (`C_Stunned`, `C_Dashing`, `C_Invulnerable`) | **Yes** (1 coalesced move via `cmd`) | Mutually exclusive systems, gating entire systems (e.g. `StunSystem` only queries `C_Stunned`) |
| **Orthogonal / Layered State** | Multiple independent components (e.g. Locomotion + Combat + Status) | **Minimal** | Action RPGs, games with simultaneous movement and shooting |
| **Traditional Node FSM** *(Anti-pattern)* | Node children per state (`StateIdle extends Node`) | N/A | **Avoid in ECS:** Breaks archetype cache, adds Node overhead |

---

## 2. Approach 1: Property-Based State (High Frequency)

Use when states transition rapidly (every few frames) and do not fundamentally alter which systems need to process the entity.

### Component (`c_character_state.gd`)
See [`examples/c_character_state.gd`](./examples/c_character_state.gd).

```gdscript
class_name C_CharacterState
extends Component

enum State {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	DASHING,
	STUNNED
}

@export var current_state: State = State.IDLE
@export var state_time: float = 0.0


func _init(initial: State = State.IDLE) -> void:
	current_state = initial
	state_time = 0.0


func change_state(new_state: State) -> void:
	if current_state != new_state:
		current_state = new_state
		state_time = 0.0
```

### System Transition Logic (`s_locomotion_state_system.gd`)

```gdscript
class_name LocomotionStateSystem
extends System


func query() -> QueryBuilder:
	return q.with_all([C_CharacterState, C_Velocity])


func process(entities: Array[Entity], _components: Array, delta: float) -> void:
	for entity in entities:
		var state := entity.get_component(C_CharacterState) as C_CharacterState
		var vel := entity.get_component(C_Velocity) as C_Velocity
		state.state_time += delta

		match state.current_state:
			C_CharacterState.State.IDLE:
				if not is_zero_approx(vel.direction.x):
					state.change_state(C_CharacterState.State.RUNNING)
				elif vel.direction.y < 0.0:
					state.change_state(C_CharacterState.State.JUMPING)

			C_CharacterState.State.RUNNING:
				if is_zero_approx(vel.direction.x):
					state.change_state(C_CharacterState.State.IDLE)
				elif vel.direction.y < 0.0:
					state.change_state(C_CharacterState.State.JUMPING)

			C_CharacterState.State.JUMPING:
				if vel.direction.y >= 0.0:
					state.change_state(C_CharacterState.State.FALLING)
```

---

## 3. Approach 2: Component-Swapping State (System Gating)

Use when entering a state completely changes what systems should operate on the entity (e.g. `C_Stunned` suspends input systems, `C_Dashing` engages invincible hurtbox filters).

### State Marker Components
```gdscript
class_name C_Stunned extends Component:
	@export var duration: float = 1.0
	func _init(dur: float = 1.0) -> void: duration = dur

class_name C_Dashing extends Component:
	@export var dash_speed: float = 500.0
	@export var duration: float = 0.2
	func _init(spd: float = 500.0, dur: float = 0.2) -> void:
		dash_speed = spd; duration = dur
```

### Safe State Swapping with `cmd: CommandBuffer`
In GECS v9, queued `cmd` removals and additions are **coalesced** into a single archetype transition:

```gdscript
# Transitioning from Dashing to Idle
cmd.remove_component(entity, dashing_comp)
cmd.add_component(entity, C_Grounded.new())
```

### Automatic System Gating via Query Filtering:
```gdscript
# PlayerInputSystem ignores stunned entities automatically!
func query() -> QueryBuilder:
	return q.with_all([C_Player, C_Velocity]).with_none([C_Stunned])
```

---

## 4. Layered / Orthogonal States (Action RPGs)

Instead of a giant combinatorial state enum (`IDLE_ATTACKING`, `RUNNING_ATTACKING`, `AIR_ATTACKING`), separate concerns into orthogonal components:

```text
Entity: Player
├── C_LocomotionState (IDLE, RUN, JUMP)   ← Processed by LocomotionSystem
├── C_CombatState     (IDLE, CAST, ATTACK) ← Processed by CombatSystem
└── C_StatusEffect    (STUNNED, POISONED)  ← Processed by StatusSystem
```

---

## 5. Detecting State Enter/Exit via Observers

Pair Component-Swapping with GECS Monitors (`.on_match()` / `.on_unmatch()`) to execute one-off enter/exit logic (e.g. playing sound effects, visual particle bursts):

```gdscript
class_name StunVisualObserver
extends Observer


func query() -> QueryBuilder:
	return q.with_all([C_Stunned]).on_match().on_unmatch()


func each(event: Variant, entity: Entity, _payload: Variant) -> void:
	match event:
		Observer.Event.MATCH:
			# Enter state: show dizzy stars
			entity.get_node(^"DizzyStars").visible = true
		Observer.Event.UNMATCH:
			# Exit state: hide dizzy stars
			entity.get_node(^"DizzyStars").visible = false
```

---

## 6. Anti-Patterns & Fixes

### Anti-Pattern 1: Traditional OOP Node-based FSM on Entities

```gdscript
# ❌ BAD: Attaching Node FSM scripts (StateIdle, StateJump) as child nodes under Entity
# Breaks archetype locality and forces per-node SceneTree dispatch
func _process(delta: float) -> void:
	current_state_node.update(delta)


# ✅ GOOD: Keep state as pure data components; process in archetype-backed Systems
func query() -> QueryBuilder:
	return q.with_all([C_CharacterState, C_Velocity]).iterate([C_Velocity])
```

---

### Anti-Pattern 2: Mutating World State Directly During Transitions

```gdscript
# ❌ BAD: Modifying components directly while iterating
entity.remove_component(C_Dashing) # Mutates archetype during loop!


# ✅ GOOD: Always queue transitions through cmd
cmd.remove_component(entity, dashing_comp)
```

