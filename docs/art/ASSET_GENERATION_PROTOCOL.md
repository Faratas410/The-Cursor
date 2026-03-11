# THE CURSOR — ASSET GENERATION PROTOCOL

Purpose:

This document defines how Codex generates asset packs
while respecting the project canon.

---

## GENERATION ORDER

Codex must generate assets in the following order:

1 Characters
2 Cursor system
3 Environment props
4 Environment backgrounds
5 UI panels
6 UI icons
7 VFX

---

## GENERATION RULES

All assets must comply with:

CURSOR_STYLE_SHEET.md
CURSOR_ART_SYSTEM.md
CURSOR_ASSET_SPEC.md

If any conflict exists:

STYLE_SHEET overrides
ART_SYSTEM overrides
ASSET_SPEC overrides

---

## VISUAL PRIORITIES

When generating assets prioritize:

1 readability
2 silhouette clarity
3 palette consistency
4 gameplay visibility
5 detail

---

## VALIDATION RULES

Before exporting each asset verify:

resolution correct
alpha transparency present
no white background pixels
sprite centered
silhouette readable
two-tone shading present
outline visible

If validation fails → regenerate asset.

---

## OUTPUT FORMAT

All assets must be exported as:

PNG
RGBA
transparent background

---

## CHARACTER EXPORT

Character sprites:

64x64

Must include:

soft ellipse shadow sprite

shadow file:

characters/shadow.png

---

## CURSOR EXPORT

Cursor sprites:

128x128

Separate layers:

cursor_base
cursor_symbol
cursor_glow
cursor_aura

---

## ENVIRONMENT EXPORT

Props:

128x128

Large structures:

256x256

---

PATCH RESULT

Art canon harmonized.
Asset generation protocol integrated.
No gameplay systems modified.
