# Asset Duplication Audit

## Summary
- total visual asset files scanned: **235**
- exact duplicate groups count: **9**
- duplicate files count: **16**
- same-name multi-path conflicts count: **6**
- suspicious near-duplicate count: **8**
- referenced duplicate groups count: **3**
- unreferenced duplicate files count: **21**

## Exact duplicate groups

- hash: a5d54479daee3e1a4c05f75c9e03d8398da01c35ddba618aefe5ba94cc6e782d
  - file size(s): 1897 bytes
  - referenced in group: 0 / 3
  - recommended canonical keep candidate: res://assets/props/cult/cult_banner_01_var_cool.png
  - files:
    - res://assets/props/cult/cult_banner_01_var_cool.png (unreferenced)
    - res://assets/props/cult/cult_banner_02_var_cool.png (unreferenced)
    - res://assets/props/cult/cult_banner_03_var_cool.png (unreferenced)

- hash: 171c75011f9125160268d2453923ac4a17db42462a9b59917248bbb7d4aaf34d
  - file size(s): 1889 bytes
  - referenced in group: 0 / 3
  - recommended canonical keep candidate: res://assets/props/cult/cult_banner_01_var_warm.png
  - files:
    - res://assets/props/cult/cult_banner_01_var_warm.png (unreferenced)
    - res://assets/props/cult/cult_banner_02_var_warm.png (unreferenced)
    - res://assets/props/cult/cult_banner_03_var_warm.png (unreferenced)

- hash: 619000d553b024704681eb1d24a2f5efa8c5a884a57a9bf2c8e33d83fb4e652e
  - file size(s): 81819 bytes
  - referenced in group: 1 / 3
  - recommended canonical keep candidate: res://assets/ui/panels/panel_main.png
  - files:
    - res://assets/ui/panels/panel_main.png (referenced)
    - res://assets/ui/panels/panel_main_9slice.png (unreferenced)
    - res://assets/ui/panels/panel_upgrade.png (unreferenced)

- hash: ba4784d6b79a210a5201766a09c995fe50e8b7e029436356da41736c1b23f817
  - file size(s): 1899 bytes
  - referenced in group: 1 / 3
  - recommended canonical keep candidate: res://assets/props/cult/cult_banner_02.png
  - files:
    - res://assets/props/cult/cult_banner_01.png (unreferenced)
    - res://assets/props/cult/cult_banner_02.png (referenced)
    - res://assets/props/cult/cult_banner_03.png (unreferenced)

- hash: 1fff651a2abfb3011eb6484ab1c716a9496842b8ad9013d2946c353f8d18b1c4
  - file size(s): 2168 bytes
  - referenced in group: 2 / 3
  - recommended canonical keep candidate: res://assets/props/cult/altar_01.png
  - files:
    - res://assets/props/cult/altar_01.png (referenced)
    - res://assets/props/cult/altar_02.png (unreferenced)
    - res://assets/props/cult/altar_03.png (referenced)

- hash: 3b62e540b8112a52e1a73c5699c4a5810a224233527c953e5869c005d6999950
  - file size(s): 2156 bytes
  - referenced in group: 0 / 3
  - recommended canonical keep candidate: res://assets/props/cult/altar_01_var_cool.png
  - files:
    - res://assets/props/cult/altar_01_var_cool.png (unreferenced)
    - res://assets/props/cult/altar_02_var_cool.png (unreferenced)
    - res://assets/props/cult/altar_03_var_cool.png (unreferenced)

- hash: 5d77497ec172c47f6cfbe506ac44086a4f06741e79c71dc464766a1ad9b61a9f
  - file size(s): 2165 bytes
  - referenced in group: 0 / 3
  - recommended canonical keep candidate: res://assets/props/cult/altar_01_var_warm.png
  - files:
    - res://assets/props/cult/altar_01_var_warm.png (unreferenced)
    - res://assets/props/cult/altar_02_var_warm.png (unreferenced)
    - res://assets/props/cult/altar_03_var_warm.png (unreferenced)

- hash: 889dc08c0659cc65fb4739208568c7fd60c093b20c513d631d69402f815655a9
  - file size(s): 28032 bytes
  - referenced in group: 0 / 2
  - recommended canonical keep candidate: res://assets/sprites/cursor/cursor_aura.png
  - files:
    - res://assets/sprites/cursor/cursor_aura.png (unreferenced)
    - res://assets/sprites/cursor/cursor_ring_outer.png (unreferenced)

- hash: 24363b898470eb35de1858bbca3b17e5052cc3c0d971902316748e28e3975456
  - file size(s): 29428 bytes
  - referenced in group: 0 / 2
  - recommended canonical keep candidate: res://assets/sprites/cursor/cursor_symbol.png
  - files:
    - res://assets/sprites/cursor/cursor_ring_inner.png (unreferenced)
    - res://assets/sprites/cursor/cursor_symbol.png (unreferenced)

## Same filename in multiple locations

- filename: cursor_ring_inner.png (different content)
  - res://assets/cursor/cursor_ring_inner.png (unreferenced)
  - res://assets/sprites/cursor/cursor_ring_inner.png (unreferenced)

- filename: cursor_ring_outer.png (different content)
  - res://assets/cursor/cursor_ring_outer.png (unreferenced)
  - res://assets/sprites/cursor/cursor_ring_outer.png (unreferenced)

- filename: cursor_aura.png (different content)
  - res://assets/sprites/cursor/cursor_aura.png (unreferenced)
  - res://assets/vfx/cursor/cursor_aura.png (referenced)

- filename: cursor_aura_final.png (different content)
  - res://assets/cursor/cursor_aura_final.png (unreferenced)
  - res://assets/sprites/cursor/cursor_aura_final.png (unreferenced)

- filename: cursor_aura_pulse.png (different content)
  - res://assets/cursor/cursor_aura_pulse.png (unreferenced)
  - res://assets/sprites/cursor/cursor_aura_pulse.png (unreferenced)

- filename: cursor_aura_soft.png (different content)
  - res://assets/cursor/cursor_aura_soft.png (unreferenced)
  - res://assets/sprites/cursor/cursor_aura_soft.png (unreferenced)

## Suspicious near-duplicates
- res://assets/cursor/cursor_aura_final.png - contains final marker (unreferenced)
- res://assets/sprites/cursor/cursor_aura_final.png - contains final marker (unreferenced)
- res://assets/sprites/cursor/cursor_final.png - contains final marker (referenced)
- res://assets/ui/icons/icon_final.png - contains final marker (referenced)
- res://assets/ui/icons/icon_final_var_cool.png - contains final marker (unreferenced)
- res://assets/ui/icons/icon_final_var_warm.png - contains final marker (unreferenced)
- res://assets/ui/nodes/upgrade_node_final.png - contains final marker (referenced)
- res://assets/ui/panels/ui_panel_gold.png - contains old marker (unreferenced)

## Likely cleanup opportunities
- Safe candidate duplicates not referenced anywhere:
  - res://assets/props/cult/altar_02.png (exact duplicate of res://assets/props/cult/altar_01.png; exact duplicate and unreferenced)
  - res://assets/props/cult/altar_02_var_cool.png (exact duplicate of res://assets/props/cult/altar_01_var_cool.png; exact duplicate and unreferenced)
  - res://assets/props/cult/altar_02_var_warm.png (exact duplicate of res://assets/props/cult/altar_01_var_warm.png; exact duplicate and unreferenced)
  - res://assets/props/cult/altar_03_var_cool.png (exact duplicate of res://assets/props/cult/altar_01_var_cool.png; exact duplicate and unreferenced)
  - res://assets/props/cult/altar_03_var_warm.png (exact duplicate of res://assets/props/cult/altar_01_var_warm.png; exact duplicate and unreferenced)
  - res://assets/props/cult/cult_banner_01.png (exact duplicate of res://assets/props/cult/cult_banner_02.png; only one referenced file in duplicate group)
  - res://assets/props/cult/cult_banner_02_var_cool.png (exact duplicate of res://assets/props/cult/cult_banner_01_var_cool.png; exact duplicate and unreferenced)
  - res://assets/props/cult/cult_banner_02_var_warm.png (exact duplicate of res://assets/props/cult/cult_banner_01_var_warm.png; exact duplicate and unreferenced)
  - res://assets/props/cult/cult_banner_03.png (exact duplicate of res://assets/props/cult/cult_banner_02.png; only one referenced file in duplicate group)
  - res://assets/props/cult/cult_banner_03_var_cool.png (exact duplicate of res://assets/props/cult/cult_banner_01_var_cool.png; exact duplicate and unreferenced)
  - res://assets/props/cult/cult_banner_03_var_warm.png (exact duplicate of res://assets/props/cult/cult_banner_01_var_warm.png; exact duplicate and unreferenced)
  - res://assets/sprites/cursor/cursor_ring_inner.png (exact duplicate of res://assets/sprites/cursor/cursor_symbol.png; exact duplicate and unreferenced)
  - res://assets/sprites/cursor/cursor_ring_outer.png (exact duplicate of res://assets/sprites/cursor/cursor_aura.png; exact duplicate and unreferenced)
  - res://assets/ui/panels/panel_main_9slice.png (exact duplicate of res://assets/ui/panels/panel_main.png; only one referenced file in duplicate group)
  - res://assets/ui/panels/panel_upgrade.png (exact duplicate of res://assets/ui/panels/panel_main.png; only one referenced file in duplicate group)
- Duplicates where only one path is referenced:
  - res://assets/props/cult/cult_banner_01.png (duplicate of res://assets/props/cult/cult_banner_02.png)
  - res://assets/props/cult/cult_banner_03.png (duplicate of res://assets/props/cult/cult_banner_02.png)
  - res://assets/ui/panels/panel_main_9slice.png (duplicate of res://assets/ui/panels/panel_main.png)
  - res://assets/ui/panels/panel_upgrade.png (duplicate of res://assets/ui/panels/panel_main.png)
- Duplicates that should be manually reviewed because referenced from scenes/resources/scripts:
  - res://assets/props/cult/altar_03.png (also referenced; duplicate of res://assets/props/cult/altar_01.png)

## No-action guarantee
This audit was read-only: no assets were deleted, renamed, moved, or rewired.
