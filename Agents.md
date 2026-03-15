AGENTS.md

Repository: The Cursor
Engine: Godot 4.6
Language: Strict Typed GDScript

This document defines the operating protocol for coding agents working in this repository.

Agents must follow these rules strictly.

1. ROLE

You are a surgical coding agent working under strict repository governance.

Your job is to implement the requested change with the smallest safe patch possible.

You must prioritize:

parse safety

architectural consistency

minimal diff size

exact scope control

Godot compatibility

Do not optimize for creativity.
Do not optimize for novelty.

Optimize for correctness and repository stability.

2. PROJECT PURPOSE

The repository contains the source code for The Cursor, a minimal incremental game prototype.

Game concept:

The player controls a divine cursor that converts NPCs into followers.

Followers generate Faith.

Faith buys upgrades.

Upgrades scale conversion, economy, sacrifice, world control, and late-game pressure.

Cult Power reflects world dominance and supports progression pressure.

Target progression: 1,000,000 followers.

3. CORE DEVELOPMENT PHILOSOPHY

This project follows four principles:

Simplicity

Modularity

Deterministic systems

Readable architecture

Agents must avoid:

speculative systems

premature extensibility

architectural rewrites

unnecessary abstraction

4. MANDATORY PRE-FLIGHT

Before editing any file, agents must perform these checks.

Read the task carefully.

Identify the minimum number of files required.

Inspect each file before editing it.

Verify the base class of every script being edited.

Example base classes:

Node

Node2D

Control

CanvasLayer

Do not assume APIs from memory.

Confirm:

existing signal names

node names

method names

node paths

before using them.

For canon, asset-path, UI, or production-alignment work, inspect these documents before editing:

`docs/canon/CURSOR_MASTER_CONTEXT.md`

`repo_map.md`

Reuse patterns already present in the repository whenever possible.

If a change can be implemented without introducing new files, prefer editing existing files.

5. ENGINE RULES

Engine version: Godot 4.6

Restrictions:

Strict Typed GDScript only

No C#

No external plugins

No architecture rewrites

Agents must produce code compatible with Godot 4.6 syntax and APIs.

6. ARCHITECTURE OVERVIEW

The project uses a system-based architecture.

Principles:

Entities are lightweight.
Systems own logic.
Global state is centralized.
Communication happens through signals.

This prevents tight coupling between gameplay elements.

Current canonical ownership:

`GameManager` owns global state and upgrade authority.

`UpgradePanel` owns the upgrade-phase lifecycle bridge.

`UpgradeMap` owns upgrade-map rendering and interactions.

`UpgradeMapNode` owns per-node presentation state only.

7. CORE ARCHITECTURE RULES
Rule 1 - Systems own gameplay logic

Examples:

spawn_system

conversion_system

economy_system

progression_system

Entities must remain lightweight.

Rule 2 - Entities never modify global state

Entities must never modify GameManager directly.

Entities should emit signals and let systems react.

Rule 3 - GameManager owns global state

GameManager is the only place where authoritative global variables exist.

Examples:

followers
faith
cult_power
conversion_value
run phase
upgrade tree state

Do not duplicate global state elsewhere.

Rule 4 - Signals for communication

Systems communicate through signals when possible.

Avoid tight coupling between scripts.

Rule 5 - Scene isolation

Scenes must remain self-contained units.

A scene must not depend on unrelated nodes in the SceneTree.

Dependencies should be injected by parent nodes.

8. PROJECT STRUCTURE

This structure must remain stable.

res://

assets/
    backgrounds/
    environment/
    sprites/
    ui/
    vfx/
    ambient_overlays/
    ambient_overlays_animated/

docs/
    canon/
    reports/

scenes/
    main_scene.tscn
    npc.tscn
    cursor.tscn
    skeptic.tscn
    prophet.tscn
    ui/
    effects/
    ambient_overlays/

scripts/
    main/
        game_manager.gd
        main_scene_controller.gd

    systems/
        spawn_system.gd
        conversion_system.gd
        economy_system.gd
        progression_system.gd

    entities/
        npc.gd
        cursor.gd
        skeptic.gd
        prophet.gd

    ui/
        ui_root.gd
        upgrade_panel.gd
        upgrade_map.gd
        upgrade_map_node.gd
        upgrade_map_camera.gd
        icon_registry.gd

Do not reorganize folders without explicit instruction.

9. SCENE STRUCTURE

Current main scene shape:

Main (Node2D)
 |- World
 |  |- Background
 |  |- GroundNoiseOverlay
 |  |- EdgeDetailsOverlay
 |  |- AmbientOverlayLayer
 |  |- DecorPropsLayer
 |  `- NPCContainer
 |- Cursor
 |- MainCamera
 |- UI
 |  |- TopBar
 |  `- UpgradePanel
 `- Systems
    |- SpawnSystem
    |- ConversionSystem
    |- EconomySystem
    |- ProgressionSystem
    `- GameManager

Some world overlay nodes are created or ensured at runtime by `progression_system.gd`.

Avoid unnecessary deep nesting.

10. SIGNAL CONTRACTS

Preferred gameplay signals:

npc_detected(npc)
npc_converted()
upgrade_purchased(upgrade)
dimension_changed(level)

Additional runtime-authoritative signals already in use:

state_changed()
run_started()
run_ended()
upgrade_phase_opened()
upgrade_phase_closed()
sacrifice_performed(amount, faith_gained, source)
auto_sacrifice_triggered(amount, faith_gained)

Reuse existing signals whenever possible.

Do not create duplicate signals with the same meaning.

11. ENTITY RULES

Entities represent world objects.

Examples:

NPC

Cursor

Skeptic

Prophet

Entities may contain:

movement logic

collision logic

signal emission

local visual state

Entities must not contain:

economy logic

progression logic

UI logic

12. SYSTEM RULES

Systems manage mechanics.

Examples:

SpawnSystem

ConversionSystem

EconomySystem

ProgressionSystem

Systems may:

read GameManager values

update GameManager values

connect to entity signals

instantiate runtime support nodes when canonical scene ownership expects them

13. UI RULES

UI must remain passive.

UI may:

display state

emit input events

forward upgrade selections to GameManager

UI must not directly modify gameplay state.

UI events should be routed through systems or controlled manager logic.

Canonical UI ownership:

`UIRoot` owns HUD presentation, debug overlay, world messages, upgrade-phase visibility, and ending presentation.

`UpgradePanel` owns the upgrade overlay lifecycle bridge.

`UpgradeMap` owns map rendering, pan/zoom, tooltip, and purchase forwarding.

`UpgradeMapNode` owns node visuals and local animation only.

14. PERFORMANCE CONSTRAINTS

Baseline target:

max_npc = 200

Current runtime note:

`spawn_system.gd` may temporarily raise effective population above 200 during late global-devotion behavior.

Agents must avoid:

expensive per-frame loops

unnecessary physics checks

repeated scene tree scans in _process()

raising population caps without explicit request

Prefer cached references when safe.

15. STRICT GDSCRIPT RULES

These rules are mandatory.

1. Use typed variables whenever possible

Example:

var followers: int = 0
2. Function signatures must be typed

Example:

func convert_npc(npc: Node) -> void:
3. Avoid dynamic typing unless required

Prefer explicit types.

4. Do not mix syntax from other languages

Common mistakes:

Python-style assumptions

C# API assumptions

JavaScript operators not supported by GDScript

5. Never use // as integer division

// starts a comment in GDScript.

Wrong:

value = a // b

Correct:

value = int(a / b)
6. Confirm node base class before using APIs

Example:

Node does not expose all CanvasItem methods

Control APIs differ from Node2D

Never assume APIs without confirming the class.

7. Never invent APIs

Do not invent:

node paths

signals

properties

exported variables

enums

child node names

Always verify existing code.

8. Do not mix Control and Node2D coordinate systems

These use different properties and layout rules.

9. Reuse repository patterns

Before introducing new patterns, check how similar code is already implemented.

16. FORBIDDEN PATTERNS

Agents must not:

rewrite architecture

move systems between folders

rename scenes without request

rename nodes without request

introduce dependencies

perform speculative refactors

duplicate GameManager state

mix bugfix + refactor + feature in one patch

17. SAFE REFACTORING

Allowed:

renaming local variables

splitting large functions

adding comments

removing dead local code

Not allowed:

moving global state

changing system responsibilities

modifying scene ownership

large structural refactors

18. PATCH BOUNDARY RULES

Every patch must be minimal.

Agents must:

modify the smallest number of files possible

avoid unrelated edits

avoid opportunistic refactors

keep one patch focused on one objective

19. TESTING EXPECTATIONS

When modifying gameplay logic verify where relevant:

NPC spawning

Cursor conversion

Followers increasing

Faith generation

Upgrade purchasing

Run phase to upgrade phase transition

Sacrifice flow if touched

When editing scripts, verify parse safety.

20. PARSE SAFETY RULES

Agents must actively prevent GDScript parse errors.

Mandatory checks:

1. Search for accidental integer division
rg -n "[A-Za-z0-9_\)\]]\s*//\s*[A-Za-z0-9_\(]" scripts
2. Inspect modified scripts for:

accidental //

missing type hints

invented APIs

Control / Node2D property confusion

missing colons

incorrect indentation

3. Re-read every modified script after patching

Verify:

parentheses balanced

indentation correct

function signatures typed

signals referenced exist

node paths verified

4. Never conclude success without parse review

Agents must not finish with "done" unless parse safety was checked.

21. COMPLETION GATE

Before concluding a task, agents must report:

Files modified
What changed
Behavioral impact
Parse-safety checks performed
Any assumptions made

If verification could not be performed, state it clearly.

22. MINIMUM PLAYABLE BUILD

A valid prototype requires:

NPC spawning

Cursor conversion

Faith generation

Upgrade purchasing

Background progression

Run or upgrade loop continuity

Agents should prioritize this state over secondary systems.

23. FEATURES NOT YET IMPLEMENTED

Agents must not implement these systems yet:

Prestige system

Offline progression

Achievements

Save system

Sound system

These are intentionally deferred.

24. WORKFLOW PRIORITY

Agents should follow this sequence:

analyze dependencies

implement minimal solution

preserve architecture

perform parse safety review

produce completion report

25. CURRENT PROJECT STATUS

The current repo is beyond the initial prototype baseline.

Implemented and active in runtime:

NPC spawn scaling and clustered spawn behavior

Cursor conversion loop

Faith generation with live per-second HUD

Upgrade-phase loop with upgrade-map UI

Choice-locked upgrade branches

Manual and auto sacrifice

World background progression and ambient overlay support

Cult Power, divinity progression, and final sequence scaffolding

Documentation rule:

Treat `docs/canon/CURSOR_MASTER_CONTEXT.md` as canonical intent and the current runtime files as implementation truth.

When they differ, update documentation carefully to distinguish:

implemented runtime behavior

canonical target behavior

deferred or asset-pipeline-only canon

26. FINAL GOAL

The goal is a clean incremental prototype that is easy to expand.

Focus on:

clarity

maintainability

minimalism

safe Godot code

deterministic gameplay systems
