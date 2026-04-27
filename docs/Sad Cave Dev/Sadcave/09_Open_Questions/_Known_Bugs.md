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
- Notes: the audit refresh (PR #6) revealed `FavoritePromptPersistence` depends on `Workspace.Avalog` (a 453-script subtree). Could be related. Investigation deferred until Tyler decides whether to bring `Avalog` into the repo or not. **Do not fix without an Opus-written brief** — `FavoritePromptPersistence` is on the no-touch list.

### PromptFavorite infinite yield warnings on `FavoritePromptShown`

- Status: open
- Priority: low (pre-existing, not blocking new work)
- Client or server: client
- Where it happens: testing place, every Studio playtest
- Exact object/script path: `StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` (or one of the scripts of that name — see class-mismatch bug below)
- Repro steps:
  1. Start a Studio playtest.
  2. Watch the console output for warnings about `FavoritePromptShown`.
- Expected result: no infinite-yield warnings.
- Actual result: warning that the script is yielding indefinitely on `FavoritePromptShown`.
- Suspected cause: a missing or never-fired event named `FavoritePromptShown` somewhere in the dependency chain.
- Notes: pre-existing; first observed during PR #4 playtest. Not investigated yet.

### PromptFavorite class mismatch — exported as `.client.lua` but live class is `Script`

- Status: open
- Priority: medium (export type mismatch could cause subtle runtime divergence)
- Client or server: client (live class is `Script` running in StarterPlayerScripts; uses `Players.LocalPlayer` and client prompt APIs, so it functions as a LocalScript)
- Exact object/script path: `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` was exported during PR #4, but live `StarterPlayerScripts.PromptFavorite` is class `Script` (not `LocalScript`).
- Repro steps:
  1. `inspect_instance` on `StarterPlayer.StarterPlayerScripts.PromptFavorite` in Studio — class is `Script`.
  2. Look at repo file `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` — extension implies LocalScript.
- Expected result: the repo extension matches the live class.
- Actual result: extension/class mismatch. There's also a duplicate-named `PromptFavorite` Script flagged as a tooling blocker in PR #6.
- Suspected cause: legacy practice of running client logic in a `Script` parented under StarterPlayerScripts (Roblox treats it as client-side because of the parent). The repo export normalized to `.client.lua` for clarity but didn't update the live class.
- Notes: needs a small Codex brief to either (a) change live class to `LocalScript` to match repo, or (b) rename repo file to `.lua` and let `init.meta.json` declare the class. Resolve the duplicate-named `PromptFavorite` Script tooling blocker at the same time.

## Resolved bugs

- _(none yet)_

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
