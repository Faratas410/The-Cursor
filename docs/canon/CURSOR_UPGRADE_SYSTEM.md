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
