# CURSOR ECONOMY SYSTEM (CANON)

Engine: Godot 4.6
Language: Strict Typed GDScript

## Core Formulae

### Faith per second

Runtime canonical formula:

faith_per_second = ((followers * 0.008 * faith_gain_multiplier) / (1.0 + followers / 200.0)) + passive_faith_per_second

This formula must be used both in runtime economy and HUD display.

### Manual/Auto Sacrifice

Canonical API:

perform_sacrifice(amount: int, source: String) -> float

Preview API:

get_sacrifice_faith_preview(amount: int, source: String) -> float

Tier multipliers:

- < 50: x1.00
- 50+: x1.10
- 100+: x1.20
- 200+: x1.35
- 400+: x1.50

Source multipliers:

- manual: x1.00
- auto: x0.80 base (upgrade-adjustable)

Final sacrifice payout:

final_faith = amount * tier_multiplier * sacrifice_efficiency_multiplier * source_multiplier

## Phase Rules

- Manual sacrifice is allowed in UPGRADE phase only.
- Auto sacrifice is active in GAMEPLAY phase only.
- Auto sacrifice is paused during UPGRADE phase.

## Auto Sacrifice Runtime Rules

Base values:

- auto_sacrifice_interval = 10.0
- auto_sacrifice_percent = 0.10
- auto_sacrifice_min_followers = 40
- auto_sacrifice_min_amount = 10
- auto_sacrifice_max_amount = 80
- auto_sacrifice_follower_floor = 25

Constraints:

- Never spend followers below floor.
- Respect min and max amount.
- Do nothing if requirements are not met.

## Rebalance Summary

- npc_spawn_interval = 2.2
- spawn_cluster_min = 2
- spawn_cluster_max = 4
- MAX_CONVERSION_RADIUS = 44.0 (hard cap)

Nerfs:

- Cult Donations: +0.2 faith/sec
- Sacred Economy: +0.15 followers/sec
- Divine Harvest: +0.5 faith/conversion
- Curious Crowds: +0.20 spawn multiplier add
- Cult Expansion: *1.35 and +1 cluster bonus

Radius tuning under cap:

- Mass Conversion: +8
- Divine Aura: +10
- Worship Wave: +12
