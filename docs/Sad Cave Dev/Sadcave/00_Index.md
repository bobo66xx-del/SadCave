# Sad Cave — Index

> Quiet emotional Roblox exploration / hangout game.
> Mood, presence, subtle social interaction, peaceful discovery.

---

## 🎯 Current Priority

**Title v2 player-facing surface is feature-complete except for the polished menu pass, and the v1 → v2 migration is now runtime-verified.** PR #12 (06:10 UTC) shipped the data + display layer — `TitleConfig` with all 56 titles, `TitleService` with auto-equip-highest, `TitleRemotes.TitleDataUpdated`, NameTag v2 with title row + effect rendering, XPBar combined-fade `level N — new title: X` at 5s hold. PR #13 (07:22 UTC) cleaned up the architecture — TitleService is a ModuleScript, NameTagScript requires it directly (no more `_G.SadCaveTitleService`), level watcher self-heals on respawn (probe confirmed `leaderstatsSame=true`). PR #14 (08:31 UTC) added the manual-equip surface — `EquipTitle` / `UnequipTitle` RemoteEvents with server-side ownership validation + 1s rate limit, placeholder TitleMenu with two `owned` / `locked` tabs, small `titles` toggle button in the top-right, production-cutover migration code reading `EquippedTitleV1`, manual choice respects the player forever (auto-equip-highest is now first-time-only fallback). PR #17 (2026-04-29 03:08 UTC) closed the migration static-review gap — `TitleService.LoadAndMigrateForUserId(userId, storeKeyPrefix)` runtime-tested all three migration cases (`regular → familiar_face`, `newcomer → new_here`, unmappable v1 → default fallback) against synthetic DataStore data with full cleanup verification. Production-cutover brief now has a confirmed migration path to build on. Sixteen PRs shipped 2026-04-27 → 2026-04-29 (latest: PR #20 AchievementTracker, 08:52:02 UTC).

Active focus:
- [ ] **Polished TitleMenu + nametag title visual — 🔵 Brief queued for Codex.** Brief at `06_Codex_Plans/2026-04-29_Title_Polished_Menu_Nametag_v1.md`. Includes the duplicate-`TitleConfig` Studio cleanup as Step 8. Branch slug: `codex/title-polish-pass`. Tyler kicks off Codex when ready. Designed 2026-04-29 in a Tyler-led design pass; full design captured in `02_Systems/Title_System.md` § "Polished Pass — Drawer + Title-Above-Name" and `02_Systems/NameTag_Status.md` § "Polished Pass — Title-Above-Name." Headline shape: nametag flips to title-on-top (Gotham 11 lowercase warm-grey at 0.75 opacity, then 2-3px gap, then Gotham 16 name) with `glow` effect rebalanced from UIStroke-border to ambient underglow halo; menu becomes a right-side drawer (~34% width) sliding in from the right with the world dimmed-but-visible behind it (no blur), category-sectioned inside (Level / Gamepass / Presence / Exploration / Achievement / Seasonal); slim edge tab on the right replaces the top-right `titles` button; click-to-commit, four close paths (click outside, ESC, internal close button, re-click the tab); locked-row hint voice goes mixed (mechanical for level/gamepass/presence/exploration, indirect-poetic for achievement and seasonal). Three carry-forwards from session 1 placeholder review folded into the spec: hint-copy voice pass, BindableEvent decoupling of the toggle button, row diffing on `TitleDataUpdated`. Next step: Codex brief at `06_Codex_Plans/YYYY-MM-DD_Title_Polished_Menu_Nametag_v1.md` whenever Tyler picks the timing — translates the spec into files-touched, build-order, Studio Test Checklist, and the 12 achievement hint lines.
- [ ] **AchievementTracker — shipped (PR #20, merged 2026-04-29 08:52:02 UTC).** Brief shipped 2026-04-29 (`06_Codex_Plans/2026-04-29_AchievementTracker_v1.md`); Codex on `codex/achievement-tracker` (head `2df4378`); Claude review passed playtest verdict "safe to merge" — four achievements (`came_back`, `keeps_coming_back`, `part_of_the_walls`, `one_of_us`) verified firing on Tyler's join, gating works for `heard_them_all` + `day_one`, no errors. Six interactive achievements (`said_something`, `sat_down`, `left_a_mark`, `knows_every_chair`, `up_too_late`, `fell_asleep_here`) read clean in diff but Tyler can verify them in normal play. **Carry-forward:** runtime confirmation of the six interactive achievements during normal play; Presence category activation queued as the next slot in the activation sequence.
- [ ] **Production cutover brief for Title v2** — write later, after the testing place soaks for a while. Migration runtime-verified by PR #17; cutover brief still needs a rollback plan, soak-period monitoring, and Tyler's "okay, push to prod" signal per `01_Vision/Environments.md`. The `LoadAndMigrateForUserId` helper is available as a tooling surface if a one-off mass-migration pass becomes useful.
- [ ] Remaining XP testing-place checks deferred (low priority): second-join migration variants 1+2 (need alt account or DataStore manipulation; variant 3 implicitly verified by Tyler's normal rejoins) and DataStore failure simulation (steps walked through with Tyler in plain English in case he wants to run them). Bar polish + level-up animation refinement parked in `08_Ideas_Parking_Lot/_Parking_Lot.md`.
- [ ] When Tyler greenlights the secret-handling approach, execute the DiscordLogs refactor (currently ⏸ Waiting — see [[06_Codex_Plans/2026-04-27_DiscordLogs_Secret_Refactor_v1]]).
- [ ] Watch `FavoritePromptPersistence` line-4 SourceCode error across future playtests — did NOT reproduce in PRs #8 → #14 playtests (seven quiet sessions). If it stays gone for one or two more, move from `_Known_Bugs.md` Active to Resolved.
- [ ] Watch flag carried forward: `StarterPlayerScripts` 9-vs-8 instance count puzzle — needs a session with working enumerate to resolve.

Recently completed:
- ✅ PR #20 — AchievementTracker shipped (2026-04-29 08:52:02 UTC). Activates the Achievement title category — 12 titles light up. New `ServerScriptService/Progression/AchievementTracker.lua` (444 lines) + init script, `ReplicatedStorage/AchievementRemotes/ClientLocalTime` RemoteEvent, `StarterPlayer/StarterPlayerScripts/AchievementClient.client.lua`, additive `ConversationEnded` BindableEvent on `DialogueDirector`, additive `NoteSubmitted` BindableEvent on `NoteSystemServer`. `TitleService.lua` extended for achievement-category ownership + four new public accessors; `TitleConfig.lua` gained `HEARD_THEM_ALL_MIN_NPCS = 3`, `LAUNCH_WINDOW = { nil, nil }` dormant placeholder, `GetAchievementTitleIds()`. Live playtest verified four achievements firing on Tyler's join (`came_back`, `keeps_coming_back`, `part_of_the_walls`, `one_of_us`); `heard_them_all` + `day_one` correctly dormant; no console errors.
- ✅ PR #17 — Title v2 migration runtime verification shipped (2026-04-29 03:08 UTC). Single additive change: `TitleService.LoadAndMigrateForUserId(userId, storeKeyPrefix)` (8 lines). Probe Script written, run, and deleted before push (`CodexMigrationProbe` pattern). All three migration cases PASSed (`regular → familiar_face`, `newcomer → new_here`, `saber_owner → new_here` with `migratedTitleId=nil` for the unmappable fallback case). All six post-cleanup `:GetAsync` reads returned `nil`. Synthetic UserIds with `_PROBE_TitleV2Migration_` namespacing kept the probe fully isolated from real player data. Closes the static-review gap PR #14 flagged.
- ✅ PR #14 — Title v2 MVP-2 shipped (2026-04-28 08:31 UTC). `EquipTitle` / `UnequipTitle` RemoteEvents with server-side ownership validation + 1s rate limit; new `equippedManually` and `migratedFromV1` fields in `TitleData`; `refreshAutoEquip` rewritten to split unlock detection from auto-equip application (notification-only payload pattern lets manually-equipped players still get unlock fades while keeping their choice on the nametag); placeholder TitleMenu (two-tab list, click-to-equip on owned, hints on locked) + small `titles` toggle button top-right; production-cutover migration code reading `EquippedTitleV1` once per player and mapping via `TitleConfig.MIGRATION`. Codex playtest confirmed manual `slow_steps` survived a level 49 → 50 boundary, invalid ownership rejected, spam rate-limited. Migration was static-reviewed only — production cutover PR will need a runtime test.
- ✅ PR #13 — Title v2 MVP-1 follow-up shipped (2026-04-28 07:22 UTC). TitleService converted to ModuleScript (`TitleService.lua`) + thin runtime starter (`TitleServiceInit.server.lua`); NameTagScript switched to direct `require`; `_G.SadCaveTitleService` deleted; `attachLevelWatcher` re-attaches on `CharacterAdded`. Probe confirmed `leaderstatsSame=true` across respawns.
- ✅ PR #12 — Title v2 MVP-1 shipped (2026-04-28 06:10 UTC). 56 titles defined in `TitleConfig`; auto-equip-highest with gamepass priority over level; `TitleRemotes.TitleDataUpdated`; NameTag BillboardGui 30→50 with TitleLabel below NameLabel; client-side `NameTagEffectController` for tint/shimmer/pulse/glow; XPBar combined-fade format with 5s hold + 100ms client-side coalescing.
- ✅ PR #11 — XP follow-up fixes shipped (2026-04-28 03:12 UTC). Gamepass ID corrected to `1790063497`; XPBar Background opacity 0.85→0.55; tick log format expanded to `source=... base=... granted=...`. All three multiplied rates verified.
- ✅ PR #10 — XP testing-place bug sweep shipped (2026-04-28 01:25 UTC). Seated SeatMarker overrides AFK (Branch A); XPBar `barHeight` unified at 6px; per-tick log added.
- ✅ PR #9 — NameTag level-row strip shipped (2026-04-27 23:20 UTC). Closed the spec-vs-build gap from Cowork session 4. Note: superseded by PR #12's title-row addition — the level row stays gone, but the BillboardGui is back at height 50 with NameLabel + TitleLabel.
- ✅ PRs #1 → #8 (all 2026-04-27): XP Progression MVP, two repo-strip passes, housekeeping export, DialogueDirector restore, audit refresh, session-2 vault wrap-up, PromptFavorite bugs cleanup. Tyler's heavy testing-place cleanup deleted most legacy systems; vault refreshed to match. Migration to Cowork.
- ✅ Three drift-found ScreenGuis (`IntroScreen`, `Menu`, `Game Version`) — Tyler decided keep all three Studio-only.
- ✅ Manual Export queue from PR #6 (`Rose`, `Avalog`, `Leader2`, `playerBugReportSystem`, `ReportGUI`, `Truss`, `WelcomeBadge`) — Tyler decided skip; `Workspace` isn't Rojo-mapped so they don't affect sync.

---

## 🧭 Quick Links

### Vision
- [[01_Vision/Tone_and_Rules]]
- [[01_Vision/Project_Overview]]
- [[01_Vision/Player_Experience_Arcs]] — felt-shape map across arrival / return / loyalty horizons. Read before adding a new system.

### Active Systems
- [[02_Systems/XP_Progression]] — 🟡 Building (MVP shipped, follow-ups pending)
- [[02_Systems/NameTag_Status]] — 🟢 Shipped (PR #12 added the title row back at BillboardGui height 50; PR #13 cleaned up the TitleService require path)
- [[02_Systems/Dialogue_System]] — 🟢 Shipped (early version live; verify scope next session)
- [[02_Systems/Title_System]] — 🟡 Building (v2 MVP-1 + MVP-1 Followup + MVP-2 + Migration Verification + AchievementTracker all shipped — title surface feature-complete except polished menu pass, v1 → v2 migration runtime-verified, Achievement category live; Presence / Discovery / Seasonal categories defined-but-inactive, each their own follow-up brief — activation order specced in [[02_Systems/Title_System]] § Category Activation Sequence)
- [[02_Systems/QuietKeeper_Memory]] — 🔵 Planned (loyalty-arc surface — NPC memory across sessions; designed 2026-04-28 session_4)
- [[02_Systems/Personal_Place]] — ⚪ Idea (loyalty-arc surface — cave noticing your favorite sit-spot; stubbed 2026-04-28 session_4)
- [[02_Systems/Seasonal_Layer]] — ⚪ Idea (return + loyalty surface — calendar-aware shifts in environment, NPC moods, Seasonal titles; stubbed 2026-04-28 session_4)
- [[02_Systems/Veteran_Threshold_Content]] — ⚪ Idea (loyalty-arc surface — content only visible after long playtime / return-count; stubbed 2026-04-28 session_4)
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
- [[06_Codex_Plans/2026-04-27_NameTag_Strip_Level_Row_v1]] — 🟢 Shipped (PR #9, merged 2026-04-27 23:20 UTC).
- [[06_Codex_Plans/2026-04-27_XP_Testing_Place_Bug_Sweep_v1]] — 🟢 Shipped (PR #10, merged 2026-04-28 01:25 UTC).
- [[06_Codex_Plans/2026-04-28_XP_Followup_Fixes_v1]] — 🟢 Shipped (PR #11, merged 2026-04-28 03:12 UTC).
- [[06_Codex_Plans/2026-04-28_Title_v2_MVP1_v1]] — 🟢 Shipped (PR #12, merged 2026-04-28 06:10 UTC).
- [[06_Codex_Plans/2026-04-28_Title_v2_MVP1_Followup_v1]] — 🟢 Shipped (PR #13, merged 2026-04-28 07:22 UTC).
- [[06_Codex_Plans/2026-04-28_Title_v2_MVP2_v1]] — 🟢 Shipped (PR #14, merged 2026-04-28 08:31 UTC).
- [[06_Codex_Plans/2026-04-28_Title_v2_Migration_Verification_v1]] — 🟢 Shipped (PR #17, merged 2026-04-29 03:08 UTC). Runtime verification confirmed all three migration cases (`regular → familiar_face`, `newcomer → new_here`, unmappable v1 → `new_here` fallback) and clean DataStore cleanup. `TitleService.LoadAndMigrateForUserId(userId, storeKeyPrefix)` left in `main` as a reusable surface for the production-cutover brief.
- [[06_Codex_Plans/2026-04-29_AchievementTracker_v1]] — 🟢 Shipped (PR #20, merged 2026-04-29 08:52:02 UTC, branch `codex/achievement-tracker`, head `2df4378`).
- [[06_Codex_Plans/2026-04-29_Title_Polished_Menu_Nametag_v1]] — 🔵 Queued. Polished TitleMenu (right-side drawer, world dimmed-but-visible, category sections, slim edge-tab entry, four close paths) + nametag flip (title above name, `glow` effect rebalanced to underglow halo) + duplicate `TitleConfig`/`TitleRemotes` Studio cleanup. Branch slug: `codex/title-polish-pass`. Closes the placeholder menu's `_Cleanup_Backlog.md` entry on ship and resolves the duplicate-Studio-instance question in `_Open_Questions.md`. Activates the Achievement title category — ~12 titles light up. Hooks into existing dialogue / sitting / note / idle / group / revisits / time-window paths, fires `AchievementUnlocked` BindableEvent that TitleService listens to. Resolved the `fell_asleep_here` focus-vs-idle question (idle, via `Player.Idled`). `heard_them_all` future-proofed via min-NPC gate (3); `day_one` ships dormant with `LAUNCH_WINDOW = nil` placeholders Tyler fills when real launch happens.
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
