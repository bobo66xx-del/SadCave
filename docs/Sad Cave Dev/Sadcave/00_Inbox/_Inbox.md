# Inbox

> Unsorted captures from the current session. Empties at end of session.
> **You**, **Claude**, and **Codex** all write here. One line per entry, timestamped.
>
> **Prefixes:**
> - `[U]` — written by you
> - `[O]` — written by Claude (the letter is legacy short for "Opus" and is preserved so older inbox/change-log entries still read cleanly)
> - `[C]` — written by Codex
> - `?` — unresolved, needs your decision before integration
>
> **Lifecycle:** items get triaged into `02_Systems/`, `_Change_Log.md`, `_Decisions.md`, `_Known_Bugs.md`, or `09_Open_Questions/` at end of session, then cleared from here. Anything still unresolved stays with a `?` prefix and rolls to next session.
>
> **Claude rule (per AGENTS.md Section 4):** before any vault edit during a session, write an `[O]` line first stating what you're about to change and why.

---

<!-- New session entries go HERE — add a new dated section above this line, like:
## 2026-04-28
- [C] 09:15 — first observation
-->

## 2026-04-27 (Cowork session 5)

- [C] 19:20 — Started `2026-04-27_XP_Testing_Place_Bug_Sweep_v1` on branch `codex/xp-testing-bug-sweep`; read the brief, XP progression spec, known bug entries, no-touch list, tone rules, and relevant progression/XPBar scripts.
- [C] 19:20 — `_No_Touch_Systems.md` still lists `ProgressionService` as protected; routing the required per-tick debug print through `Driver.server.lua` instead of editing `ProgressionService.lua`.
- [C] 19:23 — XPBar playtest probe: `Players.vesbus.PlayerGui.XPBar` is enabled, `Background` is `2439x4` at the bottom edge, and `Fill` is `2022x4` (`Size.X.Scale=0.829`). Screenshot shows a very thin warm strip at the bottom; no controller error found.
- [C] 19:23 — ? XPBar likely needs a Tyler visual call, not a code bugfix: current style is 4px tall with `BackgroundTransparency=0.85` and `Fill.BackgroundTransparency=0.6`. Bumping height/opacity would be visible-player-facing restyle, so I am not changing it without approval.
- [C] 19:28 — Added driver-side tick logging and playtested it: console now emits `[Progression] tick: source=active amount=15 ...`, then `source=sitting amount=20` after sitting on `Workspace.SeatMarkers.Seat`.
- [C] 19:28 — Confirmed AFK-vs-sitting diagnosis: while `Humanoid.Sit=true` and `SeatPart=Workspace.SeatMarkers.Seat`, firing the same AFK signal as `WindowFocusReleased` changed the next tick from sitting to `[Progression] tick: source=afk amount=3 ...`; XP delta was `230839 -> 230842`.
- [C] 19:28 — ? Need Tyler design call before code fix per brief: Branch A = seated SeatMarker overrides AFK; Branch B = tighten AFK detection with idle-time gate; Branch C = leave AFK-overrides-sitting as intentional and document later.
- [C] 19:45 — Resumed after Section 0 decisions: applied Branch A by checking `state.seatedAt` before `state.isAFK` in `PresenceTick.GetTickAmount`; changed XPBar resting `barHeight` to 6 only, with transparency/color/tween/bump values unchanged.
- [C] 19:53 — Playtested amended bug sweep in `Testing cave`: XPBar `Background.AbsoluteSize` is `2439, 6` and screenshot shows the 6px bottom strip; no XPBar controller errors appeared.
- [C] 19:53 — Playtested Branch A: seated on `Workspace.SeatMarkers.Seat`, forced `AfkEvent(true)`, next tick stayed `[Progression] tick: source=sitting amount=20 ...`; XP moved `230957 -> 230977`.
- [C] 19:53 — Playtested fallbacks: standing/non-seated with `AfkEvent(true)` logged `source=afk amount=3`; after `AfkEvent(false)`, standing active logged `source=active amount=15`. No new console errors beyond the existing Roblox protected remote warning and existing FavoritePrompt/pass logs.
- [O] — Tyler delegated the call to me. Two picks made: (1) **AFK-vs-sitting = Branch A.** A seated SeatMarker overrides AFK in `PresenceTick.GetTickAmount`. Reason: tone alignment — Sad Cave rewards presence, and the most explicit presence signal in the game is "I sat down at a meditation seat." Window focus is a weak proxy by comparison. Smallest, safest fix: one conditional reorder. The "abuse case" of farming seated XP while alt-tabbed isn't a real problem — no leaderboard race, no economy that breaks at +17 XP/min over AFK rate, and the entire game philosophy is "time spent existing matters." Branch B's idle-time gate adds state for marginal benefit and could be a follow-up if non-seated AFK detection ever needs tightening; Branch C leaves the feature nonfunctional in real play since players alt-tab constantly during normal gaming. (2) **XPBar visibility = barHeight 6 on desktop** (currently 4; mobile already 6). Reason: bar IS rendering per Codex's probe + screenshot, but at 4px with `Background.BackgroundTransparency=0.85` it's the same color as the dark cave at the bottom of the screen — Tyler couldn't see it during a full session. 6px keeps it minimal (still half the level-up bumpHeight of 8) and unifies with mobile. Keeping `Background.BackgroundTransparency=0.85` and `Fill.BackgroundTransparency=0.6` and the warm-tint Fill as-is — only changing the height. About to log both decisions in `_Decisions.md`, move the AFK question from Open Questions Active to Resolved, and amend the brief with a Decisions block at the top so Codex can finish prong 2 and add the height bump.

- [O] — Walkthrough started: XP testing-place sitting-boost check. Tyler reports sitting on `Workspace.SeatMarkers.Seat`, server probe confirms `Humanoid.Sit=true` and `SeatPart=Workspace.SeatMarkers.Seat`. Installed a client-side XPUpdated listener via `_G.SC_TickLog` to capture tick deltas without server access (execute_luau is client-context during Play).
- [O] — Walkthrough finding #1: tick fired with `delta=+3, level=557, total=230,730` at elapsed=22s. That's `PRESENCE_AFK_XP` (3), not `PRESENCE_SITTING_XP` (20) or `PRESENCE_ACTIVE_XP` (15). Means `state.isAFK=true` on the server even though `Humanoid.Sit=true` and `seatPart` is a SeatMarker descendant. PresenceTick.GetTickAmount checks AFK FIRST and returns AFK rate before considering sitting. Almost certainly caused by Tyler's Studio window losing focus while he's been typing in Cowork — `AfkDetector.client.lua` fires `WindowFocusReleased` → server sets isAFK=true; `WindowFocused` should clear it but evidently isn't (Tyler's been mostly in Cowork, focus rarely returns to Studio for the AFK-clear event to fire). Open design question for Tyler: should "physically seated at a SeatMarker" override window-focus AFK? Sad Cave is presence-rewarding and the player at a meditation seat who briefly checks Discord arguably should not collapse to AFK rate.
- [O] — Walkthrough finding #2: Tyler reports "the xp bar vanished a long while back." Probe shows `PlayerGui.XPBar` is `Enabled=true`, `Background` Frame present at the screen-bottom anchor with `Size=(1,0,0,4)` and `BackgroundTransparency=0.85`, `Fill` Frame at 78.6% scale-X with `BackgroundTransparency=0.6` and `Visible=true`, `LevelLabel` and `HoverDetector` present. The bar is rendering as a 4px semi-transparent strip at the bottom of the screen with a 78.6%-filled warm tint. Either it's so subtle Tyler stopped noticing it, OR another ScreenGui is overlaying it (`Menu` ScreenGui is also enabled with 5 children — possible cover). Codex should screenshot during Play to ground-truth.
- [O] — Walkthrough finding #3: console output is quiet — only the initial-join logs (`[NameTag]`, `[FavoritePrompt]`) appear, and `[NameTag] script ready` shows the strip shipped. No XP-tick logs because `Driver.server.lua`, `ProgressionService`, and `PresenceTick` don't `print()` per tick (only `warn()` on retry-failed paths). Not a bug — but it makes the system invisible during walkthroughs. Small enhancement: a `[Progression] tick: <source> +<amount> player=<userid>` debug print on each `Tick()` call would help Tyler see what's happening live without an MCP probe.
- [O] — Tyler's call: "have codex run through it and fix everything." About to: (a) append the three findings to `_Known_Bugs.md` Active; (b) write `06_Codex_Plans/2026-04-27_XP_Testing_Place_Bug_Sweep_v1.md` with the three-prong investigation+fix scope; (c) update `00_Index.md` Active Focus to point at the bug-sweep brief instead of the live walkthrough; (d) add an Open Question for the AFK-overrides-sitting design call (Tyler-decision, not a code fix).

## YYYY-MM-DD (template — do not write here, this is just a format example)

- [O] HH:MM — example: noticed `CashLeaderstats` still referenced in three places, see `_Cleanup_Backlog`
- [U] HH:MM — example: dialogue cooldown felt too short, bumped to 4s
- [U] HH:MM — ? should daily reward streak break on 1 missed day or 2?
