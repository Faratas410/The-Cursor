# CURSOR — ASSET LIST (DRAFT)

This document defines the draft canonical asset inventory for THE CURSOR.

It is intended as a production planning list for asset generation.

This file aligns with:

- CURSOR_ART_SYSTEM.md
- CURSOR_ASSET_SPEC.md
- CURSOR_STYLE_SHEET.md

If generated assets are missing from critical gameplay categories, extend this list.

---

## 1. Naming Rules

Use deterministic snake_case names with numeric variants where needed.

Examples:

- `tree_a.png`, `tree_b.png`, `tree_c.png`
- `civilian_01.png`, `civilian_02.png`, `civilian_03.png`
- `cultist_01.png`, `cultist_02.png`, `cultist_03.png`
- `prophet_01.png`, `prophet_02.png`

Variant policy:

- Character variants: `_01`, `_02`, `_03`, ...
- Small prop variants: `_a`, `_b`, `_c` or `_01`, `_02`, `_03`
- Stage backgrounds: `bg_<stage>.png`

---

## 2. Characters

Suggested folder: `assets/sprites/characters/`

### 2.1 Civilians

- `civilian_01.png`
- `civilian_02.png`
- `civilian_03.png`
- `civilian_04.png`
- `civilian_05.png`
- `civilian_06.png`
- `civilian_07.png`
- `civilian_08.png`
- `civilian_09.png`
- `civilian_10.png`

### 2.2 Skeptics

- `skeptic_01.png`
- `skeptic_02.png`
- `skeptic_03.png`
- `skeptic_04.png`

### 2.3 Cultists

- `cultist_01.png`
- `cultist_02.png`
- `cultist_03.png`
- `cultist_04.png`
- `cultist_05.png`
- `cultist_06.png`

### 2.4 Prophets

- `prophet_01.png`
- `prophet_02.png`

### 2.5 Special Units (Planned)

- `mini_prophet_01.png`
- `mini_prophet_02.png`
- `cult_leader_01.png`
- `cult_leader_02.png`
- `final_witness_01.png`

### 2.6 Shared Character Utility

- `shadow.png` (shared soft ellipse shadow)

---

## 3. Cursor System

Suggested folders: `assets/sprites/cursor/` (cursor states), `assets/vfx/cursor/` (runtime aura/trail/ripple)

### 3.1 Core Cursor Progression

- `cursor_base.png`
- `cursor_glow.png`
- `cursor_cult.png`
- `cursor_divine.png`
- `cursor_final.png`

### 3.2 Layered Cursor Components

- `cursor_symbol.png`

### 3.3 Cursor Runtime VFX Layers

Suggested folder: `assets/vfx/cursor/`

- `cursor_aura.png`
- `cursor_trail.png`
- `cursor_ripple.png`

---

## 4. Environment

Suggested folder: `assets/environment/`

### 4.1 Ground / Terrain

- `ground_grass_a.png`
- `ground_grass_b.png`
- `ground_grass_c.png`
- `ground_cult_a.png` (late game)
- `ground_cult_b.png` (late game)

### 4.2 Path Tiles

- `path_stone_straight.png`
- `path_stone_corner.png`
- `path_stone_t.png`
- `path_stone_cross.png`
- `path_dirt_straight.png`

### 4.3 Trees

- `tree_a.png`
- `tree_b.png`
- `tree_c.png` (planned)

### 4.4 Houses / Buildings

- `village_house_small.png`
- `village_house_medium.png`
- `village_house_large.png` (planned)
- `town_house_a.png` (planned)
- `town_house_b.png` (planned)

### 4.5 Fences / Boundaries

- `wood_fence.png`
- `wood_fence_short.png` (planned)
- `stone_wall_short.png` (planned)

### 4.6 Ritual Structures

- `altar_01.png` (planned in environment namespace)
- `altar_02.png` (planned)
- `ritual_circle_ground.png` (planned)
- `ritual_pillar_01.png` (planned)

### 4.7 Stage Backgrounds

- `bg_village.png`
- `bg_town.png`
- `bg_city.png`
- `bg_metropolis.png`
- `bg_planet.png`
- `bg_cult_world.png`

Optional top-down set (if active pipeline uses it):

- `bg_village_topdown.png`
- `bg_town_topdown.png`
- `bg_city_topdown.png`
- `bg_metropolis_topdown.png`
- `bg_planet_topdown.png`
- `bg_cult_world_topdown.png`

---

## 5. Props

Suggested folders:

- `assets/props/small/`
- `assets/props/village/`
- `assets/props/cult/`

### 5.1 Small Props

- `grass_patch_a.png`
- `grass_patch_b.png`
- `stone_small_a.png`
- `stone_small_b.png`
- `crate_small.png`

### 5.2 Village Props

- `well_01.png`
- `cart_01.png`
- `signpost_01.png`
- `barrel_01.png`
- `fence_broken_01.png`

### 5.3 Ritual / Cult Props

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
- `altar_01.png`


---

## 6. UI

Suggested folder: `assets/ui/`

### 6.1 Panels

Canonical runtime set:
- `panel_main.png`
- `panel_popup.png`
- `panel_card.png`
- `panel_tooltip.png`
- `panel_card_9slice.png`
- `panel_tooltip_9slice.png`

Legacy/non-canonical (keep only if explicitly rewired):
- `ui_panel_dark.png`
- `ui_panel_gold.png`


### 6.2 Icons (HUD / Stats)

- `followers_icon.png`
- `faith_icon.png`
- `cult_power_icon.png`
- `conversion_icon.png`
- `upgrade_icon.png`
- `momentum_icon.png`
- `pressure_icon.png`
- `influence_icon.png`

### 6.3 Buttons

- `btn_continue_idle.png`
- `btn_continue_hover.png`
- `btn_continue_pressed.png`
- `btn_upgrade.png`
- `btn_upgrade_hover.png`
- `btn_upgrade_disabled.png`

### 6.4 Upgrade Nodes

- `upgrade_card_bg.png`
- `upgrade_node_root.png`
- `upgrade_node_locked.png`
- `upgrade_node_hover.png`
- `upgrade_node_purchased.png`
- `upgrade_node_final.png`

### 6.5 Tooltips / Labels

- `tooltip_panel.png`
- `label_bg.png`

### 6.6 Overlay / Connectors

- `ui_dark_overlay.png`
- `tree_connector_line.png`
- `tree_connector_active.png`

---

## 7. VFX

Suggested folders:

- `assets/vfx/cursor/`
- `assets/vfx/conversion/`
- `assets/ui/effects/`

### 7.1 Conversion Effects

- `conversion_glyph.png`
- `conversion_flash.png`
- `conversion_smoke.png`
- `conversion_ripple.png` (planned)

### 7.2 Cursor / Aura Effects

- `cursor_aura.png`
- `cursor_trail.png`
- `cursor_flash.png`
- `cursor_ripple.png`

### 7.3 Faith / Ritual Feedback

- `divine_pulse.png`
- `upgrade_pulse.png`
- `faith_burst.png` (planned)
- `ritual_glow_small.png` (planned)

### 7.4 UI Aura Effects

- `cursor_aura_ui.png`
- `node_unlock_glow.png` (planned)

---

## 8. Variant Expansion Targets (Recommended)

To reduce repetition during long runs, prioritize adding:

- 5+ additional civilian variants (`civilian_11+`)
- 2+ additional skeptic variants (`skeptic_05+`)
- 3+ additional cultist variants (`cultist_07+`)
- 1 additional prophet variant (`prophet_03`)
- 1 additional tree variant (`tree_c`)
- 2 additional house variants (`village_house_large`, `town_house_a`)
- 2 additional ritual stones (`ritual_stone_04`, `ritual_stone_05`)

---

## 9. Minimum Gameplay-Critical Visual Set

The minimum complete set for gameplay readability is:

- Civilians, skeptics, cultists, prophets
- Cursor progression states + aura layers
- Stage backgrounds (all progression levels)
- Core props (tree, house, fence, banner, altar, stone)
- HUD icons and core UI panels/buttons
- Conversion and cursor VFX essentials

---

## 10. Draft Status

This is a draft planning inventory.

Rule of use:

- Missing gameplay-critical assets should be added immediately.
- Optional planned assets can be scheduled in production waves.

