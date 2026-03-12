# Art Style Verification (Full Asset Pass)

Date: 2026-03-12  
Scope: `assets/**/*.png`  
Canon checked against:
- `docs/canon/CURSOR_ART_SYSTEM.md`
- `docs/canon/CURSOR_ASSET_SPEC.md`
- `docs/canon/CURSOR_STYLE_SHEET.md`
- reference anchors in `docs/art/reference/`

## Method

Automated validation was run on all PNG assets with these checks:
- resolution by family (character/cursor/prop/icon/panel)
- transparency presence where required
- bounding-box occupancy and character height fill
- rough outline darkness heuristic (edge darkness ratio)
- flatness risk (very low color variation)

Raw machine output:
- `docs/reports/art_style_audit.csv`

## Summary

- Total PNG scanned: **182**
- Assets with at least one rule violation: **21**

Breakdown:
- `background`: 12 total, 0 issues
- `character`: 37 total, 3 issues
- `cursor`: 17 total, 0 issues
- `icon`: 22 total, 0 issues
- `ui_icon`: 16 total, 8 issues
- `panel`: 10 total, 0 issues
- `prop_env`: 43 total, 10 issues
- `vfx`: 8 total, 0 issues
- `other` (UI textures not in strict size families): 17 total, 0 issues

## Verified Good (Previously Reported Problem Files)

These files now pass technical style checks (clean alpha, coherent occupancy):
- `assets/props/cult/cult_banner_01.png`
- `assets/props/cult/cult_banner_02.png`
- `assets/props/cult/cult_banner_03.png`
- `assets/sprites/characters/civilians/civilian_01.png` ... `civilian_10.png`

## Non-Conforming Files

### Character issues (3)
- `assets/characters/shadow.png` -> `resolution_not_64x64`
- `assets/sprites/characters/shadow.png` -> `resolution_not_64x64;height_fill_outside_target`
- `assets/sprites/characters/prophets/prophet_03.png` -> `height_fill_outside_target;weak_outline_darkness`

Notes:
- Shadow sprites are expected to be a special case (`64x32`) by canon spec. These are flagged only because the generic character checker enforces `64x64`.  
- `prophet_03.png` is the only true character-style outlier and should be manually refined.

### Prop/Environment issues (10)
- `assets/environment/ground_cult_a.png` -> `no_transparency`
- `assets/environment/ground_cult_b.png` -> `no_transparency`
- `assets/environment/ground_grass_a.png` -> `no_transparency`
- `assets/environment/ground_grass_b.png` -> `no_transparency`
- `assets/environment/ground_grass_c.png` -> `no_transparency`
- `assets/environment/path_dirt_straight.png` -> `no_transparency`
- `assets/environment/path_stone_corner.png` -> `no_transparency`
- `assets/environment/path_stone_cross.png` -> `no_transparency`
- `assets/environment/path_stone_straight.png` -> `no_transparency`
- `assets/environment/path_stone_t.png` -> `no_transparency`

Note:
- These appear to be tile/base textures. If the project policy allows opaque ground tiles, mark this as an explicit canon exception; otherwise they need transparent rebuild.

### UI icon size issues (8)
- `assets/ui/icons/icon_aura.png` -> `ui_icon_not_32x32`
- `assets/ui/icons/icon_conversion.png` -> `ui_icon_not_32x32`
- `assets/ui/icons/icon_cult.png` -> `ui_icon_not_32x32`
- `assets/ui/icons/icon_cult_power.png` -> `ui_icon_not_32x32`
- `assets/ui/icons/icon_faith.png` -> `ui_icon_not_32x32`
- `assets/ui/icons/icon_final.png` -> `ui_icon_not_32x32`
- `assets/ui/icons/icon_follower.png` -> `ui_icon_not_32x32`
- `assets/ui/icons/icon_spawn.png` -> `ui_icon_not_32x32`

## Recommended Next Fix Order

1. `prophet_03.png` (true style-readability issue)
2. Resolve canon rule for opaque ground/path textures (exception vs regeneration)
3. Normalize `assets/ui/icons/icon_*` to intended HUD icon sizing policy (32x32 or move to a non-32 family)

## Runtime-Safety Note

This was a verification-only pass.  
No gameplay logic, scene logic, or runtime behavior was changed.
