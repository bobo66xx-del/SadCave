# Personal Place

**Status:** ⚪ Idea
**Horizon served:** Loyalty (month 3+) — see [[../01_Vision/Player_Experience_Arcs]]
**Stubbed:** 2026-04-28 session_4

---

## The idea in one paragraph

The cave notices where a specific player tends to sit, and quietly rewards it. A flower that only blooms in their favorite spot. A particle effect that only appears when *they* sit there. The QuietKeeper occasionally referencing it ("you sit by the firepit a lot"). It's the loyalty-arc surface that most clearly says *the cave knows you* without ever announcing itself.

## Why it serves the loyalty arc

Most month-3 systems require new content the player has never seen. This one is different — it makes the content the player has *already* loved feel personalized. It's cheap on content authoring and high on "this is mine" feeling. It's also the kind of thing players brag about to new players ("you should sit there for a while, eventually it does something").

## What it would touch

- Server-side tracking of seat use per player (`PresenceTick` already touches seated state — extension surface)
- A "favorite seat" determination — probably top-N by total seated time over the last N days
- Per-player, per-seat visual surfaces (a small particle attachment, an extra flower model, a soft light that activates only for that player)
- Optional: dialogue gating in [[QuietKeeper_Memory]] when the QK references the player's favorite spot

## Open questions

- One favorite or multiple tier (most-used / second-most / etc)?
- What threshold turns a seat into "yours" — minutes, sessions, weeks?
- Visual signal: should other players see the effect, or is it private to the favorite-haver?
- Does the favorite move when the player's habit changes, or is it sticky once set?

## Dependencies

- Sufficient seat density across the map for "favorite" to be meaningful (currently most seats live in [[../03_Map_Locations/Cave_Entrance]])
- [[XP_Progression]]'s `PresenceTick` already tracks seat state — extends naturally
- [[QuietKeeper_Memory]] for the dialogue surface (optional but high-value pairing)

## Designed when

After [[QuietKeeper_Memory]] ships and [[../03_Map_Locations/Outside]] is built — both expand the meaningful-seat surface this system needs.

## Related

- [[../01_Vision/Player_Experience_Arcs]] — loyalty horizon
- [[QuietKeeper_Memory]] — natural pairing
- [[XP_Progression]] — shared seat-tracking surface
