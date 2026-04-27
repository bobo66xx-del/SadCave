# Cave / Outside Lighting Transition

**Status:** 🔵 Planned (presets exist; controller does not; legacy `Theme` color-override scripts deleted in 2026-04-27 cleanup)

> **Post-cleanup note:** the old `Theme` server + client scripts that previously drove `game.Lighting.AfterPulseColor` are gone. The four lighting configs (`v1`, `V2`, `final`, `build`) and any `Workspace.Theme` parts remain in the testing place but no script is currently animating them. This doc's design intent is unaffected; the recommended cleanup (collapse the four configs into named `Cave` / `Outside` presets) is now easier because nothing live depends on the existing names.

---

## Purpose
A signature mood device — when players move from cave to outside (or vice versa), lighting smoothly transitions to reinforce the emotional shift.

## Player Experience
Walking out of the cave: light gradually warms, fog lifts, ambient sound shifts. Walking back in: things hush, cool, settle. Should feel like emotional weather, not a level transition.

---

## What's Already Built (use this)

### Lighting presets (in `Lighting`)
- `v1` — preset config
- `V2` — preset config
- `final` — preset config
- `build` — preset config

Each contains the same effect set:
- `SanctuaryBloom` (Bloom)
- `SanctuaryRays` (SunRays)
- `SanctuaryBlur` (Blur)
- `DepthOfField`
- `SanctuaryColor` (ColorCorrection)
- `SanctuaryAtmosphere` (Atmosphere)

### Zones
- **`Workspace.InsideZones`** — already-defined zone parts for inside-cave detection (also used by [[Area_Discovery]])

### Existing lighting scripts (kept post-cleanup)
- `StarterPlayerScripts.MobileLightingCompensation` — adjusts for mobile clients (in repo: `src/StarterPlayer/StarterPlayerScripts/MobileLightingCompensation.client.lua`)
- `StarterPlayerScripts.SunRayRemove` — removes/manages sun rays (in repo: `src/StarterPlayer/StarterPlayerScripts/SunRayRemove.client.lua`)
- ~~`StarterPlayerScripts.environment change`~~ — verify whether this survived the 2026-04-27 cleanup (was previously listed as unclear purpose)

## What's Missing (build this)
- ❌ A controller that detects which zone the player is in and tweens between presets
- ❌ A canonical "Inside" vs "Outside" preset (right now there are 4 presets — pick which two are real)
- ❌ Audio crossfade tied to zone transition

---

## ⚠️ Decision Needed: Which Presets Are Canonical?

Four lighting configs exist (`v1`, `V2`, `final`, `build`) — looks like iterative experimentation. Before building the transition controller, decide:
- Which one is "Inside / cave"?
- Which one is "Outside"?
- Delete the rest (see [[_Cleanup_Backlog]])

Recommendation: keep two named presets — `Lighting.Presets.Cave` and `Lighting.Presets.Outside` — and move all the other `Sanctuary*` effect sets into those, so the controller has a single clear thing to swap between.

---

## Proposed Technical Structure (when ready to build)

### Client-side (per-player, for performance)
- **`StarterPlayerScripts.Lighting.LightingZoneController`**
  - Watches player position vs `InsideZones`
  - Tweens between presets over ~3–5 seconds when crossing threshold
  - Uses `TweenService` on lighting properties + effect properties
  - Coordinates with [[Area_Discovery]] zone detection (don't double-implement)

### Config
- `ReplicatedStorage.Lighting.LightingPresets` — table of preset definitions (or copy of the cleaned-up `Lighting` configs)

---

## Design Notes
- Use `Lighting.ClockTime`, `FogStart`/`FogEnd`, `Atmosphere`, `ColorCorrection`
- Avoid sudden cuts — always tween
- Lock day/night per zone (don't run a real day-night cycle — controlled mood beats realism)
- Match audio crossfade if possible (`SoundService.SadCaveAmbient` is already a music system; ambient layers per zone could be added later)

## Open Questions
- Day/night cycle, or fixed times of day per zone? (Lean: fixed for mood control)
- How many lighting presets do we end up needing? Probably 2 (cave/outside) at first, +1–2 for special places later
- Should the existing `environment change` script be kept, refactored, or replaced?

## Related
- [[Area_Discovery]] — shares `InsideZones`
- [[../03_Map_Locations/_Map_Overview]]
- [[_Cleanup_Backlog]] — duplicate lighting configs to clean up
