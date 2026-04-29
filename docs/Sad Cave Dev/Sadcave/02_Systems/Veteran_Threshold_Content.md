# Veteran Threshold Content

**Status:** ⚪ Idea
**Horizon served:** Loyalty (month 3+) — see [[../01_Vision/Player_Experience_Arcs]]
**Stubbed:** 2026-04-28 session_4

---

## The idea in one paragraph

A small handful of beats — places, dialogues, environmental details — that only become visible after substantial playtime or return-count. Players who reach them feel like they've seen something most haven't. The content can be small. What matters is that it exists and that it's truly only for veterans.

## Why it serves the loyalty arc

The loyalty arc breaks if everything is visible to everyone. Long-tail players need surfaces only they have seen — that's what makes "I've been here a while" feel like *meaning* rather than *number*. Veteran content is the asymmetry between a day-1 player and a month-3 player that isn't just bigger numbers.

## Examples (not committed — just the shape)

- A door inside the cave that doesn't open until the player has logged 50+ hours.
- A QuietKeeper line that only fires after 90 days of return visits.
- A faint constellation in the cave ceiling that's only visible to players above level 200.
- A second NPC who only appears for players who have unlocked a specific Seasonal title.
- A "Familiar Voice" track in the music rotation that only enables once.

These are illustrative — actual veteran content gets designed when this graduates from idea to spec.

## What it would touch

- A "playtime + return-count tracker" — extends the existing presence-tracking spine
- Per-player gating on specific assets (a model that's `Visible=false` until threshold met, a dialogue branch that's locked, a sound that's parented in only after threshold)
- Possible Title v2 entries for "veteran" markers (Presence category candidate)

## Open questions

- Threshold flavor: time-based (50 hours), return-based (30 distinct days), or composite? Lean: composite — both are needed to filter for genuinely loyal.
- Should veterans see the same set of content, or randomized subsets so they can't all share the same "secret"?
- How discoverable should veteran content be — actively pointed at by something, or genuinely tucked away?
- How much content total? 3–5 beats feels right for the first batch.

## Dependencies

- Solid playtime/return-count tracking (foundation exists in [[XP_Progression]] but specifically *return-count* may need a new field)
- Locations rich enough to hide content in (currently only [[../03_Map_Locations/Cave_Entrance]] — most veteran beats need more places to live)
- [[QuietKeeper_Memory]] for veteran-only dialogue

## Designed when

After [[../03_Map_Locations/Outside]] is built and at least one other location is built — the world needs to be big enough that hidden things have somewhere to hide.

## Risks / things to be careful about

- **Bait risk.** Veteran content can become a YouTube hunt — players gaming the threshold to unlock the secret, then immediately leaving. Counter: thresholds should be unmistakably long, not gameable in a single sitting.
- **Tone risk.** Veteran content shouldn't feel like an "achievement" reveal. It should feel like the cave finally trusting the player enough to show them.

## Related

- [[../01_Vision/Player_Experience_Arcs]] — loyalty horizon
- [[Title_System]] — Presence category overlap
- [[QuietKeeper_Memory]] — dialogue gating overlap
