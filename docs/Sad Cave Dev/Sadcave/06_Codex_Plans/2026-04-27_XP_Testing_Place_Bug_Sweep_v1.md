# XP Testing-Place Bug Sweep — Codex Plan

**Date:** 2026-04-27
**Status:** 🟢 Shipped — PR #10 (merged 2026-04-28 01:25 UTC, branch `codex/xp-testing-bug-sweep`, merge commit `6a9c26b`)
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/xp-testing-bug-sweep`
**Related Systems:** [[../02_Systems/XP_Progression]]
**Driving notes:** [[../09_Open_Questions/_Known_Bugs]] entries "XPBar invisible to player despite GUI hierarchy reporting it as rendered" and "XP system grants AFK rate (3) while player is physically seated at a SeatMarker"; inbox 2026-04-27 (Cowork session 5).

---

## 0. Decisions made (read this before resuming)

Codex paused mid-flow at two `?` flags after Phase 1 and Phase 2 of the brief; Tyler delegated both calls to Claude. Both are now answered. Codex can proceed straight through the remaining work without further design checkpoints — implement what's specified here. See `_Decisions.md` (2026-04-27 entries) for the full reasoning if needed.

**Decision A — AFK-vs-sitting: pick Branch A (seated SeatMarker overrides AFK).**

- Edit `src/ServerScriptService/Progression/Sources/PresenceTick.lua`.
- In `PresenceTick.GetTickAmount`, **check `state.seatedAt` first** (with elapsed ≥ `sourceConfig.SITTING_THRESHOLD_SECONDS`) and return `PRESENCE_SITTING_XP, "sitting"` when seated. Only fall through to `state.isAFK` → `PRESENCE_AFK_XP, "afk"` when not seated. Active rate stays the final fallback.
- The 30-second sitting threshold is preserved — instant-boost on sit-down is NOT desired.
- Net behavior change: a player physically seated at a SeatMarker keeps earning sitting rate even when their Roblox window doesn't have focus. A player NOT seated falls through to AFK rate as before when window focus is lost.
- Suggested function body shape (verify against the actual file before you write):
  ```lua
  function PresenceTick.GetTickAmount(_player, state, sourceConfig)
      if state.seatedAt then
          local elapsed = os.time() - state.seatedAt
          if elapsed >= sourceConfig.SITTING_THRESHOLD_SECONDS then
              return sourceConfig.PRESENCE_SITTING_XP, "sitting"
          end
      end

      if state.isAFK then
          return sourceConfig.PRESENCE_AFK_XP, "afk"
      end

      return sourceConfig.PRESENCE_ACTIVE_XP, "active"
  end
  ```

**Decision B — XPBar visibility: bump desktop `barHeight` from 4 to 6.**

- Edit `src/StarterGui/XPBar/XPBarController.client.lua`.
- Change `local barHeight = if isMobile then 6 else 4` to `local barHeight = if isMobile then 6 else 6` (or just `local barHeight = 6` — equivalent, slightly cleaner).
- Do NOT change `Background.BackgroundTransparency` (stays 0.85), `Fill.BackgroundTransparency` (stays 0.6), `bumpHeight` (stays 8 desktop / 10 mobile), the warm-tint Fill color, or anything else in the controller. The decision is height only — single-axis bump.
- Net behavior change: the resting bar is 6px tall at the bottom of the screen instead of 4px. Level-up animation still bumps to 8px desktop. The fill color, transparency, and tween behavior all unchanged.

These two changes plus the per-tick debug log Codex already added in `Driver.server.lua` (line 86 area) complete the brief. Nothing else needs to ship in this PR.

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

### Phase 1 — XPBar visibility (prong 1)

**Already done by Codex in the first pass:** playtest probe confirmed `PlayerGui.XPBar` is `Enabled=true`, `Background` is `2439×4` at the bottom edge, `Fill` at scale-X 0.829 with `Visible=true`. Screenshot showed a "very thin warm strip at the bottom"; no controller bug. Tyler's "vanished" perception is purely the visual being too subtle.

**What to do now:**
1. Apply Decision B from Section 0 — change `local barHeight = if isMobile then 6 else 4` to `local barHeight = 6` (or `if isMobile then 6 else 6`) in `src/StarterGui/XPBar/XPBarController.client.lua`. Single-axis change. No other property edits.
2. Playtest after the change: confirm the bar reads as a perceptible 6px strip rather than 4px. Capture in inbox.
3. Confirm the level-up animation still bumps cleanly (`bumpHeight=8` desktop is unchanged, so the bump:resting ratio goes from 2x to 1.33x — verify it still reads as a level-up beat, not a no-op). If the bump feels too small post-change, flag in inbox with `?` — but do NOT change `bumpHeight` without a separate Tyler call.

### Phase 2 — AFK-vs-sitting fix (prong 2)

**Already done by Codex in the first pass:** diagnosis confirmed live — seated player on `Workspace.SeatMarkers.Seat` with `state.isAFK=true` produced `[Progression] tick: source=afk amount=3`; XP went `230839 → 230842`. No further verification needed.

**What to do now:**
1. Apply Decision A from Section 0 — reorder `PresenceTick.GetTickAmount` in `src/ServerScriptService/Progression/Sources/PresenceTick.lua` so seated state is checked first. See Section 0 for the exact function shape.
2. Playtest:
   - Sit at `Workspace.SeatMarkers.Seat` for 35 seconds, force the same AFK signal that previously demoted the tick to AFK rate, wait for the next tick. Expect `[Progression] tick: source=sitting amount=20 ...` (or `30` if gamepass owned). Capture in inbox.
   - Stand up, force AFK signal, wait for the next tick. Expect `[Progression] tick: source=afk amount=3 ...`. Capture in inbox.
   - Stand up, focus active. Expect `[Progression] tick: source=active amount=15 ...`. Capture in inbox.
3. If any of the three states grants the wrong rate, flag in inbox with `?` and stop. Otherwise proceed to push.

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
