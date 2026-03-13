# UI Asset Manifest

This manifest defines canonical intent for the current UI pipeline output.

| Canonical Filename | Category | Intended Runtime Usage | Temporary or Final | Needs Replacement After Figma Export |
|---|---|---|---|---|
| `panel_main.png` | panels | Primary container background for large panels (`Panel`, `NinePatchRect`) | final | no |
| `panel_card.png` | panels | Card panel background (`Panel`, `NinePatchRect`) | final | no |
| `panel_popup.png` | panels | Popup/overlay panel background (`Panel`, `NinePatchRect`) | final | no |
| `panel_tooltip.png` | panels | Tooltip background (`Panel`, `NinePatchRect`) | final | no |
| `button_primary.png` | buttons | Primary action visual for `TextureButton` normal/hover states | temporary | yes |
| `button_secondary.png` | buttons | Secondary action visual for `TextureButton` normal/pressed states | temporary | yes |
| `button_danger.png` | buttons | Danger/disabled button visual for `TextureButton` disabled state | temporary | yes |
| `button_small.png` | buttons | Compact action button visual (`TextureButton`) | temporary | yes |
| `button_icon.png` | buttons | Icon-only button frame (`TextureButton`) | temporary | yes |
| `node_upgrade.png` | nodes | Upgrade tree node base/active frame | temporary | yes |
| `node_locked.png` | nodes | Locked node frame variant | temporary | yes |
| `node_special.png` | nodes | Special/final node frame variant | temporary | yes |
| `connector_line.png` | connectors | Inactive tree connector line | temporary | yes |
| `connector_highlight.png` | connectors | Active/highlighted tree connector line | temporary | yes |
| `icon_faith.png` | icons | Faith resource icon in top bar and node labels | final | no |
| `icon_follower.png` | icons | Follower resource icon in top bar and node labels | final | no |
| `icon_sacrifice.png` | icons | Sacrifice/relic icon in ritual UI | temporary | yes |
| `glow_ring.png` | fx | Soft ritual glow FX | temporary | yes |
| `sparkle.png` | fx | Sparkle burst FX | temporary | yes |
| `selection_ring.png` | fx | Selection ring highlight FX | temporary | yes |

Notes:
- Temporary assets are now reference-derived PNG extracts, but still not canonical Figma component exports.
- Final status is only for the approved canonical baseline files.
