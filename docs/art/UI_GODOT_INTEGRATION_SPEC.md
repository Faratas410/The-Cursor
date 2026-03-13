# UI Godot Integration Spec

This document verifies current readiness for Godot UI usage.

## NinePatchRect Verification

| Panel Asset | Dimensions | Suggested Patch Margins (L/T/R/B) | Verification |
|---|---:|---|---|
| `res://assets/ui/panels/panel_main.png` | 256x256 | 28 / 28 / 28 / 28 | Safe: margins preserve decorative corners and keep center clean for scaling |
| `res://assets/ui/panels/panel_card.png` | 256x256 | 28 / 28 / 28 / 28 | Safe: same border profile as main panel |
| `res://assets/ui/panels/panel_popup.png` | 256x256 | 22 / 22 / 22 / 22 | Safe: thinner frame than main/card; avoids center distortion |
| `res://assets/ui/panels/panel_tooltip.png` | 256x256 | 16 / 16 / 16 / 16 | Safe: light frame with small corner ornaments |

Recommended usage:
- Prefer `NinePatchRect` for runtime-resizable UI containers.
- For static-size popups, `TextureRect` is also acceptable.

## TextureButton Verification

Expected mapping by state:

### Primary button preset
- normal: `res://assets/ui/buttons/button_primary.png`
- hover: `res://assets/ui/buttons/button_primary.png`
- pressed: `res://assets/ui/buttons/button_secondary.png`
- disabled: `res://assets/ui/buttons/button_danger.png`

### Secondary button preset
- normal: `res://assets/ui/buttons/button_secondary.png`
- hover: `res://assets/ui/buttons/button_primary.png`
- pressed: `res://assets/ui/buttons/button_secondary.png`
- disabled: `res://assets/ui/buttons/button_danger.png`

### Small button preset
- normal: `res://assets/ui/buttons/button_small.png`
- hover: `res://assets/ui/buttons/button_primary.png`
- pressed: `res://assets/ui/buttons/button_secondary.png`
- disabled: `res://assets/ui/buttons/button_danger.png`

### Icon button preset
- normal: `res://assets/ui/buttons/button_icon.png`
- hover: `res://assets/ui/buttons/button_primary.png`
- pressed: `res://assets/ui/buttons/button_secondary.png`
- disabled: `res://assets/ui/buttons/button_danger.png`

Notes:
- Current button set is pipeline-compatible but provisional.
- Replace temporary button textures with canonical Figma exports once available.
