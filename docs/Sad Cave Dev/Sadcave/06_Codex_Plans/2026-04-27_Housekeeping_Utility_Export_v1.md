# Housekeeping + Utility Export — Codex Plan

**Date:** 2026-04-27
**Related Systems:** [[../02_Systems/_Live_Systems_Reference]], [[../02_Systems/_No_Touch_Systems]], [[../02_Systems/_Cleanup_Backlog]], [[../02_Systems/Dialogue_System]]
**Branch:** `codex/housekeeping-utility-export`
**Spec source of truth:** the 11 Studio-only objects you flagged in PR #2's "Flagged uncertain / left out for review" section, plus the two pending items from `2026-04-27_Repo_Strip_to_Studio_State_v1` that PR #2 didn't cover.

---

## 1. Purpose

Finish the post-cleanup repo housekeeping in one swing. Three tracks:

1. **Export 11 Studio-only kept-list objects** into the Rojo source tree (or, where appropriate, document why an object stays Studio-only). These were on Tyler's keep list during the 2026-04-27 cleanup but were left out of PR #2 because Codex (correctly) declined to guess at repo shape without confirmation.
2. **Retire `xp-only.project.json`** at the repo root. It was scaffolding for the XP MVP build phase; XP is shipped, default project is canonical.
3. **Resolve `docs/live-repo-audit.md`** — currently stale (written 2026-04-20, pre-cleanup). Default to freezing it with a banner; full refresh only if Tyler asks.

After this brief lands, every kept Studio system is either represented in the repo (Rojo can sync it cleanly into a fresh place) or has an explicit "intentionally Studio-only" entry in `_Live_Systems_Reference.md`. No more silent gaps between Studio and the repo.

**Out of scope for this brief:**

- Any change to scripts already in `src/` (XP Progression, Notes, ToolPickup, ReportHandler, NameTagScript, AfkEvent/AfkDetector, FavoritePromptPersistence). They're post-cleanup canon.
- Any redesign or rewrite of dialogue, prompt, or utility scripts. Export the live source as-is. If something looks wrong, flag with `[C] ?` and leave it; design decisions are Claude's to make.
- Cleanup of `place-backups/` `.rbxl` files.
- Editing `AGENTS.md`, `PLANS.md`, or `README.md`.

## 2. Player Experience

None. This is repo housekeeping. After this lands, `rojo serve default.project.json` against a fresh Studio instance should sync the entire kept set into place with no missing scripts.

## 3. Technical Structure

### Server responsibilities

None changed. Scripts being exported run exactly as they do now in Studio.

### Client responsibilities

None changed.

### Remote events / functions

Two folders potentially exported as remote-bearing folders:

- `ReplicatedStorage.DialogueRemotes` — Folder containing four RemoteEvents per `_Live_Systems_Reference.md`: `PlayPlayerDialogue`, `PlayCharacterDialogue`, `PlayerDialogueChoiceSelected`, `RequestCharacterConversation`. Wire contracts. Renaming would break dialogue, so **don't rename** — export with the names exactly as Studio has them.

### DataStore keys touched

None — no script logic changes.

## 4. Files / Scripts

### The 11 Studio-only objects to handle

For each, the action is one of: **Export to repo** with the listed path, or **Document as Studio-only** in `_Live_Systems_Reference.md` with a one-line reason. Default to Export unless the object is genuinely Workspace-bound or has a Rojo-incompatible name.

| # | Studio path | Class | Action | Repo path |
|---|------------|-------|--------|-----------|
| 1 | `ReplicatedStorage.DialogueData` | ModuleScript | Export | `src/ReplicatedStorage/DialogueData.lua` |
| 2 | `ReplicatedStorage.DialogueRemotes` | Folder + 4 RemoteEvents | Export | `src/ReplicatedStorage/DialogueRemotes/` (folder with `init.meta.json` + 4 RemoteEvent subfolders, each with `init.meta.json` containing `{"className": "RemoteEvent"}`). Mirror the `ReplicatedStorage.NoteSystem/` pattern that's already in repo. |
| 3 | `ServerScriptService.RemoveFF` | Script | Export | `src/ServerScriptService/RemoveFF.server.lua` |
| 4 | `ServerScriptService.DiscordLogs` | Script | Export | `src/ServerScriptService/DiscordLogs.server.lua` |
| 5 | `ServerScriptService.Reset` | Script | Export | `src/ServerScriptService/Reset.server.lua` |
| 6 | `ServerScriptService.SoftShutdown` | Script | Export | `src/ServerScriptService/SoftShutdown.server.lua` |
| 7 | `StarterPlayerScripts.PromptGroup` | LocalScript | Export | `src/StarterPlayer/StarterPlayerScripts/PromptGroup.client.lua` |
| 8 | `StarterPlayerScripts.PromptFavorite` | LocalScript | Export | `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` |
| 9 | `StarterPlayerScripts.NpcDialogueClient` | LocalScript | Export | `src/StarterPlayer/StarterPlayerScripts/NpcDialogueClient.client.lua` |
| 10 | `StarterPlayerScripts.PlayerDialogueClient` | LocalScript | Export | `src/StarterPlayer/StarterPlayerScripts/PlayerDialogueClient.client.lua` |
| 11 | `StarterPlayerScripts.environment change` | (verify class) | **Decide** | See below |

### Special case: `environment change` (#11)

Has a trailing space in the name, which is a known Rojo path blocker (a file named `environment change.client.lua` is fine on disk but the trailing space disambiguation in folder paths is fragile). Three branches:

- **Branch A — Investigate first.** `script_read` it. If the contents are a one-line stub or it's clearly dead code (no useful function, just a leftover from old work), prefer Branch C below.
- **Branch B — Rename and export.** If the script is doing something live and useful, rename it in Studio to `EnvironmentChange` (no space) via Studio MCP, then export to `src/StarterPlayer/StarterPlayerScripts/EnvironmentChange.client.lua`. Document the rename in the inbox: `[C] HH:MM — Renamed StarterPlayerScripts."environment change" → EnvironmentChange to fix Rojo path. Behavior unchanged.`
- **Branch C — Document as Studio-only and leave alone.** If it's dead or unclear, don't export, don't rename. Add an entry to `_Live_Systems_Reference.md` under "Studio-only / kept-in-place but not in repo": `- environment change — trailing-space name blocks Rojo path. Function unclear; left in Studio pending tone audit. Verify whether to rename + export or delete next time someone touches lighting/environment.`

**Default to Branch C** unless the script is obviously live and useful. Don't take rename risk on something that might be dead.

### Workspace.ToolPickups

Re-confirmed Studio-only this session — empty Workspace folder used by `ToolPickupService` to stop yielding. Not part of this brief; leave alone.

### Files to delete

- `xp-only.project.json` at repo root — superseded by `default.project.json`.

### Files to update

- `docs/live-repo-audit.md` — prepend the freeze banner exactly:

  ```
  > ⚠️ FROZEN AS HISTORICAL — reflects pre-2026-04-27 cleanup state. Do not extend. The 2026-04-27 cleanup invalidated most of the live-side classifications below; a fresh audit can be requested when actually needed.
  ```

  Don't refresh the body. Tyler will ask if a fresh audit is needed.

- `02_Systems/_Live_Systems_Reference.md` — for any object you Document-as-Studio-only (Branch C above, or any of #1–10 you couldn't export for reasons you flag), add a one-line entry under the relevant service's "Studio-only" section explaining why.

### Files NOT to touch

Per `_No_Touch_Systems.md`:

- Anything in `src/ServerScriptService/Progression/`, `src/ReplicatedStorage/Progression/`, `src/StarterGui/XPBar/`.
- `src/ServerScriptService/NoteSystemServer.server.lua`, `src/ReplicatedStorage/NoteSystem/`, `src/ServerScriptService/ReportHandler.server.lua`, `src/ServerScriptService/report/`, `src/ReplicatedStorage/ReportRemotes/`.
- `src/ServerScriptService/FavoritePromptPersistence.server.lua` (note: this is the *server* persistence script, paired with `PromptFavorite` client — not the same file).
- `src/ReplicatedStorage/AfkEvent/`, `src/ServerScriptService/NameTagScript.server.lua`, `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua` (just landed).
- `default.project.json` — only delete `xp-only.project.json`, don't touch the canonical one.
- `AGENTS.md`, `PLANS.md`, `README.md`.

## 5. Step-by-Step Implementation (for Codex)

### Phase 0 — Setup

1. Re-read `AGENTS.md` (the workflow) and the latest `_Live_Systems_Reference.md` (post-2026-04-27 reality). Skim `_No_Touch_Systems.md` so the boundaries are fresh.
2. `git checkout main && git pull && git checkout -b codex/housekeeping-utility-export`
3. `[C]` log: `[C] HH:MM — Starting housekeeping-utility-export. Phase 0 setup complete.`

### Phase 1 — Export ReplicatedStorage objects (#1, #2)

4. **`DialogueData`:** read `ReplicatedStorage.DialogueData` via Studio MCP `script_read`. Write to `src/ReplicatedStorage/DialogueData.lua`. The file should be the exact ModuleScript source — no edits, no reformatting beyond preserving existing line endings. `[C]` log size + line count: `[C] HH:MM — Exported DialogueData (N lines, M bytes).`
5. **`DialogueRemotes`:** create `src/ReplicatedStorage/DialogueRemotes/init.meta.json` with `{"className": "Folder"}`. For each of the four RemoteEvents (verify exact names via Studio MCP `inspect_instance` on `ReplicatedStorage.DialogueRemotes`), create `src/ReplicatedStorage/DialogueRemotes/<RemoteName>/init.meta.json` containing `{"className": "RemoteEvent"}`. Use the existing `ReplicatedStorage.NoteSystem/` folder structure as the model. `[C]` log: `[C] HH:MM — Exported DialogueRemotes folder + 4 RemoteEvents: <list of names>.`

### Phase 2 — Export ServerScriptService scripts (#3–#6)

6. For each of `RemoveFF`, `DiscordLogs`, `Reset`, `SoftShutdown`: `script_read` the live source, write to `src/ServerScriptService/<Name>.server.lua`. `[C]` log per script: line count + a one-line summary of what it does (read enough to write the summary; this isn't a redesign, just a note for the inbox).
7. **Special handling for `SoftShutdown`:** `_Cleanup_Backlog.md` notes there used to be multiple `SoftShutdown` duplicates. Tyler kept one canonical. Confirm that's still the case — if Studio shows multiple `SoftShutdown` objects in `ServerScriptService`, flag with `[C] ?` and don't export until disambiguated.

### Phase 3 — Export StarterPlayerScripts client scripts (#7–#10)

8. For each of `PromptGroup`, `PromptFavorite`, `NpcDialogueClient`, `PlayerDialogueClient`: `script_read` and write to `src/StarterPlayer/StarterPlayerScripts/<Name>.client.lua`. `[C]` log per script.
9. **Special handling for `PromptFavorite`:** the deleted `PromptFavorite.server.lua` from PR #2 was a misplaced server script in `StarterPlayerScripts` (which should hold LocalScripts). The live `PromptFavorite` is the LocalScript at `StarterPlayerScripts.PromptFavorite`, paired with `ServerScriptService.FavoritePromptPersistence`. Export the LocalScript as `.client.lua`. Don't restore the deleted server file.

### Phase 4 — Handle `environment change` (#11)

10. `script_read` `StarterPlayerScripts."environment change"`. Read the contents.
11. Decide branch: A → re-investigate, B → rename and export, C → document as Studio-only.
12. Default to **Branch C**. Add an entry under the relevant section in `_Live_Systems_Reference.md` (StarterPlayer Studio-only).
13. `[C]` log the decision and reasoning.

### Phase 5 — Retire `xp-only.project.json`

14. `git rm xp-only.project.json` (or delete via filesystem — Rojo no longer references it).
15. Commit with message: `Remove xp-only.project.json now that XP MVP shipped to main`.

### Phase 6 — Freeze `live-repo-audit.md`

16. Edit `docs/live-repo-audit.md` — prepend the exact banner specified in the "Files to update" section above. No other changes.
17. Commit with message: `Freeze live-repo-audit.md as historical post-2026-04-27 cleanup`.

### Phase 7 — Studio test

18. With the branch checked out and `default.project.json` serving via Rojo, connect to the testing place.
19. Start a playtest via Studio MCP `start_stop_play`. Watch console output for errors.
20. Confirm:
    - Dialogue still works (try approaching `Workspace.QuietKeeperNPC` and triggering the conversation prompt) — if dialogue UI appears and a line plays, the dialogue export is intact.
    - XP bar still appears.
    - Nametag still shows display name.
    - No new console errors compared to a pre-branch baseline.
21. Stop playtest.
22. `[C]` log result: errors, expected behavior confirmed, anything weird.

### Phase 8 — Push and hand back

23. `git push -u origin codex/housekeeping-utility-export`
24. Tell Tyler the branch is pushed and ready for Claude review. State which objects exported, which got Branch C treatment, the SoftShutdown disambiguation result, the environment-change decision, and the playtest outcome.

## 6. Roblox Services Involved

Studio MCP only — `script_read`, `inspect_instance`, `start_stop_play`, `console_output`. No Roblox runtime services change.

## 7. Security / DataStore Notes

- ⚠️ No DataStore keys are read or written.
- ⚠️ No remote names change. **The four `DialogueRemotes` keep their exact existing names** — renaming would break live clients.
- ⚠️ `script_read` returns line numbers prefixed; strip those before writing to repo files. Verify the exported files don't have `1→`, `2→`, etc. as a prefix.

## 8. Boundaries (do NOT touch)

- Any script in `src/ServerScriptService/Progression/`, `src/ReplicatedStorage/Progression/`, `src/StarterGui/XPBar/`.
- `src/ServerScriptService/NoteSystemServer.server.lua`, `src/ReplicatedStorage/NoteSystem/`, `src/ServerScriptService/ReportHandler.server.lua`, `src/ServerScriptService/report/`, `src/ReplicatedStorage/ReportRemotes/`.
- `src/ServerScriptService/FavoritePromptPersistence.server.lua` — kept canonical persistence script.
- `src/ReplicatedStorage/AfkEvent/`, `src/ServerScriptService/NameTagScript.server.lua`, `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua`.
- `default.project.json`, `AGENTS.md`, `PLANS.md`, `README.md`.
- `place-backups/*.rbxl`.

## 9. Studio Test Checklist

- [ ] All 11 Studio-only objects either exported into the repo with the listed path, or have a one-line entry under "Studio-only" in `_Live_Systems_Reference.md` explaining why
- [ ] `xp-only.project.json` deleted from repo root
- [ ] `docs/live-repo-audit.md` has the freeze banner prepended
- [ ] Rojo serves `default.project.json` cleanly with no unexpected diffs against the testing place
- [ ] Playtest: dialogue works (QuietKeeper conversation triggers and renders)
- [ ] Playtest: XP bar visible, presence tick fires, no Progression console errors
- [ ] Playtest: nametag shows display name
- [ ] No new console errors vs baseline
- [ ] Inbox `[C]` log has a line per export with line count and one-line summary
- [ ] Branch pushed to GitHub

## 10. Rollback Notes

- Each export creates new files in `src/`. Rollback for any single file is `git checkout main -- <path>`.
- `xp-only.project.json` deletion: restore from `main` history.
- `live-repo-audit.md` banner: revert that single file.
- The branch is independent of `main` until merged. If the playtest reveals anything weird, fix on this branch — `main` is unaffected until Tyler merges.

## 11. Notes for Claude (review)

When Codex pushes, walk `_Review_Template.md`. For this brief specifically:

- Diff sanity check: every new file in `src/` should match the live Studio object's content byte-for-byte (modulo line endings). Spot-check 2-3 of them.
- Confirm Codex's `[C] ?` flags are resolved — especially the SoftShutdown disambiguation and the environment-change decision.
- Independent playtest worth running: dialogue is the most likely thing to be subtly broken (e.g., a remote folder structure mismatch), so prioritize that smoke test.
- Verdict to Tyler: list which objects landed in repo, what got Branch C treatment, anything flagged.
