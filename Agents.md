# AGENTS.md

Repository: **The Cursor**
Engine: **Godot 4.6**
Language: **Strict Typed GDScript**

This document defines the operational rules for coding agents (Codex, AI assistants, automation bots).

Agents must follow these rules strictly.

---

# 1. PROJECT PURPOSE

The repository contains the source code for **The Cursor**, a minimal incremental game prototype.

Game concept:

The player controls a divine cursor that converts NPCs into followers.

Followers generate Faith.

Faith buys upgrades.

Upgrades scale the game.

Target progression: **1,000,000 followers**.

---

# 2. DEVELOPMENT PHILOSOPHY

This project follows four principles:

Simplicity
Modularity
Deterministic systems
Readable architecture

Agents must avoid unnecessary abstraction or complexity.

---

# 3. ENGINE RULES

Engine version:

Godot **4.6**

Language:

Strict typed **GDScript only**

No C#.

No external plugins.

---

# 4. ARCHITECTURE OVERVIEW

The project follows a **system-based architecture**.

Entities are lightweight.

Systems control logic.

Global state is centralized.

Entities emit signals.
Systems react to signals.

This prevents tight coupling between gameplay elements.

---

# 5. CORE ARCHITECTURE RULES

Agents must follow these rules.

### Rule 1 — Systems own logic

Gameplay logic belongs in **systems**.

Examples:

spawn_system
conversion_system
economy_system
progression_system

Entities must remain lightweight.

---

### Rule 2 — Entities never modify global state

Entities must **not modify GameManager directly**.

Instead they emit signals.

Example:

npc emits signal → conversion_system handles it.

---

### Rule 3 — GameManager owns global state

GameManager is the only place where global variables exist.

Examples:

followers
faith
conversion_value
spawn_rate

Agents must never duplicate global state elsewhere.

---

### Rule 4 — Signals for communication

Systems must communicate through **signals**.

Avoid direct references between systems whenever possible.

---

### Rule 5 — Scene isolation

Scenes must be **self-contained units**.

A scene should not rely on unrelated nodes in the SceneTree.

Dependencies should be injected by parent nodes.

---

# 6. PROJECT STRUCTURE

The project structure must remain stable.

res://

assets/
sprites/
backgrounds/
ui/

scenes/
main_scene.tscn
npc.tscn
cursor.tscn
upgrade_button.tscn

scripts/

main/
game_manager.gd

systems/
spawn_system.gd
conversion_system.gd
economy_system.gd
progression_system.gd

entities/
npc.gd
cursor.gd

ui/
ui_root.gd
upgrade_panel.gd

Agents must not reorganize this structure without explicit instruction.

---

# 7. SCENE STRUCTURE

The main scene must remain structured as follows.

Main (Node2D)

World
Background
NPCContainer

Cursor

UI
TopBar
FollowersLabel
FaithLabel

UpgradePanel

Systems
GameManager

Agents must not introduce deep scene nesting.

---

# 8. SIGNAL CONTRACTS

Signals used in the project:

npc_detected(npc)

npc_converted()

upgrade_purchased(upgrade)

dimension_changed(level)

Agents must reuse these signals rather than creating duplicates.

---

# 9. ENTITY RULES

Entities represent **world objects**.

Examples:

NPC
Cursor

Entities must contain only:

movement logic
collision logic
signal emission

Entities must not contain:

economy logic
progression logic
UI logic

---

# 10. SYSTEM RULES

Systems manage game mechanics.

Examples:

SpawnSystem
ConversionSystem
EconomySystem
ProgressionSystem

Systems may read or update GameManager values.

Systems may connect to entity signals.

---

# 11. UI RULES

UI must remain passive.

UI elements:

display state
emit input events

UI must not modify gameplay state directly.

UI events must call systems.

---

# 12. PERFORMANCE CONSTRAINTS

NPC count must remain limited.

Hard limits:

max_npc = 200

Agents must avoid per-frame heavy loops.

Avoid expensive physics operations.

---

# 13. CODE STYLE

Strict typed variables required.

Example:

var followers : int = 0

Function signatures must include types.

Example:

func convert_npc(npc : Node) -> void:

Avoid dynamic typing.

---

# 14. AGENT MODIFICATION RULES

Agents are allowed to:

create scenes
create scripts
connect signals
implement systems
refactor small functions

Agents must NOT:

rewrite architecture
change core folder structure
introduce new frameworks
add dependencies

---

# 15. SAFE REFACTORING

Allowed refactors:

renaming variables
splitting large functions
adding comments
improving readability

Disallowed refactors:

moving global state
changing system responsibilities

---

# 16. TESTING REQUIREMENTS

When implementing features, agents must verify:

NPC spawn works
Cursor converts NPC
Followers increase
Faith increases over time
Upgrades apply correctly

---

# 17. MINIMUM PLAYABLE BUILD

A playable build requires:

NPC spawning
Cursor conversion
Faith generation
Upgrade purchase
Background progression

Agents should prioritize reaching this state.

---

# 18. FUTURE FEATURES (DO NOT IMPLEMENT)

Agents must not implement these yet:

Prestige system
Offline progression
Achievements
Sound system
Save system

These will be added later.

---

# 19. AGENT WORKFLOW

When performing tasks:

1 analyze scene dependencies
2 implement minimal solution
3 avoid premature optimization
4 preserve architecture rules

---

# 20. FINAL GOAL

Produce a **clean, minimal incremental prototype** that is easy to extend.

Focus on:

clarity
maintainability
simple gameplay loop
