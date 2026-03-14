# CURSOR UPGRADE SYSTEM (CANON)

Engine: Godot 4.6
Language: Strict Typed GDScript

## Choice Groups (Mutually Exclusive)

Choice locks are runtime-enforced in purchase logic.
When one choice in a group is purchased, sibling choices in that group become `choice_locked`.

### Group 1: faith_path

- Steady Worship
- Violent Faith

### Group 2: world_path

- Path of Growth
- Path of Control

### Group 3: cult_path

- Wide Influence
- Focused Conversion

## Ritual Branch

Required ritual upgrades:

- Ritual Knife: unlocks manual sacrifice
- Blood Ledger: sacrifice efficiency +0.15
- Blood Tithe: unlocks auto sacrifice
- Grand Offering: increases auto-sac cap and source multiplier

## Cost Rebalance

Main costs were raised to slow runaway progression.
Reference values include:

- Magnetic Presence: 40
- Faster Conversion: 75
- Conversion Pulse: 120
- Conversion Chain: 180
- Mass Conversion: 320

- Faith Amplifier: 60
- Cult Donations: 110
- Sacred Economy: 220
- Divine Harvest: 380
- Overflow Faith: 700

- Curious Crowds: 90
- Pilgrimage: 130
- Wandering Faith: 180
- Sacred Ground: 340

- Divine Aura: 500
- Cult Expansion: 800
- Worship Wave: 950
- They Can See You: 1800

## Runtime State Contracts

Choice state is kept in:

chosen_upgrade_groups: Dictionary

Display states include:

- available
- purchased
- locked
- unaffordable
- choice_locked

UI must show clear reason for `choice_locked`.

## Upgrade UI Presentation Canon

Upgrade logic remains authoritative in `GameManager`.

Canonical read/query methods:
- `get_upgrade_definitions()`
- `get_upgrade_display_state(id)`
- `are_dependencies_met(id)`
- `get_choice_lock_reason(id)`

Canonical purchase/flow methods:
- `purchase_upgrade(id)`
- `continue_from_upgrade()`

Canonical signal wiring:
- `upgrade_purchased(upgrade: Dictionary)`

The Upgrade UI is view-only and must not duplicate gameplay logic.

## Upgrade Map UI Ownership

Canonical ownership chain:

- `UpgradePanel` owns lifecycle and signal bridge.
- `UpgradeMap` owns rendering and interaction.
- `UpgradeMapNode` owns per-node visual state.

No parallel card/slot renderer is allowed.

## Map Layout and Interaction Canon

Canonical category order:

- Conversion
- Faith Flow
- World Control
- Cult Power
- Ritual

Canonical interaction set:

- hover tooltip
- click purchase
- mouse-wheel zoom
- click-drag pan with bounded offset

Map interaction is presentation-only and must not change upgrade state rules.
