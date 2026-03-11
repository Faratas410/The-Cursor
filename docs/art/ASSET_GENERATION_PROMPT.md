# THE CURSOR — ASSET GENERATION PROMPT

This document defines the operational instructions for generating
visual assets for THE CURSOR.

It must always be used together with the canonical art documents.

Required reading before asset generation:

CURSOR_ART_SYSTEM.md  
CURSOR_STYLE_SHEET.md  
CURSOR_ASSET_SPEC.md  
CURSOR_ASSET_LIST.md  
ASSET_GENERATION_PROTOCOL.md  

Reference images:

docs/art/reference/cursor_reference.png  
docs/art/reference/prophet_reference.png  
docs/art/reference/cultist_reference.png  
docs/art/reference/skeptic_reference.png  
docs/art/reference/civilian_reference.png  
docs/art/reference/ui_panel_reference.png  
docs/art/reference/environment_reference.png  

The reference images define the intended style.

Assets must visually resemble these references but must not copy them directly.

---

# Generation Objective

Generate a complete asset pack that complies with:

- project art style
- technical specifications
- naming conventions
- reference images

Assets must remain readable during gameplay.

---

# Visual Style Summary

The game uses a **cult-cartoon style inspired by Cult of the Lamb**.

Important characteristics:

- thick dark outlines
- two-tone shading
- simple silhouettes
- exaggerated character proportions
- minimal detail but strong readability

Assets must never appear as flat icons.

---

# Character Generation

Characters follow the same base structure.

Proportions:

head ≈ 60%  
body ≈ 30%  
legs ≈ 10%

Canvas rules:

characters must fill 70–80% of the sprite height.

Resolution:

64x64 PNG.

Characters must include a separate shadow sprite.

---

# Character Types

Generate the following categories:

Civilian  
Skeptic  
Cultist  
Prophet  

Civilian variants are generated using:

hair color  
shirt color  
skin tone  

The exported sprites represent baked combinations.

---

# Cursor System

The cursor represents the cult power.

Cursor sprites:

cursor_base  
cursor_symbol  
cursor_glow  
cursor_aura  

Resolution:

128x128 PNG.

The cursor must remain visually dominant and clearly visible.

---

# Environment Assets

Environment assets include:

trees  
houses  
fences  
stones  
ritual structures  

Rules:

simple shapes  
rounded silhouettes  
minimal detail  

Props must not overpower characters.

---

# UI Assets

UI assets include:

panels  
icons  
buttons  
tooltips  

Panels must follow:

dark purple background  
gold border  
rounded corners  

Panels must support 9-slice scaling.

---

# VFX Assets

VFX follow the same cult aesthetic.

Allowed effects:

ritual glyphs  
soft aura pulses  
conversion flashes  
light bursts  

Forbidden:

realistic smoke  
realistic fire  
complex particle simulations

---

# Export Rules

All assets must be exported as:

PNG  
RGBA  
transparent background

Resolution rules:

characters: 64x64  
cursor: 128x128  
props: 128x128  
large props: 256x256  

---

# Validation Checklist

Before exporting assets verify:

- correct resolution
- alpha transparency present
- no white background pixels
- silhouette readable
- outline visible
- shading present
- sprite centered
- style matches reference images

If any check fails → regenerate asset.

---

# Generation Scope

When generating assets, prioritize:

characters  
cursor system  
environment props  
UI panels  
UI icons  
VFX  

This ensures gameplay-critical visuals are available first.

---

# Final Output

Export assets using the naming scheme defined in:

CURSOR_ASSET_LIST.md

Ensure assets are placed in the correct directories:

assets/characters/  
assets/cursor/  
assets/environment/  
assets/props/  
assets/ui/  
assets/vfx/  

---

# Canon Authority

If any conflict exists between documents:

STYLE_SHEET takes priority  
ART_SYSTEM second  
ASSET_SPEC third  

All generated assets must remain compliant with the canon.
