# THE CURSOR — Repository Map (Canonical Paths)

This file defines the **canonical repository paths** for production assets.

Use this as the source of truth for path organization and duplicate cleanup.

## 1. Canonical Asset Roots

- Characters (runtime): `res://assets/sprites/characters/`
  - Civilians: `res://assets/sprites/characters/civilians/`
  - Skeptics: `res://assets/sprites/characters/skeptics/`
  - Cultists: `res://assets/sprites/characters/cultists/`
  - Prophets: `res://assets/sprites/characters/prophets/`
- Cursor sprites (runtime): `res://assets/sprites/cursor/`
- UI panels: `res://assets/ui/panels/`
- UI icons: `res://assets/ui/icons/`
- UI node skins: `res://assets/ui/nodes/`
- UI buttons: `res://assets/ui/buttons/`
- Runtime VFX: `res://assets/vfx/`
  - Cursor VFX: `res://assets/vfx/cursor/`
  - Conversion VFX: `res://assets/vfx/conversion/`
- UI-only effects: `res://assets/ui/effects/`
- Props (world art): `res://assets/props/`
  - Cult props: `res://assets/props/cult/`
  - Village props: `res://assets/props/village/`
  - Small props: `res://assets/props/small/`
- Environment/base textures: `res://assets/environment/`
- Backgrounds: `res://assets/backgrounds/`

## 2. Legacy/Parallel Roots (Do Not Use for New References)

Keep only for transition/manual review. Do not wire new runtime references here.

- `res://assets/characters/`
- `res://assets/cursor/`
- flat UI panel files under `res://assets/ui/` (outside `res://assets/ui/panels/`)

## 3. Canonicalization Rules

- One family = one canonical root.
- No parallel production storage for the same family.
- No production suffixes like `_copy`, `_new`, `_old`, `_final`, `_v2` unless explicitly temporary.
- Replacements must happen in-place for canonical files.
- Never delete a referenced file.
- Delete only files that are both:
  - exact duplicate by hash
  - unreferenced after verification

## 4. Duplicate Hotspots Detected (Latest Audit)

Source: `docs/reports/ASSET_DUPLICATION_AUDIT.md` (regenerated on 2026-03-12)

Summary:
- visual assets scanned: `191`
- exact duplicate groups: `19`
- duplicate files: `48`
- same-name multi-path conflicts: `10`
- unreferenced duplicate files: `34`

High-impact duplicate families still present:
- `res://assets/characters/*` (legacy variants and special units; many unreferenced)
- `res://assets/cursor/cursor_symbol.png` (duplicate hash of `res://assets/sprites/cursor/cursor_base.png`)
- `res://assets/ui/panel_card.png` (duplicate hash of canonical panel family)
- `res://assets/environment/*` internal duplicates (mostly unreferenced)
- `res://assets/props/small/*` and `res://assets/props/village/*` repeated hash clusters (mostly unreferenced)
- semantic referenced duplicates intentionally preserved for now:
  - cult prop triplets (`altar_*`, `candle_cluster_*`, `cult_banner_*`, `bone_pile_*`, `ritual_stone_*`)
  - VFX aliases (`divine_pulse`, `upgrade_pulse`, `conversion_flash`, `cursor_flash`)
  - panel aliases (`panel_main`, `panel_main_9slice`, `panel_upgrade`, etc.)

## 5. Safe Cleanup Workflow (Operational)

1. Run audit:
   - `powershell -ExecutionPolicy Bypass -File tools/audit_asset_duplicates.ps1`
2. Migrate references in `.gd/.tscn/.tres/.res` toward canonical roots.
3. Verify no non-canonical paths remain referenced.
4. Delete only exact-hash + unreferenced duplicates.
5. Re-run audit and record delta in `docs/reports/ASSET_DUPLICATION_AUDIT.md`.

## 6. Practical Target State

- Runtime uses only:
  - `res://assets/sprites/characters/`
  - `res://assets/sprites/cursor/`
  - `res://assets/ui/panels/`
  - `res://assets/vfx/` and `res://assets/ui/effects/` by scope
- Legacy roots (`res://assets/characters/`, `res://assets/cursor/`, flat panel files) reduced to zero referenced files, then removed.
