# THE CURSOR — FULL ASSET GENERATION COMMAND

This command instructs Codex to generate the full visual asset pack
for THE CURSOR.

The generation must strictly follow the project canon.

---

# Mandatory Documents

Before generating assets read:

docs/art/CURSOR_ART_SYSTEM.md  
docs/art/CURSOR_STYLE_SHEET.md  
docs/art/CURSOR_ASSET_SPEC.md  
docs/art/CURSOR_ASSET_LIST.md  
docs/art/ASSET_GENERATION_PROTOCOL.md  
docs/art/ASSET_GENERATION_PROMPT.md  

These files define the visual rules and technical constraints.

---

# Reference Images

Use the following reference images as visual anchors:

docs/art/reference/cursor_reference.png  
docs/art/reference/prophet_reference.png  
docs/art/reference/cultist_reference.png  
docs/art/reference/skeptic_reference.png  
docs/art/reference/civilian_reference.png  
docs/art/reference/ui_panel_reference.png  
docs/art/reference/environment_reference.png  

Assets must resemble these references but must not copy them directly.

---

# Generation Objective

Generate all assets defined in:

CURSOR_ASSET_LIST.md

Assets must comply with:

visual style  
technical specifications  
naming conventions  

---

# Generation Order

Generate assets in the following order.

1. Characters
2. Cursor system
3. Environment props
4. Environment backgrounds
5. UI panels
6. UI icons
7. VFX

---

# Character Generation

Characters must follow:

big head small body proportions  
two-tone shading  
thick outline  
70–80% canvas occupancy  

Resolution:

64x64 PNG

Character types:

civilian  
skeptic  
cultist  
prophet  

Generate all variants defined in the asset list.

---

# Cursor Generation

Cursor assets must include:

cursor_base  
cursor_symbol  
cursor_glow  
cursor_aura  

Resolution:

128x128 PNG.

The cursor must remain visually dominant.

---

# Environment Generation

Generate:

trees  
houses  
fences  
ritual structures  
ground variants  

Props must remain simple and readable.

---

# UI Generation

Generate UI assets including:

panels  
icons  
buttons  
tooltips  

Panels must support 9-slice scaling.

---

# VFX Generation

Generate visual effects such as:

conversion flash  
aura pulse  
cursor glow  
ritual glyphs  

Effects must remain simple and stylized.

---

# Export Rules

All assets must be exported as:

PNG  
RGBA  
transparent background  

Resolutions:

characters: 64x64  
cursor: 128x128  
props: 128x128  
large props: 256x256  

---

# Validation

Before exporting verify:

resolution correct  
alpha channel present  
no white background  
silhouette readable  
outline visible  
two-tone shading present  
sprite centered  

If validation fails regenerate the asset.

---

# Output Location

Export assets to:

assets/characters/  
assets/cursor/  
assets/environment/  
assets/props/  
assets/ui/  
assets/vfx/

---

# Completion Report

After generation output a summary including:

number of assets generated  
folders populated  
validation results
---

# Asset Replacement Policy

When generating assets, Codex must preserve the existing file paths.

If an asset already exists in the target directory:

- the file must be replaced
- the filename must remain identical
- no new filenames should be created

Example:

assets/characters/civilian_01.png -> overwrite  
assets/environment/tree_a.png -> overwrite  
assets/ui/panel_main.png -> overwrite

This guarantees that existing scene references remain valid.

Creating duplicate files such as:

civilian_new.png  
tree_variant_final.png  
panel_main_v2.png  

is strictly forbidden.

If an asset is missing, generate it using the naming convention
defined in CURSOR_ASSET_LIST.md.

---

# Path Preservation Rule

Codex must never rename or move assets referenced by scenes.

All replacements must occur in-place.

Do not modify directory structure unless explicitly instructed.

