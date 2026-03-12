# CURSOR — ASSET SPECIFICATION

This document defines the technical specifications for all art assets.

This file complements:

CURSOR_ART_SYSTEM.md

which defines the visual language.

This document defines:

- resolution
- canvas
- export rules
- naming conventions

This file is canonical.

---

# 1 Resolution Rules

Assets must follow standardized sizes.

Characters

64x64 PNG

Cursor

128x128 PNG

Environment props

128x128 PNG

Large props

256x256 PNG

UI panels

256x256 or 512x512 depending on usage

---

# 2 Transparency

All assets MUST:

• use full alpha transparency  
• contain NO background color  
• never contain white background pixels  

If any white pixels exist outside the asset silhouette ? asset is invalid.

---

# 3 Canvas Rules

Assets must be tightly cropped.

Characters must be centered.

Cursor must be perfectly centered.

Props must not contain large empty areas.

---

# 4 Character Canvas Occupancy

Characters must occupy approximately 70–80% of sprite height.

Occupancy constraints:

- silhouettes must not appear tiny inside the frame
- negative space must remain controlled and intentional
- avoid excessive empty margins above or beside the silhouette

Sprites that occupy too little canvas reduce gameplay readability and must be regenerated.

---

# 5 Cursor System

Cursor uses layered sprites:

cursor_base.png  
cursor_symbol.png  
cursor_glow.png  
cursor_aura.png  

This allows runtime animation.

Canvas size:

128x128

Cursor must always be centered.

---

# 6 Panel System

Panels must support 9-slice scaling.

Panels:

panel_main.png  
panel_card.png  
panel_tooltip.png  
panel_popup.png  

Panels must contain:

gold border  
dark purple base  
rounded corners  

Borders must remain intact when sliced.

---

# 7 Prop Naming Convention

environment/

village_house_small.png  
village_house_medium.png  
tree_a.png  
tree_b.png  
wood_fence.png  
cult_banner.png  
ritual_stone.png  

---

# 8 Character Naming

characters/

civilian_01.png  
civilian_02.png  
civilian_03.png  

skeptic_01.png  

cultist_01.png  
cultist_02.png  

prophet_01.png  

---

# 9 Color Compliance

Palette must match CURSOR_ART_SYSTEM.

Allowed dominant colors:

purple  
gold  
dark red  
neutral greens  

No high-saturation neon colors allowed.

---

# 10 Validation

Assets must pass these checks:

• correct resolution  
• transparent background  
• centered composition  
• readable silhouette  
• class readability preserved at gameplay scale  
• silhouette remains identifiable in grayscale preview  

If an asset fails any rule ? regenerate.

---

PATCH RESULT

The project now has a full technical specification for asset generation.


PATCH RESULT

Art canon harmonized.
Asset generation protocol integrated.
No gameplay systems modified.


