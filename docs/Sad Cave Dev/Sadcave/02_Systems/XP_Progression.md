# XP / Progression System

**Status:** 🔵 Planned — current priority

Build on top of existing [[Level_System]]. The goal is to redirect a working but generic level system into something that fits Sad Cave's tone.

---

## Purpose
Reward **presence, exploration, and light interaction** — not grinding. Progression should feel like a quiet reflection of time spent in the space, not a checklist.

## Player Experience
- Slow, ambient XP gain just for being in the cave
- Small bumps for visiting new areas (extending [[Area_Discovery]])
- Occasional bumps for meaningful interactions (NPC dialogue, sitting in spots)
- Level-ups feel like moments — gentle UI, no chat spam

---

## What's Already Built (use this)
- ✅ `LevelLeaderstats` server with `LevelSave` DataStore
- ✅ `LevelUp` RemoteEvent + `Levelup` client notification
- ✅ `AreaDiscoveryBadge` — touches discovery zone parts to award badges (badges, not XP — extend this)
- ✅ `Workspace.InsideZones` — zone parts already exist for region detection
- ✅ `Workspace.SeatMarkers` — seat infrastructure for "sitting" presence rewards
- ✅ `TitleConfig` — already maps levels to titles (no new title work needed)

## What's Missing (build this)
- ❌ Centralized XP-grant service
- ❌ Presence tick loop
- ❌ Discovery → XP (currently only awards badges)
- ❌ Sitting → XP
- ❌ Soft cinematic level-up UI (replacing chat notification)

---

## Core Sources of XP (draft)
1. **Presence ticks** — slow drip while in-game (e.g. small XP every ~60s, only while not AFK)
2. **Discovery** — first-time entry into a new `InsideZone` part
3. **Conversation** — completing dialogue threads with NPCs
4. **Quiet moments** — sitting at `SeatMarkers` for sustained time

## Anti-Patterns to Avoid
- ❌ Big "+50 XP!" toast popups
- ❌ XP for kills / combat / item pickups
- ❌ Daily streak shame mechanics
- ❌ Grinding loops of any kind
- ❌ Chat-based level-up announcements (replace existing)

---

## Proposed Technical Structure

### New service
- **`ServerScriptService.Progression.ProgressionService`**
  - Single entry point for all XP grants
  - Owns the tick loop
  - Wraps `LevelLeaderstats` (calls into existing level/save logic, doesn't reinvent it)
  - All sources route through here — no other script should touch XP directly

### New XP source modules (one file per source)
- `ServerScriptService.Progression.Sources.PresenceTick`
- `ServerScriptService.Progression.Sources.Discovery` (extends `AreaDiscoveryBadge`)
- `ServerScriptService.Progression.Sources.Conversation` (hooks into `DialogueDirector`)
- `ServerScriptService.Progression.Sources.Sitting` (uses `SeatMarkers`)

### New client UI
- `StarterPlayerScripts.Progression.LevelUpController` — replaces `Levelup` chat notification with soft cinematic moment

### Config
- `ReplicatedStorage.Progression.LevelCurve` (XP-per-level table) — should match the level thresholds in [[Title_System]]
- `ReplicatedStorage.Progression.SourceConfig` (rates, cooldowns)

---

## Security / DataStore Notes
- ⚠️ All XP grants happen server-side. Client never sends "give me XP".
- ⚠️ Discovery validated via server-side region checks, not client claims.
- ⚠️ Presence tick gated on player activity (AFK detection — game already has `AFK` script, hook into it)
- ⚠️ Use `pcall` + retry on every DataStore call.
- ⚠️ Throttle saves — every meaningful change, not every tick.
- ⚠️ Reuse `LevelSave` DataStore (don't fork persistence)

---

## Open Questions
- Level cap? Title system tops out at level 100k. Suggest soft cap with diminishing returns past ~5000.
- Does conversation XP fire once per conversation, or per branch completed?
- How long must a player sit to count as "sitting"? (Suggestion: 30s minimum at one seat)
- Should presence tick pause during dialogue (avoid double-dipping)?

## Related
- [[Level_System]]
- [[Title_System]]
- [[Area_Discovery]]
- [[Dialogue_System]]
- [[NameTag_Status]]
- [[Group_Member_Perks]]
