# THE CURSOR — Repository Map (Canonical Paths)

This file defines the canonical production paths for runtime assets.

## 1. Canonical Asset Roots

- Characters (runtime): `res://assets/sprites/characters/`
  - Civilians: `res://assets/sprites/characters/civilians/`
  - Skeptics: `res://assets/sprites/characters/skeptics/`
  - Cultists: `res://assets/sprites/characters/cultists/`
  - Prophets: `res://assets/sprites/characters/prophets/`
- Cursor progression sprites: `res://assets/sprites/cursor/`
- Runtime VFX: `res://assets/vfx/`
  - Cursor VFX: `res://assets/vfx/cursor/`
  - Conversion VFX: `res://assets/vfx/conversion/`
- Environment textures: `res://assets/environment/`
- Scene backgrounds (runtime): `res://assets/backgrounds/` (canonical files: `bg_*_topdown.png`)
- Props: `res://assets/props/`
  - Cult props: `res://assets/props/cult/`
  - Village props: `res://assets/props/village/`
  - Small props: `res://assets/props/small/`
- UI roots:
  - Panels: `res://assets/ui/panels/`
  - Icons: `res://assets/ui/icons/`
  - Buttons: `res://assets/ui/buttons/`
  - Nodes: `res://assets/ui/nodes/`
  - Labels: `res://assets/ui/labels/`
  - Overlays: `res://assets/ui/overlays/`
  - Tooltips: `res://assets/ui/tooltips/`
  - UI effects: `res://assets/ui/effects/`

## 2. Legacy Roots Policy

Legacy roots are not canonical and must not receive new runtime references.

Legacy directories `assets/characters/` and `assets/cursor/` were removed from the repo.

Rule:
- do not recreate legacy roots; add assets only under canonical roots.

## 3. Canonicalization Rules

- One asset family = one canonical root.
- No parallel production roots for the same family.
- Same filename across multiple roots is not allowed unless both files are intentionally different and both referenced (currently none).
- Delete only files that are unreferenced and safe by audit.

## 4. Current Audit Status

Source: `docs/reports/ASSET_DUPLICATION_AUDIT.md`

Current result:
- exact duplicate groups: `0`
- same-name multi-path conflicts: `0`
- unreferenced duplicate files: `0`

## 5. Operational Workflow

1. Run duplicate audit:
   - `powershell -ExecutionPolicy Bypass -File tools/audit_asset_duplicates.ps1 -RepoRoot . -ReportPath docs/reports/ASSET_DUPLICATION_AUDIT.md`
2. Migrate any non-canonical runtime references.
3. Remove unreferenced duplicates.
4. Re-run audit and confirm zeros for duplicate groups and same-name conflicts.

## 6. Asset Canon Guard

Strict check command (must pass):
- `powershell -ExecutionPolicy Bypass -File tools/audit_asset_duplicates.ps1 -RepoRoot . -ReportPath docs/reports/ASSET_DUPLICATION_AUDIT.md -Strict`

Automation:
- CI workflow: `.github/workflows/asset-canon-guard.yml`
- Optional local hook installer: `tools/install_asset_audit_hook.ps1`

