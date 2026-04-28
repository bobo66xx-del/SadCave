# XP Follow-up Fixes — Codex Plan

**Date:** 2026-04-28
**Status:** 🟢 Shipped — PR #11 (merged 2026-04-28 03:12:50 UTC, branch `codex/xp-followup-fixes`, head commit `d06753a`)
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/xp-followup-fixes`
**Related Systems:** [[../02_Systems/XP_Progression]]
**Driving notes:** inbox 2026-04-27 (Cowork session 6); follow-up to PR #10 ([[2026-04-27_XP_Testing_Place_Bug_Sweep_v1]]).

---

## 0. Decisions made (read this before resuming)

Phase 1 (gamepass ID) is already applied in the working tree. Phase 2 investigation completed and Codex correctly stopped at the brief's stop-and-flag condition: the diagnostic ruled out placement/occlusion (Background AbsolutePosition is on-screen, IgnoreGuiInset already true, no GUI was covering it, forcing Fill.Size.X.Scale=1 made the warm strip visible full-width), so the issue IS contrast — Tyler's placement hypothesis was rejected by evidence. Codex also flagged that the per-tick log shows pre-multiplier amount, which becomes a verification problem once gamepass kicks in.

Tyler delegated both calls to Claude. Both are answered now. Codex can finish without another stop. See `_Decisions.md` (2026-04-28 entries) for full reasoning.

**Decision C — XPBar contrast: drop `Background.BackgroundTransparency` from `0.85` to `0.55`.**

- Edit `src/StarterGui/XPBar/XPBarController.client.lua`.
- Find `background.BackgroundTransparency = 0.85` and change to `background.BackgroundTransparency = 0.55`.
- Do NOT change anything else in the controller. Specifically: keep `BackgroundColor3 = Color3.fromRGB(15, 15, 15)`, keep `Fill.BackgroundTransparency = 0.6`, keep `Fill.BackgroundColor3`, keep `barHeight = 6`, keep `bumpHeight` math, keep `Glow` properties, keep `LevelLabel` properties, keep `HoverDetector` properties, keep all tween logic.
- Net behavior change: the resting bar's full footprint reads with a faint dark presence even at low fill, so the unfilled region no longer blends into the dark cave. The warm Fill still pops as the progress indicator on top.

**Decision D — Per-tick log shows both base and granted amounts.**

- Edit `src/ServerScriptService/Progression/Driver.server.lua` inside `tickPlayer(player)`.
- Compute `granted` from the base `amount` and the player's gamepass-ownership state, then log both. The math duplicates what `ProgressionService.GrantXP` does (`amountToGrant = math.floor(numericAmount * multiplier)` where `multiplier = state.gamepassOwned and SourceConfig.GAMEPASS_MULTIPLIER or 1`). Add a one-line comment so the duplication is documented.
- Suggested function shape (verify against the actual file before writing):
  ```lua
  local function tickPlayer(player)
      local state = ProgressionService.GetState(player)
      local amount = nil
      local sourceName = nil

      if state then
          amount, sourceName = PresenceTick.GetTickAmount(player, state, SourceConfig)
      end

      local ok = ProgressionService.Tick(player, PresenceTick)
      if ok and amount and sourceName then
          -- granted math mirrors ProgressionService.GrantXP; keep in sync if the multiplier handling ever changes.
          local multiplier = (state and state.gamepassOwned) and SourceConfig.GAMEPASS_MULTIPLIER or 1
          local granted = math.floor(amount * multiplier)
          print(string.format(
              "[Progression] tick: source=%s base=%d granted=%d player=%s(%d)",
              sourceName,
              amount,
              granted,
              player.Name,
              player.UserId
          ))
      end
  end
  ```
- Net behavior change: when gamepass is OFF, the log reads `base=15 granted=15` (same number twice — that's the signal). When ON, `base=15 granted=22`. Trivial to verify the multiplier is firing.

These two changes plus the gamepass ID fix already applied in Phase 1 complete the brief. Phase 3's playtest checklist still applies — verify the bar reads visibly at low fill (e.g., the player's current ~20% fill state), verify the multiplier shows up in the log after a fresh-join post-merge, verify no regressions in the three rate states or the level-up animation. Then commit and push.

---

## 1. Purpose

Two issues surfaced when Tyler tested PR #10 in `Testing cave` after merge. Both are small, both are unblocking real testing-place check items (gamepass tick verification, mobile bar height verification) that need clean fixes before the rest of the XP walkthrough can proceed.

**Issue A — Gamepass multiplier never applies because `SourceConfig.GAMEPASS_ID` is a nonexistent asset.** Probe via `MarketplaceService:GetProductInfo(2110249546, Enum.InfoType.GamePass)` returned "Item not found in batch response." `MarketplaceService:UserOwnsGamePassAsync(1132193781, 2110249546)` returns `false` — the API responds, the answer is "no such gamepass." Tyler confirmed via the Roblox creator dashboard that the actual Sad Cave gamepass ID is `1790063497`. The MVP shipped with the wrong number.

**Issue B — Desktop XPBar does not render visibly to the player even though the GUI hierarchy reports it correctly.** PR #10 bumped `barHeight` from 4 to 6, but Tyler still cannot see the bar on desktop. Mobile (Studio mobile emulator) renders correctly with the same code. Importantly: Tyler CAN see the `LevelLabel` reveal on hover (`level 558 - 169/839 xp`), and the LevelLabel is positioned 16px above the screen bottom anchored to the same `Y=1.0` axis as the bar. So the bar's specific frames (`Background`, `Fill`) are being covered, displaced, or rendered behind something — this is a placement / occlusion problem, not a transparency problem. Investigate before making any visual restyle.

## 2. Player Experience

After this brief lands:
- A player who owns gamepass `1790063497` earns `floor(amount × 1.5)` XP on every grant — 22 active, 30 sitting, 4 AFK per tick. The per-tick debug log shows the multiplied amount.
- The XPBar is visibly rendering at the bottom of the screen on desktop. A player can see live progress fill toward the next level without having to hover.
- Mobile rendering is unchanged (already worked).

## 3. Technical Structure

- **Server responsibilities (Issue A):** `SourceConfig.GAMEPASS_ID` constant changes. `ProgressionService.LoadPlayer` already calls `checkGamepass(player)` once on join and caches the result on `state.gamepassOwned`; that flow does not need to change.
- **Client responsibilities (Issue B):** depends on diagnosis. Likely changes are in `XPBarController.client.lua`. Could also involve the parent `StarterGui.XPBar` ScreenGui's properties (`DisplayOrder`, `IgnoreGuiInset`, `ScreenInsets`).
- **Remote events / functions:** none touched.
- **DataStore keys touched:** none.

**Important note on Issue A's runtime effect:** existing players in a session that started BEFORE the SourceConfig fix will still have `state.gamepassOwned=false` until they rejoin (the value is set once at `LoadPlayer`). That's fine for normal workflow — Tyler will rejoin during playtest after the merge — but it means the gamepass test must be done with a fresh join post-merge, not by waiting for a tick on an existing session.

## 4. Files / Scripts

Modify (Issue A — one constant):
- `src/ReplicatedStorage/Progression/SourceConfig.lua` — change `SourceConfig.GAMEPASS_ID = 2110249546` to `SourceConfig.GAMEPASS_ID = 1790063497`.

Read first (Issue B — investigation):
- `src/StarterGui/XPBar/XPBarController.client.lua` (the controller that builds Background, Glow, Fill, LevelLabel, HoverDetector)
- The `StarterGui.XPBar` ScreenGui itself in Studio (its properties — DisplayOrder, IgnoreGuiInset, ScreenInsets — are NOT in the Rojo source tree; they live as attributes on the ScreenGui instance, set in Studio)

Modify (Issue B — depends on diagnosis): likely `XPBarController.client.lua` or the `StarterGui.XPBar` ScreenGui properties. Determine the actual fix during the investigation phase.

Do **not** touch:
- `src/ServerScriptService/Progression/ProgressionService.lua` (no-touch — gamepass check logic stays identical, just the constant changes)
- `src/ServerScriptService/Progression/Driver.server.lua` (the per-tick log + sit-tracking is correct)
- `src/ServerScriptService/Progression/Sources/PresenceTick.lua` (the Branch A reorder is correct)

## 5. Step-by-Step Implementation (for Codex)

Branch from clean main: `git checkout main && git pull && git checkout -b codex/xp-followup-fixes`.

### Phase 1 — Gamepass ID fix (Issue A)

This is one line. Do this first, then move to Issue B's investigation.

1. Open `src/ReplicatedStorage/Progression/SourceConfig.lua`.
2. Change `SourceConfig.GAMEPASS_ID = 2110249546` to `SourceConfig.GAMEPASS_ID = 1790063497`.
3. No other change in that file (`SourceConfig.GAMEPASS_MULTIPLIER` stays 1.5, all other constants unchanged).

### Phase 2 — Diagnose desktop bar invisibility (Issue B)

Investigation-first. Do NOT change visual properties (BackgroundTransparency, BackgroundColor3, Fill colors, height, etc.) without flagging — Tyler reasoned this is a placement/occlusion issue, not a contrast issue.

1. Start a Studio playtest in `Testing cave` (desktop view, NOT mobile emulator).
2. Probe via `execute_luau`:
   - `Players.LocalPlayer.PlayerGui.XPBar.Background.AbsolutePosition` and `AbsoluteSize`
   - `Players.LocalPlayer.PlayerGui.XPBar.Background.Fill.AbsolutePosition` and `AbsoluteSize`
   - `workspace.CurrentCamera.ViewportSize`
   - The `Players.LocalPlayer.PlayerGui.XPBar` ScreenGui's `DisplayOrder`, `IgnoreGuiInset`, `ScreenInsets` (if `IgnoreGuiInset` is false, the inset offsets the rendered frames).
3. Calculate: does `Background.AbsolutePosition.Y + Background.AbsoluteSize.Y == ViewportSize.Y` (i.e., is the bar's bottom edge actually at the screen's bottom edge)? If the difference is more than a couple pixels, the bar is offset somewhere — likely cause is `IgnoreGuiInset = false` combined with Roblox's bottom-screen control hints (B button, jump button, etc., on some clients).
4. Take a screenshot of the bottom 60 pixels of the desktop screen during Play. Compare to where the bar's `AbsolutePosition` says it is.
5. Iterate hypotheses, flagging each in inbox with a `[C]` line:
   - **Hypothesis 1: Roblox's GUI inset is pushing the bar below the visible viewport.** Test by setting `XPBar.IgnoreGuiInset = true` (this can be set in the ScreenGui's Studio properties or via Studio MCP `multi_edit` if the ScreenGui exists in the live tree but not in the Rojo source). If the bar appears, that's the cause. Fix is to set `IgnoreGuiInset = true` on the ScreenGui (likely via a `.meta.json` file in the Rojo source tree at `src/StarterGui/XPBar/init.meta.json`).
   - **Hypothesis 2: Another ScreenGui (or a CoreGui element) is overlaying the bar.** Iterate `PlayerGui:GetDescendants()` looking for `GuiObject`s with `AbsolutePosition.Y + AbsoluteSize.Y >= ViewportSize.Y - 12` and `BackgroundTransparency < 1`. If something opaque is sitting over the bar, identify it. If it's a Sad Cave ScreenGui, check whether DisplayOrder rebalancing fixes it. If it's CoreGui, the fix may need `XPBar.DisplayOrder` bumped above the default 0, OR the bar lifted up via a position offset.
   - **Hypothesis 3: The bar is being clipped by viewport boundary on desktop.** Less likely but possible. Test by lifting `Background.Position.Y.Offset` from 0 to some negative value (-2, -4) and see if it appears.
6. Once the cause is identified, capture in inbox with `[C]` line, then implement the smallest fix:
   - If Hypothesis 1: set `IgnoreGuiInset = true`. This is typically done via an `init.meta.json` file alongside the ScreenGui in the Rojo source. The pattern is:
     ```json
     {
       "properties": {
         "IgnoreGuiInset": true
       }
     }
     ```
     Verify by checking how other ScreenGuis in the repo handle properties before writing this file. If the Rojo project's `default.project.json` doesn't expose `StarterGui.XPBar` as a directory mapping, the property may need to be set differently.
   - If Hypothesis 2 (DisplayOrder): bump `XPBar.DisplayOrder` to a low positive number (e.g., 1 or 2) — but only if some other ScreenGui's higher DisplayOrder is the cause. Don't blindly bump.
   - If Hypothesis 2 (covered by Sad Cave's own GUI): identify the offending ScreenGui and decide with Tyler whether to lift the bar above it or change the other GUI's behavior. Flag in inbox with `?` if the offending GUI is `Menu`, `AvalogMenu`, or anything player-facing — that's a Tyler call.
   - If Hypothesis 3: lift Background's position with a small offset.
7. **Stop and flag** with `?` if:
   - The investigation reveals the bar's `AbsolutePosition` and `AbsoluteSize` actually do put it on-screen visibly AND nothing is overlaying it AND it's still invisible to Tyler. That would mean the issue is contrast after all, contrary to Tyler's hypothesis — which is a Tyler tone call before any visual restyle.
   - The fix would change visual properties beyond placement (transparency, color, height).
   - The fix involves another player-facing ScreenGui.

### Phase 3 — Playtest both fixes

1. Stop and restart Studio Play (need a fresh join for the gamepass check to re-fire with the new ID).
2. Verify Issue A: console should now log `[Progression] tick: source=active amount=22` (or similar with multiplier applied) when Tyler is moving around. Capture in inbox.
3. Verify Issue B: take a desktop screenshot during Play and confirm the bar is visibly rendering at the bottom of the screen. Capture in inbox.
4. Verify nothing regressed: walk through the three rate states again (sitting / standing+focused / standing+AFK) and confirm the multiplied amounts are still correct (sitting=30, active=22, AFK=4 with gamepass).

### Phase 4 — Push

1. Commit on the branch with a plain message: `XP follow-up: correct gamepass ID, fix desktop bar visibility`.
2. Push: `git push -u origin codex/xp-followup-fixes`. Tell Tyler the branch is ready for Claude review.

## 6. Roblox Services Involved

`Players`, `MarketplaceService`, `ReplicatedStorage`, `StarterGui`, `UserInputService`, plus probably `workspace.CurrentCamera` for viewport probing.

## 7. Security / DataStore Notes

- ⚠️ Validation: not applicable — no client input handling added or changed.
- ⚠️ DataStore retry/pcall: not applicable — no DataStore writes.
- ⚠️ Gamepass: the existing `checkGamepass` retry path in `ProgressionService.lua` stays identical. Only the constant changes.
- ⚠️ No-touch list: `ProgressionService.lua` and `Driver.server.lua` and `PresenceTick.lua` are NOT modified. Only `SourceConfig.lua` (the constants module) and `XPBarController.client.lua` and possibly an `init.meta.json` for the ScreenGui.

## 8. Boundaries (do NOT touch)

- `src/ServerScriptService/Progression/ProgressionService.lua` (no-touch, contains the gamepass check logic — unchanged)
- `src/ServerScriptService/Progression/Driver.server.lua` (correct as shipped in PR #10)
- `src/ServerScriptService/Progression/Sources/PresenceTick.lua` (correct as shipped in PR #10)
- `src/ServerScriptService/NameTagScript.server.lua` (PR #9, unrelated)
- Any visual restyle of the XPBar beyond placement (transparencies, colors, fill height, level-up `bumpHeight`) — Tyler verified the height bump is sufficient on mobile and the level-up animation reads cleanly; height/visual properties are correct, the issue is placement.
- `_Live_Systems_Reference.md`, `XP_Progression.md`, `_Change_Log.md`, `00_Index.md` — Claude updates these at integration; do not preempt.

## 9. Studio Test Checklist

- [ ] After fresh Play start (post-merge), gamepass-owning player's tick log shows multiplied amounts: `source=active amount=22`, `source=sitting amount=30`, `source=afk amount=4`.
- [ ] Non-gamepass player's tick log shows unmultiplied amounts: 15 / 20 / 3 (cannot easily test in Studio without a second account, but the code path is unchanged and verified by PR #10 if Tyler doesn't have the gamepass at probe time).
- [ ] After Play start, the XPBar is visibly rendering at the bottom of the desktop screen — Tyler can point to it without hovering. Verify with screenshot during Play.
- [ ] XPBar still tweens fill smoothly on each `XPUpdated` (no controller regressions).
- [ ] XPBar level-up animation still bumps cleanly (no animation regression from any placement change).
- [ ] Mobile rendering still correct — no regression from desktop fix.
- [ ] Hover stat (`level N - X/Y xp`) still appears for ~2 seconds on hover/tap, on both desktop and mobile.

## 10. Rollback Notes

Each fix is independently revertible:
- Issue A: revert the `SourceConfig.GAMEPASS_ID` change. Behavior returns to "gamepass never applies" — same as before this PR.
- Issue B: revert whatever placement/property change was made in `XPBarController.client.lua` or the `init.meta.json`. Bar returns to whatever placement it was before, which is what's currently shipping.

No DataStore migration, no remote-contract impact. Single commit revert on either fix.

---

## Notes for Claude (review)

- Phase 1 is one line — easy verify against the diff.
- Phase 2 is investigation-first. Codex should not just bump `IgnoreGuiInset` or change `DisplayOrder` without explaining via inbox `[C]` line WHY that fix is being applied. A blind "I changed IgnoreGuiInset and now it shows up" is acceptable as a fix but should still capture the diagnostic data (AbsolutePosition before/after, what was at the bottom of the screen blocking it, etc.) so the root cause is on the record.
- Tyler's hypothesis was that the bar is covered or displaced. Codex should confirm or reject that hypothesis explicitly, not just ship a fix and move on.
- If the investigation surprises Codex (e.g., turns out the bar IS being rendered visibly per AbsolutePosition + nothing's covering it), `?` flag for Tyler — the fix may then need to be a contrast bump after all, which is a tone call.
- Per-tick debug log makes the gamepass verification fast — one fresh-join playtest cycle should be sufficient.
