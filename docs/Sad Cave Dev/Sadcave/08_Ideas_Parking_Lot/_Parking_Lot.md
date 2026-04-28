# Parking Lot

Stray ideas. Not committed. Don't build anything from this list without first checking it against [[../01_Vision/Tone_and_Rules]].

If an idea here gets greenlit → move it to a real doc in `02_Systems/`, `03_Map_Locations/`, or `05_NPCs/` and delete it here.

---

## 🌑 Locations

- Still water pool inside the cave (reflective, sit-and-stare spot)
- High ledge with a view of outside
- Small alcove with a single light source
- Outside grove or treeline
- Bridge / walkway between zones

## 👥 NPCs

- A second NPC who only appears at certain times / conditions
- A passing visitor — leaves after talking once

## 🎭 Mechanics

- "Sitting" presence reward (XP nudge while seated at a marked spot)
- Subtle ambient soundscape that shifts by location
- Journal / notebook UI (cosmetic, lets player save thoughts) — risky, mood-aligned but scope-heavy

## 🎨 UI / Cosmetic

- Title-card style location name fade-in when entering a new area
- Soft vignette during dialogue
- Optional camera "deep breath" on idle
- **XPBar polish (parked 2026-04-28, Cowork session 6)** — current bar reads visibly on both desktop and mobile post-PR #11 (`Background.BackgroundTransparency=0.55`, `Fill.BackgroundTransparency=0.6`, `barHeight=6`, warm-tint Fill `(225, 200, 160)`). Tyler's read: "kinda ugly" on mobile, "look ok for now but definitely ugly still" on desktop. Defer the visual refinement until more game features ship and there's more visual context for what the bar should feel like alongside the rest of the UI surface. Don't restyle in isolation.
- **Level-up animation refinement (parked 2026-04-28, Cowork session 6)** — current animation is a "subtle level reveal at the bottom of screen" (the LevelLabel fades in showing `level N`, the Fill bumps from 6px to 8px, glow pulses, then fades). Tyler's read: "looks fine, can make it look better later if that's the move." Defer until there's a clearer sense of what the level-up moment should feel like in context (e.g., when Title v2 ships, the `new title: still here` overlay may want to stack/sequence with the level-up beat).

## 🚫 Rejected (and why)

- Pets — breaks tone
- Currency shop — breaks tone
- Quest log — breaks tone
- Daily login streaks — pressure mechanic, opposite of mood
