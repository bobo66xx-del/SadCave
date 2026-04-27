# Known Bugs

> **Role of this doc:** persistent tracker for open and recently-resolved bugs. Lives in `09_Open_Questions/` because it has the same persistence model — items stay until resolved.
>
> **Capture flow:** during a session, drop bug observations into `00_Inbox/_Inbox.md` with a `?` flag. At integration, Opus moves them here if they need investigation. When fixed, move to "Resolved bugs" with the date and solution.

## Bug template

```
### Bug name
- Status: open / in progress / fixed / blocked
- Priority: high / medium / low
- Client or server:
- Where it happens: Studio, live server, specific map/zone
- Exact object/script path: e.g. `StarterGui/MainGui/PlayButton`
- Repro steps:
  1.
  2.
  3.
- Expected result:
- Actual result:
- Roblox output / error message:
- Suspected cause:
- Notes:
```

## Active bugs

### FavoritePromptPersistence runtime error on `SourceCode` line 4

- Status: open
- Priority: low (pre-existing, not blocking new work)
- Client or server: server
- Where it happens: testing place, every Studio playtest
- Exact object/script path: `ServerScriptService/FavoritePromptPersistence.server.lua` line 4
- Repro steps:
  1. Start a Studio playtest in the testing place.
  2. Watch the console output.
- Expected result: clean startup, no errors.
- Actual result: error logged on `FavoritePromptPersistence.SourceCode` line 4.
- Roblox output / error message: not captured verbatim — Codex flagged the error during PRs #4 and #5 playtests but didn't paste the full stack.
- Suspected cause: unknown. `FavoritePromptPersistence` is a no-touch system; the error may relate to its `Workspace.Avalog` dependency that the audit refresh flagged as load-bearing-but-not-in-repo.
- Notes: the audit refresh (PR #6) revealed `FavoritePromptPersistence` depends on `Workspace.Avalog` (a 453-script subtree). Could be related. Investigation deferred until Tyler decides whether to bring `Avalog` into the repo or not (Tyler 2026-04-27: skipped the Avalog Manual Export, so this stays deferred). **Do not fix without an Opus-written brief** — `FavoritePromptPersistence` is on the no-touch list.
- 2026-04-27 PR #8 playtest observation: this error did NOT reproduce in Codex's PR #8 playtest run. One non-repro doesn't equal "fixed" — could be flaky, timing-dependent, or affected by something in the testing-place state. Watch flag: if it stops reproducing across multiple sessions, move to Resolved with a "did not reproduce after PR #8" note.

## Resolved bugs

### PromptFavorite infinite yield warnings on `FavoritePromptShown`

- Status: **fixed by PR #8** (2026-04-27 22:00 UTC)
- Priority: was low
- Client or server: client
- Resolution: bounded the unbounded `WaitForChild("FavoritePromptShown")` in `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` to a 10s timeout, with a tagged graceful-return warn (`"FavoritePromptShown remote missing in ReplicatedStorage; favorite prompt disabled this session"`) and an early `return` if the remote never appears. Codex's PR #8 read of `FavoritePromptPersistence` confirmed the contract: the server creates `FavoritePromptShown` at runtime via `Instance.new` and listens with `:OnServerEvent`, so the original yield was a race between the client's wait and the server's runtime publish. The 10s bound is comfortably larger than the observed publish time. Codex's playtest confirmed no infinite-yield warning, normal `[FavoritePrompt]` script logs, and `[FavoritePrompt] delayed prompt started FavDelay= 600` firing as expected.
- See: `06_Codex_Plans/2026-04-27_PromptFavorite_Bugs_Cleanup_v1.md`, `_Change_Log.md` 2026-04-27 22:00 UTC.

### PromptFavorite class mismatch — duplicate `Script` instance in StarterPlayerScripts

- Status: **fixed by PR #8** (2026-04-27 22:00 UTC)
- Priority: was medium
- Client or server: client
- Resolution: deleted the duplicate `StarterPlayer.StarterPlayerScripts.PromptFavorite` `Script` class instance via Studio MCP. The canonical `LocalScript` (matching `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` byte-equal modulo one trailing newline) stays. The original "class mismatch" repro in this file was actually `inspect_instance` resolving the ambiguous path to the duplicate `Script` instance and reporting its class — the repo file itself was always Exact-matched against the canonical `LocalScript`. Codex captured the deleted duplicate's full source in inbox before deletion as a recovery path. The audit's `duplicate StarterPlayer.StarterPlayerScripts.PromptFavorite Script` tooling blocker is now resolved.
- See: `06_Codex_Plans/2026-04-27_PromptFavorite_Bugs_Cleanup_v1.md`, `_Change_Log.md` 2026-04-27 22:00 UTC, `docs/live-repo-audit.md` Tooling Blockers section.

## Common Roblox bug categories

- Nil references when a GUI or part is renamed or missing
- RemoteEvents/RemoteFunctions firing with invalid arguments or missing handlers
- DataStore failures on save/load and missing fallback logic
- UI visibility issues caused by disabled `ScreenGui` or incorrect parent hierarchy
- Group/rank reward checks failing due to `GroupService` configuration or rank mismatches
- Lighting/zone transitions not triggering when players cross region parts

## Notes

- Always capture the exact Studio path and the player state when the bug occurs
- If the bug is client-only, note the LocalScript and the `StarterGui` object tree
- If the bug is server-only, note the ServerScriptService path and any relevant RemoteEvent listeners
