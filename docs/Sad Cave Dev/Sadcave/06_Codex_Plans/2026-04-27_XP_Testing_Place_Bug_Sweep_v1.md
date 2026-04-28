# XP Testing-Place Bug Sweep — Codex Plan

**Date:** 2026-04-27
**Status:** 🔵 Queued
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/xp-testing-bug-sweep`
**Related Systems:** [[../02_Systems/XP_Progression]]
**Driving notes:** [[../09_Open_Questions/_Known_Bugs]] entries "XPBar invisible to player despite GUI hierarchy reporting it as rendered" and "XP system grants AFK rate (3) while player is physically seated at a SeatMarker"; inbox 2026-04-27 (Cowork session 5).

---

## 1. Purpose

Three findings from the 2026-04-27 testing-place walkthrough need investigation and fixes before the rest of the XP testing-place checks (level-up animation, gamepass +22 tick, mobile bar height, second-join migration variants, DataStore failure simulation) can be exercised meaningfully:

1. **XPBar invisible.** Tyler can't see the XPBar in Play even though the GUI hierarchy reports it `Enabled=true` with `Background.Visible=true` and `Fill.Size.X.Scale=0.786`. Need to ground-truth what's actually on screen and either fix what's covering it, fix what's broken in the controller, or surface that the visual is too subtle and bump it.
2. **AFK rate fires while seated at a SeatMarker.** Server returns `PRESENCE_AFK_XP=3` even though `Humanoid.Sit=true` and `SeatPart=Workspace.SeatMarkers.Seat`. Root cause: `PresenceTick.GetTickAmount` checks `state.isAFK` first and ignores `state.seatedAt`. Tyler's call on what to do: prefer-seated-over-AFK (Branch A), tighten AFK detection (Branch B), or leave as-is (Branch C). Codex implements whichever Tyler picks — investigate, do not pick a branch.
3. **Console output silent during ticks.** `Driver.server.lua`, `ProgressionService`, and `PresenceTick` don't print per tick — only `warn()` on failure paths. Makes the system invisible during walkthroughs. Add a small debug log on each `Tick()` call.

This is an investigation-first brief: prong 1 needs Codex to playtest and capture a screenshot; prong 2 needs Codex to confirm the diagnosis and stop for a Tyler design call before implementing anything; prong 3 is a small, safe additive change.

## 2. Player Experience

After the brief lands:
- The XPBar is visibly rendering at the bottom of the screen during Play. Tyler should be able to point to it and see fill progress live.
- Whatever Tyler picked for the AFK-vs-sitting decision is reflected in the build. If Branch A: a player seated on a SeatMarker continues earning sitting-rate XP even while their Roblox window doesn't have focus. If Branch B: AFK detection no longer fires from a single window-focus blip. If Branch C: design intent is documented in `XP_Progression` spec and `_Decisions.md`, no code change.
- During Play, the console emits one line per tick like `[Progression] tick: source=sitting amount=20 player=vesbus(1132193781)`. Tyler can watch live without an MCP probe.

## 3. Technical Structure

- **Server responsibilities (prong 2 — only if Tyler picks Branch A or B):** `ProgressionService` / `PresenceTick.GetTickAmount` decides whether sitting overrides AFK. **Server responsibilities (prong 3):** `Driver.server.lua` (or `ProgressionService.Tick`) emits a `print()` on each tick with source + amount + player.
- **Client responsibilities (prong 1):** `XPBarController.client.lua` may need diagnosis. Don't change visual style without flagging in inbox first — this is presence-tone-sensitive.
- **Client responsibilities (prong 2 — only if Tyler picks Branch B):** `AfkDetector.client.lua` may need to gate on idle time in addition to focus loss.
- **Remote events / functions:** none changed. `XPUpdated`, `LevelUp`, `AfkEvent` all keep their current contracts.
- **DataStore keys touched:** none.

## 4. Files / Scripts

Read first (no edits):
- `src/StarterGui/XPBar/XPBarController.client.lua`
- `src/ServerScriptService/Progression/Driver.server.lua`
- `src/ServerScriptService/Progression/ProgressionService.lua`
- `src/ServerScriptService/Progression/Sources/PresenceTick.lua`
- `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua`
- `src/ReplicatedStorage/Progression/SourceConfig.lua`

Modify (depending on Tyler's design call + diagnosis):
- **Prong 3 (always):** `src/ServerScriptService/Progression/ProgressionService.lua` — add `print` line at the top of `ProgressionService.Tick`, OR `src/ServerScriptService/Progression/Driver.server.lua` — add `print` after `ProgressionService.Tick(player, PresenceTick)` returns. Codex picks whichever is cleaner.
- **Prong 1 (depending on diagnosis):** likely `src/StarterGui/XPBar/XPBarController.client.lua` (if a render bug is found) and/or `src/StarterGui/Menu/...` if a Menu ScreenGui overlap is the cause. Capture finding in inbox before editing.
- **Prong 2 (only after Tyler picks):**
  - Branch A: `src/ServerScriptService/Progression/Sources/PresenceTick.lua` — reorder the conditional so `state.seatedAt` (with elapsed ≥ threshold) takes priority over `state.isAFK`.
  - Branch B: `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua` — add an idle-time gate (e.g. only fire AFK if `WindowFocusReleased` AND `UserInputService.LastInputTime` shows no input for N seconds).
  - Branch C: no code change; update `02_Systems/XP_Progression.md` to document the AFK-overrides-sitting design intent and add a Decision entry in `_Decisions.md`.

## 5. Step-by-Step Implementation (for Codex)

Branch from clean main: `git checkout main && git pull && git checkout -b codex/xp-testing-bug-sweep`.

### Phase 0 — Read

1. Read every file listed in section 4 ("Read first"). Take notes.
2. Read [[../02_Systems/XP_Progression]] for the spec — what was supposed to ship.
3. Read the two `_Known_Bugs.md` entries this brief addresses for the symptom evidence.

### Phase 1 — Investigate XPBar invisibility (prong 1)

1. Start a Studio playtest in `Testing cave`. Spawn into the world.
2. Take a screenshot of the bottom of the screen via Studio MCP `screen_capture` (note: per the tool description it's edit-time only — capture from edit mode after stopping Play if needed; or use OS screenshot if you have access).
3. Probe `Players.LocalPlayer.PlayerGui.XPBar` and its descendants via `inspect_instance` / `execute_luau`. Cross-check against what the screenshot actually shows.
4. If the bar is rendering but not where Tyler expects, identify why (off-screen position, covered by another GUI, transparent style too subtle, etc.).
5. Capture finding in inbox with `[C]` line and a `?` if the fix isn't obvious.
6. **Stop and flag** if the fix is anything beyond a small bugfix — visual style changes need a Tyler call first. Examples that need flagging: bumping `Background.BackgroundTransparency` below 0.85, increasing `barHeight`, recoloring the bar.
7. If the fix is purely "the bar is being covered by `Menu` ScreenGui because Menu has wrong z-index / wrong size / a fullscreen child," fix it on the Menu side and note in inbox.
8. If the fix is "the controller errored mid-run leaving the bar in a degenerate state," fix the error in `XPBarController.client.lua` and note in inbox.

### Phase 2 — Confirm AFK-overrides-sitting diagnosis (prong 2)

1. In a fresh Play, sit on `Workspace.SeatMarkers.Seat` for 35 seconds (clears the 30s threshold). Confirm via `execute_luau` that `Humanoid.Sit=true` and `SeatPart=Workspace.SeatMarkers.Seat`.
2. Tab away from the Roblox window for the next 60-second tick. Capture the XP delta in inbox.
3. Confirm via probe that the server saw `state.isAFK=true` (this needs server-side `print` from prong 3 OR a temporary `warn()` you remove before pushing — note in inbox if you add a temporary probe).
4. Verify `PresenceTick.GetTickAmount` reads the way the diagnosis says — check `state.isAFK` first, return AFK rate, never reach the seated branch.
5. **Stop. Do not implement a fix yet.** Add an `[C] ?` inbox line summarizing the confirmed diagnosis and asking Tyler to pick Branch A / B / C. Wait for the design call.
6. Once Tyler picks, implement the corresponding branch (see section 4 for which file). For Branch A, the change is roughly: in `PresenceTick.GetTickAmount`, check `state.seatedAt` first (with elapsed ≥ threshold), and only fall through to AFK if not seated. Make sure both states still read correctly in tests.

### Phase 3 — Add per-tick debug logging (prong 3)

1. In `ProgressionService.Tick` (right after `local amount, sourceName = presenceTick.GetTickAmount(...)`), add: `print(string.format("[Progression] tick: source=%s amount=%d player=%s(%d)", sourceName, amount, player.Name, player.UserId))`.
2. Note in `02_Systems/XP_Progression.md` (or have Claude do it at integration) that the tick log is intentional debug surface — quiet by default in production should be the future call but for now leave on so Tyler can see the system working.
3. If the print becomes too noisy in production later, gate it behind a `SourceConfig.DEBUG_TICK_LOG` boolean defaulting to `true`. Cleaner approach.

### Phase 4 — Playtest + push

1. Playtest one full cycle: spawn, sit at SeatMarker, watch one or two ticks, verify XPBar fills, force window-focus loss, verify AFK behavior matches whichever branch Tyler picked, force a level-up via `execute_luau` if Phase 2 didn't already.
2. Capture the console output in inbox (now with the debug log line, this should be informative).
3. Commit with a plain message: `XP testing-place bug sweep — XPBar visibility, AFK-vs-sitting, tick debug log`.
4. Push: `git push -u origin codex/xp-testing-bug-sweep`. Tell Tyler the branch is ready for Claude review.

## 6. Roblox Services Involved

`Players`, `ReplicatedStorage`, `ServerScriptService`, `StarterGui`, `UserInputService`, `Workspace`, `TweenService`. No `DataStoreService` writes (prong 3 logging is read-only from state).

## 7. Security / DataStore Notes

- ⚠️ Validation: not applicable — no client-input handling added.
- ⚠️ DataStore retry/pcall: not applicable — no DataStore writes added.
- ⚠️ Rate limits: not applicable.
- ⚠️ Avalog watchdog: not in scope; do not touch `NameTagScript`.
- ⚠️ No-touch list: `FavoritePromptPersistence`, `ProgressionService` (per `_No_Touch_Systems.md`). The Tick function lives inside `ProgressionService`, but adding a `print` line at the start of one method is the smallest possible touch — verify with `_No_Touch_Systems.md` before editing. If the no-touch boundary forbids any edit to `ProgressionService.lua`, do prong 3's logging from `Driver.server.lua` (just after the `Tick` call returns) instead.

## 8. Boundaries (do NOT touch)

- `src/ServerScriptService/NameTagScript.server.lua` (just shipped via PR #9)
- `src/ServerScriptService/FavoritePromptPersistence` (no-touch)
- `src/ServerScriptService/Progression/ProgressionService.lua` IF `_No_Touch_Systems.md` flags it — verify first; if so, route prong 3's logging through `Driver.server.lua`
- `ReplicatedStorage.Progression.XPUpdated` / `LevelUp` (live remote contracts)
- `_Live_Systems_Reference.md`, `NameTag_Status.md`, `_Change_Log.md`, `00_Index.md`, `02_Systems/XP_Progression.md` — Claude updates these at integration; do not preempt
- Any visual restyling of the XPBar beyond fixing a bug — needs Tyler tone call first

## 9. Studio Test Checklist

- [ ] After Play start, the XPBar is visible to a human eye looking at the bottom of the screen (verify with screenshot).
- [ ] After 30+ seconds seated on `Workspace.SeatMarkers.Seat`, the next tick grants the rate matching Tyler's chosen branch (sitting=20 with gamepass-off, or AFK=3 if Branch C).
- [ ] After a window-focus blip, the rate matches Tyler's chosen branch behavior.
- [ ] Per-tick `[Progression] tick: source=... amount=... player=...` appears in console output every 60 seconds for each player.
- [ ] No new errors in console on join, on respawn, on level change, on AFK toggle.
- [ ] XPBar still tweens smoothly on each `XPUpdated` (no `currentFillFraction` regressions).

## 10. Rollback Notes

Each prong is independently revertible:
- Prong 1: revert the XPBar visibility fix commits — visible behavior returns to whatever Tyler was seeing pre-PR.
- Prong 2: revert the `PresenceTick.GetTickAmount` reorder (Branch A) or the `AfkDetector` idle gate (Branch B). Branch C has no code to revert.
- Prong 3: revert the `print` line. No state, no contract.

No DataStore migration, no remote-contract impact. Single commit revert is sufficient for any individual prong.

---

## Notes for Claude (review)

- This brief is investigation-first for prongs 1 and 2 — Codex should NOT just pick a fix and implement it. Prong 1: capture screenshot, diagnose, stop if the fix isn't tiny. Prong 2: confirm diagnosis, stop, ask Tyler to pick Branch A/B/C, then implement. If Codex skips the stop-and-flag and just ships a guess, that's a review fail — push back.
- The `?` flag on AFK-overrides-sitting is a Tyler design call, not a Codex implementation call. The brief intentionally does not pick a branch.
- For prong 3, prefer the `Driver.server.lua` location for the `print` if `ProgressionService` is on the no-touch list. Verify against `_No_Touch_Systems.md` before editing.
- After Codex pushes, expect a normal review: read the pushed branch via GitHub MCP, parse Codex's inbox notes, decide if an independent playtest is needed (likely yes for prongs 1 and 2 since visual + behavior verification is the whole point), translate to plain English for Tyler.
