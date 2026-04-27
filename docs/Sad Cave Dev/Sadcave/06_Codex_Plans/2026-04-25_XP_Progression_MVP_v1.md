# XP Progression MVP — Codex Plan

**Date:** 2026-04-25
**Status:** 🟢 Shipped — PR #1 (merged 2026-04-27 08:45 UTC, branch `codex/xp-progression-mvp`)
**Related Systems:** [[../02_Systems/XP_Progression]], [[../02_Systems/Level_System]], [[../02_Systems/Title_System]], [[../02_Systems/_Live_Systems_Reference]]
**Spec source of truth:** [[../02_Systems/XP_Progression]] — read this for design rationale before building. This plan is the build instruction; the spec is the why.

---

## 1. Purpose

Build the minimum viable version of the new XP Progression system. This delivers:

1. **`ProgressionService`** — server-side authority for XP and level. Single entry point (`GrantXP`) for all XP grants. Computes level from total XP via the curve formula. Handles save/load and migration from the legacy `LevelSave` / `TotalTimePlayedSave` / `RevisitsSave` DataStores.
2. **`PresenceTick` source** — three-state tick (sitting / active / AFK). Replaces the `+1 level/60s` behavior of `LevelLeaderstats`.
3. **`XPBar` UI** — bottom-of-screen ambient bar. Shows XP fill, plays a soft level-up animation, hover/tap reveals current numbers.

After this brief, the new XP system is live and the old `LevelLeaderstats` is retired. Players see a new XP bar; their level is preserved exactly via migration.

**Out of scope for this brief:**
- Discovery source (zones → XP)
- Conversation source (dialogue → XP)
- AchievementTracker
- TitleConfig v2 / TitleService v2 / TitleMenu v2
- Removing `CashLeaderstats` (still owns time-played counter; migration reads it)

These are follow-up briefs.

## 2. Player Experience

- On join: a thin warm-toned bar appears at the bottom of the screen, partially filled to reflect the player's current XP within their current level.
- The bar fills slowly as time passes — faster while sitting at a `SeatMarker`, slower while AFK.
- Hovering or tapping the bar reveals `level N — 234 / 500 xp` for 2 seconds, then fades.
- When the player levels up: bar fills to 100%, soft glow blooms along it, `level N` text fades in above for 2 seconds, bar resets to the new level's progress.
- No chat message on level up. No popup. No sound (or a single very soft tone — leave commented out for now).
- Existing players keep their exact current level — no progress lost.

## 3. Technical Structure

### Server responsibilities
- `ProgressionService` (ModuleScript): API for granting XP, level computation, save/load, migration
- `Progression` driver (Script): runs the 60-second tick loop, handles player join/leave, requires `ProgressionService` and `PresenceTick`
- `PresenceTick` (ModuleScript): pure logic — given a player, return XP amount based on state (sitting/active/AFK)

### Client responsibilities
- `XPBarController` (LocalScript): builds the UI programmatically, listens to `XPUpdated` and `LevelUp` remotes, animates the bar, handles hover/tap reveal

### Remote events / functions
**New (in `ReplicatedStorage.Progression`):**
- `XPUpdated` (RemoteEvent) — server → client. Payload: `{totalXP, level, xpForCurrentLevel, xpForNextLevel}`. Fired on every XP grant and on join.
- `LevelUp` (RemoteEvent) — server → client. Payload: `{newLevel}`. Fired when a player crosses a level threshold.

**Untouched:**
- `ReplicatedStorage.Remotes.LevelUp` — old remote, leave alone for now. Old `Levelup` client script will be retired in this brief, so nothing listens after this ships.

### DataStore keys touched
**New:**
- `ProgressionData` — single combined key per player. Stores:
  ```lua
  {
      totalXP = 0,                  -- integer
      discoveredZones = {},         -- list of zone IDs (empty in MVP — populated by Discovery source later)
      totalTimePlayed = 0,          -- seconds
      revisits = 0,                 -- session count
  }
  ```

**Read for migration only (never written):**
- `LevelSave` — old level data
- `TotalTimePlayedSave` — old time counter (from `CashLeaderstats`)
- `RevisitsSave` — old revisit counter (from `CashLeaderstats`)

**Untouched:**
- All other DataStores (`ShardsSave`, `EquippedTitleV1`, `DailyRewards_LastClaim_v1`, `NoteSystem`, etc.) are not read or written.

## 4. Files / Scripts

### New files

```
src/
├── ReplicatedStorage/
│   └── Progression/
│       ├── LevelCurve.lua              -- ModuleScript: GetLevel(xp), GetXPForLevel(level), GetXPForNextLevel(currentXP)
│       ├── SourceConfig.lua            -- ModuleScript: tunable XP amounts, curve constants, flag
│       ├── XPUpdated.meta.json         -- RemoteEvent
│       └── LevelUp.meta.json           -- RemoteEvent
├── ServerScriptService/
│   └── Progression/
│       ├── Driver.server.lua           -- Script: requires ProgressionService, starts tick loop, hooks Players events
│       ├── ProgressionService.lua      -- ModuleScript: GrantXP, save/load, migration, level computation
│       └── Sources/
│           └── PresenceTick.lua        -- ModuleScript: GetTickAmount(player) → number
└── StarterGui/
    └── XPBar/
        ├── init.meta.json              -- ScreenGui properties (ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=0)
        └── XPBarController.client.lua  -- LocalScript: builds UI programmatically, handles all client logic
```

> **Note on Rojo file conventions:** Codex picks the right `.meta.json` / `.model.json` / Lua file shape for instances based on existing repo conventions. For RemoteEvents in `ReplicatedStorage.Progression/`, follow whatever pattern the repo already uses (look at `ReplicatedStorage.Remotes` if any are already in `src/`, otherwise use `XPUpdated.meta.json` containing `{"className": "RemoteEvent"}`).

### Files modified
- `00_Inbox/_Inbox.md` — `[C]` captures during work (this is the only file Codex writes — plan files are read-only for Codex per `AGENTS.md`)

### Files to **disable** in Studio (disabled during the post-merge cutover, NOT during Codex's build)
- `ServerScriptService.LevelLeaderstats` — set `Disabled = true`. Don't delete; rollback safety.
- `StarterPlayerScripts.Levelup` — set `Disabled = true`. Don't delete; rollback safety.

## 5. Step-by-Step Implementation (for Codex)

### Phase 0 — Setup

1. Read [[../02_Systems/XP_Progression]] in full. The pacing table, curve formula, and three-state tick logic are all there.
2. Read [[../02_Systems/_Live_Systems_Reference]] for the relevant section: `Level Progression` and the `AFK` / `OverheadTagsToggleServer` / `Theme` notes for context on what's already live.
3. Check the repo for existing Rojo conventions on RemoteEvent files (search `*.meta.json` containing `RemoteEvent`).
4. Create branch `codex/xp-progression-mvp` from current main (per `AGENTS.md` Git Workflow — branch name must include the `codex/` prefix).
5. `[C]` log: `[C] HH:MM — Starting XP Progression MVP. Phase 0 setup complete.`

### Phase 1 — Shared foundation (`ReplicatedStorage.Progression`)

7. Create `src/ReplicatedStorage/Progression/` folder.

8. **`SourceConfig.lua`** (ModuleScript). Contents:

```lua
-- Tunable constants for the XP Progression system.
-- All values can be adjusted without touching service logic.

local SourceConfig = {}

-- Master enable flag. Set to false to keep ProgressionService dormant.
-- Used during the cutover from LevelLeaderstats so the new system can
-- be deployed inert and switched on after verification.
SourceConfig.ENABLED = false

-- Level curve constants: XP per level N = floor(A + B * N^C)
SourceConfig.CURVE_A = 45
SourceConfig.CURVE_B = 0.55
SourceConfig.CURVE_C = 1.15

-- Presence tick amounts (per 60-second tick)
SourceConfig.PRESENCE_SITTING_XP = 20
SourceConfig.PRESENCE_ACTIVE_XP = 15
SourceConfig.PRESENCE_AFK_XP = 3

-- Sitting threshold: how long a player must be seated at a SeatMarker
-- before the boosted (sitting) tick rate kicks in.
SourceConfig.SITTING_THRESHOLD_SECONDS = 30

-- Tick interval
SourceConfig.TICK_INTERVAL_SECONDS = 60

-- Gamepass multiplier (applied to all XP grants)
SourceConfig.GAMEPASS_ID = 2110249546
SourceConfig.GAMEPASS_MULTIPLIER = 1.5

-- DataStore name
SourceConfig.PROGRESSION_DATASTORE_NAME = "ProgressionData"
SourceConfig.PROGRESSION_DATASTORE_VERSION = "v1"

-- Legacy DataStore names (read-only for migration)
SourceConfig.LEGACY_LEVEL_DATASTORE_NAME = "LevelSave"
SourceConfig.LEGACY_TIME_DATASTORE_NAME = "TotalTimePlayedSave"
SourceConfig.LEGACY_REVISITS_DATASTORE_NAME = "RevisitsSave"

return SourceConfig
```

9. **`LevelCurve.lua`** (ModuleScript). Pure functions, no state. Contents:

```lua
local SourceConfig = require(script.Parent.SourceConfig)

local LevelCurve = {}

-- XP required for a single level N (not cumulative).
function LevelCurve.GetXPForLevelDelta(level)
    if level < 1 then return 0 end
    return math.floor(SourceConfig.CURVE_A + SourceConfig.CURVE_B * (level ^ SourceConfig.CURVE_C))
end

-- Cumulative XP required to *reach* level N (i.e. XP to go from 0 to level N).
-- Caches results for speed.
local cumulativeCache = {}
function LevelCurve.GetXPForLevel(level)
    if level < 1 then return 0 end
    if cumulativeCache[level] then return cumulativeCache[level] end

    local total = 0
    -- Build cache progressively. If we have cache for level-1, use it.
    local startLevel = 1
    local startTotal = 0
    if cumulativeCache[level - 1] then
        startLevel = level
        startTotal = cumulativeCache[level - 1]
    end

    total = startTotal
    for n = startLevel, level do
        total = total + LevelCurve.GetXPForLevelDelta(n)
        cumulativeCache[n] = total
    end

    return total
end

-- Given a total XP value, return the player's current level.
-- Level is the highest N where GetXPForLevel(N) <= totalXP.
function LevelCurve.GetLevel(totalXP)
    if totalXP < 0 then return 0 end
    -- Walk forward from 1 until cumulative requirement exceeds totalXP.
    -- Level 0 means "haven't reached level 1 yet" (totalXP < 45).
    local level = 0
    while LevelCurve.GetXPForLevel(level + 1) <= totalXP do
        level = level + 1
        if level > 50000 then break end -- safety cap, real curve goes much higher
    end
    return level
end

-- Given a total XP value, return the XP within the current level (for bar fill calculation).
-- Returns: currentXPInLevel, xpRequiredForNextLevel
function LevelCurve.GetLevelProgress(totalXP)
    local level = LevelCurve.GetLevel(totalXP)
    local xpAtCurrentLevel = LevelCurve.GetXPForLevel(level)
    local xpAtNextLevel = LevelCurve.GetXPForLevel(level + 1)
    local currentInLevel = totalXP - xpAtCurrentLevel
    local requiredForNext = xpAtNextLevel - xpAtCurrentLevel
    return level, currentInLevel, requiredForNext
end

return LevelCurve
```

10. **`XPUpdated.meta.json`** — RemoteEvent. **`LevelUp.meta.json`** — RemoteEvent. Use whatever Rojo convention the repo already uses for RemoteEvents.

11. `[C]` log: `[C] HH:MM — Phase 1 complete: ReplicatedStorage.Progression with LevelCurve, SourceConfig, XPUpdated, LevelUp.`

### Phase 2 — `ProgressionService.lua`

12. Create `src/ServerScriptService/Progression/ProgressionService.lua` (ModuleScript). Responsibilities:
    - Per-player in-memory state: `{totalXP, discoveredZones, totalTimePlayed, revisits, gamepassOwned, lastSeatedAt, seatPart}`
    - Load on join: read `ProgressionData` DataStore → if nil, run migration
    - Save on leave (and on level-up, on discovery — for MVP, just on leave and level-up)
    - `GrantXP(player, amount, source)` — apply gamepass multiplier, increment totalXP, check for level-up, fire remotes
    - `GetState(player)` — return the in-memory state for other modules to read
    - `RegisterSittingState(player, seatPart, timestamp)` and `ClearSittingState(player)` — tracked here so PresenceTick can read it without re-doing work each tick
    - `RegisterAFKState(player, isAFK)` — same pattern
    - `Tick(player)` — called by Driver every 60s, computes which state the player is in (AFK > Sitting > Active priority), grabs XP from PresenceTick, calls `GrantXP`. Also increments `totalTimePlayed` regardless of state.

13. **Critical implementation rules:**
    - All DataStore calls wrapped in `pcall` with at least one retry.
    - Save throttle: do NOT save on every tick. Save on level-up and on player leave only (in MVP).
    - Gamepass check: call `MarketplaceService:UserOwnsGamePassAsync` once on join, cache the boolean in player state. Wrap in `pcall` (this can throw on network failure).
    - Migration logic (only if `ProgressionData` is nil for this user):
      a. Read `LevelSave`. If a value exists, compute `seedXP = LevelCurve.GetXPForLevel(oldLevel)`.
      b. Read `TotalTimePlayedSave`. Use as `totalTimePlayed`. Default 0.
      c. Read `RevisitsSave`. Use as `revisits`. Default 0.
      d. `discoveredZones` starts as empty table.
      e. Save the combined `ProgressionData` immediately so subsequent joins use the new key.
    - On EVERY join (migration or not): increment `revisits` by 1, save.
    - When `SourceConfig.ENABLED` is false: ProgressionService should still load data on join (for verification purposes) but NOT run the tick loop and NOT fire remotes. The driver checks the flag before running ticks.

14. **Leaderstats integration:**
    - On player join (after data loaded), create or update `player.leaderstats` (Folder).
    - Inside leaderstats, create `Level` (IntValue) and `XP` (IntValue). Set both from loaded state.
    - Update both values on every `GrantXP` call.
    - Note: `LevelLeaderstats` ALSO creates a `Level` IntValue. Do not race it. While `SourceConfig.ENABLED` is false, ProgressionService skips creating the `Level` value (LevelLeaderstats owns it). When ENABLED is flipped to true (Phase 3 cutover), LevelLeaderstats gets disabled in the same step.
    - **Implementation detail:** check if `player.leaderstats.Level` already exists. If yes (LevelLeaderstats made it), reuse it. If no, create it. This avoids duplicate Value instances.

15. `[C]` log: `[C] HH:MM — Phase 2 complete: ProgressionService.lua written.`

### Phase 3 — `PresenceTick.lua`

16. Create `src/ServerScriptService/Progression/Sources/PresenceTick.lua` (ModuleScript). It exposes one function:

    ```lua
    -- Returns the XP amount to grant for this tick based on the player's state.
    -- Reads state from ProgressionService (passed in to avoid circular require).
    function PresenceTick.GetTickAmount(player, state, sourceConfig)
        -- state contains: isAFK, seatedAt (timestamp or nil), seatPart, lastSeatedAt
        if state.isAFK then
            return sourceConfig.PRESENCE_AFK_XP, "afk"
        end

        -- Check sitting: must be currently seated AND have been seated 30+ seconds
        if state.seatedAt then
            local elapsed = os.time() - state.seatedAt
            if elapsed >= sourceConfig.SITTING_THRESHOLD_SECONDS then
                return sourceConfig.PRESENCE_SITTING_XP, "sitting"
            end
        end

        return sourceConfig.PRESENCE_ACTIVE_XP, "active"
    end
    ```

17. `[C]` log: `[C] HH:MM — Phase 3 complete: PresenceTick.lua written.`

### Phase 4 — `Driver.server.lua`

18. Create `src/ServerScriptService/Progression/Driver.server.lua` (Script). Responsibilities:

    a. Require `ProgressionService` and `PresenceTick`.
    b. Read `SourceConfig.ENABLED`. If false, **still hook player events for data load/save** (so deploying with flag off doesn't lose data when flipped on later), but **skip the tick loop and skip firing remotes** until enabled. This way the system can be deployed inert.
    c. On `Players.PlayerAdded`:
       - Call `ProgressionService.LoadPlayer(player)` — this handles migration if needed.
       - Hook the player's character: `player.CharacterAdded:Connect(...)` — when character spawns, hook `Humanoid.Seated:Connect((isSeated, seatPart) -> ...)`.
         - When `isSeated` becomes true: check if `seatPart.Parent` is a child of `Workspace.SeatMarkers`. If yes, call `ProgressionService.RegisterSittingState(player, seatPart, os.time())`. If no, ensure cleared.
         - When `isSeated` becomes false: call `ProgressionService.ClearSittingState(player)`.
       - Hook `ReplicatedStorage.AfkEvent.OnServerEvent:Connect((p, isAfk) -> ProgressionService.RegisterAFKState(p, isAfk))`. **Important:** verify this is the right way to read AFK state — see Open Questions below. If `AfkEvent` requires a different listening pattern, follow what the existing `ServerScriptService.AFK` script does and mirror it. `[C] ?` flag if unclear.
       - If `SourceConfig.ENABLED`, fire `XPUpdated` to the client with the loaded state.
    d. On `Players.PlayerRemoving`: call `ProgressionService.SavePlayer(player)`. Clear in-memory state.
    e. **The tick loop:** if `SourceConfig.ENABLED`, every `TICK_INTERVAL_SECONDS` (60s), iterate all current players, call `ProgressionService.Tick(player)`. Use `task.wait` in a loop, NOT `RunService.Heartbeat` (this is a slow tick, not a per-frame thing).
    f. `game:BindToClose(...)` — on shutdown, save all players. Use `task.spawn` to save in parallel, but `task.wait` for them all to complete before returning. DataStore writes during shutdown have a deadline — keep it under 25 seconds total.

19. `[C]` log: `[C] HH:MM — Phase 4 complete: Driver.server.lua written.`

### Phase 5 — `XPBar` UI client

20. Create `src/StarterGui/XPBar/init.meta.json` — ScreenGui properties:
    ```json
    {
        "properties": {
            "ResetOnSpawn": false,
            "IgnoreGuiInset": true,
            "DisplayOrder": 0,
            "ZIndexBehavior": "Sibling"
        }
    }
    ```

21. Create `src/StarterGui/XPBar/XPBarController.client.lua` (LocalScript). Build UI programmatically — fewer files, simpler. Responsibilities:

    a. **Detect mobile:** `local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled`. Set bar height: 6px on mobile, 4px otherwise.
    b. **Build UI programmatically:**
       - `Background` (Frame): `AnchorPoint = Vector2.new(0, 1)`, `Position = UDim2.new(0, 0, 1, 0)`, `Size = UDim2.new(1, 0, 0, height)`, `BackgroundColor3 = Color3.fromRGB(15, 15, 15)`, `BackgroundTransparency = 0.85`, `BorderSizePixel = 0`.
       - `Fill` (Frame, child of Background): `AnchorPoint = Vector2.new(0, 0.5)`, `Position = UDim2.new(0, 0, 0.5, 0)`, `Size = UDim2.new(0, 0, 1, 0)` (will tween width), `BackgroundColor3 = Color3.fromRGB(225, 200, 160)` (warm tone), `BackgroundTransparency = 0.6`, `BorderSizePixel = 0`.
       - `LevelLabel` (TextLabel, child of ScreenGui): centered above bar, `AnchorPoint = Vector2.new(0.5, 1)`, `Position = UDim2.new(0.5, 0, 1, -16)`, `Size = UDim2.new(0, 200, 0, 20)`, `BackgroundTransparency = 1`, `Font = Enum.Font.Gotham`, `TextSize = 14`, `TextColor3 = Color3.fromRGB(225, 215, 200)`, `TextTransparency = 1`, `Text = ""`.
       - `HoverDetector` (TextButton, child of ScreenGui): invisible, sized to cover bar + a small padding above for easier tapping. `BackgroundTransparency = 1`, `Text = ""`, `Size = UDim2.new(1, 0, 0, height + 12)`, `Position = UDim2.new(0, 0, 1, -(height + 12))`, `AnchorPoint = Vector2.new(0, 1)`.
    c. **Listen to remotes:**
       - `Progression.XPUpdated.OnClientEvent:Connect(function(payload) ... end)` — payload has `totalXP`, `level`, `xpForCurrentLevel`, `xpForNextLevel`. Tween Fill's width to the new fraction. Cache the values for hover display.
       - `Progression.LevelUp.OnClientEvent:Connect(function(newLevel) ... end)` — play level-up animation: Fill tweens to 100%, Fill briefly bumps height (4→8 desktop, 6→10 mobile), LevelLabel fades in with text `"level " .. newLevel`, holds 2 seconds, fades out. Then reset Fill to the new level's progress (use cached values from next XPUpdated, which fires immediately after LevelUp).
    d. **Hover/tap reveal:**
       - On `HoverDetector.MouseEnter` or `.Activated`: fade in LevelLabel with text `"level " .. cachedLevel .. " — " .. cachedXPInLevel .. " / " .. cachedXPRequired .. " xp"`. Hold 2s. Fade out. Cancel if user re-hovers (extend the hold).
    e. **Animations:** all `TweenService` with `Enum.EasingStyle.Sine`, `Enum.EasingDirection.Out`. No bounce. Fill width tween: 0.6s. Glow bump: 0.3s up, 0.5s down. Label fade: 0.4s in, 0.6s out, 2s hold.
    f. **Title unlock notification hook (placeholder for follow-up brief):** add a comment `-- TODO: Listen to TitleRemotes.TitleDataUpdated for new-title fades when TitleService v2 ships.` Don't implement; that's a different brief.
    g. Wait for `ReplicatedStorage.Progression.XPUpdated` etc. with `WaitForChild` (the folder won't exist client-side until server creates it, which is on require — but in Rojo it's already in the tree, so `WaitForChild(5)` is enough).

22. `[C]` log: `[C] HH:MM — Phase 5 complete: XPBar UI written.`

### Phase 6 — Studio test (with feature flag ON)

> **This phase happens in a Studio playtest, not in the live game.** The flag stays at `false` in the committed code. Codex flips it locally for testing only.

23. Sync the branch to a Studio test session via Rojo.
24. **Disable `LevelLeaderstats` for the test:** in Studio, set `ServerScriptService.LevelLeaderstats.Disabled = true`. This is a Studio-only change for the test — do NOT save the place. Same for `StarterPlayerScripts.Levelup`.
25. Temporarily edit `SourceConfig.lua` locally (don't commit): set `SourceConfig.ENABLED = true`.
26. Run the Studio Test Checklist (Section 9 below). Capture results in inbox per test.
27. **If any test fails:** `[C] ?` flag in inbox, fix in code, re-run. Don't proceed to push (Phase 7) until all tests green.
28. After all tests pass: revert the local `SourceConfig.ENABLED` change (commit goes out with `false`). Re-enable `LevelLeaderstats.Disabled = false` and `Levelup.Disabled = false` in Studio (don't save).
29. `[C]` log: `[C] HH:MM — Phase 6 complete: all Studio tests passed. Code committed with ENABLED=false.`

### Phase 7 — Push and hand off for review

> **Only run this phase if Phase 6 passed clean. If anything is uncertain, STOP with a `[C] ?` flag and hand back unshipped — let Opus / the user review.**

30. Commit any final changes on the branch with a plain descriptive message, e.g.: `XP Progression MVP: ProgressionService, PresenceTick, XPBar (flag off)`.
31. Push the branch: `git push -u origin codex/xp-progression-mvp`.
32. Tell the user the branch is pushed and ready for Opus review. State clearly:
    - What was built (ProgressionService, PresenceTick, XPBar)
    - What Studio tests passed in Phase 6
    - Any `[C] ?` flags raised during the build
    - That `SourceConfig.ENABLED` is committed as `false`, so the system is inert in any environment until manually flipped on
33. **Stop here.** Do NOT merge to `main`. Do NOT touch any place (testing or production). The cutover is a post-merge step driven by the user and Opus together — see "Post-merge cutover" section below. It is not part of Codex's scope.
34. Final inbox capture summarizing what shipped: `[C] HH:MM — XP Progression MVP branch pushed and ready for Opus review. Built: <list>. Tested in Studio: <list>. Flagged: <list>.`

---

## Post-merge cutover (user + Opus, NOT Codex's job)

> This section is **not for Codex**. It documents what the user and Opus do together AFTER Codex has finished (Phase 7 step 34), AFTER Opus reviews the pushed branch, AFTER the user merges to `main`. Codex's responsibility ends at the push.

**Where this happens:** In the **testing place**, not production. The testing place has real player data on it (the user's own old level, time-played, revisits), which is exactly what we need to verify migration on real values. After the testing place validates clean, the production cutover is a separate later runbook.

**Steps (user drives, Opus walks through it in chat):**

1. Open the testing place in Roblox Studio.
2. Sync the merged `main` branch via Rojo (the new files appear in `ServerScriptService.Progression`, `ReplicatedStorage.Progression`, `StarterGui.XPBar`).
3. In the testing place:
    - Set `ServerScriptService.LevelLeaderstats.Disabled = true`.
    - Set `StarterPlayerScripts.Levelup.Disabled = true`.
    - Open the live `SourceConfig` ModuleScript and set `ENABLED = true`. (The repo file stays `false` — the live edit is the runtime switch. Future syncs won't accidentally re-enable a broken state, and rollback is just flipping that one value back.)
    - Save the place.
4. Publish to the testing place (NOT production).
5. Join the testing place. Verify with Opus:
    - XP bar appears at the bottom of the screen.
    - The user's level matches what it was under the old system (this validates migration against real data).
    - Bar fills with active rate (~15 XP/min) when walking around.
    - Sitting at a `SeatMarker` for 30+ seconds boosts the rate (~20 XP/min).
    - Going AFK drops the rate to ~3 XP/min.
    - Level-up animation plays cleanly when crossing a threshold (Opus can provide a server console snippet to bump XP to just below a threshold if natural play hasn't hit one yet).
    - No chat notifications from the old `Levelup` script.

**Rollback in the testing place (if anything looks wrong):**

1. Set `SourceConfig.ENABLED = false` on the live ModuleScript.
2. Set `LevelLeaderstats.Disabled = false`.
3. Set `Levelup.Disabled = false`.
4. Save and publish.

The old system is back online. Legacy `LevelSave` is never overwritten by the new system, so no progress is lost — re-enabling later picks up where it left off.

**After testing-place validation passes:** Opus appends a `_Change_Log.md` entry and the brief is considered shipped from this session's perspective. The production cutover is a separate runbook on a separate day, walked through the same way on the live place when the user is ready.

---

## 6. Roblox Services Involved

`Players`, `ReplicatedStorage`, `ServerScriptService`, `StarterGui`, `StarterPlayer`, `DataStoreService`, `MarketplaceService`, `RunService`, `TweenService`, `UserInputService`, `Workspace` (read-only — `SeatMarkers`).

## 7. Security / DataStore Notes

- ⚠️ **Validation:** No client-side XP grant remotes. The only client → server signal in this MVP is the existing `AfkEvent` (which the AFK system owns — don't change it). Discovery, conversation, sitting are all server-detected.
- ⚠️ **DataStore retry/pcall:** every `GetAsync` and `SetAsync` call wrapped in `pcall`. On failure: log to output, keep the player's in-memory data so they can keep playing, retry on next save. Don't kick the player.
- ⚠️ **Save throttle:** save on level-up and on player leave only (in MVP). Not every tick. Roblox's DataStore write rate limit is roughly 1 per 6 seconds per key per server — easily exceeded if we saved every tick on a 30-player server.
- ⚠️ **Migration safety:** migration only triggers if `ProgressionData` is nil. Once written, it's the source of truth. Legacy keys are never written. If migration partially fails (e.g. `LevelSave` is unreachable), default to 0 XP — better than blocking the player. Log the failure.
- ⚠️ **Gamepass check:** `MarketplaceService:UserOwnsGamePassAsync` can throw and is rate-limited. Wrap in `pcall`, default to `false` on failure, retry once after 5 seconds.
- ⚠️ **Shutdown safety:** `BindToClose` saves all players in parallel via `task.spawn`. Do NOT do them sequentially — Roblox gives ~30 seconds before forcibly killing the server.
- ⚠️ **Race condition:** if a player joins, gets their ProgressionData loaded, and disconnects in under 1 second, `BindToClose` might fire before save completes. Handle the `PlayerRemoving` save before `BindToClose` rather than relying only on shutdown.

## 8. Boundaries (do NOT touch)

Per `AGENTS.md`:

- **Do not modify `LevelLeaderstats` script contents.** The only modification ever made to it is setting `Disabled = true` during the post-merge cutover (or temporarily during the Phase 6 Studio test).
- **Do not modify `CashLeaderstats`.** It still owns `Shards`, `TimePlayed`, `TotalTimePlayed`, `Revisits`. ProgressionService READS from `TotalTimePlayedSave` and `RevisitsSave` for migration only — it does not WRITE to those keys, and does not edit the `CashLeaderstats` script. `CashLeaderstats` will continue to manage its own counters in parallel; that's fine. Cleanup is a follow-up brief.
- **Do not modify `TitleService`, `TitleConfig`, or `NameTagScript Owner`.** Title v2 is a separate brief.
- **Do not modify the `AFK` script** or `AfkEvent`. Read state from it; don't mutate it.
- **Do not touch DataStores not listed in Section 3.** This includes `EquippedTitleV1`, `ShardsSave`, `DailyRewards_LastClaim_v1`, `NoteSystem`, `bans`, `ShopInventory_v1`, etc.
- **Do not touch any UI other than the new `XPBar`.** Existing UIs (TitleMenu, ShopMenu, NoteUI, settingui, etc.) are off-limits.
- **Do not refactor existing scripts.** If you see ugly code, leave it alone.

## 9. Studio Test Checklist (Phase 6)

> All tests run with `SourceConfig.ENABLED = true` locally and `LevelLeaderstats` / `Levelup` disabled in Studio.

### Data & migration

- [ ] On first join with no `ProgressionData` and no legacy data: starts at 0 XP, level 0. `revisits = 1`.
- [ ] On first join with no `ProgressionData` but legacy `LevelSave = 50`: migration runs, `totalXP` seeded to `LevelCurve.GetXPForLevel(50)` = 3,402, `level` reads as 50.
- [ ] On second join (same player): `ProgressionData` loads as-is (no re-migration), `revisits` increments.
- [ ] Player leaves and rejoins: `totalXP` persists exactly.
- [ ] Server shutdown (Stop button in Studio): all players' data saves before the server actually closes.

### Tick loop

- [ ] Active player (walking around): `XPUpdated` fires every 60s with `totalXP` incremented by 15.
- [ ] AFK player (window unfocused): tick fires with +3 instead of +15.
- [ ] Sitting on a `SeatMarker` for 30+ seconds: tick fires with +20.
- [ ] Sitting on a non-`SeatMarker` seat: tick fires with +15 (active rate).
- [ ] Sitting <30s then standing up: never gets the +20 boost (resets).
- [ ] Sitting state cleared on character death/respawn.

### Level-up

- [ ] Cross a level threshold: `LevelUp` remote fires, then `XPUpdated` fires.
- [ ] `player.leaderstats.Level` increments to match.
- [ ] DataStore saves on level-up (verify by killing the server immediately after — data should persist).

### Gamepass

- [ ] Player without gamepass: 15 XP per active tick.
- [ ] Player with gamepass `2110249546`: 22 XP per active tick (15 × 1.5 = 22.5, floored to 22).
- [ ] Verify: gamepass check happens once on join, not every tick (look for `UserOwnsGamePassAsync` in output — should appear once per player).

### XP Bar UI

- [ ] Bar appears at bottom of screen on join.
- [ ] Bar height: 4px desktop, 6px mobile (verify on a phone or with mobile emulation).
- [ ] Bar fill matches `(currentXPInLevel / xpRequiredForNextLevel)`.
- [ ] Hover/tap shows `level N — X / Y xp` for 2 seconds, then fades.
- [ ] Level-up animation: fill goes to 100%, glow bump, `level N` text fades in for 2s, bar resets.
- [ ] No chat message on level-up.
- [ ] No `Levelup` script firing the old chat notification (it's disabled).

### Boundaries

- [ ] `LevelLeaderstats` script is disabled — does not interfere.
- [ ] `Levelup` client script is disabled — no chat notifications.
- [ ] Existing UIs (TitleMenu, ShopMenu, NoteUI, etc.) are unchanged.
- [ ] `CashLeaderstats` still creates and increments `Shards`, `TimePlayed`, etc. — nothing broken.
- [ ] `TitleService` still works as before — equipped titles still appear on nametags.

### Failure modes

- [ ] DataStore unavailable at join (simulate by disabling `DataStoreService.SetIsBudgetUnlocked` or just throw): player still joins, plays at 0 XP, no crashes.
- [ ] Gamepass check fails: player gets 1.0x multiplier (no boost), no crash.
- [ ] Player disconnects during a tick: no error spam, save fires on `PlayerRemoving`.

## 10. Rollback Notes

### If the post-merge cutover causes problems

**Quick rollback (in the testing place where cutover happened):**
1. Set `SourceConfig.ENABLED = false` on the live ModuleScript.
2. Set `LevelLeaderstats.Disabled = false`.
3. Set `Levelup.Disabled = false`.
4. Save and publish.

The old system is back online instantly. `ProgressionData` keeps any XP earned during the broken window — players don't lose progress when we re-enable later.

### If migration is producing wrong levels

ProgressionData is keyed per user. If a specific player has bad data, can manually reset their key via Roblox's DataStore admin tools (or write a one-off admin command — not part of MVP).

### If the issue is in code

`git revert` the merge commit, push, re-sync via Rojo. Then perform the rollback steps above.

### Worst case

Both `LevelSave` and `ProgressionData` are still in the DataStore. The legacy data is never overwritten — it's only read for migration. So even if `ProgressionData` is corrupt, the old `LevelSave` values are intact and the old system can be re-enabled to work off them.

## Open Questions (for Codex to resolve or flag)

- **AFK detection mechanism:** the live `AFK` script fires `ReplicatedStorage.AfkEvent` from the client (`AFKLS` LocalScript fires it on focus loss/gain). Does the server-side `AFK` script set a player attribute or value, or does it only update the nametag? If only the nametag, ProgressionService's listener on `AfkEvent.OnServerEvent` is the right hook. **Codex: read the live `AFK` script first, confirm the mechanism, mirror it. `[C] ?` flag if it's not clear.**
- **Existing `player.leaderstats.Level`:** when ProgressionService runs alongside `LevelLeaderstats` (briefly, during cutover), both would try to manage the `Level` IntValue. Specified the "reuse if exists" pattern in step 14, but verify in Phase 6 testing that this doesn't cause flicker or stale values during the few seconds of overlap. **Codex: if it does flicker, `[C] ?` flag for a tighter cutover sequence.**
- **Rojo conventions for empty RemoteEvents:** the repo may use `*.meta.json` with `{"className": "RemoteEvent"}`, OR `*.model.json`, OR a parent folder with `init.meta.json`. **Codex: pick whatever pattern already exists in the repo. If no precedent, use `XPUpdated.meta.json` with `{"className": "RemoteEvent"}`.**
