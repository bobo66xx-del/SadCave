# Repo Strip to Studio State — Codex Plan

**Date:** 2026-04-27
**Related Systems:** [[../02_Systems/_Live_Systems_Reference]], [[../02_Systems/_Cleanup_Backlog]], [[../02_Systems/_No_Touch_Systems]], [[../02_Systems/XP_Progression]]
**Branch:** `codex/repo-strip-to-studio-state`
**Spec source of truth:** Tyler's testing-place cleanup pass on 2026-04-27 (logged in `00_Inbox/_Inbox.md` 2026-04-27 evening section). The cleaned testing place is now the structural reference for what should remain in the repo.

---

## 1. Purpose

Bring the repo into agreement with the cleaned-up Studio testing place after Tyler's 2026-04-27 deletion pass. This is **not** a redesign — it's reconciliation. Almost everything in the repo's `src/` already matches the kept-post-cleanup set (Codex's XP MVP work and earlier strips already pruned the legacy mappings). Three repo-level housekeeping items remain:

1. **Confirm the three new post-cleanup artifacts are present and current** in `src/` — they should be, but a final verification commit-or-no-op pass is in scope so we have a clean record.
2. **Retire `xp-only.project.json`** — it was a temporary scaffold for the XP MVP build phase; default project is the canonical sync target now that XP is shipped.
3. **Freeze or refresh `docs/live-repo-audit.md`** — written 2026-04-20 and now massively stale (lists tons of live objects that were deleted on 2026-04-27). Either update its coverage table to reflect post-cleanup reality, or seal it like `PLANS.md` and start a new audit if needed.

**Out of scope for this brief:**
- Any change to scripts that already exist in `src/` (XP Progression, Notes, ToolPickup, ReportHandler, NameTagScript, AfkEvent/AfkDetector, etc.) — these are post-cleanup canon.
- Any repo additions beyond confirming the three new artifacts are committed.
- Any redesign work on systems that were deleted from Studio. The vault specs for those (Title_System v2, Daily_Rewards, Area_Discovery, etc.) are reframed by Opus separately — Codex doesn't touch them.
- Cleanup of `place-backups/` `.rbxl` files — these are intentional backups; leave alone.
- `AGENTS.md` content edits — Opus owns that file; Codex doesn't touch it.

## 2. Player Experience

None. This is a tooling / housekeeping task. After this lands, `rojo serve` against `default.project.json` will sync exactly the kept-post-cleanup files into a clean Studio session, with no leftover legacy paths or temporary build scaffolds.

## 3. Technical Structure

### Server responsibilities
None changed.

### Client responsibilities
None changed.

### Remote events / functions
None changed.

### DataStore keys touched
None.

## 4. Files / Scripts

### Files to verify (should already be present and correct — no-op if so)

- `src/ServerScriptService/NameTagScript.server.lua` — robust nametag attached to `HumanoidRootPart` with `AncestryChanged` watchdog (Avalog-safe). **Verify:** file exists, content matches what's currently in Studio at `ServerScriptService.NameTagScript`. If Studio has changed since the last commit, sync the newer version into the repo.
- `src/ReplicatedStorage/AfkEvent/init.meta.json` — `{"className": "RemoteEvent"}`. **Verify:** exists.
- `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua` — fires `AfkEvent` on `WindowFocused` / `WindowFocusReleased`. **Verify:** file exists, content matches Studio.

### Files to delete

- `xp-only.project.json` — superseded; XP Progression MVP shipped to `main`. Default project is canonical.

### Files to update

- `docs/live-repo-audit.md` — this file is stale enough that it's actively misleading. Two acceptable resolutions; **flag with `[C] ?` and pick one** based on what the live state supports:
  - **Option A (refresh):** rewrite the coverage snapshot and the lists to match post-cleanup Studio. This means walking the live tree once, reclassifying, and rewriting the doc. Probably 1-2 hours of work.
  - **Option B (freeze):** add a banner at the top: `> ⚠️ FROZEN AS HISTORICAL — reflects pre-2026-04-27 cleanup state. Do not extend. New audits start fresh.` Like `PLANS.md` was frozen. Then leave the file as-is.

If unsure, pick Option B — it's reversible and conservative. Tyler can ask for a fresh audit when one is actually needed.

### Workspace.ToolPickups (Studio-only)

`Workspace.ToolPickups` is an empty Folder Tyler created post-cleanup so `ToolPickupService` stops yielding. **Leave it Studio-only** — empty Workspace folders are typical Studio state, not Rojo source. Document in inbox that this is intentional.

### Files NOT to touch

Per `_No_Touch_Systems.md` and `_Cleanup_Backlog.md` (Opus refreshed both this session):

- Any script in `src/ServerScriptService/Progression/` — XP MVP, just shipped, no-touch.
- `src/ServerScriptService/NoteSystemServer.server.lua` and the `NoteSystem` remotes — saved player data.
- `src/ServerScriptService/ReportHandler.server.lua` and the `ReportRemotes` folder — moderation surface.
- `src/ServerScriptService/FavoritePromptPersistence.server.lua` — Avalog-tied persistence.
- `src/StarterGui/XPBar/` — XP MVP UI.
- `default.project.json` — leave structure alone; only delete `xp-only.project.json`.
- `AGENTS.md`, `PLANS.md`, `README.md` — Opus owns workflow docs; Codex doesn't touch them.
- `place-backups/*.rbxl` — intentional backup snapshots.

## 5. Step-by-Step Implementation (for Codex)

### Phase 0 — Setup

1. Read [[../02_Systems/_Live_Systems_Reference]] (post-2026-04-27 refreshed version), [[../02_Systems/_Cleanup_Backlog]], and [[../02_Systems/_No_Touch_Systems]]. The first one is your map of what's currently live; the second tells you what's already been removed and not to extend; the third is the do-not-touch list.
2. `git checkout main && git pull && git checkout -b codex/repo-strip-to-studio-state`
3. `[C]` log: `[C] HH:MM — Starting repo-strip-to-studio-state. Phase 0 setup complete.`

### Phase 1 — Verify the three new artifacts are committed and current

4. Open `src/ServerScriptService/NameTagScript.server.lua`. Open Studio and read `ServerScriptService.NameTagScript` (Studio MCP `script_read`). If they differ, copy the Studio version into the repo file. If identical, `[C]` log: `[C] HH:MM — NameTagScript.server.lua matches Studio, no change.`
5. Confirm `src/ReplicatedStorage/AfkEvent/init.meta.json` exists and contains `{"className": "RemoteEvent"}`. If absent or wrong, fix it.
6. Open `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua`. Compare to Studio `StarterPlayer.StarterPlayerScripts.AfkDetector`. Sync if different.
7. `[C]` log per file: matched-or-synced status.

### Phase 2 — Retire `xp-only.project.json`

8. Delete `xp-only.project.json` from the repo root.
9. Commit with message `Remove xp-only.project.json now that XP MVP shipped to main`.
10. `[C]` log: `[C] HH:MM — Deleted xp-only.project.json.`

### Phase 3 — Resolve `docs/live-repo-audit.md`

11. Read `docs/live-repo-audit.md` in full. It's the post-2026-04-20 audit, written before the testing-place cleanup.
12. Decide between Option A (full refresh) and Option B (freeze with banner). **Default to Option B** unless Tyler has explicitly asked for a fresh audit. If you go with B:
    - Prepend a banner: `> ⚠️ FROZEN AS HISTORICAL — reflects pre-2026-04-27 cleanup state. Do not extend. The 2026-04-27 cleanup invalidated most of the live-side classifications below; a fresh audit can be requested when actually needed.`
    - Commit with message `Freeze live-repo-audit.md as historical post-2026-04-27 cleanup`.
13. `[C]` log: `[C] HH:MM — live-repo-audit.md frozen with historical banner.` (or, for Option A: `refreshed with post-cleanup state`).
14. Flag to Tyler in the inbox: `[C] ? — live-repo-audit.md handled via Option B (freeze). If you want a fresh audit, just say.`

### Phase 4 — Studio test (light)

15. With the branch checked out and Rojo serving `default.project.json`, connect to the testing place. Confirm Rojo connects without errors and no extra files are pushed/pulled (the `$ignoreUnknownInstances: true` flag should keep it conservative). `[C]` log: `[C] HH:MM — Rojo serve clean, no unexpected diffs.`
16. Quick playtest via `start_stop_play` to confirm nothing in the kept set broke. Watch console for errors. `[C]` log the result.

### Phase 5 — Push and hand back

17. `git push -u origin codex/repo-strip-to-studio-state`
18. Tell Tyler the branch is pushed and ready for Opus review. State which option you picked for the audit, what was no-op vs synced for the three artifacts, and any errors during Phase 4.

## 6. Roblox Services Involved

None directly — this is repo housekeeping. Studio MCP is used for verifying `script_read` parity on the three artifacts and for the playtest in Phase 4.

## 7. Security / DataStore Notes

- ⚠️ No DataStore keys are read or written in this brief.
- ⚠️ No remotes change names, contracts, or argument shapes.
- ⚠️ No security boundary moves.

## 8. Boundaries (do NOT touch)

- Do not alter scripts inside `src/ServerScriptService/Progression/`, `src/ReplicatedStorage/Progression/`, `src/StarterGui/XPBar/`. The XP MVP just shipped — touching it triggers an Opus review of the wrong scope.
- Do not alter `src/ServerScriptService/NoteSystemServer.server.lua`, `src/ReplicatedStorage/NoteSystem/`, or any `Report*` files — saved data and moderation surfaces.
- Do not edit `AGENTS.md`, `PLANS.md`, or `README.md`.
- Do not delete from `place-backups/`.
- Do not push to `main` — branch only.

## 9. Studio Test Checklist

- [ ] Rojo serves `default.project.json` cleanly with no unexpected diffs against the testing place
- [ ] `[C] ?` flagged for the audit Option choice (A or B) so Opus can confirm during review
- [ ] `start_stop_play` runs with no console errors
- [ ] XP system still functions (XPBar visible, presence tick fires) — quick smoke test, not a re-validation of XP MVP
- [ ] All three new artifacts (`NameTagScript`, `AfkEvent`, `AfkDetector`) are confirmed in repo and matching Studio

## 10. Rollback Notes

This brief makes minimal repo changes. Rollback is straightforward:

- `xp-only.project.json` deletion: restore from `main` history (`git checkout main -- xp-only.project.json`).
- `live-repo-audit.md` banner / refresh: revert that single file.
- The three artifact verifications are no-op if everything matched; if any were synced, the change is replacing repo content with the Studio version, which is the actual desired state — no rollback needed.

If the branch goes wrong somehow, just don't merge it. `main` is unaffected.
