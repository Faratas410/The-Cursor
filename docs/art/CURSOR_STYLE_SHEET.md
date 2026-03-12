# CURSOR — STYLE SHEET

This document defines the official visual reference for THE CURSOR.

Its purpose is to provide concrete visual targets for asset generation.

This file complements:

CURSOR_ART_SYSTEM.md

If an asset conflicts with this sheet ? regenerate it.

---

# 1. Style Philosophy

The game uses a **cult-cartoon aesthetic inspired by Cult of the Lamb**, but simplified for incremental gameplay.

Design priorities:

readability  
silhouette clarity  
cartoon exaggeration  

Assets must remain readable at small scale.

---

# 2. Visual Pillars

All assets must follow these pillars.

### Thick Outline

Characters and props must use a dark outline.

Outline color:

very dark purple or black.

The outline must remain visible at gameplay scale.

---

### Two-Tone Shading

Assets must not be flat.

Each asset must contain:

base color  
shadow color  

Shadow areas appear under folds, under shapes and inside silhouettes.

---

### Silhouette Simplicity

Silhouettes must be:

round  
clean  
instantly readable  

Avoid complex shapes.

---

## 2.1 Shading and Outline System

Character and prop rendering must follow these constraints:

- thick outer outline for silhouette lock
- minimal interior lines (only where needed for form separation)
- two-tone shading only (base + shadow)
- no painterly gradients
- no texture noise or gritty surface overlays

At reduced gameplay scale, shape readability has priority over decorative detail.

---

# 3. Character Proportions

Characters use exaggerated proportions.

Recommended ratio:

head ˜ 60%  
body ˜ 30%  
legs ˜ 10%

Large heads improve readability.

---

# 4. Canvas Occupancy

Characters must fill most of the sprite.

Target:

70–80% of sprite height.

Sprites that occupy too little canvas appear like icons.

---

# 5. Official Color Palette

Primary purple range:

dark purple #2A1A38  
mid purple #4E2C68  
light purple #7B4FA1  

Gold accents:

gold dark #B0892C  
gold light #F0D97A  

Environment greens:

grass #7DA65D  
tree #3F7A4A  

These colors may vary slightly but must remain within this palette.

---

# 6. Reference Assets

These reference assets define the expected visual style.

They are examples, not unique designs.

---

## Civilian Reference

Characteristics:

round head  
simple clothing  
clear hair silhouette  

Shirt colors vary.

Eyes must remain visible.

---

## Cultist Reference

Characteristics:

hooded robe  
glowing eyes  
cult emblem  

Silhouette must be clearly different from civilians.

Eyes must remain visible even at small scale.

---

## Prophet Reference

Characteristics:

larger robe  
ornamental gold details  
staff  
mystical aura  

Prophets appear visually superior to cultists.

---

## Cursor Reference

The cursor represents the cult's mystical power.

Design features:

ritual circle  
geometric symbols  
central eye  

Cursor tiers increase:

glow intensity  
symbol complexity  
aura size

---

## Tree Reference

Trees use simplified shapes.

Structure:

round canopy  
simple trunk  

Two-tone shading required.

---

## House Reference

Village houses must use:

simple roof shapes  
minimal detail  
clear silhouette

Avoid architectural realism.

---

# 7. Readability Test

Before accepting any asset verify:

silhouette readable  
outline visible  
shadow tone present  
eyes readable (for characters)

If any condition fails ? regenerate.

---

# 8. Anti-Icon Rule

Assets must not resemble UI icons.

Invalid assets:

single flat color  
tiny silhouette in large canvas  
missing outline  

These must be regenerated.

---

# 9. Anti-Drift Validation

Reject generated assets that resemble:

- anime-proportioned characters
- realistic anatomy studies
- glossy mobile-game chibi style
- flat vector icon characters
- pixel-art character systems

If any of these drifts appear, regenerate using the canonical references.

---

# 10. Character Silhouette Test

For every character class (civilian, skeptic, cultist, prophet):

1. convert preview to grayscale or pure silhouette
2. hide color and material cues
3. verify class identity remains recognizable

If class identity is unclear, the asset is invalid and must be regenerated.

---

# 11. Canon Authority

This document defines the **visual reference style**.

If generated assets deviate ? they must be corrected.

---

# 12. VFX Style Rules

Visual effects must follow the same cult-cartoon aesthetic.

Rules:

- simple shapes
- soft glow
- additive light
- minimal particle count

Allowed effects:

ritual glyphs
aura pulses
conversion flashes
light bursts

Forbidden:

realistic fire
realistic smoke
photorealistic particles
fluid simulations

PATCH RESULT

Art canon harmonized.
Asset generation protocol integrated.
No gameplay systems modified.


