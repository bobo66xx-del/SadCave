# Sad Cave — Index

> Quiet emotional Roblox exploration / hangout game.
> Mood, presence, subtle social interaction, peaceful discovery.

---

## 🎯 Current Priority

**Walk the post-merge XP testing-place checks, then start Title v2 design when Tyler kicks it off.** Eight PRs shipped on 2026-04-27 (XP MVP, two repo-strip passes, housekeeping export, DialogueDirector restore, audit refresh, session-2 vault wrap-up, PromptFavorite bugs cleanup). Vault is in sync with main. Next priority is exercising the open XP testing-place items now that the workflow is clean.

Active focus:
- [ ] Hand the NameTag level-row strip brief to Codex — small surgical change, removes the doubled-up level surface from the overhead nametag. See [[06_Codex_Plans/2026-04-27_NameTag_Strip_Level_Row_v1]]. **Next up.**
- [ ] Walk the XP testing-place checks listed in `09_Open_Questions/_Open_Questions` (sitting boost at a real `SeatMarker` — now unblocked since SeatMarkers has a Seat child, level-up animation, gamepass +22 tick, mobile bar height, second-join migration, DataStore failure simulation).
- [ ] Title v2 — full v2 spec exists in `02_Systems/Title_System`, ready for build planning when Tyler kicks off the thread (decided 2026-04-27, see `_Decisions.md`). Don't auto-design.
- [ ] When Tyler greenlights the secret-handling approach, execute the DiscordLogs refactor (currently ⏸ Waiting — see [[06_Codex_Plans/2026-04-27_DiscordLogs_Secret_Refactor_v1]]).
- [ ] Watch `FavoritePromptPersistence` line-4 SourceCode error across future playtests — did NOT reproduce in PR #8's run; if it stays gone for several sessions, move it from `_Known_Bugs.md` Active to Resolved with a "did not reproduce after PR #8" note. Investigation still blocked by no-touch + Avalog deferral.

Recently completed (all 2026-04-27):
- ✅ PR #1 — XP Progression MVP merged (08:45 UTC).
- ✅ PR #2 — Repo strip to Studio state merged (10:13 UTC).
- ✅ PR #3 — Repo strip follow-up merged (11:33 UTC).
- ✅ PR #4 — Housekeeping utility export merged (11:58 UTC). 10 of 11 flagged Studio-only kept-list objects exported.
- ✅ PR #5 — DialogueDirector restored (13:32 UTC). 679-line server script back from the 2026-04-24 Studio capture; Tyler verified dialogue works post-merge.
- ✅ PR #6 — Live-repo-audit refresh shipped (20:51 UTC). 49 rows reclassified post-cleanup; surfaced three vault drift items (Studio id, IntroScreen/Menu, SeatMarkers child) that got reconciled.
- ✅ PR #7 — Session-2 vault wrap-up shipped to main (21:54 UTC). 18 vault files: AGENTS.md sync-hardening, plan-file Status convention, _Decisions.md introduced, change-log reordered, Open Questions / UI Hierarchy / Live Systems Reference / Index reconciled.
- ✅ PR #8 — PromptFavorite bugs cleanup shipped (22:00 UTC). Bounded WaitForChild on `FavoritePromptShown` with graceful exit; deleted duplicate `PromptFavorite` Script in StarterPlayerScripts. Resolved two `_Known_Bugs.md` entries and the audit's PromptFavorite tooling blocker.
- ✅ Three drift-found ScreenGuis (`IntroScreen`, `Menu`, `Game Version`) — Tyler decided keep all three Studio-only.
- ✅ Manual Export queue from PR #6 (`Rose`, `Avalog`, `Leader2`, `playerBugReportSystem`, `ReportGUI`, `Truss`, `WelcomeBadge`) — Tyler decided skip; `Workspace` isn't Rojo-mapped so they don't affect sync.
- ✅ Tyler's heavy testing-place cleanup deleted most legacy systems.
- ✅ Vault refreshed to match post-cleanup reality (Cowork session 1).
- ✅ Migration to Cowork — same MCPs wired up, no capability lost.

---

## 🧭 Quick Links

### Vision
- [[01_Vision/Tone_and_Rules]]
- [[01_Vision/Project_Overview]]

### Active Systems
- [[02_Systems/XP_Progression]] — 🟡 Building (MVP shipped, follow-ups pending)
- [[02_Systems/NameTag_Status]] — 🟡 Building (rebuilt 2026-04-27 with name + level; level row removal queued via brief — see Plans & Logs)
- [[02_Systems/Dialogue_System]] — 🟢 Shipped (early version live; verify scope next session)
- [[02_Systems/Title_System]] — 🔵 Planned (v2 redesign; v1 deleted in cleanup)
- [[02_Systems/Area_Discovery]] — 🔵 Planned (legacy badge script deleted; will be rebuilt as part of XP Discovery source)
- [[02_Systems/Cave_Outside_Lighting]] — 🔵 Planned
- [[02_Systems/Group_Member_Perks]] — ⚪ Idea
- [[02_Systems/Choice_UI_Panel]] — 🟢 Shipped (lives inside dialogue clients)
- [[02_Systems/Cinematic_Subtitle_Panel]] — 🟢 Shipped (lives inside dialogue clients)

### Historical / Superseded
- [[02_Systems/Level_System]] — ⚫ Superseded by XP_Progression (deleted 2026-04-27)
- [[02_Systems/Daily_Rewards]] — ⚫ Removed in 2026-04-27 cleanup
- [[02_Systems/Level_Stat_System]] — Replaced stub, see XP_Progression and Level_System

### Reference / Meta
- [[02_Systems/_Live_Systems_Reference]] — what's currently in Studio (refreshed 2026-04-27)
- [[02_Systems/_UI_Hierarchy]] — `StarterGui` structure (refreshed 2026-04-27)
- [[02_Systems/_Cleanup_Backlog]] — what was cleaned, what's still pending (donations decision)
- [[02_Systems/_No_Touch_Systems]] — must-not-modify list (refreshed 2026-04-27)

### Map
- [[03_Map_Locations/_Map_Overview]]

### NPCs
- [[05_NPCs/QuietKeeper]]

### Workflow & Capture
- **`AGENTS.md`** (at repo root, `C:\Projects\SadCave\AGENTS.md`) — the workflow doc + Codex rules. Read this first on a fresh session.
- [[_Workflow]] — stub pointing at AGENTS.md (kept so the vault still finds it).
- `PLANS.md` (at repo root) — 🧊 historical context only.
- `docs/live-repo-audit.md` (at repo root) — refreshed 2026-04-27 via PR #6. 49 rows classified against the cleaned testing place. Refresh policy: redo whenever a substantive cleanup or export pass lands.
- [[00_Inbox/_Inbox]] — unsorted captures, this session
- [[_Change_Log]] — append-only history of substantive changes

### Plans & Logs
- [[06_Codex_Plans/_Plan_Template]] — copy this; every new plan now carries a `Status:` line.
- [[06_Codex_Plans/2026-04-25_Repo_Resync_v1]] — ⚫ Superseded (replaced by Live Reconciliation Continuation).
- [[06_Codex_Plans/2026-04-25_Live_Reconciliation_Continuation_v1]] — 🟢 Shipped (pre-cleanup reconciliation pass).
- [[06_Codex_Plans/2026-04-25_XP_Progression_MVP_v1]] — 🟢 Shipped (PR #1).
- [[06_Codex_Plans/2026-04-27_Repo_Strip_to_Studio_State_v1]] — 🟢 Shipped (PR #2 + PR #3).
- [[06_Codex_Plans/2026-04-27_Housekeeping_Utility_Export_v1]] — 🟢 Shipped (PR #4).
- [[06_Codex_Plans/2026-04-27_Restore_DialogueDirector_v1]] — 🟢 Shipped (PR #5).
- [[06_Codex_Plans/2026-04-27_DiscordLogs_Secret_Refactor_v1]] — ⏸ Waiting (planned, on hold per Tyler).
- [[06_Codex_Plans/2026-04-27_Live_Repo_Audit_Refresh_v1]] — 🟢 Shipped (PR #6).
- [[06_Codex_Plans/2026-04-27_PromptFavorite_Bugs_Cleanup_v1]] — 🟢 Shipped (PR #8).
- [[06_Codex_Plans/2026-04-27_NameTag_Strip_Level_Row_v1]] — 🔵 Queued (Cowork session 4; strip `LevelLabel` per Tyler's decision).
- [[07_Sessions/_Session_Template]]
- [[08_Ideas_Parking_Lot/_Parking_Lot]]
- [[09_Open_Questions/_Open_Questions]] — unresolved design decisions
- [[09_Open_Questions/_Known_Bugs]] — active bug tracker

---

## 🛠 Tools

- **Roblox Studio** (place: `Testing cave`) — runtime
- **Rojo repo:** `SadCaveV2` (`C:\Projects\SadCave\`) — source of truth
- **Codex** — implementation
- **Claude (in Cowork)** — planning, design, architecture, review (formerly Claude Opus in chat)
- **Obsidian** — this vault, project memory
- **GitHub MCP** — branch review, PR management
- **Cowork desktop tool** — current host for Claude (migrated 2026-04-27)

---

## 📌 Status Legend

- 🟢 **Shipped** — live and working
- 🟡 **Building** — actively in progress
- 🔵 **Planned / Queued** — designed, not started (Codex plans use this as "Queued for Codex")
- ⏸ **Waiting** — written but deliberately on hold (e.g. waiting on a Tyler decision)
- ⚪ **Idea** — rough thought, not committed
- 🔴 **Cleanup** — legacy, to be removed
- ⚫ **Superseded** — replaced or deleted; doc kept for history

---

## 📝 Notes

- Always check [[01_Vision/Tone_and_Rules]] before adding a new feature.
- Park stray ideas in [[08_Ideas_Parking_Lot/_Parking_Lot]] instead of expanding scope mid-task.
- Drop in-session captures into [[00_Inbox/_Inbox]] — Opus integrates at session end.
- Log every working session briefly in `07_Sessions/`.
- For **how the whole stack works** (Claude + Codex + vault), see `AGENTS.md` at the repo root.
- **Plan statuses are now mandatory.** Every file in `06_Codex_Plans/` carries a `Status:` line at the top. Update it when state changes (Queued → Building → Shipped, or Waiting / Superseded). Keeping this index in sync with plan-file statuses is part of end-of-session integration.
- **Production caveat:** the testing place was cleaned 2026-04-27. If the live production place still runs the older systems, several pieces of the vault — most notably `_No_Touch_Systems` and `Title_System`'s migration plan — apply differently for production cutover.
