# Live Repo Audit Refresh — Codex Plan

**Date:** 2026-04-27
**Status:** 🟢 Shipped — PR #6 (merged 2026-04-27 20:51 UTC, branch `codex/live-repo-audit-refresh`, commit b878ce6). 49 rows classified (27 Exact / 0 Structural / 5 Studio-only / 10 Manual export / 7 Tooling blocker). Audit caught three vault drift items (Studio id, IntroScreen/Menu still live, SeatMarkers child-script) — all reconciled in `Environments.md`, `_UI_Hierarchy.md`, and `_Live_Systems_Reference.md` post-merge.
**Branch:** `codex/live-repo-audit-refresh`
**Related Systems:** [[../02_Systems/_Live_Systems_Reference]], [[../02_Systems/_UI_Hierarchy]], [[../02_Systems/_No_Touch_Systems]]
**Spec source of truth:** the cleaned testing place (Studio MCP — `Testing cave`) compared against the current `src/` tree. The old `docs/live-repo-audit.md` was authored before Tyler's 2026-04-27 cleanup pass and was frozen with a banner via PR #4 (Option B). Tyler's call: redo it fresh now that most legacy systems are gone.

---

## 1. Purpose

Replace the frozen `docs/live-repo-audit.md` with a current, authoritative classification of every top-level live object in the testing place against what's tracked in `src/`. The goal is a short, scannable doc that anyone (Tyler, Claude, future-Codex) can look at and answer two questions immediately:

1. Is this live object in the repo? (Exact / Structurally mapped / Not in repo)
2. If not in repo, why? (Studio-only intentional / Manual export needed / Tooling blocker / Deferred secret)

After the cleanup, the live testing place is small enough that the audit should fit comfortably in one page per container. It is the queue for any future export work.

**Out of scope for this brief:**

- Any actual export work. The audit *classifies*; it doesn't move files. If the audit reveals an object that should be in the repo and isn't, flag it; don't fix it in this brief.
- Any change to live Studio state. Read-only inspection across the board.
- Any change to scripts the audit covers — including obvious bug fixes you might notice. Capture them in the inbox; don't fix.
- Production place. This audit is testing-place-only. Production gets its own audit when production cutover work begins (per `01_Vision/Environments.md`).

## 2. Player Experience

None. This is documentation work.

## 3. Technical Structure

No code changes. The deliverable is a Markdown file at `docs/live-repo-audit.md`. The structure:

- A header block with `Last refreshed:` date, `Auditor:` (Codex), `Place:` (`Testing cave`), and a short legend of the four classification buckets.
- One section per top-level Studio container that the project cares about: `ServerScriptService`, `ReplicatedStorage`, `StarterGui`, `StarterPlayer/StarterPlayerScripts`, `StarterPlayer/StarterCharacterScripts`, `Workspace` (top-level only — don't enumerate every part), `Lighting` (only if there are scripts under it), `SoundService` (only if scripts).
- Within each container, a table with columns: `Object`, `Class`, `Repo path` (or `—`), `Bucket`, `Notes`.

### Buckets

- **Exact** — present in `src/` and byte-for-byte equal to the live source (verify with `script_read` + comparison).
- **Structurally mapped** — present in `src/` but not byte-exact (transcription drift, formatting differences, line-ending differences, etc.). Note line counts.
- **Studio-only (intentional)** — deliberately not in repo. Examples: `Workspace.ToolPickups` empty Folder, `ServerScriptService.DiscordLogs.LogsSettings` (secret), `StarterPlayerScripts."environment change "` trailing-space empty Folder, anything you discover that's clearly placeholder/dev-only.
- **Manual export needed** — should be in the repo but isn't. Codex did the right thing flagging it instead of guessing repo shape. Caller of the audit decides next step.
- **Tooling blocker** — cannot be exported via current MCP tooling (e.g. UI with `AnchorPoint=null` returning incorrectly, duplicate-named children that can't be uniquely addressed). Document the blocker briefly so future tooling fixes can target it.

### Special handling

- **No-touch systems** — listed but classified normally. The audit doesn't change them; it just records them.
- **DiscordLogs** — classified as Studio-only (intentional, deferred) with a note pointing at the [[2026-04-27_DiscordLogs_Secret_Refactor_v1]] brief. Don't expand on the secret approach here.
- **DialogueDirector** — should be Exact post-PR #5; verify against the restored source.
- Anything in `_Live_Systems_Reference.md` that doesn't show up in Studio during the walk: flag in inbox as a possible vault-vs-Studio drift.

## 4. Files / Scripts

### File to create (overwrite the frozen one)

- **`docs/live-repo-audit.md`** at the repo root. Replace the entire file. The frozen banner stays in `_Change_Log.md` as a record; it's not preserved in the audit doc itself.

### Files NOT to touch

Per `_No_Touch_Systems.md`:
- All scripts in `src/ServerScriptService/Progression/`, `src/ReplicatedStorage/Progression/`, `src/StarterGui/XPBar/`.
- `src/ServerScriptService/NoteSystemServer.server.lua`, `src/ReplicatedStorage/NoteSystem/`, `src/ServerScriptService/ReportHandler.server.lua`, `src/ServerScriptService/report/`, `src/ReplicatedStorage/ReportRemotes/`.
- `src/ServerScriptService/FavoritePromptPersistence.server.lua`, `src/ReplicatedStorage/AfkEvent/`, `src/ServerScriptService/NameTagScript.server.lua`, `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua`.
- All scripts exported in PRs #4 and #5 (DialogueData, DialogueRemotes, RemoveFF, Reset, SoftShutdown, PromptGroup, PromptFavorite, NpcDialogueClient, PlayerDialogueClient, DialogueDirector).
- `default.project.json`, `AGENTS.md`, `PLANS.md`, `README.md`.

This is a read-only audit. The only file written is `docs/live-repo-audit.md`.

## 5. Step-by-Step Implementation (for Codex)

### Phase 0 — Setup

1. Re-read `AGENTS.md` (Session Bookends + Codex Rules) and `_No_Touch_Systems.md`.
2. `git checkout main && git pull && git checkout -b codex/live-repo-audit-refresh`
3. `[C]` log: starting brief.

### Phase 1 — Inventory the live testing place

4. `list_roblox_studios` to confirm the active instance is `Testing cave` (id `b2f076e7-1056-4618-9ac5-3e41f079a2e4` per `Environments.md`; verify in case it's changed).
5. For each top-level container below, use `inspect_instance` (or `search_game_tree` if more efficient) to enumerate children. **One container at a time**, top-level only — don't recurse into nested folders for the audit table; recurse only when needed to verify byte-exactness.
   - `ServerScriptService`
   - `ReplicatedStorage`
   - `StarterGui`
   - `StarterPlayer.StarterPlayerScripts`
   - `StarterPlayer.StarterCharacterScripts`
   - `Workspace` (top-level children only — don't list every part)
   - `Lighting` (only if there are scripts under it; skip if pure visual config)
   - `SoundService` (only if scripts)
6. `[C]` log per container: `[C] HH:MM — Inventoried <Container>: <N> top-level children.`

### Phase 2 — Classify each object

7. For each top-level child found in Phase 1:
   - Look for a corresponding entry in `src/` (matching container path).
   - If present in `src/`: `script_read` the live source and read the repo file; compare. Bucket = **Exact** if identical, **Structurally mapped** if different.
   - If absent from `src/`: decide between **Studio-only (intentional)**, **Manual export needed**, or **Tooling blocker**:
     - Empty Folders, trailing-space-name objects, secret-bearing scripts → **Studio-only (intentional)**.
     - Real scripts/UI that should reasonably be tracked → **Manual export needed**.
     - Anything you'd export but the connector can't address (duplicates, AnchorPoint nulls, returns numbered conversation instead of source) → **Tooling blocker**.
8. `[C]` log: `[C] HH:MM — Classified <Container>: Exact <X>, Structural <Y>, Studio-only <Z>, Manual <W>, Blocker <V>.`

### Phase 3 — Write the audit doc

9. Open `docs/live-repo-audit.md` and replace the entire contents with the fresh audit. Suggested top-of-file template:

   ```markdown
   # Live Repo Audit — Testing Place

   **Last refreshed:** 2026-04-27 (Codex, brief `2026-04-27_Live_Repo_Audit_Refresh_v1`)
   **Place:** `Testing cave` (Studio id: `b2f076e7-1056-4618-9ac5-3e41f079a2e4`)
   **Repo:** `SadCaveV2` @ `main`

   > Authoritative classification of every top-level live object's export status.
   > Refresh policy: redo whenever a substantive cleanup or export pass lands.
   > Buckets:
   > - **Exact** — present in `src/` and byte-for-byte equal to live.
   > - **Structurally mapped** — in `src/`, not byte-exact. Line counts noted.
   > - **Studio-only (intentional)** — deliberately not in repo.
   > - **Manual export needed** — should be in repo, isn't yet.
   > - **Tooling blocker** — can't be exported via current MCP tooling.

   ## ServerScriptService

   | Object | Class | Repo path | Bucket | Notes |
   |--------|-------|-----------|--------|-------|
   | ... | ... | ... | ... | ... |

   ## ReplicatedStorage
   ...
   ```

10. Fill every container table from Phase 2 data. Sort each table alphabetically by Object name. Use `—` in the Repo path column when there is no repo entry.
11. End the file with a "Summary" section: bucket totals across the whole testing place, plus a short list of any **Manual export needed** items so future briefs can pick them up cleanly.
12. **Do NOT include the old frozen banner**, the pre-cleanup audit content, or any speculation about production. This file is testing-place reality on 2026-04-27.

### Phase 4 — Sanity check the doc

13. Read your own audit top-to-bottom. Spot-check three random Exact entries against Studio. If any Exact entry isn't actually byte-exact, fix the classification before pushing.
14. Confirm the no-touch systems all appear in the doc (audit *does* include them — it just doesn't change them).
15. `[C]` log: `[C] HH:MM — Audit doc written, N pages, M total objects classified, breakdown <buckets>.`

### Phase 5 — Push and hand back

16. `git add docs/live-repo-audit.md && git commit -m "Refresh live-repo-audit to post-cleanup testing-place state" && git push -u origin codex/live-repo-audit-refresh`
17. Tell Tyler: branch pushed, total objects classified, count per bucket, and the list of any **Manual export needed** items so the next brief can be scoped.

## 6. Roblox Services Involved

Read-only access to the testing place via Studio MCP — no service-level interaction.

## 7. Security / DataStore Notes

- ⚠️ This is a read-only audit. Do not modify any live script during the walk, even if you spot a bug.
- ⚠️ DiscordLogs / LogsSettings: do **not** read or echo the webhook URL. Classify the parent script as Studio-only (deferred) and move on.
- ⚠️ The audit must not contain the webhook URL or fragments of it. If you accidentally paste source containing it, redact before commit.

## 8. Boundaries (do NOT touch)

See "Files NOT to touch" above. Plus: don't refactor the audit format mid-pass — if you see a better structure, finish the current pass and propose the format change in the inbox for a future refresh.

## 9. Studio Test Checklist

This is a doc brief, not a build brief. The "test" is the audit's own correctness. Checklist:

- [ ] All listed top-level containers walked
- [ ] Every Exact entry spot-checked at least once for byte-equality
- [ ] No-touch systems all appear in the audit (just listed, not modified)
- [ ] DiscordLogs classified as Studio-only with pointer to its refactor brief
- [ ] `Workspace.ToolPickups` and `environment change ` (trailing-space) classified as Studio-only intentional
- [ ] DialogueDirector verified Exact against the restored source from PR #5
- [ ] Summary section with bucket totals and Manual-export queue
- [ ] No webhook URL, no secret content, no fragments thereof in the audit doc
- [ ] Branch pushed

## 10. Rollback Notes

Trivial: `git checkout main -- docs/live-repo-audit.md` reverts to the frozen banner version. No code is affected.

## 11. Notes for Claude (review)

When Codex pushes:

- Spot-check a handful of Exact entries against live source via Studio MCP — pick one each from ServerScriptService, ReplicatedStorage, and StarterPlayerScripts. Confirm byte-exactness.
- Check that the **Manual export needed** list is reasonable — if anything obvious is missing, that's a sign the walk wasn't complete.
- Confirm no DiscordLogs source / webhook URL leaked into the audit file (`grep -r "discord.com/api/webhooks" docs/live-repo-audit.md` should return nothing).
- Confirm the doc replaces the frozen banner cleanly — no stray pre-cleanup content remains.
- Verdict format: "Audit looks consistent — N Exact, M Structural, K Manual-export queue, none of those surprising" / "Hold off — <specific issue>" / "Need Tyler's call on <flag>."

After this merges, the index gets a one-line change-log entry and the `docs/live-repo-audit.md` reference in the Workflow & Capture section gets its "currently frozen" note replaced. That's an integration task at end-of-session, not part of this brief.
