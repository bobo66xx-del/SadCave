# Live Reconciliation Continuation v1 — Codex Plan

**Date:** 2026-04-25
**Status:** 🔵 Planned
**Related Systems:** [[../02_Systems/_Live_Systems_Reference]], [[../02_Systems/_UI_Hierarchy]]
**Audit:** `docs/live-repo-audit.md` (at repo root) — read this before starting; it's the queue.
**Continues:** the live-only reconciliation work whose history lives in `PLANS.md` (entries from 2026-04-19 and 2026-04-20).

---

## 1. Purpose

Continue the live-only reconciliation by exporting the next three highest-priority load-bearing systems still outside the repo. Per the audit's "highest-priority load-bearing systems still outside repo" section:

1. `game.StarterGui.fridge-ui` — live food/snack interaction UI used at the fridge prop; affects player-visible behavior.
2. `game.ServerScriptService.Theme` — server-side admin/owner theme override for `Lighting.AfterPulseColor`; tied to `StarterPlayer.StarterPlayerScripts.Theme` (already exact in repo) and `ReplicatedStorage.Remotes.Theme`.
3. `game.ServerScriptService.OverheadTagsToggleServer` — controls global overhead-tag enable/disable; ties into the `NameTagScript Owner` pipeline that's already structurally mapped.

Each item gets exported with the same exactness rigor used in prior PLANS.md entries: byte-exact when the connector allows, structurally-mapped-with-line-counts when it doesn't, true-tooling-blocker classification when neither is possible.

## 2. Player Experience

Nothing changes. This is repo work — the live game keeps running off Studio. The export only affects what `src/` contains, not what players see.

## 3. Technical Structure

- **Server responsibilities:** none added. `Theme` and `OverheadTagsToggleServer` are existing live scripts being represented in `src/`.
- **Client responsibilities:** none added.
- **Remote events / functions:** none added. `Theme` already uses `ReplicatedStorage.Remotes.Theme` (in repo). `OverheadTagsToggleServer` likely uses `ReplicatedStorage.OverheadTagsEnabled` (`BoolValue`) and `ReplicatedStorage.RebuildOverheadTags` (`BindableEvent`) per `_Live_Systems_Reference`.
- **DataStore keys touched:** none. No DataStore code is being changed.

## 4. Files / Scripts

### Targets

#### `game.StarterGui.fridge-ui`

Live structure summary (from `_UI_Hierarchy` snapshot):
- `fridge-ui` [`ScreenGui`]
  - `main` [`CanvasGroup`]
    - `mainframe` [`Frame`] — header, sub-header, close button, `LocalScript`, `itemframe` (`ScrollingFrame`) with 8 food item buttons (`bloxiade`, `burger`, `cake`, `chockymilk`, `cola`, `pizza`, `smore`, `taco`), each with `setup` LocalScript, `itemname`, `itemprice`, `UICorner`
  - `close` [`Sound`]
  - `open` [`Sound`]

Repo target: `src/StarterGui/fridge-ui/...`

Expected outcome buckets:
- **Exact-safe** if the connector returns `AnchorPoint` for all centered nodes and raw script source for `mainframe.LocalScript` and the 8 `setup` LocalScripts
- **Tooling blocker** if `AnchorPoint` returns `null` for any centered node (likely `main`, `mainframe`, `itemframe` based on the pattern with other ScreenGuis). Classify in audit and stop.
- **Structurally mapped, not byte-exact** if scripts return numbered conversational output but property data is exposed

#### `game.ServerScriptService.Theme`

Repo target: `src/ServerScriptService/Theme.server.lua`

Expected outcome:
- Likely **exact-safe** — it's a single `Script`, not a UI tree. Per `_Live_Systems_Reference` it only listens to `Remotes.Theme.OnServerEvent`, validates user IDs `1132193781` or `1`, and updates `Lighting.AfterPulseColor.Value`. Small.
- If `get_script_source` returns numbered conversational output (same blocker that's hit other scripts), classify as structurally-mapped with line count and move on.

#### `game.ServerScriptService.OverheadTagsToggleServer`

Repo target: `src/ServerScriptService/OverheadTagsToggleServer.server.lua`

Expected outcome:
- Likely **exact-safe** (single Script). `_Live_Systems_Reference` lists it under "assumptions" — it's not yet inspected. Codex reads it during export.
- If contents reveal it touches `NameTagScript Owner` internals or DataStore code, **STOP and `[C] ?` flag** — that's the no-touch overhead-tag pipeline and Opus needs to scope expansion before continuing.

### Files Codex will touch

- `src/StarterGui/fridge-ui/...` — new tree (or new file if blocked)
- `src/ServerScriptService/Theme.server.lua` — new file
- `src/ServerScriptService/OverheadTagsToggleServer.server.lua` — new file
- `docs/live-repo-audit.md` — update bucket assignments for the three targets
- `PLANS.md` — append a new plan entry following the established format with Status log entries
- `00_Inbox/_Inbox.md` — `[C]` captures as Codex works
- This plan's `Status` field — flip 🔵 → 🟡 → 🟢

## 5. Step-by-Step Implementation (for Codex)

### Phase 0 — Setup

1. Read `docs/live-repo-audit.md` end-to-end. Confirm the three targets are still in "manual export still required → highest-priority load-bearing systems still outside repo".
2. Read `PLANS.md`. Append a new `---`-separated section at the bottom for this work. Use the established format (Goal/Scope/Non-goals/Files/Risks/Steps/Validation/Status log). The Goal is "Export live `fridge-ui`, `Theme`, `OverheadTagsToggleServer` per audit priority queue." Scope is the three targets. Non-goals: don't expand to other audit items, don't modify live, don't refactor.
3. Create branch `live-reconciliation-2026-04-25` from current main.
4. Update this plan's Status: 🔵 Planned → 🟡 In Progress.
5. `[C]` log: `[C] HH:MM — Starting live-reconciliation continuation. Three targets: fridge-ui, Theme, OverheadTagsToggleServer.`

### Phase 1 — Export `ServerScriptService.Theme`

6. Smallest target first. Run `inspect_instance` on `game.ServerScriptService.Theme`. Confirm class is `Script`, get the `Enabled` state.
7. Run `script_read` (or equivalent) to get the live source. Note line count.
8. **If raw source is available:** create `src/ServerScriptService/Theme.server.lua` with exact content. Verify line count matches. Mark "exact and in repo" in the audit. **If only numbered conversational output:** create the file with the transcribed content, mark as "structurally mapped, not byte-exact" with both line counts.
9. **If contents touch DataStore code, gamepass entitlement, or any no-touch system:** STOP and `[C] ?` flag in inbox: `[C] HH:MM — ? Theme contains <X>; outside expected scope. Stopping until Opus reviews.` Don't write the file.
10. Update audit: move `game.ServerScriptService.Theme` from "manual export still required" into the appropriate bucket.
11. `[C]` log: `[C] HH:MM — Theme exported (<bucket>). <line counts>.`

### Phase 2 — Export `ServerScriptService.OverheadTagsToggleServer`

12. Same flow as Phase 1 but for `OverheadTagsToggleServer`. Read it carefully — `_Live_Systems_Reference` doesn't have direct evidence of what it does, only an assumption.
13. Watch for: DataStore writes, MarketplaceService calls, modifications to `NameTagScript Owner` internals, or anything outside "toggle a `BoolValue` and fire a `BindableEvent`". Any of those = `[C] ?` flag and stop.
14. Repo target: `src/ServerScriptService/OverheadTagsToggleServer.server.lua`. Same exact-vs-structural classification as Phase 1.
15. Update audit. `[C]` log result.

### Phase 3 — Export `StarterGui.fridge-ui`

16. Larger target — UI tree, not a single script. Walk the live tree at depth 5 to capture full structure. The `_UI_Hierarchy` snapshot is reference-only; verify against current live before exporting.
17. For each node, check `get_instance_properties` for `AnchorPoint`. If any centered node (`Position` containing `0.5`) returns `null` for `AnchorPoint`, classify the affected subtree as a **tooling blocker** in the audit, do NOT export, and stop. This is the same blocker that hit `IntroScreen`, `NoteUI`, `settingui`, `Custom Inventory.Inventory`, etc.
18. **If `AnchorPoint` is exposed for all centered nodes:** proceed. Build the Rojo tree:
    - `src/StarterGui/fridge-ui/init.meta.json` (root ScreenGui properties)
    - `src/StarterGui/fridge-ui/main/init.meta.json` (CanvasGroup)
    - `src/StarterGui/fridge-ui/main/mainframe/init.meta.json` (Frame)
    - `src/StarterGui/fridge-ui/main/mainframe/LocalScript.client.lua` (the main script)
    - `src/StarterGui/fridge-ui/main/mainframe/itemframe/init.meta.json` (ScrollingFrame)
    - For each of the 8 food items: a folder with `init.meta.json` (ImageButton) + `setup.client.lua` + child meta.json files for `itemname`, `itemprice`, `UICorner`
    - `src/StarterGui/fridge-ui/close/init.meta.json` (Sound)
    - `src/StarterGui/fridge-ui/open/init.meta.json` (Sound)
19. For every script (the main `LocalScript` + 8 `setup` LocalScripts), follow the exact-vs-numbered-output rule from Phase 1.
20. Update audit with the classification (likely a mix: structure exact, scripts mostly exact, some scripts maybe numbered-output-blocker).
21. **If structural drift exists between live and the `_UI_Hierarchy.md` snapshot,** `[C] ?` flag in inbox: `[C] HH:MM — ? fridge-ui drifted from _UI_Hierarchy snapshot: <details>. Opus update?` Codex does not edit `_UI_Hierarchy.md` directly — Opus updates it at integration if the drift is real.
22. `[C]` log: `[C] HH:MM — fridge-ui exported (<bucket counts>). <details>.`

### Phase 4 — Validate

23. Run `default.project.json` parse check (it shouldn't have changed but verify nothing broke).
24. For each new file under `src/`, parse the `init.meta.json` files as JSON to confirm no syntax errors.
25. Confirm no files outside the three target trees were modified.
26. **Do NOT run `rojo serve` or sync to Studio.** This export is repo-only. The repo writes don't push to Studio because we're still in partial-ownership mode and that's intentional per the existing reconciliation strategy.

### Phase 5 — Wrap

27. Update this plan's Status: 🟡 In Progress → 🟢 Shipped.
28. Update `PLANS.md` with the final Status log entries.
29. Stage and commit on branch: `git commit -m "Live reconciliation: export fridge-ui, Theme, OverheadTagsToggleServer"`.
30. Push branch. Don't merge to main.
31. `[C]` log: `[C] HH:MM — Reconciliation continuation complete on branch live-reconciliation-2026-04-25. <N> exact, <N> structural, <N> blocker. Audit updated. Awaiting Opus review.`

## 6. Roblox Services Involved

`StarterGui`, `ServerScriptService`, `ReplicatedStorage` (read-only — `Remotes.Theme`, `OverheadTagsEnabled`, `RebuildOverheadTags`), `Lighting` (read-only — `AfterPulseColor`).

## 7. Security / DataStore Notes

- ⚠️ **No DataStore code modified.** If `OverheadTagsToggleServer` or `Theme` turn out to touch DataStores, that's a STOP signal — the brief is wrong about scope.
- ⚠️ **Validation:** N/A — no new remotes added.
- ⚠️ **Rate limits:** N/A.
- ⚠️ **Monetization:** `fridge-ui` may include purchase flows for the 8 food items. Pull files only, do not edit. If the `setup` LocalScripts contain MarketplaceService calls, that's expected — preserve verbatim.

## 8. Boundaries (do NOT touch)

Per `AGENTS.md`:

- DataStore code (contents)
- Live networking contracts
- Title / overhead tag pipeline contents — **note:** `OverheadTagsToggleServer` is in the perimeter of this pipeline. Codex *exports its file*, doesn't *edit its logic*.

Beyond `AGENTS.md`:

- Don't expand scope. The audit has dozens of other items in the manual-export queue. Stick to the three targets in this brief.
- Don't refactor. If you see ugly code in any exported file, copy it verbatim. Refactors come through Opus design briefs.
- Don't touch the vault. The only vault write is updating this plan's Status field, plus `[C]` entries in `00_Inbox/_Inbox.md`.

## 9. Studio Test Checklist

(This task does not modify Studio. The "test" is post-export validation only.)

- [ ] All new files in `src/` have valid syntax (Lua sources lex; `init.meta.json` files parse as JSON)
- [ ] Line counts in audit match source files for any "structurally mapped" classifications
- [ ] No changes outside the three target trees
- [ ] Audit's bucket assignments updated for all three targets
- [ ] `PLANS.md` has a new `---`-separated section with full Goal/Scope/Status log
- [ ] This plan Status flipped to 🟢

## 10. Rollback Notes

- **Lightweight:** `git checkout main && git branch -D live-reconciliation-2026-04-25`. No Studio impact since this is repo-only work.
- **No `.rbxl` backup needed.** Studio isn't touched.
- If Opus review surfaces issues, fix on the branch and re-push. Don't squash; the Status log entries in `PLANS.md` and inbox are the audit trail.
