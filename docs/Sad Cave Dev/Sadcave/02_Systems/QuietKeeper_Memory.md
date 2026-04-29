# QuietKeeper Memory

**Status:** 🔵 Planned (designed 2026-04-28 session_4 — ready for Codex MVP brief)
**Horizon served:** Loyalty (month 3+) primarily, with return-arc benefits — see [[../01_Vision/Player_Experience_Arcs]]
**Related NPC:** [[../05_NPCs/QuietKeeper]]
**Related system:** [[Dialogue_System]] (requires extension — see *Dependencies*)

---

## What this system is

QuietKeeper notices and remembers. Across sessions. The same player coming back for the fifth time hears something subtly different from a stranger arriving for the first time. The player who's been gone a month gets a different greeting from the one who showed up yesterday. QK doesn't list facts at the player ("you've visited 47 times!") — they just *speak as if they remember*.

This is the loyalty-arc surface that most directly says *the cave knows you*. It does not announce itself. A player may not consciously notice that QK's lines are different until weeks in, at which point it lands as quiet recognition rather than mechanical reward.

## What this system is NOT

- Not a quest tracker.
- Not an "achievement" system. Earned-content lives in [[Title_System]].
- Not a stats reveal. QK never says numbers. ("You've been here 47 times" is wrong. "You're a regular now" is right. "...hey." is also right.)
- Not loud. Most visits, QK still just says hi.

The loudest variant of this system is still quieter than the loudest line in `01_Vision/Tone_and_Rules`'s "Bad" examples.

---

## Memory state — what gets tracked per player

A small profile, persisted across sessions. The MVP only uses the first two fields; the rest are designed-in so the data is captured from the start and the v2+ surfaces don't need a migration.

| Field | Type | What it means |
|---|---|---|
| `visitCount` | int | Total distinct visits (a visit = a session that lasted ≥ 60 seconds). Increments on the **next** join after a session ends, not at join time, so a quick crash-and-rejoin doesn't double-count. |
| `lastVisitAt` | os.time | Unix timestamp of when the most recent counted visit started. |
| `currentStreakDays` | int | Consecutive calendar days with at least one counted visit. Resets to 1 on a >24h gap (in player local time, falling back to UTC if not knowable). |
| `longestStreakDays` | int | Highest `currentStreakDays` ever reached for this player. |
| `totalSeatedSeconds` | int | Lifetime seated time across all visits (extends from [[XP_Progression]]'s seat-tracking — the same source). |
| `firstVisitAt` | os.time | Set once, never changes. Lets QK reference how long they've known the player. |
| `recentUnlocks` | list[titleId] | Last 3 titles unlocked, FIFO. Cleared on read by QK so a unlock is acknowledged once. (v2 surface — captured from MVP.) |
| `hasBeenOutside` | bool | Whether the player has ever entered the [[../03_Map_Locations/Outside]] zone. (v2 surface — captured from MVP, no-op until Outside is built.) |

**Storage:** A small DataStore alongside the existing player-profile stores. Loaded on `PlayerAdded`, saved on `PlayerRemoving` and intermittently (every N minutes during a session, with `pcall` + retry, mirroring the pattern XP_Progression already uses).

**No data leak across players.** All state is keyed by `Player.UserId`.

---

## Surface — how memory becomes dialogue

The existing [[Dialogue_System]] supports two QuietKeeper conversation entries: `start` (first meeting) and `return` (any subsequent visit). This system extends `return` into a **prioritized list of conditional variants**, with the existing `return` line preserved as the default fallback.

### Conceptual model

When the player triggers QK's ProximityPrompt and they're not a first-time player, the dialogue runtime:

1. Reads the player's memory snapshot via `NPCMemory.GetMemorySnapshot(player)`.
2. Walks the variant list for `QuietKeeper.return_variants` in order.
3. Picks the **first variant whose condition matches**.
4. Falls through to `QuietKeeper.return` if none match.

Variants are ordered most-specific-first. Generally: rare/long-tail variants on top, common ones below.

### MVP variant set (visit-count gated)

The MVP ships with these five variants plus the existing fallback. Lines are placeholder — Tyler writes the final voice (see *Content authoring* below).

```
return_variants:
  - condition: visitCount >= 100
    line: "still here, then."
  - condition: visitCount >= 25
    line: "the regular."
  - condition: visitCount >= 5
    line: "good to see you again."
  - condition: visitCount == 2
    line: "you came back."
  - condition: visitCount == 3 or 4
    line: "still around."

return:  (existing fallback — keep as-is)
    line: "It's quieter when you're here."  (or whatever the current line is)
```

**Why these counts:** 2 catches the very-first-return moment, which is the strongest single beat in the game today and deserves its own line. 3–4 fills the immediate stretch. 5 is "you're not just curious anymore." 25 is "you're showing up regularly." 100 is the long-tail nod.

### v2 variants (post-MVP, additive)

The same priority-list, with new conditions inserted in the right tier:

```
- condition: gapDaysSinceLastVisit >= 60
  line: "didn't think you'd come back."

- condition: gapDaysSinceLastVisit >= 14 and visitCount >= 5
  line: "where've you been."

- condition: currentStreakDays >= 7
  line: "every day this week."

- condition: longestStreakDays >= 30 and currentStreakDays == 1 (broken streak)
  line: "back to it."

- condition: hasBeenOutside == true and previousVisitWasFirstTimeOutside
  line: "saw you went out yesterday."  (one-shot, clears the flag)

- condition: recentUnlocks contains a title
  line: a unlock-acknowledgement variant — see "Title acknowledgement" below
```

These are sketches, not committed lines. The condition shapes are the real spec.

### Title acknowledgement (v2 surface)

When the player unlocks a title, QK gets *one* chance to acknowledge it on their next visit. Spec:

- On title unlock, append `titleId` to `recentUnlocks` (FIFO, cap at 3).
- Next QK conversation, if `recentUnlocks` is non-empty, the title-acknowledgement variant fires once and clears the list.
- The line itself is generic ("noticed.") rather than per-title — naming the title would be too explicit. Tone is *I saw what you did, I won't make a thing of it*.

If Tyler wants per-title lines later, the unlock list already carries enough information.

---

## Tone-critical design rules (binding)

These are not suggestions. Any line authored for this system must pass all of them.

1. **Under 10 words.** Most under 5.
2. **No numbers.** QK never says "47 visits" or "30 days" or any count. Always feeling-language.
3. **No celebration.** No "welcome back!" or "great to see you!". The warmth is in the brevity, not the words.
4. **Default line stays live.** Even at high visit counts, the fallback line is still authored to feel right for any visit. The system *prefers* the specific variant when one matches, but there must be no visit at which the fallback feels wrong.
5. **Sometimes the higher tier is the *quieter* line.** A 100-visit player getting "...hey." can land more powerfully than the same player getting a paragraph. Don't escalate verbosity with rank.
6. **Silence is allowed.** A variant can be an *empty* line (`""`) — QK just nods, no text appears. Reserve for very specific moments (e.g., a player who has been here every day for a month — sometimes there's nothing to say). Use sparingly.
7. **No 4th-wall awareness.** QK never refers to "the game," "Roblox," "your level," "your XP." They are a person in the cave.

---

## Dependencies

- **[[Dialogue_System]] extension required.** The current dialogue runtime supports `start` and `return` keys; it must learn to read a `return_variants` list and evaluate conditions in order. This is the build-blocker for the MVP.
- **[[XP_Progression]]'s seat-tracking spine.** `totalSeatedSeconds` reads from the same source `PresenceTick` already uses.
- **[[Title_System]] hook.** When a title is granted, the unlock should fire a BindableEvent or write to a shared module that `NPCMemory` can observe to push to `recentUnlocks`. Avoid tight coupling — prefer event subscription.
- **DataStore quota.** Adds one new DataStore. Confirm against existing stores in the testing place before building so we don't blow the per-place limit.

## Codex MVP brief — what to ship first

When this graduates to a `06_Codex_Plans/` brief, the MVP scope is:

- New `ServerScriptService.NPCMemory` ModuleScript implementing the state above (only `visitCount`, `lastVisitAt`, `firstVisitAt`, plus the unused-but-captured fields).
- DataStore load on join, save on leave + every 5 min, `pcall` + retry.
- Visit-count increment logic gated on session ≥ 60s.
- Public function `NPCMemory.GetMemorySnapshot(player)` returning the state struct.
- Dialogue_System extension to read `return_variants` and evaluate `visitCount` conditions only.
- Five MVP variants wired in (with placeholder lines — Tyler authors finals before merge).
- A small probe Script (in the `CodexMigrationProbe` pattern from PR #17) that synthesizes joins for fake users at counts 1, 2, 3, 5, 25, 100 and confirms the right variant fires. Probe deleted before push.

**Out of scope for MVP:** streaks, gap detection, seated-time tier, title acknowledgement, hasBeenOutside, all v2 variants. Capture the data from MVP day one (so no migration later) but no surfaces use it yet.

## Content authoring — Tyler's part

The system spec defines structure. The lines are Tyler's voice. Before the MVP merges:

1. Tyler reviews the five MVP variant slots and writes the final lines (placeholder lines above are starting points — the voice should be Tyler's).
2. Lines pass the seven tone rules above.
3. Tyler can choose to leave any variant as `""` (silent — QK nods) if a tier feels right wordless.

Voice authoring happens in `ReplicatedStorage.DialogueData.Characters.QuietKeeper` — the same surface that holds the existing `start` and `return` lines. No code change for line edits.

---

## Open questions

- **Visit-count thresholds:** do `2 / 3–4 / 5 / 25 / 100` feel right, or do we want different shape (e.g. `2 / 7 / 30 / 100 / 365`)?
- **Streak vs gap interaction:** if a player has a 30-day streak then takes 60 days off, does the gap variant or the broken-streak variant win? Lean: gap, because the absence is the more recent signal.
- **Voice for the unlock acknowledgement:** does QK acknowledge every title, or only "meaningful" ones? (The Presence and Seasonal categories feel right; Achievement might be too small to surface.)
- **Per-NPC vs shared:** is this system QuietKeeper-only, or does it generalize to future NPCs (every NPC can hold their own memory of the player)? Lean: generalize from day one, but only QuietKeeper has variants until other NPCs exist.

These get resolved in the Codex MVP brief.

---

## Risks / things to be careful about

- **Over-recognition risk.** It's tempting to add a variant for every milestone. Don't. The system gets weaker with more variants, not stronger — too many specific lines feels mechanical. Keep MVP at five and grow slowly.
- **DataStore failure handling.** If memory load fails, fall through to the existing `return` line as if no memory exists. Never block the conversation on a load error. The player sees normal QK; nothing surfaces about the failure.
- **Privacy.** Memory is per-UserId. Don't leak any state to other players (no visible "regular" badge, no shared knowledge). The intimacy is between QK and this specific player.

## Related

- [[../01_Vision/Player_Experience_Arcs]] — the loyalty horizon this system serves
- [[../05_NPCs/QuietKeeper]] — the NPC's personality + base setup
- [[../04_Dialogue/QuietKeeper_Lines]] — current line content; expanded by this system
- [[Dialogue_System]] — the runtime this system extends
- [[Personal_Place]] — natural pairing (favorite-spot dialogue references)
- [[Veteran_Threshold_Content]] — overlapping veteran-only dialogue gating
