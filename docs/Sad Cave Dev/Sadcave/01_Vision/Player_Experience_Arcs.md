# Player Experience Arcs

The felt shape of being a Sad Cave player over time. Sibling to [[Tone_and_Rules]] (which says what the game *is*) and [[Project_Overview]] (which says what the game *does* at a pitch level). This doc says what the player *feels*, across the three time horizons that actually shape design choices.

Read this before adding a new system. Every system either serves one of these arcs or it doesn't belong.

---

## The three horizons

Sad Cave is a quiet, return-shaped game. Players don't beat it; they live with it for a while. So the design has to answer three different questions, each on a different time scale.

| Horizon | Time scale | The question | Carried by |
|---|---|---|---|
| **Arrival** | First 10 minutes | Does the very first impression feel like Sad Cave? Will a stranger stay past minute 10? | Atmosphere, first NPC contact, first sit |
| **Return** | First week (visits 2–7) | Why does a player come back tomorrow? Why next weekend? | Discovery, recognition, small things noticed |
| **Loyalty** | Month 3 and beyond | Why are they *still* here? | Relationships, mastery, things only loyal players see |

A healthy game has all three working. Sad Cave today has Arrival mostly working and Return / Loyalty mostly missing.

---

## Horizon 1 — Arrival (first 10 minutes)

### What the player feels

Hush. A place that doesn't want anything from them. The faint sense of having been invited.

### What currently happens

Spawn into the [[../03_Map_Locations/Cave_Entrance]]. Visually this is the strongest stretch of the game — firepit, fireflies, sun rays, foliage, multiple seats, soft warm lighting. They wander toward [[../05_NPCs/QuietKeeper]], get a short on-tone dialogue (the `start` line is doing real work — see [[../04_Dialogue/QuietKeeper_Lines]]). They might find a seat. After 30 seconds of seated time, presence XP starts ticking via [[../02_Systems/XP_Progression]]. Around minute 5, the bar fills, level ticks up, a low-level title fades in via [[../02_Systems/Title_System]] and renders on the [[../02_Systems/NameTag_Status]].

### Where it thins

Minute 1–4 is carried by atmosphere alone, and that's enough — the cave is genuinely beautiful. Minute 5–10 is where the cracks show: they've met the only NPC, found the seats, their first title has faded in, and there's nowhere new to go. The [[../03_Map_Locations/Outside]] area exists in the vault as planned but isn't built.

The bridge into Horizon 2 is fragile. There's nothing on day 1 that hints at what day 2 will offer.

### What this horizon needs

- Outside built out, even at low fidelity, to give the cave a *contrast* the player can feel.
- A second seat-spot type that *recognizes* the player when they come back to it (foundation for Horizon 2 and 3).
- Something on the way out — the moment the player closes the game — that suggests "there's more here than you saw."

---

## Horizon 2 — Return (visits 2–7, days 2–7)

### What the player feels

*I want to go back to that quiet place tonight.* Return matters — they're not starting from scratch. Small things noticed that weren't there before.

### What currently happens

Day 2: QuietKeeper greets them with the `return` line. This is one of the strongest content beats in the project — your tone is doing real work. They sit, accumulate XP, level climbs. Day 3: same. Day 4: leveling slows naturally, same room, title-watching gets thinner because only the level-based titles in the [[../02_Systems/Title_System]] v2 spec are actually earnable right now — the AchievementTracker, Discovery, Presence, and Seasonal categories are all defined but inactive. Days 5–7 start to feel like grind, because the only thing happening is progression.

### Where it thins

Return is currently rewarded by progression, not by discovery. [[Tone_and_Rules]] explicitly says "quiet emotional exploration" — and right now the *exploration* axis is missing from the return arc. A returning player sees no new content, only larger numbers.

This is the weakest stretch of the entire game today. See *Diagnosis* below.

### What this horizon needs

- Activate one of the discovery-shaped title categories (Discovery or Achievement) so days 3–4 have a non-progression reason to wander.
- A small handful of "moments" — places or beats — that aren't visible on day 1 but become visible on day 3 or day 5. They don't have to be big. A flower that only opens on the third visit. A faint sound near the waterfall on day 4. The QuietKeeper using your name (or a quiet variant of "you") on visit 5.
- Recognition surfaces that *prove* the game noticed: a presence title that fades in on visit 7 ("regular," "comes around"), not just visit-count XP.

---

## Horizon 3 — Loyalty (month 3 and beyond)

### What the player feels

*This place knows me.* NPCs greet them by what they've shared, not what they bought. Things only they can see — a Seasonal title earned during last winter, a quiet alcove they've sat in a hundred times. They show new players around because the cave belongs to them a little.

### What currently happens

This horizon doesn't exist yet as a design. There are scattered hooks — the Seasonal category in [[../02_Systems/Title_System]] (defined but inactive), QuietKeeper's "notices when you've been gone or when you're back" personality note, the general direction in [[Project_Overview]] — but none of it has been pulled together into a felt shape.

A real month-3 player today would have leveled past most unlocks, heard everything QK has to say, and would be coming back for vibe + friends. Vibe + friends is real value, but without surfaces that recognize them, they drift.

### What this horizon needs

- **Memory.** NPCs that know how long you've been around, what you've done, and surface it lightly. Not "Welcome back, level 80!" — more "You sat by the firepit a lot last winter." (Designed in [[../02_Systems/QuietKeeper_Memory]] — the most distinctive month-3 surface.)
- **Seasonal layer.** Titles, environmental shifts, NPC moods that only happen during specific in-game seasons or real-world months. Loyal players accumulate these like passport stamps.
- **Personal place.** The cave noticing where this specific player tends to sit, and rewarding it quietly — a flower that only blooms there for them, a particle effect that only shows when *they* sit there.
- **Veteran-only content.** A handful of beats that only become visible after, say, 50 hours of playtime or 30 days of return visits. Players who reach them feel like they've seen something most haven't. The content can be small — what matters is that it exists.

---

## Diagnosis — the weakest stretch right now

**Days 3–7 of the return arc.**

Three reasons:

The first is *design density*. Day 1 is carried by atmosphere; month 3 will be carried by social bonds and edge content. Days 3–7 have no distinct surface at all — same QuietKeeper, same room, slowly climbing XP. It's the stretch where the design is thinnest relative to how heavily it weights retention.

The second is *leverage*. Most Roblox players don't get past day 4 in any game; the ones who do are the ones who saw something on day 4 they didn't see on day 1. So days 3–7 is literally the gate to ever having month-3 players. Fix nothing else and the loyalty arc has no input.

The third is *actionability*. The fix mostly already exists in the vault as inactive systems — AchievementTracker, Discovery title category, Presence title category. None of them require new pillars. Activating them is mostly a sequence of Codex briefs against existing specs, plus content authoring. The work is concrete.

---

## How to use this doc

When proposing a new system or content beat, ask:

- Which horizon is this for?
- What does it *make the player feel* on that horizon?
- Does the horizon it serves currently need help, or is it already strong?

If the answer to "which horizon" is "all of them" — be suspicious. That usually means the design isn't focused enough yet. The strongest Sad Cave systems serve one horizon clearly.

When deprioritizing or cutting something, the same questions apply. Anything that doesn't serve one of the three horizons is probably wrong for this game even if it's mechanically interesting.

---

## Related

- [[Tone_and_Rules]] — what the game is and isn't
- [[Project_Overview]] — pitch-level summary
- [[../02_Systems/Title_System]] — the recognition surface most directly tied to all three arcs
- [[../02_Systems/QuietKeeper_Memory]] — the loyalty-arc system this doc most directly justifies
- [[../02_Systems/XP_Progression]] — the progression spine that runs underneath all three arcs
