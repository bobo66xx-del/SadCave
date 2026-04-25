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

- _(none yet)_

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
