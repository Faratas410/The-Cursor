# THE CURSOR - Repository Map (Canonical and Runtime Paths)

This file defines the production paths that are currently canonical for runtime references, plus the non-runtime roots that are allowed to exist for source, audit, and reference work.

Alignment rule:
- `docs/canon/CURSOR_MASTER_CONTEXT.md` is the authoritative canon for project intent.
- This file describes repository path truth and current runtime usage.
- If canon and repo contents diverge, do not invent new paths. Align new work to the paths actually used by the runtime unless the same task explicitly rewires code.

## 1. Runtime Gameplay Roots

- Characters (runtime): `res://assets/sprites/characters/`
  - Civilians: `res://assets/sprites/characters/civilians/`
  - Skeptics: `res://assets/sprites/characters/skeptics/`
  - Cultists: `res://assets/sprites/characters/cultists/`
  - Prophets: `res://assets/sprites/characters/prophets/`
- Cursor progression sprites: `res://assets/sprites/cursor/`
- Runtime VFX: `res://assets/vfx/`
  - Cursor VFX: `res://assets/vfx/cursor/`
  - Conversion VFX: `res://assets/vfx/conversion/`
- Environment props and ground tiles: `res://assets/environment/`
- Runtime stage backgrounds: `res://assets/backgrounds/`
  - Flattened stage files in active use: `bg_village.png`, `bg_town.png`, `bg_city.png`, `bg_metropolis.png`, `bg_planet.png`, `bg_cult_world.png`
  - Layered stage-support sources already present: `stage_village_ground.png`, `stage_village_overlay.png`

## 2. Runtime World Overlay Roots

- Static overlay textures: `res://assets/ambient_overlays/`
- Animated overlay frame sets: `res://assets/ambient_overlays_animated/`
  - Village: `res://assets/ambient_overlays_animated/village/`
  - Town: `res://assets/ambient_overlays_animated/town/`
  - Metropolis: `res://assets/ambient_overlays_animated/metropolis/`
  - Planet: `res://assets/ambient_overlays_animated/planet/`
  - Cult: `res://assets/ambient_overlays_animated/cult/`
- Animated overlay scenes instantiated by runtime: `res://scenes/ambient_overlays/`

Rule:
- `scripts/systems/progression_system.gd` instantiates overlay scenes from `res://scenes/ambient_overlays/`.
- Those scenes reference frame assets under `res://assets/ambient_overlays_animated/`.
- New ambient overlay work must preserve that scene-to-frame split unless the runtime is deliberately rewritten in the same task.

## 3. Runtime UI Roots

- UI panels: `res://assets/ui/panels/`
- UI buttons: `res://assets/ui/buttons/`
- UI labels: `res://assets/ui/labels/`
- UI overlays: `res://assets/ui/overlays/`
- UI tooltips: `res://assets/ui/tooltips/`
- UI effects: `res://assets/ui/effects/`
- UI FX legacy runtime root still present: `res://assets/ui/fx/`
- UI connectors: `res://assets/ui/connectors/`
- HUD and general UI icons: `res://assets/ui/icons/`
- Upgrade icons in active use: `res://assets/ui/icons/upgrades/`
- Relic icons in active use: `res://assets/ui/icons/relics/`

Rule:
- Current runtime scripts load icons from `res://assets/ui/icons/...`.
- Do not point new runtime code at `res://assets/icons/...` unless the same task performs a deliberate migration.

## 4. Runtime Script and Scene Roots

- Main gameplay scene: `res://scenes/main_scene.tscn`
- Core entities: `res://scenes/npc.tscn`, `res://scenes/cursor.tscn`, `res://scenes/skeptic.tscn`, `res://scenes/prophet.tscn`
- UI scenes: `res://scenes/ui/`
- Effect scenes: `res://scenes/effects/`

- Main scripts: `res://scripts/main/`
- System scripts: `res://scripts/systems/`
- Entity scripts: `res://scripts/entities/`
- UI scripts: `res://scripts/ui/`

## 5. Non-Runtime But Allowed Roots

- Canon and style docs: `res://docs/canon/`
- Audit outputs: `res://docs/reports/`
- Art references: `res://docs/art/reference/`
- External or internal visual reference packs: `res://reference/`

Rule:
- These roots can inform production work, but runtime code must not depend on them.

## 6. Legacy and Parallel Root Policy

These roots exist in the repo but are not canonical runtime targets for new references:

- `res://assets/icons/`
  - Current audit shows these are same-name parallel files and are unreferenced at runtime.
- `res://assets/ui/panels/ui_panel_dark.png`
- `res://assets/ui/panels/ui_panel_gold.png`
  - Present in repo but marked legacy or non-canonical by canon and audit.

Rules:
- do not create new runtime references into `res://assets/icons/`
- do not add new same-name duplicates across `assets/icons/` and `assets/ui/icons/`
- do not treat old panel files as default panel assets

## 7. Current Audit Status

Source:
- `docs/reports/ASSET_DUPLICATION_AUDIT.md`
- `docs/reports/ASSET_DUPLICATION_AUDIT_SUMMARY.json`

Current result:
- total visual assets scanned: `217`
- exact duplicate groups: `0`
- duplicate files: `0`
- same-name multi-path conflicts: `17`
- suspicious near-duplicates: `6`
- referenced duplicate groups: `0`
- unreferenced duplicate files: `0`

Interpretation:
- there are no exact duplicate groups to clean up automatically
- there are still parallel same-name roots to avoid when adding or rewiring runtime references

## 8. Operational Workflow

1. Inspect `docs/canon/CURSOR_MASTER_CONTEXT.md` for intent.
2. Inspect this file for canonical runtime paths.
3. If changing code, preserve existing runtime paths unless the task explicitly includes migration.
4. If changing asset references, verify with `rg` which path is actually loaded by scripts/scenes.
5. Run duplicate audit when asset roots or references change.

Audit command:
- `powershell -ExecutionPolicy Bypass -File tools/audit_asset_duplicates.ps1 -RepoRoot . -ReportPath docs/reports/ASSET_DUPLICATION_AUDIT.md`

Strict command:
- `powershell -ExecutionPolicy Bypass -File tools/audit_asset_duplicates.ps1 -RepoRoot . -ReportPath docs/reports/ASSET_DUPLICATION_AUDIT.md -Strict`

## 9. Asset Canon Guard

Automation:
- CI workflow: `.github/workflows/asset-canon-guard.yml`
- Optional local hook installer: `tools/install_asset_audit_hook.ps1`

Guard intent:
- keep runtime references on canonical roots
- prevent silent reintroduction of duplicate production paths
