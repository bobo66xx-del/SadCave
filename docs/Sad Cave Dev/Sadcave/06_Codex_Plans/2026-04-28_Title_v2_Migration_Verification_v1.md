# Title v2 Migration — Runtime Verification — Codex Plan

**Date:** 2026-04-28
**Status:** 🟢 Shipped — PR #17 (merged 2026-04-29 03:08 UTC, branch `codex/title-v2-migration-verification`, head `e3d11fd`, merge commit `3ad5880`)
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/title-v2-migration-verification` (merged + deleted)
**Related Systems:** [[../02_Systems/Title_System]]
**Driving notes:** PR #14 (`codex/title-v2-mvp2`, merged 2026-04-28 08:31 UTC) shipped the production-cutover migration code that reads `EquippedTitleV1` and maps via `TitleConfig.MIGRATION`. Codex's PR #14 playtest noted: "Migration was static/best-effort only; I did not write fake DataStore values for the real test user." So the migration logic exists, matches the spec via static review, but has never been exercised at runtime. Before the production-cutover PR (which will flip the cutover flag for live players) ships, we want one concrete runtime confirmation that the migration path actually works end-to-end. This brief does that confirmation cleanly, against synthetic data, with no production risk.

---

## 1. Purpose

Run the v1 → v2 title migration logic against a synthetic UserId, verify the expected mapping lands, and clean up afterward — same temporary-probe pattern as PR #13's `CodexTitleFollowupProbe` (write the probe, run it, capture the result, delete the probe; no code in main). Output of this brief: one Studio playtest log showing each migration mapping case landed correctly, plus a clean DataStore (no leftover synthetic data).

This is **not** a production cutover — it's a one-shot runtime confirmation that the migration code Codex wrote works as the static review claimed it does. After this lands, the production-cutover brief can ship with confidence that the migration path is exercised, not just inspected.

## 2. Player Experience

No player-visible change. This brief lives entirely in test infrastructure — synthetic data, server-side probe, no UI, no player join, no real player data touched.

## 3. Technical Structure

### Probe approach

A temporary `ServerScriptService.CodexMigrationProbe` Script that:

1. **Plants synthetic v1 data** for two test UserIds:
   - UserId `999999991` with `EquippedTitleV1 = "regular"` — should map to `familiar_face` per `TitleConfig.MIGRATION`.
   - UserId `999999992` with `EquippedTitleV1 = "newcomer"` — should map to `new_here` per the table.
   - Optionally a third: UserId `999999993` with `EquippedTitleV1 = "saber_owner"` (a fake shop title not in the migration table) — should fall back to `new_here` because unmappable v1 entries default to `DEFAULT_TITLE_ID`.
2. **Calls the migration logic directly** via the public TitleService module API. The cleanest call is `TitleService.LoadAndMigrateForUserId(userId)` — a small function we add to TitleService for this verification (and that the production-cutover brief can also use as a one-off migration tool if needed). The function should: build a synthetic `Player`-like struct (just `UserId` is needed for the DataStore key), call the existing `loadTitleData` path, return the loaded `titleData` table. Migration should fire automatically because `migratedFromV1` is false on a fresh slate.
3. **Captures and prints results:**
   - Expected: `userId=999999991, equippedTitle="familiar_face", migratedFromV1=true, migratedTitleId="familiar_face"`
   - Expected: `userId=999999992, equippedTitle="new_here", migratedFromV1=true, migratedTitleId="new_here"`
   - Expected: `userId=999999993, equippedTitle="new_here", migratedFromV1=true, migratedTitleId=nil`
4. **Cleans up:** wipes the three synthetic `EquippedTitleV1` keys + the three synthetic `TitleData` keys via `:RemoveAsync`. Verifies cleanup with a final read returning nil.
5. **Self-deletes** when done. Same pattern as `CodexTitleFollowupProbe`: probe lives in the test branch's commit, runs once during the playtest, gets removed before push (or stays in code as a dev-tools utility — Codex's call, but the simplest cut is to delete it).

### Where the migration helper lives

Adding a small public function to `TitleService.lua`:

```lua
function TitleService.LoadAndMigrateForUserId(userId)
    -- Synthetic-Player path: build a stub for DataStore key calls,
    -- then call the existing loadTitleData logic.
    -- Used by the migration verification probe and (later) by any
    -- standalone migration tooling. Not called during normal player flow.
    local stub = { UserId = userId }
    return loadTitleData(stub)
end
```

This is **additive and safe** — it doesn't change any existing code path. `loadTitleData` already accepts anything with a `.UserId` field via `getStoreKey(player)`, so a stub object works. The function is exposed on the public API so Codex's probe can call it cleanly without monkey-patching.

If Codex prefers to keep `LoadAndMigrateForUserId` private and call it via a different mechanism, that's fine — the goal is just runtime verification, not a permanent API surface.

## 4. Files / Scripts

**Create:**
- `src/ServerScriptService/CodexMigrationProbe.server.lua` — temporary Script. Plants synthetic data for three UserIds, calls the migration helper, prints expected vs actual results, cleans up the synthetic data. Self-documenting with header comment explaining "this script is a one-shot runtime verification of the v1 → v2 title migration; delete after running."

**Modify:**
- `src/ServerScriptService/TitleService.lua` — add `TitleService.LoadAndMigrateForUserId(userId)` to the public API (small additive function; ~5 lines). Document inline as "used by migration tooling and verification probes; not called during normal player flow."

**Do NOT modify:**
- Any other TitleService logic. The verification is purely additive — no changes to `loadTitleData`, `migrateFromV1`, or any of the equip/unequip paths.
- `TitleConfig.lua` — the migration table is the source of truth being verified, don't touch it.
- Anything else in the codebase. This brief is verification-only.

**Cleanup at end of brief:**
- Delete `src/ServerScriptService/CodexMigrationProbe.server.lua` from the branch before pushing for review (probe ran, results captured, no need to ship the probe to main). The `LoadAndMigrateForUserId` API addition can stay — it's a small useful surface for future migration tooling.

## 5. Step-by-Step Implementation (for Codex)

1. **Branch.** `git checkout main && git pull && git checkout -b codex/title-v2-migration-verification`.
2. **Read context.** Open `src/ServerScriptService/TitleService.lua` (especially `loadTitleData` and `migrateFromV1`) and `src/ReplicatedStorage/TitleConfig.lua` (the MIGRATION table). Verify the mapping for `regular`, `newcomer`, and confirm there's no entry for `saber_owner` (or pick another fake v1 title that's definitely not in the table).
3. **Add `TitleService.LoadAndMigrateForUserId`.** ~5 lines. Builds a stub `{ UserId = userId }`, calls `loadTitleData(stub)`, returns the result.
4. **Write the probe.** `src/ServerScriptService/CodexMigrationProbe.server.lua`:
   - For each of the three test UserIds: call `DataStoreService:GetDataStore("EquippedTitleV1"):SetAsync(tostring(userId), v1Title)` to plant the fake v1 value.
   - Call `TitleService.LoadAndMigrateForUserId(userId)` for each.
   - Print the result via `print(string.format("[MigrationProbe] userId=%d expected=%s got equippedTitle=%s migratedTitleId=%s migratedFromV1=%s", userId, expected, result.equippedTitle, tostring(result.migratedTitleId), tostring(result.migratedFromV1)))`.
   - Compare each result against the expected mapping; print `PASS` or `FAIL` per case.
   - Clean up: `DataStoreService:GetDataStore("EquippedTitleV1"):RemoveAsync(tostring(userId))` and `DataStoreService:GetDataStore("TitleData"):RemoveAsync(tostring(userId))` for each UserId. Verify each `:GetAsync` post-cleanup returns nil.
   - Wrap the whole flow in pcall and print any errors clearly.
5. **Studio playtest.** Use `start_stop_play` + `console_output`. Confirm:
   - All three test cases print `PASS`.
   - Cleanup succeeded (all six post-cleanup reads returned nil).
   - No errors in the log.
   - `[MigrationProbe]` lines are visible and self-explanatory.
6. **Capture the probe output in inbox** as `[C]` lines so the verification result is preserved in the integration record.
7. **Delete the probe** from the branch (`git rm src/ServerScriptService/CodexMigrationProbe.server.lua`) — keep only the `LoadAndMigrateForUserId` API addition. Re-build with `rojo build` to confirm the branch still compiles cleanly.
8. **Push and hand back for review.** `git push -u origin codex/title-v2-migration-verification`. Standard handoff.

## 6. Roblox Services Involved

`DataStoreService`. That's it. No `Players`, no UI, no MarketplaceService, no Run/Tween/HTTP. Server-only verification.

## 7. Security / DataStore Notes

- ⚠️ **Synthetic UserIds only.** Don't use real player UserIds. The test IDs `999999991`, `999999992`, `999999993` are deliberately chosen above the typical real-account range to avoid collision (real Roblox UserIds today max in the low billions for new accounts, but `999999991-3` are old enough that they may belong to actual accounts — verify by checking `Players:GetUserIdFromNameAsync` for these IDs, OR pick deliberately invalid IDs like `-1` or `0` which Roblox doesn't issue). If Codex wants extra paranoia, prefix the DataStore keys with a probe-namespace like `_PROBE_999999991` to fully isolate from any real player data.
- ⚠️ **Cleanup is mandatory.** The probe writes to real cloud DataStores (the testing place uses real DataStores per `01_Vision/Environments.md`). Leftover synthetic data is harmless functionally but bloats the DataStore listing and would confuse future audits. Cleanup verification (post-cleanup `:GetAsync` returns nil) is part of the probe's success criteria.
- ⚠️ **No production data touched.** The probe operates on synthetic UserIds only. Tyler's real `TitleData` (and all other real player data) is never read or written.
- ⚠️ **DataStore quota.** Three writes + three reads + six removes = ~12 DataStore operations, well under any reasonable rate limit. No throttling concern.

## 8. Boundaries (do NOT touch)

- `ProgressionService.lua` and the rest of `Progression/` — no-touch.
- `TitleConfig.lua` — read only; migration table is the source of truth being verified.
- The equip/unequip path, the placeholder TitleMenu, the `NameTagEffectController`, the XPBar, NameTagScript — all unrelated to this brief.
- Real player data on any DataStore — synthetic UserIds only, never touch real accounts.
- `_No_Touch_Systems.md` list — re-read before starting.

## 9. Studio Test Checklist

- [ ] **All three test cases PASS.** `[MigrationProbe]` log shows `regular → familiar_face`, `newcomer → new_here`, `saber_owner → new_here` (fallback) all match expectations.
- [ ] **`migratedFromV1` is true after migration.** Every test case's result shows `migratedFromV1=true` — confirms the migration is one-shot.
- [ ] **`migratedTitleId` is nil for unmappable entries.** The `saber_owner` case shows `migratedTitleId=nil` (we tried the migration but couldn't map; fell back to default) — confirms the fallback path works.
- [ ] **Cleanup succeeded.** Post-cleanup, six `:GetAsync` calls (three for `EquippedTitleV1`, three for `TitleData`) all return nil. No leftover synthetic data.
- [ ] **No console errors.** The `[MigrationProbe]` script runs cleanly. Any pcall errors are caught and printed clearly without crashing.
- [ ] **No new errors in TitleService.** Adding `LoadAndMigrateForUserId` to the public API didn't break anything; `[TitleService] script ready` still prints, real player flow (Tyler joining as normal) still works.

## 10. Rollback Notes

- Adding `LoadAndMigrateForUserId` is purely additive — `git revert` removes it cleanly, no callers in main code depend on it.
- The probe is deleted before push, so there's nothing in main to roll back from the verification side.
- If for any reason synthetic DataStore data leaks (cleanup failed mid-run), Tyler can manually clean it up via Studio command bar:
  ```lua
  local DataStoreService = game:GetService("DataStoreService")
  for _, userId in ipairs({999999991, 999999992, 999999993}) do
      DataStoreService:GetDataStore("EquippedTitleV1"):RemoveAsync(tostring(userId))
      DataStoreService:GetDataStore("TitleData"):RemoveAsync(tostring(userId))
  end
  ```

## 11. Notes for Tyler / Claude review

- This brief is **runtime verification only**. The actual production cutover is a separate later brief that flips the live cutover flag with a soak period, monitoring, and rollback plan per `01_Vision/Environments.md`. This brief just makes sure the migration logic works as written.
- If any test case FAILs, do not delete the probe. Push the branch with the probe included, flag in inbox what failed, and we'll diagnose. Most likely failure mode: the migration table mapping doesn't match what was actually written, or `loadTitleData` has a subtle path that skips migration when it shouldn't. Either is fixable; the probe is the diagnostic surface.
- Codex caught a Rojo class-swap gotcha during PR #13. If `LoadAndMigrateForUserId` somehow doesn't appear at runtime even though it's in the source, check Studio for stale TitleService instances the same way (`ServerScriptService` for orphaned old `TitleService` modules from before PR #13's class swap).
