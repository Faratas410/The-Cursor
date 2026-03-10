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
