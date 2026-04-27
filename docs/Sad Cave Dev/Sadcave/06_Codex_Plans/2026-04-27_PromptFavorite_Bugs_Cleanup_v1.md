# PromptFavorite Bugs Cleanup — Codex Plan

**Date:** 2026-04-27
**Status:** 🟢 Shipped — PR #8 (merged 2026-04-27 22:00 UTC, branch `codex/promptfavorite-bugs-cleanup`)
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/promptfavorite-bugs-cleanup`
**Related Systems:** [[../09_Open_Questions/_Known_Bugs]], [[../02_Systems/_No_Touch_Systems]], [[../docs/live-repo-audit]]

---

## 1. Purpose

Clean up two pre-existing bugs around `StarterPlayerScripts.PromptFavorite`:

- **Bug A — Infinite yield on `FavoritePromptShown`.** `PromptFavorite.client.lua` line 15 does `ReplicatedStorage:WaitForChild("FavoritePromptShown")` with no timeout. The 2026-04-27 live-repo audit lists every `ReplicatedStorage` child and `FavoritePromptShown` is **not** among them, so this `WaitForChild` triggers Roblox's 5-second infinite-yield warning on every playtest.
- **Bug B — Duplicate `PromptFavorite` in StarterPlayerScripts (tooling blocker).** Audit shows two top-level objects named `PromptFavorite` under `StarterPlayer.StarterPlayerScripts`: the canonical `LocalScript` (matches `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` Exact, 69 live lines) **and** a duplicate `Script` class with the same name not represented in `src/`. This duplicate is also what produced the original "class mismatch" repro in `_Known_Bugs.md` — `inspect_instance` resolved to the `Script` class instance and reported a class mismatch against the repo's `.client.lua` extension. The repo file itself is fine; the live duplicate `Script` is the problem.

Both bugs are low/medium priority, pre-existing, and do not block any current work. Goal is repo + live cleanliness, not new behavior.

## 2. Player Experience

Nothing visible. The favorite prompt itself only fires after 600 seconds of play and is gated by server-side eligibility. After this brief ships:

- No infinite-yield warning in the console on every playtest.
- The favorite prompt either still fires the same way it did before (if it was working) or fails silently with a tagged log line (if `FavoritePromptShown` truly doesn't exist live). Either is an improvement over the current "warns every session, behavior unclear" state.

## 3. Technical Structure

- **Server responsibilities:** none new. The brief is read-only against `ServerScriptService.FavoritePromptPersistence` to understand the contract — see Boundaries below.
- **Client responsibilities:** `StarterPlayerScripts/PromptFavorite.client.lua` adds a bounded `WaitForChild` for the `FavoritePromptShown` RemoteEvent and exits gracefully with a tagged log if it never appears.
- **Remote events / functions:** `ReplicatedStorage.FavoritePromptShown` (existing — created or expected by `FavoritePromptPersistence`; do not modify the server).
- **DataStore keys touched:** none.

## 4. Files / Scripts

- `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` — modify (add WaitForChild timeout + graceful exit).
- Studio-only via Studio MCP: delete duplicate `StarterPlayer.StarterPlayerScripts.PromptFavorite` Script class instance, leaving only the canonical `LocalScript`.

No other repo files in scope.

## 5. Step-by-Step Implementation (for Codex)

1. **Branch + read context.**
   - Branch off `main`: `git checkout main && git pull && git checkout -b codex/promptfavorite-bugs-cleanup`.
   - Read `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` end-to-end. Note that `PromptShownRemote:FireServer()` is the only contract point with the server.
   - Read `src/ServerScriptService/FavoritePromptPersistence.server.lua` — **read only, do not modify.** Look specifically for:
     - whether `FavoritePromptPersistence` creates `ReplicatedStorage.FavoritePromptShown` at runtime (e.g. `Instance.new("RemoteEvent", ReplicatedStorage)`) or expects it to pre-exist;
     - what handler it registers on `:OnServerEvent`.
   - Read `docs/live-repo-audit.md` `ReplicatedStorage` and `StarterPlayer.StarterPlayerScripts` rows to confirm the audit findings still match what you see in Studio.

2. **Investigate the duplicate `PromptFavorite` in Studio (Bug B).**
   - Use `search_game_tree` with name `PromptFavorite` under `StarterPlayer.StarterPlayerScripts` to enumerate both instances.
   - Use `inspect_instance` (with whatever instance reference disambiguates the duplicate — index, instance id, etc.) on each to confirm: one is `LocalScript`, the other is `Script`.
   - `script_read` the `Script` class duplicate. **Compare its source against the canonical `LocalScript`.**
     - If the duplicate `Script` source is byte-equal to the `LocalScript`, **or differs only by trailing whitespace / line-ending characters** (e.g. one extra `\n` at end-of-file, or CRLF vs LF) → treat as accidental copy and **delete the duplicate**. Whitespace-only diffs are not meaningful source differences in Luau and don't change behavior.
     - If the duplicate `Script` source differs in any non-whitespace way (different code, different comments, different identifiers, different constants) → **stop. Flag with `[C] ? — PromptFavorite duplicate Script source differs from LocalScript: <diff summary>`.** Do not delete; do not silently pick one. Hand back to Opus for review.
   - Before deleting the duplicate either way, capture its full source verbatim in an inbox `[C]` line so we have a recovery path in case the deletion turns out to have been wrong.
   - Delete the duplicate `Script` instance via Studio MCP. The canonical `LocalScript` (which matches the repo) stays.

3. **Patch the infinite-yield (Bug A).**
   - In `PromptFavorite.client.lua`, replace the unbounded WaitForChild on line 15:
     ```lua
     local PromptShownRemote = ReplicatedStorage:WaitForChild("FavoritePromptShown")
     ```
     with a bounded wait + graceful early return. Suggested shape (you may refine for style):
     ```lua
     local REMOTE_WAIT_TIMEOUT = 10 -- seconds; long enough to let the server publish, short enough to avoid the 5s infinite-yield warning being meaningful
     local PromptShownRemote = ReplicatedStorage:WaitForChild("FavoritePromptShown", REMOTE_WAIT_TIMEOUT)
     if not PromptShownRemote then
         warn("[FavoritePrompt] FavoritePromptShown remote missing in ReplicatedStorage; favorite prompt disabled this session")
         return
     end
     ```
   - The early `return` at module top means the `CharacterAdded` connection at the bottom of the file never gets wired up if the remote is missing — that's the intended graceful degrade.
   - Keep the existing `[FavoritePrompt]` log prefix style for consistency with the rest of the script's prints.
   - Do **not** introduce a new RemoteEvent in `ReplicatedStorage` to "fix" this. If the remote really is missing live, that's the server's job to publish (and `FavoritePromptPersistence` is no-touch). The right fix on the client side is a graceful exit, not adding state.

4. **Playtest.**
   - `start_stop_play` the testing place. Watch `console_output` through character spawn.
   - **Expected outcomes**, depending on whether `FavoritePromptShown` actually exists live:
     - If it exists: no infinite-yield warning, normal eligibility logs from the script. Confirm `[FavoritePrompt] client checking eligibility start` still prints.
     - If it doesn't: the new `FavoritePromptShown remote missing` warn fires once and the script exits. No infinite-yield warning. Confirm the warn appears.
   - Either way: there should be **no Roblox infinite-yield warning** about `FavoritePromptShown` after this change. That's the success criterion.
   - Capture observed behavior with one or more `[C] HH:MM — Playtested: ...` inbox lines.

5. **Push branch and hand back.**
   - Commit messages: `Add WaitForChild timeout for FavoritePromptShown remote` and `Remove duplicate PromptFavorite Script in StarterPlayerScripts` (or one combined commit if you'd rather).
   - `git push -u origin codex/promptfavorite-bugs-cleanup`.
   - Inbox summary: what was deleted (Studio-only), what was patched (repo file), what playtest observed, and any `?` flags.

## 6. Roblox Services Involved

`Players`, `ReplicatedStorage` (read-only structurally — wait for an existing child, do not create one).

## 7. Security / DataStore Notes

- ⚠️ Validation: not applicable — this brief touches a client script that fires an existing RemoteEvent. No new server-side surface, no new validation needed.
- ⚠️ DataStore retry/pcall: not applicable.
- ⚠️ Rate limits: not applicable.

## 8. Boundaries (do NOT touch)

- **`ServerScriptService.FavoritePromptPersistence`** — no-touch. Read-only for context. If the right fix would require modifying it, **stop and flag** with `[C] ?` in the inbox; do not proceed.
- **`Workspace.Avalog`** — no-touch dependency of `FavoritePromptPersistence`, deferred. Do not export, do not modify, do not investigate beyond confirming it's still live.
- The other open `_Known_Bugs.md` entry — `FavoritePromptPersistence` line-4 SourceCode error — is **out of scope for this brief**. It's blocked on the Avalog decision; leave it alone.
- Other live `Workspace` items flagged Manual export in the audit (`Leader2`, `playerBugReportSystem`, `ReportGUI`, `Truss`, `WelcomeBadge`, `Rose`) — out of scope; Tyler decided to leave them Studio-only.
- Other tooling-blocker duplicates in Studio (`Workspace.Model`, `Workspace.Rig`, `Workspace.toggle Lantern`) — out of scope. Only the duplicate `PromptFavorite` Script is in scope.

## 9. Studio Test Checklist

- [ ] No infinite-yield warning on `FavoritePromptShown` during a fresh playtest.
- [ ] If `FavoritePromptShown` exists live: `[FavoritePrompt]` eligibility logs still print on character spawn (script path still wired).
- [ ] If `FavoritePromptShown` does not exist live: the new "remote missing" warn prints once; no further script execution.
- [ ] After the duplicate `Script` instance is deleted, only one `PromptFavorite` exists in `StarterPlayer.StarterPlayerScripts`, and it's a `LocalScript`.
- [ ] No new errors in the console on character spawn that weren't there before.
- [ ] Other unrelated-but-existing pre-existing errors (e.g. `FavoritePromptPersistence` line 4 SourceCode error) are still present unchanged — we did not silently fix or break them.

## 10. Rollback Notes

- Repo change: `git revert` the commit on `main`, or undo the WaitForChild edit by hand. Restoring the unbounded `WaitForChild` brings the warning back but does not break behavior.
- Studio-only change (duplicate `Script` deletion): if the duplicate turns out to have had unique source we missed (this is what the step-2 whitespace-tolerant equality check is meant to catch — if it fires Codex with a real diff, do not delete), restoring it requires re-creating the `Script` instance from the source captured in Codex's inbox notes. Codex must include the duplicate's full source in the inbox before deletion so we have a recovery path even if step 2 said the diff was whitespace-only.

---

**Notes for Opus reviewer:**
- The brief intentionally avoids prescribing a "publish `FavoritePromptShown` from the client side" or "stub the RemoteEvent in `ReplicatedStorage` via Rojo" fix. Both would have side effects on the no-touch `FavoritePromptPersistence` contract. The graceful-degrade on the client is the smallest safe change.
- **Server contract confirmed (Codex investigation, 2026-04-27 session 3):** `FavoritePromptPersistence` creates `ReplicatedStorage.FavoritePromptShown` at runtime via `Instance.new` and listens with `:OnServerEvent`. The infinite-yield warning is therefore a race between the client's unbounded `WaitForChild` and the server's runtime publish — exactly what the bounded-timeout patch in step 3 addresses. No Rojo-static stub is needed (and would actually be wrong, since the server would then have two RemoteEvents to reconcile).
- **Whitespace-only source equality:** step 2 explicitly allows deleting the duplicate `Script` when its source differs from the canonical `LocalScript` only by trailing whitespace / line endings. This was relaxed from a stricter "byte-equal or stop" rule after the first run hit a one-trailing-newline diff (Script 2190 chars, LocalScript 2189) and stalled — Lua/Luau treat trailing whitespace as semantically inert, and Studio copy-paste introduces these deltas trivially. Real non-whitespace diffs still stop-and-flag.
- The duplicate-named-Script tooling-blocker class is shared by `Workspace.Model`, `Workspace.Rig`, `Workspace.toggle Lantern`. This brief is the smallest such resolution to ship; if the pattern works, those three could fold into a follow-up brief later.
