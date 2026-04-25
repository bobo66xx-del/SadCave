# Repo Resync — Codex Plan

**Date:** 2026-04-25
**Status:** ⚫ Superseded — do not execute
**Related Systems:** [[../02_Systems/_Cleanup_Backlog]]

> **Why this is superseded (added 2026-04-25 during audit):**
>
> This brief was written before reading `PLANS.md` and `docs/live-repo-audit.md`. It assumed the repo was "stale" and a fresh resync was needed. In reality, a months-long live-only reconciliation effort is already in progress, the audit classifies every live object's export status (`exact` / `structurally mapped` / `tooling blocker` / `duplicate-name blocker` / `manual export needed`), and many items in this brief are blocked by the connector (`AnchorPoint` returns `null` for centered UI; duplicate names cannot be uniquely addressed; some scripts only return numbered conversational output, not raw source).
>
> Executing this brief would have:
> - pulled UI that has known unfaithful-export blockers (UI shifts, breaks)
> - deleted duplicate scripts the connector can't uniquely identify (deletes the wrong one)
> - overwritten already-transcribed no-touch DataStore scripts with another non-byte-exact copy
> - flipped `$ignoreUnknownInstances: false` while ~50 live items are still classified as manual-export-needed or tooling-blocked — Rojo would then delete them all from Studio on next sync
>
> **Replacement:** [[2026-04-25_Live_Reconciliation_Continuation_v1]] picks up where the audit left off, working through its "highest-priority load-bearing systems still outside repo" queue.
>
> The original content below is preserved as a record of what was almost done, and so future Opus instances can see the audit-vs-fresh-resync mistake and not repeat it.

---

## 1. Purpose

The Rojo repo at `C:\Projects\SadCave` is stale. Studio has scripts and UI that aren't in the repo. The repo has Rojo source that may not match what's in Studio. The Rojo project runs in **partial-ownership mode** (`$ignoreUnknownInstances: true` in `default.project.json`), so this drift has been silently accumulating.

This task does three things in one pass:

1. **Resync** — pull the live Studio state into the repo (Studio → repo) AND remove repo entries that no longer exist in Studio (repo → Studio reconciliation).
2. **Cleanup** — delete the legacy Shop / Cash / Donation / duplicate scripts from BOTH Studio and repo. List below in §4.
3. **Lock down** — flip Rojo to full-ownership mode (`$ignoreUnknownInstances: false`) so future drift is impossible. After this commit, the repo is canonical: Studio cannot have scripts or instances Rojo doesn't manage.

After this task, the repo and Studio match exactly, and Rojo enforces it going forward.

## 2. Player Experience

Nothing visible should change. This is infrastructure. If the player notices anything, it's a regression and must be flagged and fixed before shipping. The cleanup deletions in §4 should remove dead code paths only — UI for shop tools, donation displays, and cash leaderstats may visibly disappear, which is intentional and aligned with the cleanup backlog.

## 3. Technical Structure

- **Server responsibilities:** none added; some removed (legacy scripts).
- **Client responsibilities:** none added; some removed (legacy scripts).
- **Remote events / functions:** none added; some removed (Shop remotes if cleanup removes Shop entirely — see §4).
- **DataStore keys touched:** none. **No DataStore code is being changed.** The no-touch DataStore systems listed in `AGENTS.md` stay exactly as they are. We are only moving them between Studio and repo, not modifying their code. CashLeaderstats, DonationLeaderstats, and Shop are exceptions — those are being removed entirely per the cleanup backlog.

## 4. Files / Scripts

### Reality snapshot (taken 2026-04-25 by Opus via Studio MCP)

This is the diff between Studio (live) and `src/` (repo) as of plan-write time. Codex MUST re-verify before executing — Studio may have changed.

#### ServerScriptService — IN STUDIO BUT NOT IN REPO (pull these)

- `DialogueDirector` (Script) — pull, `Dialogue_System` is shipped per index
- `AreaDiscoveryBadge` (Script) — pull, `Area_Discovery` is shipped per index
- `AdminGamePass` (Script) — pull, monetization, **no-touch contents**
- `AdminServerManager` (Script) + child `WebhookService` (ModuleScript) + child `Admin` (ScreenGui w/ 4 children) — pull, **no-touch contents**
- `AFK` (Script) — pull, verify what it does
- `AnimToggle` (Script) — pull, verify what it does
- `ChatTag` (Script) — pull, verify whether duplicated by `Custom Chat Script`
- `Colide off` (Script, name has space) — pull, verify what it does
- `Commands` (Script) — pull, verify (admin-related?)
- `DiscordLogs` (Script) + child `LogsSettings` (ModuleScript) — pull, **no-touch contents**
- `GenerateSeatMarkers` (Script) — pull, verify
- `HealthChanger` (Script) — pull, verify
- `InviteFriends` (Script) — pull, verify
- `NoticeNew` (Script) — pull, verify
- `OverheadTagsToggleServer` (Script) — pull, related to NameTag pipeline (no-touch contents)
- `RefreshCommand` (Script) — pull, verify (admin-related?)
- `RemoveFF` (Script) — pull, verify
- `Reset` (Script) — pull, verify
- `Script` (Script, generic name) — pull, **flag in inbox** — generic-named scripts are usually orphans
- `Theme` (Script, server-side, distinct from `StarterPlayerScripts.Theme`) — pull
- `DelayedStarterTools` (Script) — pull, verify
- `AvItems` (Folder) + 10 children (`VOID`, `Korblox`, `CF`, `WCH`, `WCS`, `Headless`, `UnHeadless`, `SKOTN`, `CWH`, `CWS`) — pull entire folder, looks like avatar item gamepass scripts (**monetization, no-touch contents**)

#### ServerScriptService — IN REPO BUT NOT IN STUDIO (delete from repo)

- None confirmed. Codex must run a final pass to verify nothing in `src/ServerScriptService/` lacks a Studio counterpart. If found, delete from repo.

#### ServerScriptService — DELETE FROM BOTH (cleanup, per §4 of cleanup backlog)

- `Shop` (Script in Studio + `Shop/init.server.lua` + `Shop/init.meta.json` in repo) — legacy Shop with Saber/Scythe/Gun/Rocket Launcher
- `CashLeaderstats` (Studio + `CashLeaderstats.server.lua` in repo) — legacy currency display
- `DonationLeaderstats` (Studio only) — legacy donation board
- `DonationAmount` (Studio only) — legacy donation board
- `Purchase` (Studio, **2 copies** — both delete) — legacy shop purchase handler
- `SoftShutdown` (Studio, **3 copies** — keep ONE if any actually works, delete the other two; if uncertain which is the real one, **flag in inbox** with `[C] ?` and skip until Opus decides)

#### ServerScriptService — DUPLICATION CHECK NEEDED

- `report` (Folder, lowercase) + `reportHandler` (Script inside) AND `ReportHandler` (Script, top-level) — both in Studio AND repo. **Flag in inbox** — likely one is dead code. Do not delete without Opus deciding.

#### ReplicatedStorage — IN STUDIO BUT NOT IN REPO (pull these)

- `DialogueData` (ModuleScript) — pull, Dialogue System
- `DialogueRemotes` (Folder) + 4 children (`PlayPlayerDialogue`, `PlayerDialogueChoiceSelected`, `PlayCharacterDialogue`, `RequestCharacterConversation`) — pull, Dialogue System
- `Rose` (Tool) + child `Handle` (Part w/ SpecialMesh) — pull, in-world item
- `UIGradient` (UIGradient) + child `Script` — pull, verify what the child Script does

#### ReplicatedStorage — DELETE FROM BOTH (cleanup)

- `ShopItems` (Folder) — legacy shop tool inventory:
  - `Saber` (Tool) — delete
  - `Scythe` (Tool) — delete
  - `Gun` (Tool) — delete
  - `Rocket Launcher` (Tool) — delete
  - `Book` (Tool) — **keep, flag in inbox** — Book is not on the cleanup backlog and may be a real prop. Do not delete without Opus decision.
- `Remotes.Shop` (RemoteEvent inside `Remotes` folder) — delete, paired with Shop server script removal

#### ReplicatedStorage — DUPLICATION CHECK NEEDED

- `report` (Folder, lowercase) with `Settings` (ModuleScript) inside — same situation as ServerScriptService. Same `[C] ?` inbox flag.

#### StarterGui — IN STUDIO BUT NOT IN REPO (pull these)

- `fridge-ui` (ScreenGui, listed as live in `AGENTS.md`) — pull
- `Settings` (ScreenGui) — pull, verify (note: lowercase `settingui` ALSO exists; confirm which is live — likely `settingui` per AGENTS.md and `Settings` is legacy)
- `ComputerUI` (ScreenGui) — pull, verify
- `MainUI` (ScreenGui) — pull, verify
- `settingui` (ScreenGui, lowercase, listed as live in `AGENTS.md`) — pull
- `TPUI` (ScreenGui) — pull, verify (teleport UI? Already have `Teleport Button`)
- `IntroScreen` (ScreenGui) — pull, verify
- `NoteUI` (ScreenGui, listed as live in `AGENTS.md`) — pull
- `tipui` (ScreenGui, listed as live in `AGENTS.md`, **monetization** — no-touch contents) — pull

#### StarterGui — DELETE FROM BOTH (cleanup)

- `Menu` (ScreenGui, **3 copies** in Studio) — duplicate Menu ScreenGuis per cleanup backlog. **Keep the canonical one** if there is one (the one wired to actual scripts), delete the other two. If unclear which is canonical, **flag in inbox** with `[C] ?` and skip.
- `ScreenGui` (ScreenGui, generic name, **2 copies**) — both look like orphans. Delete both; **flag in inbox** for Opus to confirm none of these is wired to anything live.
- `NotificationTHingie` (ScreenGui) — delete, looks like a typo'd dev artifact. Confirmed unused? **Flag in inbox** if uncertain.
- `bruh` (ScreenGui) — delete, name says it all. **Flag in inbox** if uncertain.
- `TTTUI` (ScreenGui) — delete unless wired up. **Flag in inbox**.

#### StarterPlayerScripts — IN STUDIO BUT NOT IN REPO (pull these)

- `NpcDialogueClient` (LocalScript) — pull, Dialogue System
- `PlayerDialogueClient` (LocalScript) — pull, Dialogue System
- `environment change ` (Folder, **trailing space in name**) — pull contents, but flag the name. Trailing-space names are dev cruft. **Flag in inbox** for rename or delete.

#### StarterPlayerScripts — IN REPO BUT NOT IN STUDIO (delete from repo)

- None obvious. Codex must verify by running a final diff after the pull.

### Files Codex will touch

- Pull operations: many — Codex uses Rojo's pull workflow (or manual save-to-disk via Studio plugin) to bring the items above into `src/...`
- Delete operations:
  - In Studio: every script/instance in the "DELETE FROM BOTH" lists above
  - In repo: `src/ServerScriptService/Shop/`, `src/ServerScriptService/CashLeaderstats.server.lua`, plus any newly-orphaned files surfaced by the diff
- `default.project.json` — change `$ignoreUnknownInstances` from `true` to `false` in all four service entries (`ReplicatedStorage`, `ServerScriptService`, `StarterPlayer/StarterPlayerScripts`, `StarterPlayer/StarterCharacterScripts`, `StarterGui`). LAST step, after parity is confirmed.
- `place-backups/` — create a new `.rbxl` save here named `Pre-Resync_2026-04-25.rbxl` BEFORE any deletion.

## 5. Step-by-Step Implementation (for Codex)

> **Read this whole list before starting.** Steps are ordered for safety. Don't skip ahead.

### Phase 0 — Backup

1. Create branch `repo-resync-2026-04-25` from current main. Commit nothing yet.
2. In Studio, File → Save As → `place-backups/Pre-Resync_2026-04-25.rbxl`. This is the rollback point.
3. In `00_Inbox/_Inbox.md`, add `[C] HH:MM — Backup branch + .rbxl saved. Starting resync.`
4. Update plan Status: 🔵 Planned → 🟡 In Progress.

### Phase 1 — Verify the Studio diff

5. The §4 diff was captured 2026-04-25. Studio may have changed. Walk the four containers (`ServerScriptService`, `ReplicatedStorage`, `StarterGui`, `StarterPlayer`) at depth 2 and compare against §4.
6. For each item where reality differs from §4, log to inbox: `[C] HH:MM — Diff drift: <item> was <X> in plan, is <Y> now.`
7. If drift is significant (more than ~5 items off), STOP and `[C] ?` flag — Opus needs to update the plan before proceeding.

### Phase 2 — Pull (Studio → repo)

8. For each item in the "IN STUDIO BUT NOT IN REPO (pull these)" lists, save it into the corresponding `src/` path. Use Rojo's recommended pull workflow — typically the Rojo Studio plugin's "Build" or save-to-file feature, or `rojo build` with manual export. Whichever you use, the result must be that `src/` matches Studio for those items.
9. Pull in this order: `ReplicatedStorage` first (others depend on its remotes/configs), then `ServerScriptService`, then `StarterGui`, then `StarterPlayer`.
10. After each container, log to inbox: `[C] HH:MM — Pulled <container>, <N> new files, <N> updated files.`
11. **Do NOT pull DataStore-touching scripts that are flagged no-touch in `AGENTS.md` if their content has changed.** If `TitleService`, `LevelLeaderstats`, `ShopService`, `DailyRewardsServer`, `FavoritePromptPersistence`, `NoteSystemServer` show differences, log them but do not overwrite. `[C] ?` flag in inbox for Opus to review separately. The risk is silent data-shape changes that break saves on next deploy.

### Phase 3 — Reconcile (repo → Studio)

12. After pulling, walk `src/` and find any file/folder that does not have a matching Studio instance. These are stale repo entries. List them in inbox under one entry: `[C] HH:MM — Stale repo entries to delete: <list>.` Do not delete them yet — wait for Opus to confirm or mark `Status: ok-to-delete` in the inbox.
13. After Opus confirms (or after this session if no flags), delete the stale entries from `src/`.

### Phase 4 — Cleanup (delete legacy from both sides)

14. Delete from Studio AND repo, in this order — `[C]` log each one as it goes:
    - `ReplicatedStorage.Remotes.Shop` (RemoteEvent) — delete first, before Shop server script, so other scripts that listen for it fail-fast and surface
    - `ServerScriptService.Shop` (the Script) and `src/ServerScriptService/Shop/` (folder)
    - `ServerScriptService.Purchase` (both copies)
    - `ServerScriptService.CashLeaderstats` and `src/ServerScriptService/CashLeaderstats.server.lua`
    - `ServerScriptService.DonationLeaderstats`
    - `ServerScriptService.DonationAmount`
    - `ReplicatedStorage.ShopItems.Saber`, `Scythe`, `Gun`, `Rocket Launcher` (NOT Book — flag Book in inbox)
    - The 2 extra `SoftShutdown` scripts (only if you can identify which is canonical; otherwise `[C] ?` and skip)
    - The 2 extra `Menu` ScreenGuis (same caveat — only if canonical is identifiable)
    - The 2 generic `ScreenGui` ScreenGuis in StarterGui (after `[C] ?` inbox flag)
    - `NotificationTHingie`, `bruh`, `TTTUI` (after `[C] ?` inbox flags)
15. After each deletion, run a Studio playtest of ~30 seconds. If any error appears in the console referencing the deleted item, STOP and roll back from the `.rbxl` backup. `[C]` log the error verbatim.

### Phase 5 — Parity test

16. With everything pulled, deleted, and reconciled, do a clean Studio playtest:
    - Join, see currency UI render correctly
    - Equip a title via `TitleMenu`
    - Submit a note via `NoteUI`
    - Daily reward popup if applicable
    - Wander to a discoverable area, confirm Area Discovery badge fires
    - Talk to an NPC, confirm dialogue plays
    - Open `tipui`, confirm tip product page renders (do NOT actually buy)
    - Confirm chat tags / overhead nametags display
    - Confirm `fridge-ui` opens at the fridge prop
17. Log each pass/fail to inbox with `[C]`.

### Phase 6 — Lock down

18. Only after Phase 5 fully passes: edit `default.project.json` and change `$ignoreUnknownInstances: true` to `$ignoreUnknownInstances: false` in all four service entries.
19. Run `rojo serve` (or restart it) and connect from Studio. Watch the Rojo plugin output. If it reports "would delete N instances" or similar, STOP — those are items still in Studio that aren't in repo and weren't caught by the diff. `[C] ?` flag in inbox with the list.
20. If Rojo connects clean with no diffs, parity is confirmed.

### Phase 7 — Commit

21. Stage all changes: `git add -A`.
22. Commit message: `Resync repo with Studio + cleanup legacy scripts; switch to full ownership`
23. Do NOT merge to main. Push the branch and `[C]` log: `[C] HH:MM — Resync complete on branch repo-resync-2026-04-25. Awaiting Opus review.`
24. Update plan Status: 🟡 In Progress → 🟢 Shipped.

## 6. Roblox Services Involved

`Players`, `ReplicatedStorage`, `ServerScriptService`, `StarterPlayer`, `StarterGui`, `Lighting` (RainScript-adjacent), `SoundService` (SadCaveMusicGui-adjacent). No service code changes — services are listed only because the resync touches their containers.

## 7. Security / DataStore Notes

- ⚠️ **No DataStore code is being modified.** This task moves files between Studio and repo and deletes legacy scripts. If at any point Codex finds itself writing or editing the *contents* of `TitleService`, `LevelLeaderstats`, `ShopService`, `DailyRewardsServer`, `FavoritePromptPersistence`, or `NoteSystemServer`, STOP and `[C] ?` flag — that's outside this task's scope.
- ⚠️ **Validation:** N/A — no new remotes added.
- ⚠️ **Rate limits:** N/A.
- ⚠️ **Datastore retry/pcall:** untouched — all DataStore code is no-touch.
- ⚠️ **Monetization scripts** (`AdminGamePass`, `tipui`, `AvItems` gamepass scripts, `TipProductConfig`) — pull files only, do not edit contents. If pull surfaces a content diff vs repo, flag it.

## 8. Boundaries (do NOT touch)

Per `AGENTS.md`:

- DataStore code (contents) — `CashLeaderstats` excepted (it's being deleted)
- Live networking contracts — Shop remotes excepted (being deleted)
- Title / overhead tag pipeline contents
- Admin / moderation / report content (you ARE moving the files, not editing them)

Beyond `AGENTS.md`:

- Don't refactor anything during the resync. If you see ugly code, `[C]` log it as an observation, don't fix it. Resync first, refactor never (unless Opus assigns a new task).
- Don't add features. Don't rename things (except where the trailing-space `environment change ` folder forces a rename — and even then, flag it).
- Don't touch the vault except `00_Inbox/_Inbox.md` and the `Status` field of this plan.

## 9. Studio Test Checklist

(Same as Phase 5, listed here as a checkbox view.)

- [ ] Player joins without console errors
- [ ] Currency UI renders
- [ ] `TitleMenu` opens and equipping a title works end-to-end
- [ ] `NoteUI` accepts a submission
- [ ] Daily reward triggers if eligible (skip if not eligible to test)
- [ ] Area discovery badge fires on entering a flagged area
- [ ] NPC dialogue plays through `DialogueDirector` + clients
- [ ] `tipui` opens and shows products (DO NOT PURCHASE)
- [ ] Chat tags display
- [ ] Overhead nametags display
- [ ] `fridge-ui` opens at the fridge prop
- [ ] No console errors referencing `Shop`, `CashLeaderstats`, `Donation*`, or any deleted script
- [ ] Rojo connects clean in full-ownership mode (no "would delete" diffs)

## 10. Rollback Notes

Two rollback paths, in order of preference:

1. **Lightweight (repo only).** `git checkout main && git branch -D repo-resync-2026-04-25` — abandons the branch. Studio is unchanged because no Rojo serve/sync has happened yet (or because we kept Studio as the source until Phase 4).
2. **Full (Studio + repo).** Open `place-backups/Pre-Resync_2026-04-25.rbxl` in Studio, save it as the live place file, and discard the git branch. This recovers everything to pre-resync state.

If Phase 6 (the `$ignoreUnknownInstances: false` flip) causes Rojo to delete instances unexpectedly, immediately:
- Stop Rojo serve
- Open the `.rbxl` backup
- Revert `default.project.json` to `$ignoreUnknownInstances: true`
- Then diagnose what was missed in the diff before re-attempting

If something breaks in production AFTER commit + deploy:
- Revert the merge commit on main
- Republish from the previous good place file
- Open Phase 6 fresh in a new branch with the lessons learned
