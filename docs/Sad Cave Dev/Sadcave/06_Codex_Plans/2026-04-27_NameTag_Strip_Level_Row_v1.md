# NameTag — Strip Level Row — Codex Plan

**Date:** 2026-04-27
**Status:** 🟢 Shipped — PR #9 (merged 2026-04-27 23:20 UTC, branch `codex/nametag-strip-level-row`)
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/nametag-strip-level-row`
**Related Systems:** [[../02_Systems/NameTag_Status]], [[../02_Systems/XP_Progression]]
**Decision driving this brief:** [[../_Decisions]] 2026-04-27 — "NameTag level row: remove"

---

## 1. Purpose

Strip the `LevelLabel` (and the leaderstats-Level hooking that feeds it) from `src/ServerScriptService/NameTagScript.server.lua`. The nametag becomes name-only: one TextLabel above each player showing the display name, nothing else.

The current script renders both `NameLabel` (display name) and `LevelLabel` (`"level N"` from leaderstats `Level`). Tyler decided in Cowork session 4 to remove the level row because the level already renders in the `XPBar` and the doubled surface was louder than the game's tone allows. See `_Decisions.md` 2026-04-27 for the full reasoning.

This is a small surgical change — about 25 lines deleted, 0 added. No new behavior, no new files, no remote-contract changes.

## 2. Player Experience

After this ships: every player sees a single line of text floating above their character — just the player's name, in the existing soft warm-grey color. The `"level N"` row that currently sits underneath the name disappears entirely. The XPBar at the bottom of the screen continues to display level as before; this change does not touch the XPBar.

## 3. Technical Structure

- **Server responsibilities:** `NameTagScript.server.lua` builds and maintains a BillboardGui with one TextLabel (the existing `NameLabel`). All Level-related code is removed.
- **Client responsibilities:** none changed. The XPBar already gets level info from the `ReplicatedStorage.Progression.XPUpdated` remote payload (not from leaderstats), so it is not affected.
- **Remote events / functions:** none touched. No wire contracts change.
- **DataStore keys touched:** none. `ProgressionService` still writes leaderstats `Level` (NoteSystem's level gate depends on this); only the *consumer* in NameTagScript is removed.

## 4. Files / Scripts

Modify (one file only):

- `src/ServerScriptService/NameTagScript.server.lua`

Do **not** touch:

- `src/ServerScriptService/Progression/*` — no-touch system; still authoritative for leaderstats `Level`.
- `src/StarterGui/XPBar/XPBarController.client.lua` — no-touch (just shipped); separately consumes `XPUpdated` remote.
- Any other file in `src/`.

## 5. Step-by-Step Implementation (for Codex)

Before starting:
1. Confirm Studio is the active testing place (`list_roblox_studios`).
2. Read the current `src/ServerScriptService/NameTagScript.server.lua` end-to-end so you know exactly what's being removed.
3. Branch from clean `main`: `git checkout main && git pull && git checkout -b codex/nametag-strip-level-row`.

The edits inside `NameTagScript.server.lua`:

1. In `buildBillboard(adornee, displayName)`:
   - Delete the entire `levelLabel` block (the `Instance.new("TextLabel")` for `LevelLabel` and all of its property assignments through `levelLabel.Parent = bb`).
   - Resize `nameLabel` to fill the BillboardGui — change `nameLabel.Size = UDim2.new(1, 0, 0.6, 0)` to `UDim2.new(1, 0, 1, 0)`. The label now occupies the full BillboardGui area.
   - Optionally tweak `BillboardGui.Size` from `UDim2.new(0, 200, 0, 50)` down to `UDim2.new(0, 200, 0, 30)` so the empty bottom region doesn't add visual weight. Tyler's call — if unsure, leave at `0, 50` and Tyler can adjust live.
   - Change the function's return signature from `return bb, levelLabel` to just `return bb`. Update every caller accordingly (`local bb, levelLabel = buildBillboard(...)` → `local bb = buildBillboard(...)`).

2. In `applyNameTag(player, character)`:
   - Delete the `local function updateLevel()` block entirely.
   - In `ensureBillboard()`, remove the `levelLabel` references — return only the BillboardGui itself. Update callers.
   - Delete the entire `local function hookLeaderstats(lb) ... end` block.
   - Delete the `local existingLB = player:FindFirstChild("leaderstats") ... end` block that wires up `hookLeaderstats`.
   - Delete the trailing `updateLevel()` call at the end of `applyNameTag`.

3. In the `watchBillboard()` closure: remove the `updateLevel()` call inside the re-create branch. The watchdog should still re-create the BillboardGui on `AncestryChanged`, just without the level update afterward.

4. Sanity-check the diff: nothing else should change. The Avalog-safe `AncestryChanged` watchdog must still be present and identical except for the removed `updateLevel()` call.

5. Run `Rojo` to sync the modified script into Studio (or rely on the live Rojo connection if it's already running).

6. Playtest via `start_stop_play` + `console_output` (Studio MCP):
   - Confirm `[NameTag] script ready` still prints on join.
   - Spawn a character; confirm only the name floats above (no `level 0` row).
   - Force a level-up via the existing XP MVP flow (or wait for one via PresenceTick) and confirm no errors fire from the nametag system. Errors specifically to watch for: "attempt to index nil with `Connect`" or anything mentioning `LevelLabel` / `updateLevel`.
   - Confirm the XPBar still updates on level change (regression check on the no-touch consumer).
   - Capture console output verbatim in the inbox.

7. Capture inbox notes per usual format:
   - `[C] HH:MM — Stripped LevelLabel and leaderstats hooks from NameTagScript per brief.`
   - `[C] HH:MM — Playtested: <observed result>.`
   - Any `?` entries for ambiguity.

8. Commit on the branch with a plain message: `Remove level row from nametag — name-only`.

9. Push: `git push -u origin codex/nametag-strip-level-row`. Tell Tyler the branch is ready for Claude review. Do not merge.

## 6. Roblox Services Involved

`Players` only. The script does not touch `DataStoreService`, `RunService`, `TweenService`, or any other service.

## 7. Security / DataStore Notes

- ⚠️ Validation: not applicable; this script does not accept any client input.
- ⚠️ DataStore retry/pcall: not applicable; this script does not read or write a DataStore.
- ⚠️ Rate limits: not applicable.
- ⚠️ Avalog watchdog: must remain. The `AncestryChanged` re-create branch is the only thing keeping the nametag visible for players whose character flow touches Avalog. Removing it (or breaking it) regresses a previously-fixed bug.

## 8. Boundaries (do NOT touch)

- `src/ServerScriptService/Progression/*` (no-touch — populates leaderstats `Level` for NoteSystem's gate)
- `src/StarterGui/XPBar/*` (no-touch, just shipped)
- `ReplicatedStorage.Progression.*` remotes (live wire contracts)
- `ReplicatedStorage.AfkEvent`, `StarterPlayerScripts.AfkDetector` (independent AFK plumbing)
- Anything in `src/ReplicatedStorage/`, `src/StarterPlayer/StarterPlayerScripts/`, or `src/StarterGui/`
- `_Live_Systems_Reference.md`, `NameTag_Status.md`, `_Change_Log.md`, `00_Index.md` — Claude updates these at integration; do not preempt

## 9. Studio Test Checklist

- [ ] Console shows `[NameTag] script ready` after Play starts.
- [ ] One TextLabel renders above the spawned character — the player's display name, no level text.
- [ ] No `level N` row anywhere on the BillboardGui.
- [ ] No errors in console on join, on character respawn (use `Reset` chat command), or on level change.
- [ ] XPBar still shows the player's level and updates on level-up (regression check; XPBar is no-touch).
- [ ] Avalog watchdog still re-creates the BillboardGui if forcibly destroyed (force a destroy via `execute_luau` on a HumanoidRootPart's `NameTag` if you want to confirm; otherwise call out as untested).

## 10. Rollback Notes

If the change breaks anything in production cutover or someone wants the level row back: revert the merge commit on `main`. The deleted code is preserved in git history under this branch's commits, so a re-add is a one-commit revert. No DataStore migration, no remote-contract impact, no client redeploy needed.

---

## Notes for Claude (review)

- This is a small change but it's the first nametag edit since the 2026-04-27 rebuild. Verify the Avalog watchdog wiring survived intact — that's the load-bearing part, not the visible label work.
- Confirm the playtest covered both spawn (level row absent) and a level-up event (no error from the deleted `updateLevel` path).
- Confirm Codex didn't inadvertently widen scope into Progression or XPBar.
