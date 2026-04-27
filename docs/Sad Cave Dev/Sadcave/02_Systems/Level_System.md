# Level System

**Status:** ⚫ Superseded by [[XP_Progression]] — deleted from testing place 2026-04-27

> **Historical doc.** The legacy `LevelLeaderstats` (`+1 level/60s`) + `Levelup` chat client + `LevelSave` DataStore was the live progression system from project start through 2026-04-27. Replaced by the XP Progression MVP (PR #1, merged 2026-04-27). Tyler then deleted both `LevelLeaderstats` and `Levelup` from the testing place during the same-day cleanup pass.
>
> **Reading from the old DataStore:** `ProgressionService` still reads `LevelSave` once during migration (first join under the new system). After all live players have migrated, that read can be retired in a follow-up cleanup brief. Production may still hold v1 data — this matters whenever production gets the cutover.
>
> Kept as historical record because the change log and `_Cleanup_Backlog` reference "the level system" by this doc's name.

---

## Purpose
Track player level. Persist across sessions. Trigger level-up events. Feed the title system.

## Player Experience (current)
- Level appears in leaderstats and on nametag
- Level-up notification fires via chat system (`Levelup` client script)

---

## Real Architecture (as built)

### Server
- **`ServerScriptService.LevelLeaderstats`**
  - Manages level progression with autosave and gamepass bonus
  - **DataStore key:** `LevelSave`
  - Dependencies: `MarketplaceService`, `Players`

### Shared
- **`ReplicatedStorage.Remotes.LevelUp`** — RemoteEvent fired on level up

### Client
- **`StarterPlayerScripts.Levelup`** — listens to `LevelUp` event, shows notification via chat

---

## Current Issues / Why It Needs Redesign

1. **No clear XP source design** — level goes up, but on what trigger? (Currently unclear without further inspection — likely tied to `CashLeaderstats` legacy. Verify.)
2. **No alignment with tone** — leaderstats display + chat notification is generic Roblox UX, not Sad Cave UX
3. **No anti-grind protection** — system has no concept of "presence-based" gain
4. **`LevelUp` notification routes through chat** — should be a soft cinematic moment instead

---

## What XP Should Drive Level (target design)

See [[XP_Progression]] for the full plan. Short version:
- Presence ticks (slow drip while in-game)
- Discovery (first-time entry into a new area)
- Conversation completion
- Quiet moments (sitting at marked spots)

---

## Security Notes
- ⚠️ Client only reads — never writes XP/level
- ⚠️ All mutations through server services
- ⚠️ DataStore calls wrapped in `pcall` with retry
- ⚠️ Throttle saves — don't write per-tick

## Open Questions
- What's the current XP source? (Need to grep — might be tied to legacy Cash/leaderstats.)
- Should `LevelLeaderstats` and a new `ProgressionService` coexist, or should we refactor into one?
- Cap level? Soft cap? (Title system goes to 100k — that's a long tail; might need diminishing returns.)

## Related
- [[XP_Progression]]
- [[Title_System]]
- [[NameTag_Status]]
- [[_Cleanup_Backlog]]
