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

### XPBar invisible to player despite GUI hierarchy reporting it as rendered

- Status: open
- Priority: medium
- Client or server: client
- Where it happens: testing place, every Studio playtest (reported 2026-04-27 Cowork session 5 walkthrough)
- Exact object/script path: `Players.<player>.PlayerGui.XPBar` (`StarterGui.XPBar` in repo: `src/StarterGui/XPBar/`)
- Repro steps:
  1. Start a Studio playtest in `Testing cave`.
  2. Spawn into the world, observe the screen.
  3. Look for the XPBar at the bottom of the screen.
- Expected result: a thin warm-tinted bar visible at the bottom of the screen, partially filled to indicate progress within the current level.
- Actual result: Tyler reports "the xp bar vanished a long while back" — he can't see it in Play.
- Roblox output / error message: none captured. Console output is quiet.
- Suspected cause: probe via `execute_luau` shows `XPBar` ScreenGui is `Enabled=true`, `Background` Frame is at the bottom-screen anchor with `Size=(1,0,0,4)` and `Visible=true`, `Fill` Frame is at scale-X 0.786 (78.6% filled) with `Visible=true`, `LevelLabel` and `HoverDetector` are also present. So the bar is technically rendering. Two leading hypotheses: (a) the bar is so subtle (`Background.BackgroundTransparency=0.85`, `Fill.BackgroundTransparency=0.6`, only 4 pixels tall) that Tyler stopped seeing it; (b) another ScreenGui covers it — `Menu` ScreenGui is also enabled with 5 children, plausible candidate for overlay; or (c) a runtime path is hiding/destroying parts of the bar that the probe didn't catch (e.g. a tween path failing during one of the `XPUpdated` payloads).
- Notes: needs a screenshot during Play to ground-truth what Tyler is actually seeing, and a comparison to what the GUI hierarchy reports. Probe-vs-render mismatch is the puzzle.

### XP system grants AFK rate (3) while player is physically seated at a SeatMarker

- Status: open (design question + possible bug)
- Priority: medium
- Client or server: cross-cutting (client AfkDetector + server ProgressionService/PresenceTick)
- Where it happens: testing place, observed 2026-04-27 Cowork session 5 walkthrough
- Exact object/script path: client `StarterPlayer.StarterPlayerScripts.AfkDetector` (`src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua`); server `ServerScriptService.Progression.Driver` + `ProgressionService` + `Sources.PresenceTick`
- Repro steps:
  1. Start a Studio playtest in `Testing cave`.
  2. Walk to `Workspace.SeatMarkers.Seat` and sit (`Humanoid.Sit=true`).
  3. Tab away from Studio (e.g. into another window like a chat or browser) for the full 60-second tick interval.
  4. Watch the leaderstats `XP` value for the next tick.
- Expected result: after `SITTING_THRESHOLD_SECONDS=30` of seated time, ticks should grant `PRESENCE_SITTING_XP=20` per 60-second interval (×1.5 = 30 if gamepass owned).
- Actual result: tick grants `PRESENCE_AFK_XP=3` instead. Captured live: `delta=+3, level=557, total=230,727 → 230,730` while `Humanoid.Sit=true` and `SeatPart=Workspace.SeatMarkers.Seat`.
- Roblox output / error message: none — system has no per-tick logging.
- Suspected cause: `PresenceTick.GetTickAmount` checks `state.isAFK` first and returns AFK rate without considering `state.seatedAt`. The client `AfkDetector` fires `AfkEvent:FireServer(true)` on `WindowFocusReleased` and `false` on `WindowFocused`; if Studio loses focus (e.g. Tyler in Cowork chat) the server sets `state.isAFK=true` and stays there until `WindowFocused` fires. While AFK, sitting is ignored.
- Notes: open design question for Tyler — should "seated at a SeatMarker" override window-focus AFK? In Sad Cave's tone (presence-rewarding, quiet exploration), a player physically seated who briefly switches windows is arguably not "AFK" in the meaningful sense. Resolution path: either (a) make `PresenceTick.GetTickAmount` prefer `seatedAt` over `isAFK` when both are set; (b) tighten AFK detection (require focus-loss + idle for some duration); (c) leave as-is and accept that focus-loss demotes you. Captured for design call rather than auto-fixed.

## Resolved bugs

### FavoritePromptPersistence runtime error on `SourceCode` line 4

- Status: **resolved by attrition** (2026-04-29 — moved to Resolved after 9 quiet sessions)
- Priority: was low
- Client or server: server
- Resolution: did NOT reproduce in 9 consecutive playtest sessions following PR #8 (PRs #8 → #14 + Cowork session 10 design playtest + 2026-04-29 AchievementTracker review playtest). Original error was logged during PRs #4 and #5 playtests, last seen Cowork session 5. Most likely the error was timing-dependent on something specific to the pre-cleanup testing-place state — Tyler's heavy 2026-04-27 cleanup (which deleted ~20 systems) appears to have removed whatever was racing with `FavoritePromptPersistence` during initialization. `FavoritePromptPersistence` is a no-touch system; no code change was made to fix the error. Watch flag from Active section retired. If the error reappears in a future session, reopen with timestamp + repro steps and revisit.
- See: `_Change_Log.md` 2026-04-29 entries; `_Known_Bugs.md` Active section history (now retired).


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
