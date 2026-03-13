# Asset Duplication Audit

## Summary
- total visual asset files scanned: **213**
- exact duplicate groups count: **0**
- duplicate files count: **0**
- same-name multi-path conflicts count: **0**
- suspicious near-duplicate count: **7**
- referenced duplicate groups count: **0**
- unreferenced duplicate files count: **0**

## Exact duplicate groups
No exact duplicate groups found.

## Same filename in multiple locations
No same-filename multi-path conflicts found.

## Suspicious near-duplicates
- res://assets/sprites/cursor/cursor_aura_final.png - contains final marker (unreferenced)
- res://assets/sprites/cursor/cursor_final.png - contains final marker (referenced)
- res://assets/ui/icons/icon_final.png - contains final marker (referenced)
- res://assets/ui/icons/icon_final_var_cool.png - contains final marker (unreferenced)
- res://assets/ui/icons/icon_final_var_warm.png - contains final marker (unreferenced)
- res://assets/ui/nodes/upgrade_node_final.png - contains final marker (referenced)
- res://assets/ui/panels/ui_panel_gold.png - contains old marker (unreferenced)

## Likely cleanup opportunities
- Safe candidate duplicates not referenced anywhere:
  - none
- Duplicates where only one path is referenced:
  - none
- Duplicates that should be manually reviewed because referenced from scenes/resources/scripts:
  - none

## No-action guarantee
This audit was read-only: no assets were deleted, renamed, moved, or rewired.
