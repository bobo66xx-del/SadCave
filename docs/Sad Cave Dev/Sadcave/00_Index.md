# Sad Cave — Index

> Quiet emotional Roblox exploration / hangout game.
> Mood, presence, subtle social interaction, peaceful discovery.

---

## 🎯 Current Priority

**Title v2 player-facing surface is feature-complete on polish + desktop refinement + medium polish, with the Achievement category live.** PR #12 (06:10 UTC) shipped the data + display layer. PR #13 (07:22 UTC) cleaned up the architecture (TitleService as ModuleScript). PR #14 (08:31 UTC) added the manual-equip surface. PR #17 (2026-04-29 03:08 UTC) runtime-verified the v1 → v2 migration. PR #20 (2026-04-29 08:52 UTC) activated the Achievement title category — 12 titles live. PR #23 (2026-04-29 10:48 UTC) shipped the polished menu + nametag visual pass. PR #25 (2026-04-29 14:01 UTC) shipped the Desktop Refinement Pass — Brief A — via two-iteration same-branch loop. **PR #27 (2026-04-30 04:38 UTC) shipped Brief B — medium polish**: title `TextStrokeTransparency` 0.7 → 0.5, mobile name-row gap 19 → 21 for ~5px breathing, desktop hover label tween 0.4 → 0.2 on the edge tab, right-edge `EdgeRecess` Frame at 2×130 desktop / 2×100 mobile (recess fades with tab on drawer open — carry-forward note: drawer fully occludes recess so fade is unnecessary motion). Item 5 (drawer-dim while menu open) dropped from Brief B as obsolete per Brief A iteration 1's tab fade-out-on-open. Letterspacing held item folded into the queued Aura Pass. **Nineteen PRs shipped 2026-04-27 → 2026-04-30 (latest: PR #27 medium polish, 2026-04-30 04:38:32 UTC).**

Active focus:
- [ ] **Nametag Aura Pass — Stillness Bloom** 🔵 Queued. The biggest visual upgrade since the polished pass. Designed 2026-04-29 session_5 after Tyler flagged nametags "look lame, kinda ugly, no aura." Direction A chosen from a four-option design conversation: a layered atmospheric expression of player presence — cushion + edge bloom + outer halo + breath + stillness-responsive bloom (5s stillness threshold → cushion +10% / warmer halo) + tint bleed + letterspacing + choreography. Pure client-side, extends `NameTagEffectController.client.lua`, no server / remote / DataStore changes. Canonical design at [[02_Systems/NameTag_Status]] § "Aura Pass — Stillness Bloom"; brief at [[06_Codex_Plans/2026-04-29_Nametag_Aura_Pass_v1]]; branch slug `codex/nametag-aura-pass`. The bloom is the thesis-move — makes "presence rewards stillness" visible as accumulated atmospheric weight on the most-visible-to-other-players surface. **Recommend Tyler kicks off after Brief B merges** so the Aura Pass branch bases on a clean post-Brief-B `main`.

- [ ] **`up_too_late` achievement bug** — client formula in `AchievementClient.client.lua` returns 0 instead of real UTC offset (Roblox's `os` library is UTC-only, so `os.difftime(os.time(), os.time(os.date("!*t")))` evaluates to 0). Server falls back to checking UTC hour; Tyler at 10:59pm CDT = 03:59 UTC fires the `hour == 3` check. Bug filed in `_Known_Bugs.md`. Fix is one function (~5 lines). Could ship as its own tiny PR (`codex/up-too-late-offset-fix` branch) any time — unblocked, low priority.
- [ ] **Presence category activation** — next deliberately-queued slot in the Title category activation sequence after the desktop refinement settles. Smaller brief than AchievementTracker (single counter against thresholds, no new hook authoring). Reads `ProgressionData.totalTimePlayed` and lights up the eight Presence titles when their hour milestones are crossed. Open Tyler's call.
- [ ] **AchievementTracker carry-forward.** Six interactive achievements (`said_something`, `sat_down`, `left_a_mark`, `knows_every_chair`, `up_too_late`, `fell_asleep_here`) still need runtime confirmation in normal play. Code reads clean in diff; Tyler verifies as he plays.
- [ ] **Production cutover brief for Title v2** — write later, after the testing place soaks for a while. Migration runtime-verified by PR #17; cutover brief still needs a rollback plan, soak-period monitoring, and Tyler's "okay, push to prod" signal per `01_Vision/Environments.md`. The `LoadAndMigrateForUserId` helper is available as a tooling surface if a one-off mass-migration pass becomes useful.
- [ ] Remaining XP testing-place checks deferred (low priority): second-join migration variants 1+2 (need alt account or DataStore manipulation; variant 3 implicitly verified by Tyler's normal rejoins) and DataStore failure simulation. Bar polish + level-up animation refinement parked in `08_Ideas_Parking_Lot/_Parking_Lot.md`.
- [ ] When Tyler greenlights the secret-handling approach, execute the DiscordLogs refactor (currently ⏸ Waiting — see [[06_Codex_Plans/2026-04-27_DiscordLogs_Secret_Refactor_v1]]).
- [ ] Watch flag carried forward: `StarterPlayerScripts` 9-vs-8 instance count puzzle — needs a session with working enumerate to resolve.
- [ ] Studio-state hygiene sweep — opportunistic, no urgent driver. Three stale duplicates found in the title surface in 36 hours during PR #23 suggested adjacent areas may have other lurking ones. Worth a focused pass at some point.
- [ ] **Production cutover brief for Title v2** — write later, after the testing place soaks for a while. Migration runtime-verified by PR #17; cutover brief still needs a rollback plan, soak-period monitoring, and Tyler's "okay, push to prod" signal per `01_Vision/Environments.md`. The `LoadAndMigrateForUserId` helper is available as a tooling surface if a one-off mass-migration pass becomes useful.
- [ ] Remaining XP testing-place checks deferred (low priority): second-join migration variants 1+2 (need alt account or DataStore manipulation; variant 3 implicitly verified by Tyler's normal rejoins) and DataStore failure simulation (steps walked through with Tyler in plain English in case he wants to run them). Bar polish + level-up animation refinement parked in `08_Ideas_Parking_Lot/_Parking_Lot.md`.
- [ ] When Tyler greenlights the secret-handling approach, execute the DiscordLogs refactor (currently ⏸ Waiting — see [[06_Codex_Plans/2026-04-27_DiscordLogs_Secret_Refactor_v1]]).
- [ ] Watch `FavoritePromptPersistence` line-4 SourceCode error across future playtests — did NOT reproduce in PRs #8 → #14 playtests (seven quiet sessions). If it stays gone for one or two more, move from `_Known_Bugs.md` Active to Resolved.
- [ ] Watch flag carried forward: `StarterPlayerScripts` 9-vs-8 instance count puzzle — needs a session with working enumerate to resolve.

Recently completed:
- ✅ PR #27 — Brief B (medium polish) shipped (2026-04-30 04:38:32 UTC, branch `codex/title-polish-brief-b`, head `d3c6958`). Single-iteration push, no review iterations. Two files: `NameTagEffectController.client.lua` (title `TextStrokeTransparency` 0.7 → 0.5, mobile name-row position 19 → 21, property listeners on both) and `TitlesToggleController.client.lua` (desktop hover label tween 0.4 → 0.2 over 0.15s gated on `not isOpen`, right-edge `EdgeRecess` Frame, recess fade with tab via `setTabVisible`). Two non-blocking carry-forwards parked: (1) Step 0 bright-background test was skipped, stroke shipped at 0.5 unconditionally — effectively moot once Aura Pass cushion lands as the structural legibility solution; (2) recess fades preemptively with tab on drawer open — unnecessary motion (drawer fully occludes recess), one-line revert in any future polish touch on `TitlesToggleController.client.lua`. Letterspacing held item folded into Aura Pass.
- ✅ PR #25 — Desktop Refinement Pass (Brief A) shipped (2026-04-29 14:01:58 UTC). Two-iteration same-branch loop: initial commit `4aef1de` matched the original brief (Claude review "safe to merge"); Tyler reviewed live and asked for tuning; iteration-1 commit `9bca238` incorporated five deltas (proportional size bump to title 16 / name 25 / BillboardGui 280×80, stillness threshold 1.0s → 2.0s for less aggressive fade, distance fade halved with MaxDistance halved to 50 via client-side override applied on both platforms, tab fade-out-on-open replacing re-click-tab close path, per-row notification dots in TitleMenu with clear-on-close). Three client files touched: `NameTagEffectController.client.lua` (sizing + fades + MaxDistance override + property listener), `TitlesToggleController.client.lua` (sizing + tab fade-orchestration + tactile press + tab dot), `TitleMenuController.client.lua` (per-row dots + clear-on-close cleanup). No server changes, no remote contract changes, no DataStore work. Stillness fade is the thesis-move — UI behavior tied to "presence rewards stillness" core. Tyler verified live merge; next: sit with state for a session before deciding on Brief B.
- ✅ PR #23 — Polished TitleMenu + nametag visual shipped (2026-04-29 10:48:45 UTC). Title now sits above the name (Gotham 11 lowercase warm-grey at 0.75 opacity on top, 2-3px gap, Gotham 16 name underneath). Menu replaced with right-side drawer (~34% width sliding in with `Quart Out 0.3s`) over a world-dimmed-but-visible overlay (no blur, ~75% brightness via 0.2s sine fade). Six category sections with quiet headers + hairlines, owned-then-locked within each section, currently-equipped row shows a soft `wearing` caption. Click-to-commit, four close paths wired (click outside the drawer, ESC, internal `x`, re-click the edge tab). Slim 18×90px right-edge tab with rotated `titles` text replaces the top-right text button — hover lifts and inches outward by 4px. `glow` effect rebalanced from `UIStroke` Thickness 1 / Transparency 0.55 (bordered label) to Thickness 2 / Transparency 0.85 with `ApplyStrokeMode.Border` (ambient halo). `shimmer` and `pulse` contrast tweaks landed. 12 achievement hint lines authored verbatim from the brief's mixed-voice table. BindableEvent decoupling of the toggle button + row diffing on `TitleDataUpdated` (carry-forwards from session 2 placeholder review). Three stale Studio duplicates deleted: `TitleConfig 1_12815` and `TitleRemotes 1_10394` (per brief), plus an unauthorized-but-correct `NameTagEffectController 1_10619` deletion that was actively running the old glow stroke and would have silently overridden the new ambient halo (approved post-hoc by Claude review). No server-side changes, no DataStore changes, no remote contract changes.
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
- [[02_Systems/NameTag_Status]] — 🟢 Shipped (PR #12 added the title row back at BillboardGui height 50; PR #13 cleaned up the TitleService require path; PR #23 flipped the layout to title-above-name with `glow` rebalanced to ambient halo)
- [[02_Systems/Dialogue_System]] — 🟢 Shipped (early version live; verify scope next session)
- [[02_Systems/Title_System]] — 🟡 Building (v2 MVP-1 + MVP-1 Followup + MVP-2 + Migration Verification + AchievementTracker + Polished Menu/Nametag all shipped — player-facing surface feature-complete on polish, v1 → v2 migration runtime-verified, Level + Gamepass + Achievement categories live; Presence / Exploration / Seasonal categories defined-but-inactive, each their own follow-up brief — activation order specced in [[02_Systems/Title_System]] § Category Activation Sequence)
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
- [[06_Codex_Plans/2026-04-29_Title_Polished_Menu_Nametag_v1]] — 🟢 Shipped (PR #23, merged 2026-04-29 10:48:45 UTC, branch `codex/title-polish-pass`, head `c098f659`). Polished menu + nametag pass live; placeholder TitleMenu retired from `_Cleanup_Backlog.md`; duplicate-`TitleConfig`/`TitleRemotes` open question resolved (three stale Studio duplicates deleted, none remaining). Activates the Achievement title category — ~12 titles light up. Hooks into existing dialogue / sitting / note / idle / group / revisits / time-window paths, fires `AchievementUnlocked` BindableEvent that TitleService listens to. Resolved the `fell_asleep_here` focus-vs-idle question (idle, via `Player.Idled`). `heard_them_all` future-proofed via min-NPC gate (3); `day_one` ships dormant with `LAUNCH_WINDOW = nil` placeholders Tyler fills when real launch happens.
- [[06_Codex_Plans/2026-04-29_Title_Tag_Tab_Desktop_Refinement_v1]] — 🟢 Shipped (PR #25, merged 2026-04-29 14:01:58 UTC, branch `codex/title-tag-tab-desktop-refinement`, head `9bca238`). Brief A shipped via two-iteration same-branch loop. Iteration-1 amended values: title 16pt / name 25pt / BillboardGui 280×80, stillness threshold 2.0s, distance bands 20-40-50, tab fade-out-on-open, per-row TitleMenu dots clear-on-close.
- [[06_Codex_Plans/2026-04-29_Title_Polish_Brief_B_v1]] — 🟢 Shipped (PR #27 merged 2026-04-30 04:38:32 UTC, branch `codex/title-polish-brief-b`, head `d3c6958`). Single-iteration push. Two files: `NameTagEffectController.client.lua` (stroke 0.7 → 0.5, mobile gap 19 → 21, property listeners) and `TitlesToggleController.client.lua` (desktop hover label tween, `EdgeRecess` Frame). Two non-blocking carry-forwards parked: Step 0 bright-background test skipped (moot once Aura Pass cushion lands), recess fade preemptive (one-line revert in future polish touch). Letterspacing held item folded into Aura Pass; first-time tab pulse stays held.
- [[06_Codex_Plans/2026-04-29_Nametag_Aura_Pass_v1]] — 🔵 Queued (written 2026-04-29 session_5, branch slug `codex/nametag-aura-pass`). The biggest visual upgrade to the nametag since the polished pass. Tyler's framing: nametags currently "look lame, kinda ugly, no aura." Direction A (Stillness Bloom) chosen from a four-option design conversation. Seven layers: breath (1-2px sine drift, 3.5s period, random phase per player), cushion (dark warm-grey vignette Frame as legibility solution + atmospheric base), edge bloom (warm amber bottom-edge glow), bloom state machine (5s stillness threshold → cushion +10% / transparency 0.55→0.4 / outer halo appears, 0.4s motion threshold to collapse), tint bleed (15% mix of equipped title's `tintColor` into the warm halo), letterspacing (`TextLetterSpacing = 0.5` on title row — the held item from Brief B's "held entirely" list, finally landing), choreography (1.5s pulse on title unlock, 0.2s staggered reveal on approach). Pure client-side; extends `NameTagEffectController.client.lua`. No server / remote / DataStore changes. Bloom is the thesis-move — makes "presence rewards stillness" visible as accumulated atmospheric weight. Canonical design at [[02_Systems/NameTag_Status]] § "Aura Pass — Stillness Bloom."
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
