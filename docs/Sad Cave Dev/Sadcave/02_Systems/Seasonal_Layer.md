# Seasonal Layer

**Status:** ⚪ Idea
**Horizon served:** Return + Loyalty — see [[../01_Vision/Player_Experience_Arcs]]
**Stubbed:** 2026-04-28 session_4

---

## The idea in one paragraph

A calendar-aware layer that shifts the cave's surface details with real-world time. Seasonal titles unlock during specific windows. Environmental details change — different particles in winter, different ambient light in autumn, the firepit's flame variant. NPC moods nudge with the season. Loyal players accumulate seasonal markers like passport stamps; new players get a snapshot of "right now."

## Why it serves the loyalty + return arcs

For loyalty, it gives long-tail players surfaces they can only have seen by being there at the right time. A "Last Winter" title in summer says *I was here before you were*. For return, it gives a reason to come back next month even if mechanics haven't changed — *the cave is different in November*.

## What it would touch

- A calendar/season service — probably a small ModuleScript that maps real-world dates to in-game seasons + active windows
- The Seasonal title category in [[Title_System]] — currently defined-but-inactive, this is its activation engine
- [[Cave_Outside_Lighting]] preset overrides per season
- Particle / prop swaps in [[../03_Map_Locations/Cave_Entrance]] and any other built locations
- Optional: NPC dialogue variants gated on season

## Open questions

- Real-world calendar (January / July) or in-game seasons that drift independently?
- How long is a season — calendar month, real-world month, in-game two weeks?
- Are seasonal titles permanently kept once earned, or do they fade when the season ends? (Lean: permanently kept — that's what makes them passport stamps.)
- How visible is the seasonal shift — subtle (just title availability + a few particles) or strong (overhauled lighting, weather, NPC moods)? Tone says subtle.
- Holiday treatment — quiet acknowledgment, or full themed content?

## Dependencies

- [[Title_System]] — Seasonal category already specced, just inactive
- [[Cave_Outside_Lighting]] — preset infrastructure that doesn't exist yet
- [[Dialogue_System]] — for season-gated NPC lines

## Designed when

After at least one of the four Title categories ships (likely Presence per the activation sequence in [[Title_System]]), so the category-activation pattern is proven before adding calendar awareness on top.

## Risks / things to be careful about

- **Tone risk.** Seasonal content can drift toward themed events ("HALLOWEEN SALE!"). That's not Sad Cave. The seasonal layer should be felt, not announced — a different ambient sound, a winter title that quietly fades in, not a banner across the screen.
- **Authoring debt.** Every season needs content. If we ship 4 seasons × monthly variants = 12 content drops/year. Scope this carefully before committing.

## Related

- [[../01_Vision/Player_Experience_Arcs]] — loyalty + return horizons
- [[Title_System]] — Seasonal category activation
- [[Cave_Outside_Lighting]] — environmental shift surface
