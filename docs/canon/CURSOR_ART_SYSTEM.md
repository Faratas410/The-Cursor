# CURSOR — ART SYSTEM CANON

## Purpose

This document defines the visual grammar and asset generation rules for **THE CURSOR**.

Its goals are:

• ensure consistent art direction  
• allow automated asset generation by Codex  
• preserve readability for incremental gameplay  
• maintain stylistic coherence across the project  

This document is **canonical**.

If any asset conflicts with this document → the asset must be corrected.

---

# 1. Global Art Direction

THE CURSOR uses a **minimalist cult-themed cartoon aesthetic**.

Primary inspiration:

Cult-of-the-Lamb-like visual language (simplified for idle gameplay).

Design priorities:

readability > detail  
silhouette > texture  
clarity > realism  

The game must remain visually readable at small gameplay scale.

---

# 2. Core Style Rules

All assets must follow these global constraints.

Perspective

- strict top-down camera
- orthographic view
- no perspective distortion

Shapes

- clean shapes
- rounded silhouettes
- soft outlines
- minimal geometry complexity

Color

- flat colors
- minimal shading
- consistent palette
- high readability contrast

Lighting

- soft ambient lighting
- no dramatic directional shadows
- characters use a soft ellipse shadow underneath

---

# 3. Character System

Characters follow a **big-head small-body cartoon proportion**.

Base proportions:

head ˜ 55%  
body ˜ 35%  
legs ˜ 10%

Silhouettes must remain readable at small scale.

Faction readability rules:

Civilian  
round head, simple shirt

Skeptic  
arms crossed, defensive posture

Cultist  
hooded robe silhouette

Prophet  
larger robe, staff, mystical elements

---

# 4. Civilian Generator

Civilian assets are generated through parameter variation.

Base structure

- round head
- small body
- neutral pose

Variation parameters

Shirt colors:

blue  
green  
orange  
red  
purple  

Hair colors:

brown  
black  
blonde  

Skin tones:

light  
medium  
dark  

Shadow

soft ellipse shadow  
opacity around 30%

---

# 5. Skeptic System

Skeptics represent resistant civilians.

Visual cues:

arms crossed  
slightly leaning posture  
skeptical facial expression  
darker clothing palette  

Colors typically include:

grey  
brown  
dark green  

---

# 6. Cultist System

Cultists represent converted followers.

Base design:

hooded robe  
face mostly hidden  
glowing eyes  
cult emblem on chest  

Robe palette:

dark purple  
deep red  
black  

Accent palette:

gold  
dark shadows  

---

# 7. Prophet System

Prophets represent high-tier cult leaders.

They must visually appear:

larger  
more ornate  
more mystical  

Design elements:

ritual robes  
gold ornaments  
staff  
glowing eyes  
mystical aura  

Aura types:

purple  
gold  
white  

---

# 8. Cursor System

The cursor represents the primary gameplay entity.

Design language:

ritual circle  
central cult eye  
geometric magical symbols  

Primary colors:

gold  
white highlights  
purple glow  

Cursor progression tiers:

cursor_base  
cursor_glow  
cursor_cult  
cursor_divine  
cursor_final  

Each tier increases:

glow intensity  
symbol complexity  
aura radius  

---

# 9. Environment System

Environments are top-down arenas.

Layout rule:

center area = gameplay space (empty)

edges = environmental decoration

This guarantees gameplay clarity.

---

# 10. Environment Progression

Each environment stage represents civilization escalation.

Village

grass terrain  
small houses  
trees  
wood fences  

Town

more houses  
stone paths  
market elements  

City

stone plazas  
walls  
larger buildings  

Metropolis

dense buildings  
towers  
stone roads  

Planet

alien terrain  
crystals  
unusual colors  

Cult World

ritual symbols  
altars  
candles  
cult banners  

Each stage must introduce **new visual elements**, not only color tinting.

---

# 11. UI System

UI uses a **dark ritual aesthetic**.

Panel design:

rounded corners  
dark purple background  
gold frame  
soft shadow  

Color palette:

panel base: #241B33  
gold border: #D4AF37  
gold highlight: #F0D97A  

---

# 12. UI Component Hierarchy

UI components include:

Main panel  
Upgrade panel  
Popup panel  
Tooltip panel  

These may share the same base panel asset scaled to different sizes.

---

# 13. Upgrade Node System

Upgrade nodes represent progression.

States include:

root  
locked  
hover  
purchased  
final  

Differentiation must be visible using:

color  
glow  
symbol  

---

# 14. Asset Generation Rules for Codex

When generating assets:

follow this document strictly  
maintain silhouette readability  
prefer parameter variation over redesign  
maintain consistent palette  

Never introduce:

realistic shading  
photorealism  
heavy texture noise  
high-detail illustration  

---

# 15. Asset Pack Generation

Codex may generate asset packs.

Examples:

generate 10 civilians  
generate 5 cultists  
generate ritual icons  
generate UI buttons  
generate environment variants  

All generated assets must comply with this art system.

---

# 16. Artistic Priority Order

When uncertain, prioritize:

1 readability  
2 gameplay clarity  
3 silhouette recognition  
4 style coherence  
5 visual detail  

---

# 17. Canon Authority

This file is the **source of truth for art direction**.

If an asset:

breaks style  
breaks proportions  
breaks silhouette clarity  

? it must be corrected.

---

PATCH RESULT

The project now has a **canonical art generation system**.

Codex can safely generate new assets using a consistent visual grammar.

No runtime code affected.

No gameplay systems modified.

---

# 18. Visual Style Technical Rules

This section defines the concrete technical rules that ensure assets match the intended cult-cartoon aesthetic.

These rules exist to guide automated asset generation.

---

## 18.1 Outline Rules

All characters and props must use a visible outline.

Outline characteristics:

color: very dark purple or near black  
thickness: clearly visible at gameplay scale  
style: smooth and rounded  

The outline is essential to preserve silhouette readability.

Assets without visible outlines are invalid.

---

## 18.2 Two-Tone Shading Rule

Assets must never be fully flat.

Every object must contain at least:

base color  
shadow color  

The shadow tone is slightly darker and used for:

lower areas  
inside folds  
under objects  

Realistic shading is forbidden, but minimal cartoon shading is required.

---

## 18.3 Silhouette Fill Ratio

Sprites must occupy most of their canvas.

Characters should fill approximately:

70–80% of the sprite height.

Sprites that occupy too little space appear like icons and break readability.

---

## 18.4 Character Readability

Characters must remain readable when zoomed out.

Key elements that must remain visible:

cultist glowing eyes  
civilian head shape  
skeptic crossed arms silhouette  
prophet staff or aura  

If a character loses readability at small size → regenerate.

---

## 18.5 Head Proportion Emphasis

Characters follow exaggerated cartoon proportions.

Recommended ratio:

head ≈ 60%  
body ≈ 30%  
legs ≈ 10%

Large heads are required for readability.

---

## 18.6 Color Palette

The visual palette should revolve around these tones.

Primary purple range:

dark purple #2A1A38  
mid purple #4E2C68  
light purple #7B4FA1  

Gold accents:

gold dark #B0892C  
gold light #F0D97A  

Environmental greens:

grass green #7DA65D  
tree green #3F7A4A  

These values are guidelines and may vary slightly.

---

## 18.7 Eye Visibility Rule

Cultist and prophet eyes must remain visible even at small scale.

Eyes should use bright tones:

yellow  
white  
light gold  

This ensures faction readability.

---

## 18.8 Cursor Visual Priority

The cursor represents the primary gameplay entity.

It must remain visually dominant through:

glow  
contrast  
symbol complexity  

The cursor must always remain readable even inside large groups of followers.

---

## 18.9 Prop Simplification

Environment props must remain simple and readable.

Trees, houses and fences must:

use rounded shapes  
avoid excessive detail  
preserve clear silhouettes  

Props must support gameplay readability and never dominate characters.

---

## 18.10 Anti-Icon Rule

Assets must never resemble UI icons.

If an asset:

contains a single flat color  
occupies less than half the canvas  
lacks shading  

→ regenerate.

The game uses sprites, not icons.
