# Change Log

> Append-only history of substantive changes to Sad Cave. Newest entries on top.
> Written by Opus during end-of-session integration. One line per change. Date + system + what changed + why.
>
> **What belongs here:** shipped features, design pivots, removed systems, renamed concepts, broken assumptions corrected.
> **What does NOT belong here:** stray ideas (→ `08_Ideas_Parking_Lot`), open questions (→ `09_Open_Questions`), session recaps (→ `07_Sessions`), small in-progress tweaks (→ `00_Inbox` until they ship).

---

## 2026

### April

<!-- New entries go directly below this line -->

2026-04-27 — XP_Progression — Hardened MVP legacy migration safety on `codex/xp-progression-mvp`: if the legacy `LevelSave` read fails during migration, `ProgressionService` now marks the load as failed so it skips writing a 0-XP `ProgressionData` record. Reason: live testing briefly showed level 0 when the legacy read failed; preserving old level data is more important than completing a partial migration.

2026-04-25 — Workflow — Adopted branch-and-merge workflow ahead of GitHub MCP being connected. Codex now works on `codex/<task-name>` branches and pushes them; never commits to `main` directly. The user merges (one click on GitHub) only after Opus reviews. AGENTS.md updated: new Git Workflow section explaining the branch lifecycle, Loop steps 3 and 5 updated, Build Loop steps 3 and 6 updated, Done When adds branch-pushed bullet, new anti-pattern (Codex pushes to main). Reason: with GitHub MCP, Opus can read pushed branches and give a verdict before anything lands in `main`. Branches are the safety gate; `main` only gets clean reviewed code.

2026-04-25 — Workflow — Three changes after a beginner-perspective audit. (1) Merged `_Workflow.md` into `AGENTS.md` — one workflow doc instead of two paired docs. `_Workflow.md` replaced with a pointer stub so Obsidian still finds it. (2) Dropped the 🔵→🟡→🟢 plan-status mechanic. Codex no longer updates Status fields on plan files; vault write access is now just the inbox. Plan template and the active XP plan file had their Status lines removed. (3) Opus review is now universal — every Codex task gets reviewed by Opus before the user accepts it, no risk gradient. The user does not script and cannot verify code; Opus translates the diff into a plain-English verdict. Changes locked into AGENTS.md (Loop step 5, Build Loop step 6, Done When, anti-patterns). Reason: previous workflow assumed an experienced solo dev who could route their own notes, judge task risk, and read diffs. The user is none of those things — they need Opus to do the routing, judging, and verifying.

2026-04-25 — 02_Systems — Created `_No_Touch_Systems.md`. Migrated the canonical no-touch list out of `AGENTS.md` and into the vault as a sister doc to `_Cleanup_Backlog.md` and `_Live_Systems_Reference.md`. AGENTS.md now points to it instead of carrying the inline list. Reason: static lists in AGENTS.md drift from reality as systems get renamed/added/removed. Vault location means the list gets maintained alongside the `02_Systems/` notes that own those systems.

2026-04-25 — Workflow — Audit pass on `_Workflow.md` and `AGENTS.md`. Six fixes: (1) AGENTS.md → vault pointer for the no-touch list (above). (2) Both docs now declare themselves paired — workflow rule changes update both in the same edit pass. (3) Build Loop step 6 in AGENTS.md gained playtest failure-mode bullets (runtime error → fix-or-flag, MCP unavailable → don't silently skip). (4) Both docs corrected on Rojo — it syncs files to Studio, it doesn't commit; git commits separately. (5) New "Starting a Fresh Session" section in AGENTS.md mirrors Opus's re-orientation checklist for Codex. (6) AGENTS.md "Done When" plan-Status bullet caveated for ad-hoc tasks. Two new anti-patterns in `_Workflow.md`: playtest theater and asset bloat — both with mitigations wired into existing steps. Asset Generation section in AGENTS.md gained a placeholder-tracking note; integration step 6 in `_Workflow.md` gained a placeholder-cleanup-logging line. All changes additive; no role boundaries moved.

2026-04-25 — Workflow — Added Studio MCP tool integration to the loop. Step 1 (Design): Opus may use `execute_luau` for live state queries. Step 3 (Build): Codex now playtests via `start_stop_play` + `console_output` before marking 🟢 — was implicit before, now explicit. Step 5 (Review): Opus reads Codex's playtest notes and only spot-checks if risky or thin. AGENTS.md updated to match — Build Loop step 6 calls the playtest tools by name, Validation section reflects MCP playtest, new Asset Generation section authorizes `generate_mesh` / `generate_material` for placeholders. All changes additive; no role boundaries moved. Reason: Codex playtest capability went live this session; docs caught up.

2026-04-25 — 06_Codex_Plans — Wrote `2026-04-25_XP_Progression_MVP_v1.md`. First design-driven brief on the new system. MVP scope: ProgressionService + PresenceTick + XPBar. Build-and-test phase ships with `SourceConfig.ENABLED = false`; production cutover (Phase 7) flips the flag and disables `LevelLeaderstats` / `Levelup`. Rollback is one boolean. Three open questions left for Codex to resolve during build (AFK detection mechanism, leaderstats Level overlap during cutover, Rojo conventions for empty RemoteEvents).
2026-04-25 — 00_Index — Updated current priority from live reconciliation to XP Progression MVP. Marked Title_System v2 as 🔵 Planned (v1 still live). Marked XP_Progression as 🟡 Building. Added `LevelLeaderstats` and `Levelup` chat notification to cleanup backlog (retired by MVP).
2026-04-25 — Title_System — Full v2 redesign. Scrapped the v1 list (34 level + 30 shop + 15 gamepass + 2 special = 81 titles, many off-tone). Replaced with ~60 titles across 6 categories: level (20), exploration (6+), presence (8), achievements (12), seasonal (4+), gamepass (6). Names all lowercase with spaces, emotional/internal voice (`still here`, `half awake`, `gone quiet`, `always was here`). Every title has a per-title `tintColor` (Color3) for effect rendering. Five effect tiers: none → tint → shimmer → pulse → glow. New `TitleConfig` data shape with category-keyed unlock conditions. New combined DataStore key `TitleData` (equipped title + achievement flags). New `AchievementTracker` module under Progression. TitleMenu simplified to two filter tabs: `owned` + `locked`. Full v1→v2 migration table written. Rationale: v1 was generic-Roblox-rank flavored; v2 reads as a state of mind, not a flex.
2026-04-25 — XP_Progression — Full spec written. Replaces time-only leveling (`+1 level/60s`) with real XP system. Curve: `floor(45 + 0.55 * N^1.15)`. Pacing tuned so level 10 hits in ~27 min, level 100 in ~9 hrs, level 500 in ~2 months, level 1000 in ~8 months. Three-state presence tick: sitting (20 XP) > active (15 XP) > AFK (3 XP) — sitting is the most rewarded behavior, fits hangout-game tone. Gamepass `2110249546` keeps 1.5x multiplier. XP bar: bottom of screen, 4px desktop / 6px mobile, hover/tap reveals numbers, soft level-up glow. DataStores consolidated to two combined keys (`ProgressionData`, `TitleData`) instead of four — fewer reads on join, safer with Roblox rate limits. MVP scope cut to ProgressionService + PresenceTick + XPBar; Discovery/Conversation/Achievement/Title v2 are follow-up briefs.

2026-04-25 — Live Reconciliation — Exported `Theme.server.lua` and `OverheadTagsToggleServer.server.lua` to repo (structurally mapped, 9/9 and 35/35 lines). Both hit the numbered-conversational-output connector blocker, so not byte-exact. `fridge-ui` classified as tooling blocker (AnchorPoint null on centered nodes). Audit updated; highest-priority queue cleared.
2026-04-25 — NameTag_Status — Confirmed `OverheadTagsToggleServer` is a no-op server handler. Overhead tag visibility is client-side only. Server remote kept for backward compatibility. Updated `_Live_Systems_Reference` to reflect this — was previously listed as an unverified assumption.

2026-04-25 — Workflow — Frozen `PLANS.md` as historical-only; consolidated all planning to `06_Codex_Plans/` in the vault. Two surfaces was unnecessary friction; PLANS.md predated the vault and was never the intended go-forward.
2026-04-25 — Workflow — Vault committed to git for the first time. Backed up to `origin/main` after a near-deletion incident. Future drift cannot wipe the vault silently.
2026-04-25 — Workflow — Migrated `docs/project-overview.md`, `docs/game-systems.md`, `docs/ui-hierarchy.md`, `docs/known-bugs.md` into the vault. Single source of truth for text documentation. Originals left as stub pointers.
2026-04-25 — AGENTS.md — Removed `CashLeaderstats` from the no-touch DataStore list. It's slated for removal in cleanup, not a system to preserve. Frozen-not-extended is the correct stance.
2026-04-25 — AGENTS.md — Restored `PLANS.md` and `docs/live-repo-audit.md` references after audit revealed they were the active record of months of live-only reconciliation work. Repo wasn't "stale" — it was a curated subset with documented blockers.
2026-04-25 — AGENTS.md — Fixed file extension convention from `.luau`/`.client.luau`/`.server.luau` to `.lua`/`.client.lua`/`.server.lua` to match what the repo actually uses. Language is still Luau; extension is `.lua` for Rojo tooling reasons.
2026-04-25 — 06_Codex_Plans — Wrote, then superseded, `2026-04-25_Repo_Resync_v1.md`. Brief was based on a wrong premise (treating repo as stale). Replaced with `2026-04-25_Live_Reconciliation_Continuation_v1.md` targeting the audit's actual top priorities: `fridge-ui`, `Theme`, `OverheadTagsToggleServer`. Lesson preserved in the superseded brief's frontmatter.
2026-04-25 — Vault — Migrated Codex instructions from `_Codex_Instructions.md` (vault) into `AGENTS.md` (repo root) per session 1's plan. Codex's rules now live next to the code Codex edits.

---

## Format

`YYYY-MM-DD — [System] — Change. Reason.`

Example:
`2026-04-25 — Dialogue_System — Bumped default cooldown 3s → 4s. Felt rushed in playtest.`
`2026-04-25 — Cleanup_Backlog — Removed legacy saber shop. Off-tone, replaced by nothing (intentional).`
