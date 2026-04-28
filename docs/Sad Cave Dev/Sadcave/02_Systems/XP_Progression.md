# XP / Progression System

**Status:** 🟡 Building — MVP shipped 2026-04-27 (PR #1), follow-ups pending

> **Where we are:** ProgressionService + LevelCurve + SourceConfig + PresenceTick + XPBar are all live on `main`. Migration tested and recovered the user's level (557, totalXP 230,177). Old `LevelLeaderstats` and `Levelup` chat script were retired during Tyler's 2026-04-27 testing-place cleanup pass — not just disabled, deleted. The MVP is the only progression authority now.
>
> **What's left (follow-up briefs):** Discovery source, Conversation source, AchievementTracker, TitleConfig v2 + TitleService v2 + TitleMenu v2, NameTag update for v2 TitleConfig format, retire v1 title pipeline (already deleted in testing place; production may still have v1).
>
> **Open testing-place checks** (from `09_Open_Questions/_Open_Questions`): sitting boost at a real `SeatMarker`, level-up animation, gamepass +22 tick, mobile bar height, second-join migration variants, DataStore failure simulation.

---

## Purpose

Replace the current time-only leveling (`+1 level/60s`) with a real XP system that rewards **presence, exploration, and light interaction**. Players accumulate XP from multiple sources. Level is derived from total XP via a scaling curve. A quiet XP bar shows progress. Title unlocks gate on level — see [[Title_System]] for the v2 title redesign that rides on top of this.

## Player Experience

- XP ticks up quietly while you're in the cave — faster if you're sitting, slower if AFK
- A thin ambient bar at the bottom of the screen shows progress to the next level
- When you level up: bar fills, gentle glow, soft fade — then resets. No popup, no chat spam
- When you unlock a new title: brief text fade above the bar — `new title: still here` — holds 2s, then gone
- Discovering a new area, finishing a conversation, or sitting quietly at a marked spot all give XP bumps — enough to feel rewarding, not enough to grind
- **Sitting is the most rewarding thing you can do.** This is a chill game — the player who finds a quiet bench and stays is rewarded for that.

---

## Data Model

### XP is the source of truth

- **`TotalXP`** (integer) — lifetime XP earned. Persisted in DataStore. Never decreases.
- **`Level`** (integer) — derived from `TotalXP` using the level curve. Not saved separately — always recomputed from XP on join.
- **`XP` (leaderstats display)** — shows current `TotalXP` value. Read-only for client.
- **`Level` (leaderstats display)** — shows derived level. Read-only for client.

### Level Curve

Each level N requires XP calculated as:

```
XP for level N = floor(A + B * N^C)
```

**Constants (tunable in `SourceConfig`):**
- `A = 45` (flat base — ensures early levels aren't trivially fast)
- `B = 0.55` (scaling coefficient)
- `C = 1.15` (scaling exponent — steeper = bigger gap between early and late)

**Cumulative XP to reach a level** = sum of XP for levels 1 through N.

### Pacing Table

Based on an active player earning ~18 XP/min average (mix of sitting at 20 XP/min, exploring at 15 XP/min, plus discovery/conversation bonuses):

| Level | XP for this level | Cumulative XP | Active play time | Real-world pace |
|-------|------------------|---------------|-----------------|-----------------|
| 1 | 45 | 45 | 2 min | First moments |
| 5 | 48 | 232 | 13 min | First session |
| 10 | 52 | 485 | 27 min | First session |
| 20 | 62 | 1,060 | ~1 hr | End of first session |
| 50 | 94 | 3,402 | ~3 hrs | A few sessions |
| 100 | 154 | 9,611 | ~9 hrs | ~3 days @ 3hr/day |
| 200 | 288 | 31,678 | ~29 hrs | ~10 days |
| 300 | 433 | 67,713 | ~63 hrs | ~3 weeks |
| 500 | 743 | 185,053 | ~171 hrs | ~2 months |
| 1000 | 1,595 | 766,261 | ~710 hrs | ~8 months |
| 2000 | 3,484 | 3,290,645 | ~3,047 hrs | ~3 years |
| 5000 | 9,911 | 23,173,595 | ~21,457 hrs | Lifetime |

**Design intent:**
- First 10 levels fly by in one session (~27 min) — instant hook
- Level 50 in a few sessions (~3 hrs) — player feels established
- Level 100 in about a week of regular play — meaningful milestone
- Level 500+ takes months — signals real dedication
- Level 1000+ takes close to a year — rare, impressive
- Level 2000+ is lifetime dedication territory — aspirational
- No hard cap — curve scales forever, diminishing returns are built in

### DataStore

Two combined keys to minimize requests on join:

**`ProgressionData`** (dictionary) — one key for all progression state:
```lua
{
    totalXP = 5000,                           -- lifetime XP
    discoveredZones = {"cave_entrance", "rooftop"},  -- set of zone IDs found
    totalTimePlayed = 14400,                  -- seconds (migrated from CashLeaderstats)
    revisits = 12,                            -- session count (migrated from CashLeaderstats)
}
```

> **Why one key instead of separate keys:** Each DataStore read costs one "request" to Roblox's cloud. Roblox limits requests per minute (roughly 60 + 10 per player in the server). Combining related data into fewer keys means fewer requests on join, less chance of hitting the limit, and simpler save logic. Progression data is all written together anyway — it makes sense to store it together.

- **Migration:** On first join under new system, if `ProgressionData` is nil, check for legacy data:
  - Read `LevelSave` → seed `totalXP` with `GetXPForLevel(oldLevel)`
  - Read `TotalTimePlayedSave` and `RevisitsSave` from `CashLeaderstats` → seed `totalTimePlayed` and `revisits`
  - `discoveredZones` starts empty (badges already track this separately — no legacy data to migrate)
  - Save the combined `ProgressionData` key
- **Save throttle:** Save on meaningful changes — level-up, discovery grant, disconnect. NOT every tick.

---

## XP Sources

All XP grants go through `ProgressionService.GrantXP(player, amount, source)`. No other script touches XP directly.

### 1. Presence Tick (primary source — three states)

The presence tick fires every 60 seconds per player. The amount depends on what the player is doing:

| State | XP per tick | Description |
|-------|------------|-------------|
| **Sitting** | 20 XP | Seated at a `SeatMarker` for 30+ continuous seconds |
| **Active** | 15 XP | Moving around, exploring, not AFK |
| **AFK** | 3 XP | Flagged AFK by existing AFK system |

- **Sitting is the best XP rate.** Intentional — this is a hangout game, and chilling at a bench should be the most rewarded behavior.
- **30-second threshold:** Player must be seated at a `SeatMarker` child for at least 30 continuous seconds before the boosted rate kicks in. If they just sat down, they get the active rate until the threshold is met.
- **AFK detection:** hook into existing `ServerScriptService.AFK` script — it already tracks AFK state via `AfkEvent`
- **Gamepass boost:** multiply tick amount by `1.5x` (gamepass ID `1790063497`, "2X Levels"). A gamepass player sitting gets 30 XP/tick. (Note: ID was originally `2110249546` in the MVP, which turned out to be a nonexistent asset — corrected to `1790063497` in PR #11 after live testing showed the multiplier never applied.)

### 2. Area Discovery (one-time per area)
- **Amount:** `+50 XP` per new zone discovered
- **Source:** `Workspace.InsideZones` parts (same zones used by `AreaDiscoveryBadge`)
- **Tracking:** server-side set of discovered zone IDs per player, stored in `ProgressionData.discoveredZones`
- **Validation:** server checks player position against zone part bounds, not client claims
- **Coexists with badges:** `AreaDiscoveryBadge` keeps awarding badges separately. Discovery XP is a parallel grant, not a replacement.

### 3. Conversation Completion
- **Amount:** `+25 XP` per dialogue tree completed (not per line — per full conversation)
- **Source:** hook into existing dialogue system's completion signal
- **Cooldown:** same conversation with same NPC only grants XP once per session (prevents farming by re-triggering same dialogue)
- **Tracking:** server-side set of `{npcId}` completed this session (resets on rejoin, so returning players can re-earn)

### Summary Table

| Source | Amount | Frequency | Farmable? |
|--------|--------|-----------|-----------|
| Presence (sitting) | 20 XP | Every 60s | No — time-gated |
| Presence (active) | 15 XP | Every 60s | No — time-gated |
| Presence (AFK) | 3 XP | Every 60s | No — time-gated |
| Discovery | 50 XP | Once per zone, ever | No — finite zones |
| Conversation | 25 XP | Once per NPC per session | Mildly — resets on rejoin |

**All numbers are tunable in `SourceConfig`.** Start with these, playtest, adjust.

---

## Gamepass Boost

- **Gamepass ID:** `1790063497` ("2X Levels")
- **Effect:** `1.5x` multiplier on ALL XP sources (presence, discovery, conversation)
- **Applied inside `ProgressionService.GrantXP`** — single multiplication point, not per-source
- **Display:** no special UI for boost status. Gamepass owners just progress ~50% faster. Subtle, not advertised in-game beyond the gamepass purchase screen.

---

## XP Bar UI

### Placement
- **Bottom of screen**, full width, thin strip
- Sits above the existing subtitle panel area (doesn't overlap — subtitle panel is a centered box, XP bar is a full-width strip behind/below it)
- Always visible but ambient — like part of the screen border, not a HUD element

### Visual Design
- **Height:** ~4px on desktop, **~6px on mobile** (larger touch target, easier to see on small screens)
- **Background:** dark, semi-transparent (`0.55` transparency, post-PR #11 — was `0.85` originally but the bar visually disappeared against dark cave at low fill levels). Color `(15, 15, 15)`.
- **Fill color:** soft warm tone, low saturation — e.g. muted gold or warm white at ~40% opacity
- **No text by default** — just the bar filling
- **On hover / tap:** briefly shows `level N — 234 / 500 xp` in small lowercase text above the bar, then fades after 2s
- **Animations:** all eases, no bounce. Fill tweens smoothly on XP gain. Glow pulses gently on level-up, then fades.

### Level-Up Moment
1. Bar fills to 100%
2. Gentle glow bloom along the bar (warm, ~0.5s)
3. Brief text fade-in above bar: `level N` in the same understated lowercase style — holds for 2s
4. Bar resets to new level's progress, glow fades
5. No sound (or extremely soft, like a single quiet tone — your call in playtest)
6. No chat message (replaces current `Levelup` chat notification)

### Title Unlock Notification
- When a new title is earned mid-session, brief text fades in above the XP bar: `new title: still here`
- Same understated lowercase style as level-up text
- Holds for 2s, then fades
- Does NOT stack with level-up text — if both happen simultaneously, show level-up first, then title unlock after a 1s gap
- Fired from client when `TitleDataUpdated` remote arrives with a new title in the owned set

### Technical
- **`StarterGui.XPBar`** — ScreenGui with `DisplayOrder` below most UI, `IgnoreGuiInset = true`
- Contains: `Background` (Frame, full width, anchored bottom), `Fill` (Frame inside Background), `LevelLabel` (TextLabel, hidden by default), `TitleLabel` (TextLabel, hidden by default)
- Client listens to `ReplicatedStorage.Progression.XPUpdated` (RemoteEvent) for fill updates
- Client listens to `ReplicatedStorage.Progression.LevelUp` (RemoteEvent) for level-up animation
- Client listens to `ReplicatedStorage.TitleRemotes.TitleDataUpdated` (RemoteEvent) for title unlock notification
- Detect mobile via `UserInputService.TouchEnabled` to set 6px height
- All visual logic is client-side. Server just fires the events with the numbers.

---

## Technical Structure

### Server

**`ServerScriptService.Progression.ProgressionService`** (ModuleScript, required by a driver Script)
- `GrantXP(player, amount, source)` — single entry point for all XP grants. Applies gamepass multiplier. Updates `TotalXP`. Checks for level-up. Fires remotes. Throttles saves.
- `GetLevel(totalXP)` — pure function, computes level from cumulative XP using curve formula
- `GetXPForLevel(level)` — pure function, returns cumulative XP needed to reach a level
- Manages the presence tick loop (polls all players every 60s, checks sitting/active/AFK state)
- Tracks `totalTimePlayed` per player (increment every tick, regardless of state)
- Tracks `revisits` (increment on join)
- Loads/saves `ProgressionData` via DataStore on join/leave
- Handles migration from `LevelSave`, `TotalTimePlayedSave`, `RevisitsSave`
- Updates `player.leaderstats.Level` and `player.leaderstats.XP` values (server-authoritative)

**`ServerScriptService.Progression.Sources.PresenceTick`** (ModuleScript)
- Called by `Driver.server.lua`'s `tickPlayer` wrapper every 60s per player. The wrapper captures `(amount, sourceName)` for the per-tick debug log, then routes through `ProgressionService.Tick` for the actual grant.
- Checks three states in priority order: **Sitting → AFK → Active** (post-PR #10 — was AFK → Sitting → Active before; reorder shipped in PR #10 implements the "seated SeatMarker overrides AFK" decision; see `_Decisions.md` 2026-04-27)
- Sitting check: `state.seatedAt` is set (registered by `Driver.hookCharacter` when `Humanoid.Seated` fires with a seat that's a descendant of `Workspace.SeatMarkers`) AND `os.time() - state.seatedAt >= SITTING_THRESHOLD_SECONDS`
- Returns the appropriate XP amount (20 sitting, 15 active, 3 AFK) and source name string for the debug log
- Per-tick `[Progression] tick: source=... base=... granted=... player=...` print fires from `Driver.tickPlayer` after each successful grant (post-PR #11 — earlier format was `amount=...`; new format shows both pre-multiplier `base` and post-multiplier `granted` so gamepass ownership is visible at a glance)
- Returns the appropriate XP amount (20 sitting, 15 active, 3 AFK)

**`ServerScriptService.Progression.Sources.Discovery`** (ModuleScript)
- Connects to `Workspace.InsideZones` children `.Touched` events (server-side)
- Tracks discovered zones per player (in memory, seeded from `ProgressionData.discoveredZones` on join)
- Calls `ProgressionService.GrantXP` on first-time discovery
- Updates `ProgressionData.discoveredZones` on save

**`ServerScriptService.Progression.Sources.Conversation`** (ModuleScript)
- Hooks into dialogue system's completion signal (needs: dialogue system to fire a BindableEvent or call a function when a conversation ends)
- Tracks `{npcId}` set per player per session
- Calls `ProgressionService.GrantXP` on first completion per NPC per session

### Shared (ReplicatedStorage)

**`ReplicatedStorage.Progression`** (Folder)
- `XPUpdated` (RemoteEvent) — server → client, payload: `{totalXP, level, xpForCurrentLevel, xpForNextLevel}`
- `LevelUp` (RemoteEvent) — server → client, payload: `{newLevel}`
- `LevelCurve` (ModuleScript) — shared `GetLevel(xp)` and `GetXPForLevel(level)` so client can compute bar fill locally. Contains the curve constants `A=45, B=0.55, C=1.15`.
- `SourceConfig` (ModuleScript) — XP amounts, cooldowns, thresholds (readable by both, authoritative values on server)

### Client

**`StarterGui.XPBar`** — ScreenGui + internal scripts
- `XPBarController` (LocalScript) — listens to `XPUpdated`, `LevelUp`, and `TitleDataUpdated` remotes. Animates the bar, handles hover/tap reveal, shows level-up and title unlock text.

### Retired

- `StarterPlayerScripts.Levelup` — **remove**. Replaced by `XPBar` level-up animation. No more chat notifications.
- `ReplicatedStorage.Remotes.LevelUp` — **keep for now** but stop firing it from new system. Old `Levelup` client script will be removed, so nothing listens. Clean up in a later pass.

---

## Migration Plan

### Existing player data

Players currently have a `Level` value from `LevelSave`, plus `TotalTimePlayed` and `Revisits` from `CashLeaderstats`. On first join under the new system:

1. Load `ProgressionData` → if it exists, use it (player already migrated)
2. If `ProgressionData` is nil:
   - Load `LevelSave` → compute `totalXP = GetXPForLevel(oldLevel)`
   - Load `TotalTimePlayedSave` → seed `totalTimePlayed`
   - Load `RevisitsSave` → seed `revisits`
   - `discoveredZones` starts empty
   - Save combined `ProgressionData`
3. Set `player.leaderstats.Level` from derived level (should match old level exactly after migration)
4. Player sees no change — their level is the same, bar appears for the first time showing current progress

**Migration note:** A player with level 500 under the old system (~8 hrs of play) gets seeded with 185,053 XP, which maps to level 500 under the new curve. But new players need ~171 hrs to reach level 500. Old players will be disproportionately high-level — this is fine, it rewards loyalty.

### Transition from LevelLeaderstats

- **Phase 1 (ship):** `ProgressionService` takes over level/XP management. `LevelLeaderstats` script is **disabled** (not deleted — keep as rollback).
- **Phase 2 (after 1 week stable):** Delete `LevelLeaderstats` script. Remove legacy DataStore reads from migration path.
- **Phase 3 (after cleanup backlog):** Remove `CashLeaderstats` — its role as implicit progression source is now fully replaced.

---

## Security Notes

- ⚠️ All XP grants are server-side only. No remote from client requests XP.
- ⚠️ Discovery validated by server-side position check against zone part bounds.
- ⚠️ Sitting validated by server checking `Humanoid.Sit` and seat parent.
- ⚠️ Conversation validated by server-side dialogue completion (not a client claim).
- ⚠️ AFK state already tracked server-side — just read it, don't trust new client signals.
- ⚠️ DataStore calls wrapped in `pcall` with retry.
- ⚠️ Save throttle: meaningful changes only (level-up, discovery, disconnect). Not every 60s tick.
- ⚠️ Gamepass check via `MarketplaceService:UserOwnsGamePassAsync` — cache result on join, don't re-check every tick.

---

## Open Questions (resolved)

- ~~Level cap?~~ → No hard cap. Curve scales forever. Diminishing returns are built into the exponent.
- ~~Conversation XP: once per conversation or per branch?~~ → Once per full conversation completion, per NPC, per session.
- ~~Sitting threshold?~~ → 30 seconds minimum, then boosted presence tick rate.
- ~~Presence tick during dialogue?~~ → Yes, presence tick runs regardless. It's ambient. No double-dipping concern because conversation XP is one-time per NPC per session anyway.
- ~~Curve balance?~~ → Tuned with `A=45, B=0.55, C=1.15` and ~18 XP/min active average. Level 10 in ~27 min, level 100 in ~9 hrs, level 500 in ~171 hrs, level 1000 in ~710 hrs.
- ~~DataStore structure?~~ → Two combined keys: `ProgressionData` (XP, zones, time, revisits) and `TitleData` (equipped title, achievements). Two requests on join instead of four.
- ~~Sitting vs exploring XP?~~ → Sitting is the highest rate (20 XP/tick). Active exploring is 15 XP/tick. AFK is 3 XP/tick. Sitting is the most rewarded behavior.

## Open Questions (remaining)

- How many `InsideZones` currently exist? (Codex should count before building Discovery source — affects whether 50 XP per zone is too much or too little.)
- Does the dialogue system currently have a "conversation completed" signal, or does Codex need to add one? (Check `DialogueDirector` or equivalent.)
- Should discovery zones persist across sessions (never re-earnable) or reset daily? Current plan: persist forever, one-time only. But if total zone count is very low, this runs out fast.

---

## MVP Scope

For the first shippable version, build only:

1. **ProgressionService core** — data model, LevelCurve, SourceConfig, migration, save/load
2. **PresenceTick source** — three-state tick (sitting/active/AFK). This alone replaces `LevelLeaderstats`.
3. **XP Bar UI** — client bar with level-up and title unlock notifications

This gets the new system live and replaces the old one. Follow-up briefs add:
- Discovery source
- Conversation source
- AchievementTracker
- TitleConfig v2 + TitleService v2
- TitleMenu v2

Each follow-up is independently shippable.

---

## Implementation Order (for Codex brief)

1. **ProgressionService + LevelCurve + SourceConfig** — core service, data model, migration, save/load
2. **PresenceTick source** — plug into the service. This alone replaces `LevelLeaderstats`.
3. **XPBar UI** — client bar + remotes + level-up and title unlock notifications
4. **Discovery source** — extend `InsideZones` with XP grants
5. **Conversation source** — dialogue system hook (may need dialogue system changes — scope TBD)
6. **AchievementTracker** — first-time action tracking, DataStore persistence
7. **TitleConfig v2 + TitleService v2** — new title data, ownership resolution, migration
8. **TitleMenu v2** — new UI with owned/locked filters
9. **NameTag update** — read v2 TitleConfig format
10. **Retire `LevelLeaderstats`** — disable, then delete after soak
11. **Retire `Levelup` client script** — remove chat notifications
12. **Retire v1 TitleConfig/TitleService** — after v2 soak period

Each step is independently shippable and testable. If any step breaks, roll back only that step.

---

## Related

- [[Level_System]]
- [[Title_System]]
- [[Area_Discovery]]
- [[Daily_Rewards]]
- [[Dialogue_System]]
- [[NameTag_Status]]
- [[Group_Member_Perks]]
- [[_Cleanup_Backlog]]
