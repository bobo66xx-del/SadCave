# Known Bugs

## Purpose
Track current issues in the Sad Cave Roblox project with concrete repro details, exact object/script paths, and validation status.

## Bug template
### Bug name
- Status: open / in progress / fixed / blocked
- Priority: high / medium / low
- Client or server:
- Where it happens: Studio, live server, specific map/zone.
- Exact object/script path: e.g. `StarterGui/MainGui/PlayButton` or `ServerScriptService/DataStoreManager`.
- Repro steps:
  1. 
  2. 
  3. 
- Expected result:
- Actual result:
- Roblox output / error message:
- Screenshot / log reference:
- Suspected cause:
- Notes:

## Active bugs
- Use this section for bugs that still need work.
- Include exact paths and status updates.

## Resolved bugs
- Keep a short history of fixed bugs and the solution implemented.
- This helps avoid regressions and provides context for future changes.

## Common Roblox bug categories
- Nil references when a GUI or part is renamed or missing.
- RemoteEvents/RemoteFunctions firing with invalid arguments or missing handlers.
- DataStore failures on save/load and missing fallback logic.
- UI visibility issues caused by disabled `ScreenGui` or incorrect parent hierarchy.
- Group/rank reward checks failing due to `GroupService` configuration or rank mismatches.
- Lighting/zone transitions not triggering when players cross region parts.

## Notes
- Always capture the exact Studio path and the player state when the bug occurs.
- If the bug is client-only, note the LocalScript and the `StarterGui` object tree.
- If the bug is server-only, note the ServerScriptService path and any relevant RemoteEvent listeners.
