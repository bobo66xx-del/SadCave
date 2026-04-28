# Title v2 MVP-1 — Post-Merge Follow-Up — Codex Plan

**Date:** 2026-04-28
**Status:** 🔵 Queued
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/title-v2-mvp1-followup` *(once started)*
**Related Systems:** [[../02_Systems/Title_System]], [[../02_Systems/NameTag_Status]]
**Driving notes:** Post-merge Claude review of PR #12 (`codex/title-v2-mvp1`, merged 2026-04-28 06:10:58 UTC) flagged two non-blocking architectural notes. Tyler asked to clean both up before MVP-2 lands so they don't compound. This brief covers both.

---

## 1. Purpose

Two small architectural cleanups on top of the just-merged Title v2 MVP-1 implementation. Neither changes player-facing behavior — both harden how TitleService talks to NameTagScript and how it tracks level changes across the player's lifecycle.

**Item A — TitleService becomes a ModuleScript.** PR #12 used a `_G.SadCaveTitleService` shared-state registry so `NameTagScript.server.lua` could read the current title payload and apply it to BillboardGuis. That works, but it's order-sensitive: if NameTagScript's `applyNameTag` runs for an early-joining player before `TitleService.server.lua` has finished its top-level setup, NameTag falls back to the default payload (warm white, no title text) for that one frame. The fix the brief originally preferred is to make TitleService a ModuleScript that NameTagScript `require`s — Luau guarantees the module's top-level code runs to completion before `require` returns, so the order question goes away by construction.

**Item B — leaderstats Level watcher survives respawns.** PR #12 connects to `Player.leaderstats.Level:GetPropertyChangedSignal("Value")` once during `onPlayerAdded` and never re-attaches. If `ProgressionService` ever destroys-and-recreates leaderstats during a character lifecycle event, the connection would dangle on a destroyed instance and milestone level-ups would stop triggering title re-resolution silently. Standard Roblox pattern is to keep leaderstats persistent across respawns, so this may already be fine in practice — but the cheap fix is to also re-attach the watcher inside the existing `CharacterAdded` handler so the system is robust regardless of how ProgressionService manages leaderstats.

After this brief: TitleService is a clean ModuleScript that NameTagScript depends on through `require`, the title payload reaches the BillboardGui without timing risk, and the level watcher self-heals if leaderstats ever blinks.

## 2. Player Experience

No player-visible change intended. Run the same end-to-end test as PR #12 — auto-equip on join, milestone level-up combined fade, gamepass-purchase title flip — and verify nothing regressed.

## 3. Technical Structure

### Item A — TitleService as ModuleScript

**Split TitleService.server.lua into two files:**

- **`TitleService.lua`** — ModuleScript. Owns all state (`playerStates`, `levelConnections`), all functions (`loadTitleData`, `saveTitleData`, `checkGamepass`, `resolveOwnership`, `pickAutoEquip`, `applyEquip`, `refreshAutoEquip`, `attachLevelWatcher`, `getPlayerTitlePayload`, `applyTitlePayloadToBillboard`, `updateNameTag`, `onPlayerAdded`, `onPlayerRemoving`, etc.). Exports a small public API table:
  ```lua
  return {
      Start = function() ... end,                          -- wires Players.PlayerAdded / PlayerRemoving / MarketplaceService listeners; spawns onPlayerAdded for any players already present
      GetPlayerTitlePayload = function(player) ... end,    -- same shape as the current _G entry
      ApplyTitlePayloadToBillboard = function(bb, payload) ... end,  -- same shape as the current _G entry
  }
  ```
  All other helpers stay file-local (`local function ...`).
- **`TitleServiceInit.server.lua`** — Script. Single responsibility: `require(ReplicatedStorage:WaitForChild("ReplicatedStorage")...)` — no, wait — TitleService lives in `ServerScriptService`. So: `local TitleService = require(script.Parent.TitleService); TitleService.Start(); print("[TitleService] script ready")`. That's it. The init file exists purely to drive the runtime; the module itself does no work at top level beyond defining its functions and the `playerStates` / `levelConnections` tables.

**NameTagScript.server.lua** — replace the `_G.SadCaveTitleService` lookups with a direct `require`:

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local TitleService = require(ServerScriptService:WaitForChild("TitleService"))
```

Then `getTitlePayload(player)` becomes a direct call: `return TitleService.GetPlayerTitlePayload(player)`. `applyTitlePayload` becomes `TitleService.ApplyTitlePayloadToBillboard(bb, payload)`. Drop the `_G` fallback path — if `require` fails the script should crash loudly so the bug is visible, not silently fall back to defaults.

**Remove `_G.SadCaveTitleService` entirely.** The registry pattern is gone. No more global namespace usage from this system.

**Avalog watchdog:** must continue to call into TitleService when the BillboardGui is rebuilt, exactly as it does today. The `require` pattern doesn't change that flow — the watchdog calls `applyTitlePayload(newBillboard, getTitlePayload(player))` after re-creating the billboard, and both helpers route through TitleService now.

### Item B — Level watcher on respawn

In `TitleService.lua`'s `onPlayerAdded`, the existing block is:

```lua
attachLevelWatcher(player)
refreshAutoEquip(player, false)

player.CharacterAdded:Connect(function()
    task.defer(function()
        updateNameTag(player, getPlayerTitlePayload(player))
    end)
end)
```

Update the `CharacterAdded` handler to also re-attach the watcher:

```lua
player.CharacterAdded:Connect(function()
    attachLevelWatcher(player)  -- idempotent; disconnects-then-reconnects if leaderstats was recreated
    task.defer(function()
        updateNameTag(player, getPlayerTitlePayload(player))
    end)
end)
```

`attachLevelWatcher` is already idempotent — it disconnects any existing connection on the same player before re-attaching — so this is safe to call repeatedly. If leaderstats survives the respawn, the new connection lands on the same IntValue and behaves identically. If leaderstats was destroyed and recreated, the new connection lands on the new instance and the system continues working.

**Optional probe (light verification, not required):** add a one-line `print("[TitleService] CharacterAdded for", player.Name, "leaderstats present:", player:FindFirstChild("leaderstats") ~= nil)` so a single Studio playtest reveals the truth about leaderstats persistence. Tyler can decide whether to keep this as a permanent log or strip it after one test session.

## 4. Files / Scripts

**Create:**
- `src/ServerScriptService/TitleService.lua` — ModuleScript (the bulk of the current `TitleService.server.lua` body, restructured to expose `Start`, `GetPlayerTitlePayload`, `ApplyTitlePayloadToBillboard`).
- `src/ServerScriptService/TitleServiceInit.server.lua` — Script. Three lines: require the module, call `Start()`, print ready.

**Delete:**
- `src/ServerScriptService/TitleService.server.lua` — replaced by the module + init pair above.

**Modify:**
- `src/ServerScriptService/NameTagScript.server.lua` — swap `_G.SadCaveTitleService` reads for a direct `require`. Drop the default-payload fallback in `getTitlePayload` (the require will succeed or the script crashes, which is the desired loud-failure behavior).
- `src/ServerScriptService/TitleService.lua` (the new module) — inside `onPlayerAdded`, add `attachLevelWatcher(player)` to the `CharacterAdded` handler.

**Do NOT modify:**
- `src/ReplicatedStorage/TitleConfig.lua` — no changes; the data layer is untouched.
- `src/ReplicatedStorage/TitleRemotes/` — no changes.
- `src/StarterPlayer/StarterPlayerScripts/NameTagEffectController.client.lua` — client-side, doesn't touch the server module pattern.
- `src/StarterGui/XPBar/XPBarController.client.lua` — client-side, doesn't touch TitleService.
- `ProgressionService.lua` and the rest of `Progression/` — no-touch, read-only access via leaderstats.

## 5. Step-by-Step Implementation (for Codex)

1. **Branch.** `git checkout main && git pull && git checkout -b codex/title-v2-mvp1-followup`.
2. **Read current state.** Open `src/ServerScriptService/TitleService.server.lua` end-to-end. Open `src/ServerScriptService/NameTagScript.server.lua` and confirm exactly which functions/calls reference `_G.SadCaveTitleService`. Read `02_Systems/_No_Touch_Systems.md` and confirm nothing in this brief touches no-touch surfaces.
3. **Create `TitleService.lua` (ModuleScript).** Copy the body of `TitleService.server.lua` into the new file. Wrap the public API in a returned table. Replace the bottom `_G.SadCaveTitleService = { ... }` block with the table return. Move the `Players.PlayerAdded:Connect(onPlayerAdded)` / `Players.PlayerRemoving:Connect(onPlayerRemoving)` / `MarketplaceService.PromptGamePassPurchaseFinished:Connect(...)` connects + the existing-players loop into a `Start` function on the public API. Verify the file has no top-level side effects beyond defining functions and module-local tables.
4. **Add the `CharacterAdded` re-attach.** Inside `onPlayerAdded`, prepend `attachLevelWatcher(player)` to the existing `CharacterAdded` handler.
5. **Create `TitleServiceInit.server.lua`.** Three lines:
   ```lua
   local TitleService = require(script.Parent:WaitForChild("TitleService"))
   TitleService.Start()
   print("[TitleService] script ready")
   ```
   The `print` matches the line currently at the bottom of `TitleService.server.lua` so console parity is preserved.
6. **Delete `TitleService.server.lua`.** `git rm` the old file.
7. **Update `NameTagScript.server.lua`.** Add the `local TitleService = require(...)` near the top. Replace the two `_G.SadCaveTitleService` lookups in `getTitlePayload` and `applyTitlePayload` with direct module calls. Drop the `_G`-not-found fallback default branches — if the require fails the script should error loudly. Keep the `DEFAULT_TITLE_PAYLOAD` constant if it's still used as the *initial* state before `getTitlePayload` is called (e.g. for a player without state yet); otherwise remove.
8. **Studio playtest.** Use `start_stop_play` + `console_output`. Verify:
   - `[TitleService] script ready` and `[NameTag] script ready` both print.
   - Joining the testing place auto-equips a title (gamepass `believer` for Tyler, since the gamepass-priority logic from PR #12 is unchanged).
   - BillboardGui shows 200×50 with NameLabel + TitleLabel as before.
   - Trigger a level change via the command bar (e.g. `game.Players.<name>.leaderstats.Level.Value = 10` to cross a milestone). Verify the combined fade fires and the nametag title updates.
   - Force a respawn (`game.Players.<name>.Character.Humanoid.Health = 0`). After the new character spawns, trigger another level change. Verify the title still updates — this is the regression test for the watcher re-attach.
   - Verify no new console errors. The `[FavoritePrompt]` and other unrelated logs should look the same as in PR #12's playtest.
9. **Push and hand back for review.** `git push -u origin codex/title-v2-mvp1-followup`. Note in the inbox what you tested, especially whether the post-respawn level-change still fires the title update.

## 6. Roblox Services Involved

`Players`, `ReplicatedStorage`, `ServerScriptService`, `MarketplaceService`, `DataStoreService` — all already in use; no new service dependencies.

## 7. Security / DataStore Notes

No DataStore changes. No remote-contract changes (`TitleRemotes.TitleDataUpdated` is unchanged). No new client-trust surfaces. Server-authoritative ownership unchanged. This brief is purely server-side architectural cleanup.

## 8. Boundaries (do NOT touch)

- `ProgressionService.lua` and the rest of `Progression/` — no-touch.
- `ProgressionData` DataStore — no-touch.
- `TitleConfig.lua` — leave alone, the data layer is fine.
- `TitleRemotes/` — leave alone, the wire contract is fine.
- `XPBarController.client.lua` — leave alone, client-side coalescing is fine.
- `NameTagEffectController.client.lua` — leave alone, the client-side effect controller doesn't talk to TitleService.
- `_No_Touch_Systems.md` list — re-read before starting.

## 9. Studio Test Checklist

- [ ] **Console clean.** `[TitleService] script ready` + `[NameTag] script ready` both print at startup. No new errors.
- [ ] **Join auto-equip.** Test user joins; correct title auto-equips on the nametag (gamepass `believer` for the test account).
- [ ] **Mid-session level change updates title.** Bump leaderstats.Level via command bar across a milestone (e.g. 9 → 10); combined fade fires; nametag title updates to `still here`. (Note: gamepass priority means the displayed title may not change if gamepass is owned — verify by also testing with `userOwnsGamePass` stubbed to false to see the level title.)
- [ ] **Post-respawn level change still updates title.** Force respawn via `Humanoid.Health = 0`. After spawn completes, bump leaderstats.Level again across another milestone. Verify the fade fires and the title updates. **This is the regression test for Item B.** If the title doesn't update post-respawn, leaderstats is being recreated and `attachLevelWatcher` isn't re-running — debug from there.
- [ ] **Avalog watchdog still works.** Force-destroy the BillboardGui via command bar (`game.Players.<name>.Character.HumanoidRootPart.NameTag:Destroy()`). Verify it re-creates with the title row + correct title text + effect — same as the PR #12 test.
- [ ] **No `_G.SadCaveTitleService` references remain.** `git grep "SadCaveTitleService"` returns no matches in `src/`.

## 10. Rollback Notes

- Item A is a refactor; revert with `git revert` of the merge commit. The behavior is identical to PR #12 by design.
- Item B is a one-line addition (`attachLevelWatcher(player)` inside the CharacterAdded handler). Revert by removing that one line. The function is idempotent so removing the call is safe — the system reverts to PR #12's "attach once at PlayerAdded" behavior.
- No DataStore migrations. No remote-contract changes. No no-touch boundaries crossed. Rollback is clean.
