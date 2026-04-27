# Inbox

> Unsorted captures from the current session. Empties at end of session.
> **You**, **Opus**, and **Codex** all write here. One line per entry, timestamped.
>
> **Prefixes:**
> - `[U]` — written by you
> - `[O]` — written by Opus
> - `[C]` — written by Codex
> - `?` — unresolved, needs your decision before integration
>
> **Lifecycle:** items get triaged into `02_Systems/`, `_Change_Log.md`, or `09_Open_Questions/` at end of session, then cleared from here. Anything still unresolved stays with a `?` prefix and rolls to next session.

---

<!-- New session entries go HERE — add a new dated section above this line, like:
## 2026-04-26
- [C] 09:15 — first observation
-->

## 2026-04-27

- [C] 00:36 — Starting XP Progression MVP. Phase 0 setup complete: read AGENTS, XP brief, linked specs/context, no-touch and cleanup notes; created branch `codex/xp-progression-mvp`; using existing RemoteEvent folder + `init.meta.json` convention.
- [C] 00:42 — Phase 1 complete: `ReplicatedStorage.Progression` now has `LevelCurve`, `SourceConfig`, `XPUpdated`, and `LevelUp`; `SourceConfig.ENABLED` remains false.
- [C] 00:42 — Phase 2 complete: `ProgressionService.lua` written with ProgressionData load/save, legacy migration reads, cached gamepass check, level/XP state, and remotes.
- [C] 00:42 — Phase 3 complete: `PresenceTick.lua` written with AFK > sitting > active priority and 30s SeatMarker threshold.
- [C] 00:42 — Phase 4 complete: `Driver.server.lua` written; live `AFK` script confirmed only updates nametag from `AfkEvent`, so Progression mirrors `AfkEvent.OnServerEvent` for AFK state.
- [C] 00:42 — Phase 5 complete: `XPBar` ScreenGui and client controller written; UI is bottom ambient bar with hover/tap reveal and soft level-up animation.
- [C] 00:51 — Phase 6 partial Studio test: with `ENABLED=true` locally and legacy level scripts disabled, XPBar cloned into PlayerGui, Level/XP values populated, active tick granted +15 XP, AFK signal path granted +3-sized increments, and console showed no Progression errors.
- [C] 00:51 — ? Phase 6 sitting checklist blocked: testing place has `Workspace.SeatMarkers` but it currently has 0 children/seats, so SeatMarker sitting boost could not be validated against a real marked seat.
- [C] 00:51 — Phase 6 cleanup complete: stopped playtest, restored `SourceConfig.ENABLED=false`, and re-enabled `LevelLeaderstats` / `Levelup` in Studio without saving the place.
- [C] 00:53 — ? Phase 6 remaining limits: timed playtest did not naturally cross a level threshold, and did not cover new-player/no-legacy data, second-join migration variants, gamepass-owner +22 tick, mobile height, or manual hover/tap visual feel.
- [C] 00:55 — Tightened dormant deploy behavior: with `SourceConfig.ENABLED=false`, ProgressionService no longer touches the `LevelLoaded` attribute, leaving the live `LevelLeaderstats` / title pipeline authority alone.
- [C] 00:55 — XP Progression MVP branch pushed and ready for Opus review. Built: ProgressionService, LevelCurve, SourceConfig, PresenceTick, Driver, XPUpdated/LevelUp remotes, XPBar. Tested in Studio: Rojo sync, XPBar clone, migration/loaded Level+XP values, active +15 tick, AFK +3 tick path, no Progression console errors. Flagged: SeatMarker sitting boost untested because `Workspace.SeatMarkers` is empty in the testing place.

## 2026-04-26

- [O] — Fixed Rojo project parse error blocking `rojo serve`. Removed redundant `"className": "Script"` from 4 `init.meta.json` files in `ServerScriptService` (`AntiExploit`, `Custom Chat Script`, `Shop`, `TextChatServiceHandler`). Each conflicted with its sibling `init.server.lua` (newer Rojo rejects the redundant declaration). No behavior change — config hygiene only. Unblocked the first XP session.
- [O] — Fixed second wave of Rojo errors. Triple-bracket UDim2 bug (`[[[a, b]], [[c, d]]]` instead of `[[a, b], [c, d]]`) in 25 init.meta.json files across `SadCaveMusicGui` (13 files) and `ShopMenu` (12 files). Caused by an older Studio exporter; newer one used by `TitleMenu` is fine. Also emptied `notificationUI/Scripting/NotificationsHandler/init.meta.json` (contained only `className: ModuleScript` which conflicted with sibling `init.lua`). All cosmetic/structural — no logic changes.
- [O] — Third wave: removed redundant `"className": "LocalScript"` from 4 init.meta.json files in `StarterPlayer/StarterPlayerScripts` (`ChatBubbleDarkTheme`, `OldChatBubbleTheme`, `RainScript`, `Theme`). Same pattern as the ServerScriptService fix — each had an `init.client.lua` already determining the class. ReplicatedStorage scanned, no className conflicts there.
- [O] — Discovered: `default.project.json` cannot be used to sync the testing place safely. Per `docs/live-repo-audit.md`, the repo only mirrors a fraction of live (`StarterGui` 17%, `ServerScriptService` 11%) and even mapped scripts are not byte-exact — the repo has shorter transcribed versions of live scripts. Full sync would downgrade live. Created targeted `xp-only.project.json` at repo root that only maps `ReplicatedStorage/Progression`, `ServerScriptService/Progression`, and `StarterGui/XPBar` — all empty placeholder dirs for now. For XP MVP work: run `rojo serve xp-only.project.json` instead of default. Default project file unchanged — still valid for whoever does the broader reconciliation work later.

## YYYY-MM-DD (template — do not write here, this is just a format example)

- [O] HH:MM — example: noticed `CashLeaderstats` still referenced in three places, see `_Cleanup_Backlog`
- [U] HH:MM — example: dialogue cooldown felt too short, bumped to 4s
- [U] HH:MM — ? should daily reward streak break on 1 missed day or 2?
