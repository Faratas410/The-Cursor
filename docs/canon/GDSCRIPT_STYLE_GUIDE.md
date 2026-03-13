GDSCRIPT_STYLE_GUIDE.md

Canonical style guide for The Cursor repository.

Engine: Godot 4.6
Language: Strict Typed GDScript

This document defines the coding standards and safety rules for writing GDScript in this repository.

All coding agents must follow this guide.

1. LANGUAGE MODE

This repository uses:

Strict Typed GDScript

Agents must prefer explicit typing for:

variables

function parameters

return types

Example:

var followers: int = 0
var faith: float = 0.0

Avoid dynamic typing unless strictly necessary.

2. VARIABLE DECLARATION RULES

Always prefer explicit types.

Correct:

var followers: int = 0
var npc_speed: float = 80.0
var is_converted: bool = false

Avoid:

var followers = 0
var npc_speed = 80

Typed variables improve:

readability

static analysis

agent reliability

3. FUNCTION SIGNATURES

All functions must include:

typed parameters

typed return values

Example:

func convert_npc(npc: Node) -> void:

Another example:

func get_conversion_value() -> int:

Avoid untyped signatures:

func convert_npc(npc):

4. FUNCTION SIZE

Functions should remain small and focused.

Recommended maximum:

~40 lines

If a function becomes larger:

Split into helper functions.

Example:

func process_conversion(npc: Node) -> void:
    apply_conversion(npc)
    update_follower_count()
    emit_conversion_signal()

5. CLASS BASE TYPES

Before writing code, confirm the base class.

Different node types expose different APIs.

Common classes:

Node
Node2D
Control
CanvasLayer
CharacterBody2D
Area2D

Never assume an API without confirming the base class.

6. CONTROL vs NODE2D

A very common source of bugs.

Node2D uses:
position
rotation
scale
global_position

Control uses:
size
anchors
offsets
theme

Do not mix these systems.

Example mistake:

control_node.position = Vector2(100,100)

Correct:

control_node.size = Vector2(200,50)

7. INTEGER DIVISION RULE

GDScript does not support // integer division.

// starts a comment.

Wrong:

value = a // b

Correct:

value = int(a / b)

Agents must always verify this.

8. SIGNAL USAGE

Signals are the preferred communication method.

Example:

signal npc_converted

Emit signals like this:

emit_signal("npc_converted")

Connect signals in systems when possible.

Avoid direct coupling between entities.

9. NODE PATH SAFETY

Never invent node paths.

Wrong:

$UI/TopBar/FaithLabel

unless confirmed in the scene.

Preferred approach:

@onready var faith_label: Label = $UI/TopBar/FaithLabel

Always verify scene structure before referencing nodes.

10. ONREADY VARIABLES

Use @onready for node references.

Example:

@onready var npc_container: Node = $World/NPCContainer

Avoid searching nodes every frame.

Wrong:

get_node("World/NPCContainer")

inside _process().

11. PROCESS FUNCTIONS

Godot main loops:

_process(delta)
_physics_process(delta)

Guidelines:

Use _process for:

UI updates

lightweight logic

Use _physics_process for:

movement

physics interactions

Avoid expensive logic inside either loop.

12. RANDOMNESS

Prefer controlled randomness.

Example:

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
rng.randomize()

Avoid using global random functions repeatedly.

13. CONSTANTS

Constants should use UPPERCASE_SNAKE_CASE.

Example:

const MAX_NPC: int = 200
const BASE_CONVERSION_VALUE: int = 1

14. ENUMS

Enums improve readability.

Example:

enum UpgradeType {
    CONVERSION,
    SPAWN,
    FAITH
}

15. GAME MANAGER ACCESS

Global game state lives in GameManager.

Examples:

followers
faith
spawn_rate
conversion_value

Entities must not modify GameManager directly.

Systems handle global state.

16. EXPORT VARIABLES

Export variables only when needed for the editor.

Example:

@export var npc_speed: float = 80.0

Avoid exporting internal values.

17. SCENE REFERENCES

Avoid deep scene tree traversal.

Bad:

get_tree().get_root().get_node("Main/UI/TopBar")

Prefer cached references or injected dependencies.

18. MEMORY SAFETY

When removing nodes:

queue_free()

Avoid calling free() directly.

19. LOOP SAFETY

Avoid modifying arrays while iterating.

Wrong:

for npc in npc_list:
    npc_list.erase(npc)

Correct approach:

Use a temporary list or iterate backwards.

20. DEBUG PRINTS

Temporary debug prints are allowed but must be removed.

Example:

print("NPC converted")

Before final patches, remove unnecessary logs.

21. ERROR PREVENTION CHECKLIST

Before committing code, verify:

variable types defined

function signatures typed

no accidental //

node paths verified

Control vs Node2D APIs not mixed

signals exist

parentheses balanced

indentation correct

22. AGENT SAFETY RULES

Coding agents must never invent APIs.

Agents must not invent:

node paths

signals

enums

exported properties

scene children

Everything must be verified in existing files.

23. PATCH SIZE RULE

Prefer small patches.

Do not mix:

refactor

bugfix

feature

in the same patch unless requested.

24. EXAMPLE SAFE SCRIPT

Example minimal typed script.

extends Node2D

signal npc_converted

@export var conversion_value: int = 1

var followers: int = 0

func convert_npc(npc: Node) -> void:
    followers += conversion_value
    emit_signal("npc_converted")

25. STYLE SUMMARY

Preferred code style:

typed variables

typed functions

small functions

signal-based communication

cached node references

minimal architecture

Avoid:

dynamic typing

invented APIs

deep node lookups

monolithic scripts

FINAL NOTE

This document exists to reduce:

parse errors

invalid APIs

architectural drift

Agents must always consult:

AGENTS.md
GDSCRIPT_STYLE_GUIDE.md

before writing or modifying code.
