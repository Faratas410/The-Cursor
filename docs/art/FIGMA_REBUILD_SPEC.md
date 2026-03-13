# Figma Rebuild Spec: Cursor_UI_System

Status: MCP capture flow is currently blocked in this environment (capture remains `pending`; local browser/script submit path cannot be completed from this runtime).

Target file name: `Cursor_UI_System`

## 1. File Setup

Create a new Figma design file named `Cursor_UI_System`.

Create pages in this exact order:
1. `01 Panels`
2. `02 Buttons`
3. `03 Nodes`
4. `04 Connectors`
5. `05 Icons`
6. `06 FX`

## 2. Global Visual Tokens

Use consistent tokens across all components:
- Corner radius:
  - Large panels: 26
  - Medium panels/buttons: 18
  - Small/icon frames: 14
- Gold frame treatment:
  - Outer stroke: warm gold `#E0A73A`
  - Inner accent stroke: pale gold `#F6D67D`
  - Shadow stroke/glow: dark amber `#6B3A00` at 35-45% opacity
- Purple base fill:
  - Radial/linear blend of `#2A1142`, `#3A1A5A`, `#4D2672`
- Corner ornaments:
  - Small curved glyph in each corner using gold + violet gem accent
- Soft magical glow:
  - Violet glow `#B56CFF` (screen/add at low opacity)

Rules:
- Decorations must remain close to borders.
- Center area must remain clean for text/icons.
- Keep all panel assets compatible with 9-slice behavior.

## 3. Master Components

Create these master components:
- `Panel_Master`
- `Button_Master`
- `Node_Master`
- `Connector_Master`
- `Icon_Frame_Master`
- `FX_Master`

## 4. Required Variants

### 4.1 Panels (`Panel_Master`)
Create variants:
- `panel_main`
- `panel_card`
- `panel_popup`
- `panel_tooltip`
- `panel_inventory`

Suggested base sizes:
- panel_main: 640x420
- panel_card: 360x260
- panel_popup: 420x240
- panel_tooltip: 340x140
- panel_inventory: 520x360

Construction:
- Outer frame + inner rim + fill layer + corner ornaments.
- Keep border ornamentation outside safe center zone.

### 4.2 Buttons (`Button_Master`)
Create variants:
- `button_primary`
- `button_secondary`
- `button_danger`
- `button_small`
- `button_icon`

Suggested sizes:
- primary/secondary/danger: 280x72
- small: 200x56
- icon: 112x72

Color accents:
- primary: gold + violet
- secondary: subdued gold + purple
- danger: red-violet core with gold frame

### 4.3 Nodes (`Node_Master`)
Create variants:
- `node_upgrade`
- `node_locked`
- `node_special`

Suggested size:
- 220x120

Special treatment:
- locked includes lock badge area
- special includes brighter center glow and stronger gold accents

### 4.4 Connectors (`Connector_Master`)
Create variants:
- `connector_line`
- `connector_highlight`

Suggested size:
- 256x16

Construction:
- line: thin gold-violet track
- highlight: brighter center gem/glow and stronger emissive strip

### 4.5 Icons (`Icon_Frame_Master`)
Create variants:
- `icon_faith`
- `icon_follower`
- `icon_sacrifice`
- `icon_upgrade`

Suggested frame size:
- 96x96

### 4.6 FX (`FX_Master`)
Create variants:
- `glow_ring`
- `sparkle`
- `selection_ring`

Suggested size:
- 128x128 or 256x256 depending on effect scale

## 5. Export Spec

Export all runtime assets as PNG with:
- transparent background
- tight bounding box
- no padding
- no white border
- 1x and 2x exports

Output naming (exact):
- panels: `panel_main.png`, `panel_card.png`, `panel_popup.png`, `panel_tooltip.png`
- buttons: `button_primary.png`, `button_secondary.png`, `button_danger.png`, `button_small.png`, `button_icon.png`
- nodes: `node_upgrade.png`, `node_locked.png`, `node_special.png`
- connectors: `connector_line.png`, `connector_highlight.png`
- icons: `icon_faith.png`, `icon_follower.png`, `icon_sacrifice.png`
- fx: `glow_ring.png`, `sparkle.png`, `selection_ring.png`

## 6. Placement in Repository

Put exports in:
- `assets/ui/panels`
- `assets/ui/buttons`
- `assets/ui/nodes`
- `assets/ui/connectors`
- `assets/ui/icons`
- `assets/ui/fx`

## 7. Acceptance Checklist

- All required pages exist.
- All six master components exist.
- All required variants exist.
- Panel center zones remain clean and 9-slice safe.
- PNG exports have transparency and no white edge artifacts.
- Filenames exactly match runtime expectations.
