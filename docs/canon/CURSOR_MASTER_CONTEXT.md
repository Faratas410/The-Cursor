# THE CURSOR - MASTER CONTEXT

Status: definitive canonical context for AI, art generation, UI generation, asset planning, and production alignment.

Authority rule:
- This document replaces fragmented canon/spec/style/manifests for game context, visual style, UI direction, asset generation, economy-facing presentation rules, and upgrade presentation rules.
- If any existing asset, prompt, or future document conflicts with this document, this document wins.
- This document is written to minimize interpretation. Follow it literally.

---

## 1. Project Identity

Title:
- `THE CURSOR`

Engine:
- `Godot 4.6`

Language:
- `Strict Typed GDScript`

Genre:
- Minimal incremental game prototype

Core fantasy:
- The player controls a divine cursor.
- The cursor converts NPCs into followers.
- Followers generate Faith.
- Faith buys upgrades.
- Upgrades increase reach, conversion power, economy, and stage progression.
- Long-term target progression is `1,000,000 followers`.

Design intent:
- readable
- deterministic
- simple
- expandable
- gameplay-first

Do not frame the project as:
- a narrative RPG
- a management sim with deep building systems
- a realistic medieval world
- a prestige/offline-progression game

Not implemented and intentionally deferred:
- prestige
- offline progression
- achievements
- save system
- sound system

---

## 2. Core Gameplay Loop

Primary loop:
1. NPCs spawn into the world.
2. The cursor attracts and converts NPCs.
3. Converted NPCs become followers.
4. Followers generate Faith.
5. Faith is spent during upgrade phase.
6. Upgrades improve conversion, economy, influence, sacrifice, and world control.
7. Follower thresholds change the world stage and visual background.
8. The game escalates toward total world domination.

Player-facing resources:
- `followers`
- `faith`
- `cult_power`

Primary gameplay readability rule:
- The cursor and active NPC/follower motion must remain more important than environmental decoration.

---

## 3. Runtime Architecture

Architecture model:
- systems own logic
- entities stay lightweight
- global state is centralized
- communication uses signals

Authority ownership:
- `GameManager` owns global state
- systems read/write `GameManager`
- entities emit signals
- UI displays state and forwards input only

Entities must not:
- modify global state directly
- own economy logic
- own progression logic
- own UI logic

UI must not:
- duplicate gameplay logic
- become authoritative for upgrade, economy, or progression state

Canonical systems:
- `spawn_system`
- `conversion_system`
- `economy_system`
- `progression_system`

Canonical entities:
- `cursor`
- `npc`
- `skeptic`
- `prophet`

Canonical UI ownership:
- `UpgradePanel` owns lifecycle bridge
- `UpgradeMap` owns upgrade map rendering/interactions
- `UpgradeMapNode` owns node visuals/state presentation

No parallel UI implementation is allowed for the same feature if one canonical owner already exists.

---

## 4. Canonical Scene Structure

Expected main scene shape:

```text
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
```

Gameplay-space rule:
- center of the world is the active play area
- edges hold environmental framing and decorative support

Scene isolation rule:
- scenes must not depend on unrelated tree nodes
- dependencies must be injected through exported paths or canonical ownership chains

---

## 5. Canonical Signals and Contracts

Preferred gameplay signals:
- `npc_detected(npc)`
- `npc_converted()`
- `upgrade_purchased(upgrade)`
- `dimension_changed(level)`

Signal policy:
- reuse these meanings
- do not create duplicate signals for the same concept

Upgrade UI query methods:
- `get_upgrade_definitions()`
- `get_upgrade_display_state(id)`
- `are_dependencies_met(id)`
- `get_choice_lock_reason(id)`

Upgrade flow methods:
- `purchase_upgrade(id)`
- `continue_from_upgrade()`

Upgrade purchase signal:
- `upgrade_purchased(upgrade: Dictionary)`

---

## 6. Economy Canon

Faith-per-second formula:

```text
faith_per_second =
((followers * 0.008 * faith_gain_multiplier) / (1.0 + followers / 200.0))
+ passive_faith_per_second
```

This exact formula must be used consistently in:
- economy runtime
- HUD display
- previews based on current live state

Sacrifice API:
- `perform_sacrifice(amount: int, source: String) -> float`
- `get_sacrifice_faith_preview(amount: int, source: String) -> float`

Sacrifice tier multipliers:
- `< 50`: `x1.00`
- `50+`: `x1.10`
- `100+`: `x1.20`
- `200+`: `x1.35`
- `400+`: `x1.50`

Sacrifice source multipliers:
- `manual`: `x1.00`
- `auto`: `x0.80` base, then upgrade-adjustable

Final sacrifice payout:

```text
final_faith =
amount
* tier_multiplier
* sacrifice_efficiency_multiplier
* source_multiplier
```

Phase rules:
- manual sacrifice: upgrade phase only
- auto sacrifice: gameplay phase only
- auto sacrifice pauses during upgrade phase

Auto-sacrifice defaults:
- `auto_sacrifice_interval = 10.0`
- `auto_sacrifice_percent = 0.10`
- `auto_sacrifice_min_followers = 40`
- `auto_sacrifice_min_amount = 10`
- `auto_sacrifice_max_amount = 80`
- `auto_sacrifice_follower_floor = 25`

Auto-sacrifice constraints:
- never reduce followers below floor
- respect min and max sacrifice amount
- do nothing if requirements are not met

Baseline rebalance:
- `npc_spawn_interval = 2.2`
- `spawn_cluster_min = 2`
- `spawn_cluster_max = 4`
- `MAX_CONVERSION_RADIUS = 44.0` hard cap

---

## 7. Upgrade System Canon

Upgrade map is canonical.

Canonical branch order:
- Conversion
- Faith Flow
- World Control
- Cult Power
- Ritual

Canonical interactions:
- hover tooltip
- click purchase
- mouse-wheel zoom
- click-drag pan with bounded offset

Choice groups are mutually exclusive and runtime enforced.

Choice groups:
- `faith_path`
  - `Steady Worship`
  - `Violent Faith`
- `world_path`
  - `Path of Growth`
  - `Path of Control`
- `cult_path`
  - `Wide Influence`
  - `Focused Conversion`

Choice result:
- when one upgrade in a choice group is purchased, its siblings become `choice_locked`

Display states:
- `available`
- `purchased`
- `locked`
- `unaffordable`
- `choice_locked`

UI rule:
- if `choice_locked`, UI must show clear reason

Required ritual upgrades:
- `Ritual Knife`: unlocks manual sacrifice
- `Blood Ledger`: `+0.15` sacrifice efficiency
- `Blood Tithe`: unlocks auto sacrifice
- `Grand Offering`: increases auto-sac cap and source multiplier

Important cost references:
- `Magnetic Presence`: `40`
- `Faster Conversion`: `75`
- `Conversion Pulse`: `120`
- `Conversion Chain`: `180`
- `Mass Conversion`: `320`
- `Faith Amplifier`: `60`
- `Cult Donations`: `110`
- `Sacred Economy`: `220`
- `Divine Harvest`: `380`
- `Overflow Faith`: `700`
- `Curious Crowds`: `90`
- `Pilgrimage`: `130`
- `Wandering Faith`: `180`
- `Sacred Ground`: `340`
- `Divine Aura`: `500`
- `Cult Expansion`: `800`
- `Worship Wave`: `950`
- `They Can See You`: `1800`

Canonical presentation rule:
- upgrade logic remains authoritative in `GameManager`
- the map UI is presentation only

Upgrade node readability rule:
- show icon, name, and cost
- long descriptions belong to tooltip only
- avoid overlap at 1080p baseline and remain readable on smaller windows

---

## 8. World Progression Canon

World progression is tied to follower thresholds and stage escalation.

Dimension thresholds:
- `100`
- `1,000`
- `10,000`
- `100,000`
- `1,000,000`

Canonical world stages:
1. `Village`
2. `Town`
3. `City`
4. `Metropolis`
5. `Planet`
6. `Cult World`

Stage background runtime set:
- `bg_village.png`
- `bg_town.png`
- `bg_city.png`
- `bg_metropolis.png`
- `bg_planet.png`
- `bg_cult_world.png`

Stage escalation rule:
- every stage must introduce distinct visual elements, not only recolor the previous stage

Late-game world messages:
- world should visually imply that it is becoming dominated by the cult

---

## 9. Global Art Direction

Visual identity:
- minimalist cult-themed cartoon aesthetic
- inspired by `Cult of the Lamb`, but simplified for incremental readability

Primary priority order:
1. readability
2. gameplay clarity
3. silhouette recognition
4. style coherence
5. detail

Global rendering rules:
- strict top-down or near-top-down orthographic feeling
- no perspective distortion
- no photorealism
- no realistic material rendering
- no heavy texture noise
- no painterly clutter that reduces gameplay readability

Shape rules:
- rounded silhouettes
- simple forms
- low complexity
- clean outline

Lighting rules:
- soft ambient lighting
- no cinematic dramatic shadows
- no strong directional realism

Color rules:
- controlled, consistent palette
- no neon
- no mobile-game generic gloss

Anti-style rules:
- do not generate realistic medieval concept art
- do not generate dense storybook illustrations for gameplay backgrounds
- do not generate flat generic dashboard UI

---

## 10. Canonical Palette

Primary purples:
- dark purple `#2A1A38`
- mid purple `#4E2C68`
- light purple `#7B4FA1`

Gold accents:
- gold dark `#B0892C`
- gold light `#F0D97A`

Environmental greens:
- grass green `#7DA65D`
- tree green `#3F7A4A`

UI panel palette:
- panel base `#241B33`
- border gold `#D4AF37`
- highlight gold `#F0D97A`

Extended UI token set:
- outer frame gold `#E0A73A`
- inner accent gold `#F6D67D`
- shadow amber `#6B3A00` at `35-45%` opacity
- purple blend tones `#2A1142`, `#3A1A5A`, `#4D2672`
- violet glow `#B56CFF` at low opacity

Palette rule:
- slight variation is acceptable
- hue family shifts outside this range are not acceptable

---

## 11. Line, Shape, and Shading Rules

Outline:
- required on characters and props
- very dark purple or near black
- clearly visible at gameplay scale
- smooth and rounded

Two-tone shading:
- mandatory
- every asset must contain at least base tone + darker shadow tone
- fully flat art is invalid

Silhouette fill:
- sprites must occupy most of their canvas
- characters should fill `70-80%` of sprite height

Anti-icon rule:
- world sprites must not look like UI glyphs
- if a sprite is tiny in a large canvas, single-color, or missing shading, it is invalid

---

## 12. Character Art Canon

Character base proportion:
- head `~60%`
- body `~30%`
- legs `~10%`

All characters must remain readable when zoomed out.

Shared rules:
- soft ellipse shadow under character
- shadow delivered as separate sprite: `characters/shadow.png`
- eyes or face cues must remain readable when required by faction

Faction silhouettes:

Civilian:
- round head
- simple shirt
- neutral readable pose
- visible eyes

Skeptic:
- crossed arms or defensive posture
- darker palette
- skeptical expression

Cultist:
- hooded robe
- face mostly hidden
- glowing eyes
- cult emblem on chest

Prophet:
- larger, more ornate robe
- staff
- mystical aura
- stronger gold accents
- visually superior to cultists

Variation policy:
- prefer parameterized variants over total redesign

---

## 13. Cursor Canon

The cursor is the primary gameplay entity and must remain visually dominant.

Core motifs:
- ritual circle
- central cult eye
- geometric magical symbols

Primary colors:
- gold
- white highlights
- purple glow

Cursor progression states:
- `cursor_base`
- `cursor_glow`
- `cursor_cult`
- `cursor_divine`
- `cursor_final`

Layered cursor components:
- `cursor_base.png`
- `cursor_symbol.png`
- `cursor_glow.png`
- `cursor_aura.png`

Progression rule:
- each tier increases glow intensity, symbol complexity, and aura radius

Canvas:
- `128x128`

Alignment:
- perfectly centered

---

## 14. Environment and Map Composition Canon

Environment purpose:
- support gameplay
- frame stage identity
- never obstruct readability of cursor/NPC interaction

Universal map rule:
- center area is gameplay space and must stay visually calm
- edges contain environmental decoration

Background composition rule:
- treat gameplay backgrounds as modular-friendly maps, not finished narrative illustrations

Canonical map structure:
1. base ground
2. path or stage-defining terrain overlay
3. edge vegetation / edge detail overlay
4. separate modular props placed above the background when needed

Do not bake large props irreversibly into the central playfield.

Stage identities:

Village:
- grass terrain
- small houses
- trees
- wood fences

Town:
- more houses
- stone paths
- market elements

City:
- stone plazas
- walls
- larger buildings

Metropolis:
- dense buildings
- towers
- stone roads

Planet:
- alien ground
- crystals
- unusual but controlled palette

Cult World:
- ritual symbols
- altars
- candles
- cult banners

Composition constraints:
- central area must stay clear
- density should increase toward corners and borders
- decorative contrast near the playfield center must stay low
- no oversized props dominating characters

---

## 15. Props Canon

Props are modular environmental assets used to support stage identity.

Prop rules:
- simple
- readable
- rounded silhouettes
- moderate detail only
- no realistic architectural clutter

Canonical environment scale buckets:
- environment props: `128x128 PNG`
- large props: `256x256 PNG`

Current and planned environment namespace includes:
- `village_house_small.png`
- `village_house_medium.png`
- `village_house_large.png`
- `town_house_a.png`
- `town_house_b.png`
- `tree_a.png`
- `tree_b.png`
- `tree_c.png`
- `wood_fence.png`
- `wood_fence_short.png`
- `stone_wall_short.png`
- `cult_banner.png`
- `altar_01.png`
- `altar_02.png`
- `ritual_circle_ground.png`
- `ritual_pillar_01.png`

Planned modular props include:
- `well_01.png`
- `cart_01.png`
- `signpost_01.png`
- `barrel_01.png`
- `fence_broken_01.png`
- `grass_patch_a.png`
- `grass_patch_b.png`
- `stone_small_a.png`
- `stone_small_b.png`
- `crate_small.png`
- `candle_cluster_01.png`
- `candle_cluster_02.png`
- `candle_cluster_03.png`
- `cult_banner_01.png`
- `ritual_stone_01.png`
- `ritual_stone_02.png`
- `ritual_stone_03.png`
- `bone_pile_01.png`
- `bone_pile_02.png`
- `bone_pile_03.png`

Placement rule:
- props belong near edges, corners, entrances, or stage framing zones
- props must not block main play area

---

## 16. UI Visual Canon

UI identity:
- dark ritual aesthetic
- decorative but disciplined
- readable first

Panel design:
- rounded corners
- dark purple base
- gold frame
- soft shadow
- border ornaments remain close to edges
- center remains clean for text or icons

UI hierarchy:
- main panel
- upgrade panel
- popup panel
- tooltip panel

Token rules:
- large panel radius: `26`
- medium panel/button radius: `18`
- small/icon frame radius: `14`

9-slice rule:
- panel border ornamentation must survive scaling
- corners and border motifs must remain intact
- center must stay visually quiet

Canonical panel runtime assets:
- `panel_main.png`
- `panel_card.png`
- `panel_popup.png`
- `panel_tooltip.png`
- `panel_card_9slice.png`
- `panel_tooltip_9slice.png`

Legacy/non-canonical unless explicitly rewired:
- `ui_panel_dark.png`
- `ui_panel_gold.png`

---

## 17. UI Components and States

Buttons:
- `button_primary`
- `button_secondary`
- `button_danger`
- `button_small`
- `button_icon`

Additional runtime buttons:
- `btn_continue_idle.png`
- `btn_continue_hover.png`
- `btn_continue_pressed.png`
- `btn_upgrade.png`
- `btn_upgrade_hover.png`
- `btn_upgrade_disabled.png`

Button accent logic:
- primary: gold + violet emphasis
- secondary: subdued gold + purple
- danger: red-violet core with gold frame

Button generation rule:
- button face must support readable label placement
- no oversized ornament in center

Upgrade node presentation:
- node visuals are secondary to the icon
- runtime canonical map uses icons plus overlays and lines
- no card-heavy replacement renderer

Connector assets:
- `connector_line`
- `connector_highlight`
- also runtime tree connectors:
  - `tree_connector_line.png`
  - `tree_connector_active.png`

Tooltip / labels / overlay:
- `tooltip_panel.png`
- `label_bg.png`
- `ui_dark_overlay.png`

UI FX:
- `glow_ring.png`
- `sparkle.png`
- `selection_ring.png`
- `ritual_glow_small.png`
- `node_unlock_glow.png`
- `faith_burst.png`
- `divine_pulse.png`

---

## 18. UI Icons Canon

There are three icon families and they must not be mixed stylistically.

HUD icons:
- represent gameplay resources
- symbolic cult marks are valid
- must stay simple and readable

Upgrade icons:
- represent ritual powers or doctrines
- should resemble occult sigils, seals, or mystical diagrams
- must not look like generic modern interface icons

Relic icons:
- represent physical cult artifacts
- must look like objects, not glyphs

Outline rule:
- dark purple outline, thick enough for readability

Shading rule:
- two-tone minimum

Canvas occupancy:
- icons must fill at least `60%` of canvas

Anti-UI rule:
- no mobile app icon look
- no infographic/dashboard pictogram look
- no minimalist logo look

Canonical HUD/stat icon set:
- `followers_icon.png`
- `faith_icon.png`
- `cult_power_icon.png`
- `conversion_icon.png`
- `upgrade_icon.png`
- `momentum_icon.png`
- `pressure_icon.png`
- `influence_icon.png`

Canonical upgrade icon set:
- `upgrade_conversion_speed.png`
- `upgrade_corruption_power.png`
- `upgrade_cult_dominion.png`
- `upgrade_cult_growth.png`
- `upgrade_cult_influence.png`
- `upgrade_dark_ritual.png`
- `upgrade_divine_favor.png`
- `upgrade_faith_multiplier.png`
- `upgrade_forbidden_knowledge.png`
- `upgrade_mass_conversion.png`
- `upgrade_ritual_mastery.png`
- `upgrade_conversion_chain.png`
- `upgrade_candle_rite.png`

Canonical relic icon set:
- `relic_idol.png`
- `relic_orb.png`
- `relic_skull.png`
- `relic_bone.png`
- `relic_book.png`
- `relic_candle.png`
- `relic_coin.png`
- `relic_dagger.png`
- `relic_eye.png`
- `relic_halo.png`

---

## 19. Asset Technical Specification

Standard resolutions:
- characters: `64x64 PNG`
- cursor: `128x128 PNG`
- environment props: `128x128 PNG`
- large props: `256x256 PNG`
- UI panels: `256x256` or `512x512` depending on use

Transparency:
- full alpha transparency required
- no background color
- no white background pixels
- any white fringe outside silhouette is invalid

Canvas rules:
- tightly cropped
- centered when required
- props must not contain large empty zones

Alignment rules:
- characters centered
- cursor perfectly centered
- props visually grounded

Export rules:
- transparent PNG
- no white edge artifacts
- no excess padding unless runtime requires it

---

## 20. Naming Convention

Use deterministic snake_case names.

Character variants:
- `_01`, `_02`, `_03`

Small prop variants:
- `_a`, `_b`, `_c` or `_01`, `_02`, `_03`

Stage backgrounds:
- `bg_<stage>.png`

Do not invent inconsistent names if a canonical family already exists.

---

## 21. Current Runtime Expectations

Current runtime directly references:
- stage backgrounds from `assets/backgrounds`
- selected decor props and ambient overlays in progression system
- UI panels, buttons, labels, connectors, and icons from `assets/ui`
- upgrade and relic icons through the icon registry

Runtime implication:
- canonical filenames must remain stable unless code is explicitly updated

Current decor-runtime pattern:
- backgrounds are scaled to viewport
- overlays and a small set of decor props are placed above them
- ambient animated overlays are stage-specific

Current ambient overlay families:
- village smoke
- town lantern glow
- metropolis rune pulse
- planet spores
- cult embers
- cult candle flicker

---

## 22. AI Generation Rules

When generating anything for this project, AI must obey all of the following:

Game understanding:
- this is a cult-cartoon incremental prototype
- gameplay readability is more important than decorative density

World generation:
- keep center clean
- push visual density outward
- produce modular-friendly backgrounds
- avoid baking critical props into the main play area

Prop generation:
- generate reusable modular assets, not scene illustrations
- preserve consistent scale and top-down readability

UI generation:
- produce dark ritual UI, not generic fantasy UI and not sci-fi UI
- preserve clean center zones and 9-slice safety

Icon generation:
- match the icon family rules exactly
- ritual sigils for upgrades
- artifacts for relics
- symbolic resources for HUD

Do not introduce:
- photorealism
- heavy painterly clutter
- anime rendering
- realistic perspective
- high-saturation neon
- modern flat-product UI language

---

## 23. Acceptance and Validation Checklist

Every generated asset must pass all relevant checks below.

Visual checks:
- silhouette readable
- outline visible
- shadow tone present
- small-scale readability preserved

Technical checks:
- correct resolution
- transparent background
- no white fringe
- tight crop
- centered where required

Gameplay checks:
- does not reduce cursor/NPC readability
- does not clutter center of world maps
- does not visually dominate active gameplay objects

UI checks:
- text-safe center zone preserved
- borders remain scale-safe
- icon remains readable at intended runtime size

If an asset fails any required check:
- regenerate
- do not patch around a bad source asset with code unless explicitly required

---

## 24. Final Non-Interpretation Rules

If uncertain:
- choose the simpler silhouette
- choose the quieter center
- choose the more gameplay-safe composition
- choose the more cult-ritual visual language
- choose the option that matches existing canonical filenames and runtime expectations

Never assume:
- a new visual category is allowed unless it fits an existing canonical family
- a generic fantasy solution is acceptable
- a highly detailed illustration is acceptable for gameplay backgrounds
- a generic UI asset is acceptable because it is readable

The correct result for this project is:
- clean
- cult-themed
- cartoon-readable
- runtime-compatible
- modular where possible
- visually coherent across gameplay, props, maps, icons, and UI

---

## 25. Canonical Reference Summary

This project is:
- a Godot 4.6 incremental game
- about converting NPCs into followers with a divine cursor
- visually a minimalist cult-cartoon world
- structurally system-driven and deterministic
- artistically centered on readability, silhouette, and ritual iconography
- operationally dependent on stable filenames, transparent PNGs, and modular-friendly environment production

This document is the definitive context to give an AI.
