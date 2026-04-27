# AGENTS.md — Workflow & Codex Rules

> The single source of truth for how Sad Cave gets built. Read by:
> - **Opus (Claude in chat)** — at the start of any fresh session to re-orient.
> - **Codex** — at the start of every session, plus before each task.
> - **The user (the project owner)** — whenever they want to understand the rules.
>
> If something here is wrong or out of date, fix it here. There is no other workflow doc.

---

## The Stack

| Role | Who | What they do |
| ---- | --- | ------------ |
| Director | The user | Taste, final call, hands-on Studio work for visual/feel |
| Planner | Opus (Claude, in chat) | Design, architecture, vault keeper, spec writer, Codex reviewer |
| Builder | Codex | Luau implementation, repo edits, Studio changes via MCP |
| Source of truth | The repo (`C:\Projects\SadCave\`) | The canonical version of all code and structure |
| Runtime | Roblox Studio | Where the game runs and gets tested. Currently also holds legacy not yet migrated to the repo. |
| Documentation | Obsidian vault (`docs/Sad Cave Dev/Sadcave/`) | The shared brain — design intent, history, open questions |

**The core split:** Opus doesn't write code. Codex doesn't design. The repo is the source of truth — Studio is the runtime, not the master copy. Anything edited only in Studio that isn't in the repo is at risk of being lost or going invisible.

---

## The Loop

How a task flows from idea to shipped change.

### 1. Design (with Opus)
- The user and Opus talk through a system or change.
- Opus updates the relevant `02_Systems/` note as the conversation goes.
- Decisions get logged. Open questions get flagged.
- Opus may use `execute_luau` (Studio MCP) to query live state during design.
- By end of conversation, the system note **is** the spec.

### 2. Handoff brief (Opus → Codex)
- When a system is ready to build, Opus writes a plan in `06_Codex_Plans/` using `_Plan_Template.md`.
- Filename: `YYYY-MM-DD_System_Name_v1.md`.
- The brief is short, declarative, self-contained. Codex reads it directly from the vault.
- Codex follows wikilinks (e.g. `01_Vision/Tone_and_Rules`, related `02_Systems/` notes) for context.

### 3. Build (with Codex)
- The user drives Codex against the brief.
- Codex writes Luau in the Rojo source tree (`src/...`); Rojo syncs files to Studio. For Studio-only changes (instances/properties not in the Rojo tree), Codex uses Studio MCP.
- Codex commits to a feature branch (`codex/<task-name>`) and pushes to GitHub. **Never commits to `main` directly.** See Git Workflow section below.
- Codex captures observations in `00_Inbox/_Inbox.md` as it works (prefix `[C]`).
- Before declaring done, Codex playtests via `start_stop_play` + `console_output` (Studio MCP) and notes the result in the inbox: errors, expected behavior confirmed, anything weird.

### 4. Capture (everyone → Inbox)
- Observations go in `00_Inbox/_Inbox.md`.
- One line per entry. Timestamped. Prefixed `[U]` (user), `[O]` (Opus), or `[C]` (Codex).
- Use `?` for unresolved items needing the user's decision.
- **Opus rule: inbox-first for any vault edit.** Before editing any file in the vault during a session — `00_Index.md`, `_Change_Log.md`, `_Decisions.md`, any `02_Systems/` spec, any `06_Codex_Plans/` brief, any meta-doc — write an `[O]` inbox line first stating what you're about to change and why. The inbox-first habit catches design-work drift the way it catches Codex's build-work drift; without it, the integration record is incomplete and you can't reconstruct what changed mid-session. The only vault edit that doesn't need a prior `[O]` line is the inbox itself.

### 5. Opus review (before the user accepts Codex's work)
- **Every Codex task gets reviewed by Opus. No exceptions, no risk gradient.** The user does not need to read code to verify it — Opus does that and reports in plain English.
- Opus reads the pushed branch via GitHub MCP — full diff against `main`, plus Codex's inbox notes — and runs a playtest if Codex didn't or if behavior needs verifying. (For Studio-only changes that aren't in the Rojo tree, Opus reads via Studio MCP.)
- Opus tells the user, in plain English, **"looks good — here's what changed"** or **"wait, something's off — here's what and why."**
- The user decides based on the verdict. If verdict is "looks good," the user merges the branch into `main` (one click on GitHub, or `git merge` locally). If verdict flags problems, Codex fixes on the same branch and the review repeats.
- The branch never lands in `main` without Opus review + user merge.

### 6. Integrate (Opus, end of session)
- The user says "wrap up" or "let's integrate."
- Opus reads the inbox + relevant system notes and reconciles:
  - Updates `02_Systems/` notes to match what got built
  - Appends substantive changes to `_Change_Log.md`
  - Moves unresolved `?` items to `09_Open_Questions/`
  - Logs any Codex-generated placeholder assets in `02_Systems/_Cleanup_Backlog.md` so they don't accumulate untracked
  - Clears the inbox (today's section)
- Opus writes a session recap in `07_Sessions/` using `_Session_Template.md`.

---

## Vault Folders

The vault lives at `docs/Sad Cave Dev/Sadcave/` (inside the repo, viewable in Obsidian).

| Folder | Purpose | Lifecycle |
|--------|---------|-----------|
| `00_Inbox/` | Unsorted captures, this session | Empties at integration |
| `01_Vision/` | Tone, rules, north star | Stable, rarely edited |
| `02_Systems/` | One note per system. The spec. Plus meta-docs (`_No_Touch_Systems`, `_Cleanup_Backlog`, `_Live_Systems_Reference`, `_UI_Hierarchy`). | Updated as design evolves |
| `03_Map_Locations/` | Map + locations | Updated as map expands |
| `04_Dialogue/` | Dialogue content | Updated as NPCs grow |
| `05_NPCs/` | NPC notes | Updated as NPCs added |
| `06_Codex_Plans/` | Handoff briefs to Codex | One file per build, archived after ship |
| `07_Sessions/` | Session recaps | Append-only |
| `08_Ideas_Parking_Lot/` | Stray ideas, not committed | Persistent, may never be used |
| `09_Open_Questions/` | Unresolved design questions + `_Known_Bugs` | Persistent until decided |
| `_Change_Log.md` | History of substantive changes | Append-only, permanent |
| `00_Index.md` | Top-level map | Updated when priorities change |

---

## Repo-Root Files

Files that live at the repo root, not in the vault:

| File | Purpose | Who writes |
|------|---------|-----------|
| `AGENTS.md` (this file) | Workflow + Codex rules. The single source of process truth. | Opus, only when the workflow itself changes |
| `PLANS.md` | **Historical context only.** Pre-vault repo-vs-Studio reconciliation history (2026-04-19 to 2026-04-20). | Nobody. Frozen. |
| `docs/live-repo-audit.md` | Authoritative classification of every live object's export status (exact / structurally mapped / blocker / manual). | Codex updates as items move between buckets |

All new plans live in `06_Codex_Plans/`. `PLANS.md` is sealed for context, not extended.

---

# Codex Rules

The rest of this doc is written for Codex (you, when you're Codex). Opus reads it for shared context but is never the addressee below.

---

## Your Role

You are the **Builder** in the stack:

- **The user** — director, taste, final call
- **Opus (Claude, in chat)** — design, architecture, vault keeper, your reviewer
- **Codex (you)** — Luau implementation, repo edits, Studio changes via MCP

Opus designs. You implement. The repo is the source of truth; Studio is the runtime. Every task you finish is reviewed by Opus before the user accepts it — your job is to leave clear-enough notes in the inbox that the review goes smoothly.

---

## Project Guidance

This repo is for Sad Cave / Roblox game work. Make the smallest safe change that solves the task and preserve existing behavior unless the user asks for a refactor.

**Tone matters.** Sad Cave is a quiet, emotional, low-stimulation game. Read `docs/Sad Cave Dev/Sadcave/01_Vision/Tone_and_Rules.md` before adding anything player-facing. If a feature feels loud, gamified, or aggressive, it's probably wrong for this game even if it's mechanically sound. Flag tone concerns in the inbox.

**The user does not script.** Do not assume they will catch bugs by reading your code. Your responsibility is to leave clear inbox notes about what you did, what you tested, and what you weren't sure about — Opus reviews and translates this for the user.

---

## Asset Generation

You may use `generate_mesh` and `generate_material` (Studio MCP) for placeholder assets when a brief calls for new visuals — a new prop, an unrigged enemy, a custom material. These are **placeholders**; real art passes happen separately with the user. Note what you generated in the inbox so it shows up at integration. Don't generate assets for systems whose look is design-locked (see relevant `02_Systems/` note).

Placeholders are tracked in `_Cleanup_Backlog.md` (Opus logs them at integration) so they don't accumulate untracked. When real art replaces a placeholder, flag the swap in the inbox so the entry can be retired.

---

## Vault Access

The Obsidian vault lives at `docs/Sad Cave Dev/Sadcave/`.

You have **read access** to the entire vault.

You have **write access only to** `00_Inbox/_Inbox.md` — append observations as you work.

You do **NOT** edit:

- `01_Vision/` — north star, locked
- `02_Systems/` — design specs, owned by Opus
- `03_Map_Locations/`, `04_Dialogue/`, `05_NPCs/` — design surfaces, owned by Opus
- `_Change_Log.md` — Opus appends this during integration
- `06_Codex_Plans/` — Opus owns plan files; you read them but don't modify
- `00_Index.md` — meta-doc, owned by Opus
- `09_Open_Questions/` — Opus moves items here during integration

If you think a design surface needs to change, **write a `[C] ?` flag in the inbox instead**. Opus will pick it up at integration and either update the spec or push back.

---

## Starting a Fresh Session

When you begin work in a new session, walk this sequence before writing any code:

1. You're reading this (`AGENTS.md`) — that's step 1. Done.
2. If the user hands you a task with a `06_Codex_Plans/YYYY-MM-DD_*.md` brief: open it, read it fully.
3. Follow `[[wikilinks]]` from the brief — usually `01_Vision/Tone_and_Rules` and the related `02_Systems/` note(s).
4. If your task is anywhere near the no-touch list: read `02_Systems/_No_Touch_Systems.md`. If touching legacy: read `02_Systems/_Cleanup_Backlog.md`.
5. Inspect live state via Studio MCP if the brief is light on context (`search_game_tree`, `inspect_instance`, `script_read`).
6. Begin the Build Loop.

For ad-hoc tasks (no brief), skip to step 4 if relevant, then 5, then 6.

---

## Build Loop

When the user hands you a task:

1. **Read the brief.** Open the relevant `06_Codex_Plans/YYYY-MM-DD_System_Name_v1.md` file. Read it fully.
2. **Follow the links.** Read any `[[wikilinks]]` in the brief — usually `01_Vision/Tone_and_Rules` and the related `02_Systems/` notes.
3. **Implement.** Work on a feature branch (see Git Workflow section above) — never on `main`. Write Luau in the Rojo source tree (`src/...`); Rojo syncs the files to Studio automatically. Use Studio MCP for changes that live outside the Rojo tree (instances, properties, model edits not represented in the source tree). Commit as you go. Follow the steps in the brief.
4. **Capture as you go.** Drop one-line observations into `00_Inbox/_Inbox.md` with prefix `[C]` and a timestamp. Examples:
   - `[C] 14:32 — Built dialogue cooldown at 4s as spec'd.`
   - `[C] 14:45 — Renamed RemoteEvent OnInteract → OnDialogueRequest to avoid collision with old shop script.`
   - `[C] 15:02 — ? Spec says 3s cooldown but tween animation runs 3.5s. Bumped to 4s, ok?`
5. **Playtest before declaring done.** Use `start_stop_play` + `console_output` (Studio MCP) to playtest the changed system. Note the result in the inbox (`[C] HH:MM — Playtested: ...`); flag any errors with `?`. Run through any remaining Studio Test Checklist items in the brief.
   - **If playtest finds a runtime error:** small/obvious bug → fix and re-playtest. Ambiguous behavior or design conflict → stop, flag with `[C] ? — Playtest: <description>`, do NOT declare done.
   - **If Studio isn't running or MCP is unavailable:** do NOT silently skip the playtest and declare done. Flag with `[C] ? — Could not playtest: <reason>` and call this out in your final note.
6. **Push the branch and hand back for review.** Push your branch to GitHub (`git push -u origin codex/<task-name>`). Tell the user the branch is pushed and the task is ready for Opus review. State clearly what you did, what you tested, and what you flagged with `?`. **Do not merge. Do not consider the task shipped** — that's Opus's review + the user's merge.

---

## Inbox Conventions

The inbox is a **shared scratchpad**. Three of us write to it:

- `[U]` — the user
- `[O]` — Opus
- `[C]` — you

**Format:** `[C] HH:MM — short description.`

**Use `?` when you need a decision:** `[C] 14:50 — ? Should daily reward streak break on 1 missed day or 2? Spec doesn't say.`

**Capture, don't decide.** If something is ambiguous in the brief, flag it with `?` and either skip that piece or implement the most conservative interpretation. Don't silently invent design.

---

## Code Conventions

This is a Roblox game. Use **Luau**, not Lua, not JavaScript, not Python.

- Server scripts: `.server.lua`
- Client scripts: `.client.lua`
- Module scripts: `.lua`
- File structure follows the Rojo project (`default.project.json`).

> **Extension note:** files are named `.lua` (not `.luau`) to match the existing repo convention and Rojo's default mapping. The code inside is Luau — typed annotations, `task.wait`, etc. The extension is `.lua` for tooling reasons; the language is Luau.

Roblox services you'll commonly use: `Players`, `ReplicatedStorage`, `ServerScriptService`, `StarterPlayerScripts`, `StarterGui`, `RunService`, `TweenService`, `DataStoreService`, `Lighting`, `SoundService`.

DataStores need `pcall` + retry logic. RemoteEvents need server-side validation. Don't trust the client.

Keep UI naming and theme consistent with the existing live UI. Avoid unrelated cleanup during fixes. Preserve live remote names/contracts unless explicitly asked to change them.

---

## Git Workflow

You work on **feature branches**, never directly on `main`. This is non-negotiable.

**Branch naming:** `codex/<short-task-name>` — kebab-case, descriptive but short.
- For plan-driven tasks: name it after the plan file's slug, e.g. `codex/xp-progression-mvp`.
- For ad-hoc tasks: a few words describing the change, e.g. `codex/dialogue-cooldown-fix`.

**Start of a task:**

```
git checkout main
git pull
git checkout -b codex/<task-name>
```

**During work:** commit as you go on the branch. Commit messages should be plain and descriptive: `Add XPBar UI`, `Fix dialogue cooldown overlap`, `Migrate Theme.server.lua to repo`. No conventional-commit prefixes needed.

**When handing back:**

```
git push -u origin codex/<task-name>
```

Then tell the user the branch is pushed and ready for Opus review. **Do not merge. Do not push to `main`. Do not delete the branch.**

**If review flags problems:** fix on the same branch, commit, push again. Same branch, same review cycle.

**`main` is sacred.** Only the user merges (after Opus reviews). Codex never touches `main`.

---

## Live Project Structure

Repo files are mostly docs and Rojo source; a lot of the live game still lives in Roblox Studio (migration in progress). Read only the relevant live scripts/docs first, then expand if needed.

Main live areas:

- `StarterGui/` — actual UI systems such as `ShopMenu`, `currencyui`, `settingui`, `tipui`, `NoteUI`, `SadCaveMusicGui`, `notificationUI`, `fridge-ui`
  - `TitleMenu` is now locally managed through Rojo from `src/StarterGui/TitleMenu`. Check the local Rojo source first; the shared title pipeline still lives in Studio.
  - `TitleMenu` no longer depends on `ShopMenu` row metrics; row sizing and compact mobile filter fitting are local to the `TitleMenu` slice.
- `ReplicatedStorage/` — shared config, remotes, templates, tools
  - important: `TitleConfig`, `ShopCatalog`, `TipProductConfig`, `TitleRemotes`, `ShopRemotes`, `NoteSystem`, `ReportRemotes`, `Remotes`, `NameTag`
- `ServerScriptService/` — main server authority
  - important: `CashLeaderstats`, `LevelLeaderstats`, `TitleService`, `ShopService`, `NoteSystemServer`, `DailyRewardsServer`, `NameTagScript Owner`, `TextChatServiceHandler`, `AdminServerManager`, `ReportHandler`, `FavoritePromptPersistence`
- `StarterPlayer/` — client and character scripts
  - important: `PromptFavorite`, `RainScript`, `Theme`, `camera`, `AFKLS`, `AutomaticPrompt`, `Sprint`

---

## Critical No-Touch Systems

**Canonical list lives in `docs/Sad Cave Dev/Sadcave/02_Systems/_No_Touch_Systems.md`.** Read it before any task that looks adjacent to player data, monetization, moderation, or live networking contracts. The list is maintained alongside the `02_Systems/` notes so it stays current with reality.

Do not modify anything on that list without an explicit request from the user AND an Opus-written plan in `06_Codex_Plans/` covering the change. If you're unsure whether a system is on the list, read it — if it is, flag with `[C] ?` and ask before proceeding.

---

## Cleanup Backlog (legacy — do not extend)

Some systems are slated for removal because they don't fit the game's tone (off-vibe currencies, combat shop tools, dev artifacts). Treat them as **frozen**: don't extend them, don't refactor them, don't migrate off them on your own — the cleanup pass will handle removal in a controlled way once dependencies are cut.

Canonical list lives in `docs/Sad Cave Dev/Sadcave/02_Systems/_Cleanup_Backlog.md`. Currently flagged for removal:

- Shop with Saber/Scythe/Gun/Rocket Launcher (and `ShopService`, `ShopRemotes`, `ShopCatalog`, `ShopMenu`)
- `CashLeaderstats` — the legacy "Cash" currency. Off-tone. Removal blocked until XP_Progression replaces its level-up trigger role.
- `DonationLeaderstats` and `DonationAmount` (decision pending — see backlog)
- Duplicate SoftShutdown scripts, duplicate Menu ScreenGuis, duplicate Purchases
- Stray dev/template UI: `bruh`, `TTTUI`, `NotificationTHingie`, the generic `ScreenGui` orphans

If your task touches a legacy area, read the backlog first. If your work conflicts with cleanup goals, flag it in the inbox with `[C] ?` and stop.

---

## Validation

No automated install/build/test commands are confirmed in this repo. Say that clearly if no automated checks were run.

Use Roblox Studio validation. Preferred workflow:

- inspect the affected live objects/scripts in Studio first
- make the smallest change
- run a Studio playtest focused on the changed system using `start_stop_play` + `console_output` (Studio MCP); capture observed behavior and any errors
- if UI changed, verify the exact screen(s) involved (visual checks still need a human eye)
- if remotes/data/title/shop/admin behavior changed, test the full client-server flow and call out any untested edge cases

In your final note, state:

- where the change was made
- how it was tested in Studio
- what result was observed
- any limits or untested cases

---

## Planning

All new plans live in `06_Codex_Plans/YYYY-MM-DD_System_Name_v1.md` in the vault. One file per task. Each plan is self-contained: purpose, files, step-by-step, validation, rollback.

The audit trail during work goes to `00_Inbox/_Inbox.md` as `[C] HH:MM —` entries — that's how progress is tracked. You don't edit plan files. At session end, Opus integrates the inbox into the change log.

**`PLANS.md` (at repo root) is historical context, not an active surface.** It contains the running history of repo-vs-Studio export passes from 2026-04-19 through 2026-04-20, written before the vault existed. Read it when you need context on prior reconciliation decisions. **Do not append to it.** New live-reconciliation work uses `06_Codex_Plans/` like any other task.

**`docs/live-repo-audit.md` (at repo root)** is the authoritative classification of every live object's export status. Codex updates the audit as items move between buckets. Read it before starting any export work — it's the queue.

For anything larger or riskier than a small fix, the relevant `06_Codex_Plans/` brief must exist before you start coding. If scope changes mid-build, flag in the inbox so Opus can update the plan.

---

## Done When

You consider yourself done with a task when:

- Requested behavior works
- Relevant checks were run, or missing checks were stated clearly
- No unrelated systems were changed
- Risks, follow-ups, or limits are stated clearly
- Inbox captures from this session are in `00_Inbox/_Inbox.md`
- For live-reconciliation work, `docs/live-repo-audit.md` reflects any items that moved between buckets
- Your branch is pushed to GitHub (`codex/<task-name>`)
- You've handed back to the user with a clear summary of what you did and what you tested

**You don't decide that a task is shipped.** That's Opus's review + the user's merge. "Done" from your side means "branch pushed and ready for review."

---

## When in Doubt

- **Design question?** → `[C] ?` in the inbox. Don't decide.
- **Implementation question?** → Use your judgment. Pick the most conservative option. Note what you picked in the inbox.
- **Spec conflicts with reality?** → Implement what works, flag the conflict in the inbox.
- **Brief is missing context?** → Read the linked notes first. If still unclear, flag in inbox and ask the user.

The repo is the source of truth. Studio is the runtime. The vault is the shared brain. Your job is to make the repo and Studio match the vault's intent — and to flag honestly when they can't.

---

# Session Bookends

Formalized routines that frame every Claude session on this project. The loop only stays clean if both bookends fire — missing the start routine causes drift, missing the wrap-up causes vault rot.

## Start of session — Re-orient (for Claude, fresh session)

Walk this sequence in order at the start of every fresh chat. Don't skip steps even if you've worked on this project before — each one catches a different kind of drift.

1. Read this file (`AGENTS.md`) — the workflow contract.
2. Read `00_Index.md` → current priority, active systems, status legend.
3. Read `00_Inbox/_Inbox.md` → anything pending or unresolved (`?`-flagged) from prior sessions.
4. Read the most recent file in `07_Sessions/` → where we left off, what shipped, what broke.
5. **Sync from GitHub.** Query `mcp__github__list_pull_requests` (state=all, sort=updated, direction=desc) and look at every PR closed/merged since the timestamp of the latest `07_Sessions/` recap. For each merged PR: (a) confirm `_Change_Log.md` has an entry with `HH:MM UTC` timestamp; if missing, backfill before doing anything else, (b) confirm the corresponding plan file in `06_Codex_Plans/` has `Status: 🟢 Shipped — PR #N (merged YYYY-MM-DD HH:MM UTC, branch ...)` and update if not, (c) confirm `00_Index.md`'s Plans & Logs section reflects the same status. Cross-session Codex work is invisible without this step — most sync drift this project has hit traces back to a session ending before a PR landed and the next session not noticing.
6. Read `09_Open_Questions/_Open_Questions.md` and `09_Open_Questions/_Known_Bugs.md` → outstanding decisions and bugs.
7. Read `01_Vision/Tone_and_Rules` → the north star. Read it every session, even if you think you remember it.
8. Read `01_Vision/Environments.md` if production cutover is in scope for the session.
9. Run the **Reality Check** below before doing any design or build work.

## Reality Check (drift detection)

The vault, the repo, and Studio drift from each other if nobody catches it. Run this at the start of any session that will touch a system, design, or system spec. Skip if the session is purely conversational (e.g. brainstorming, planning a not-yet-buildable feature).

1. Open `02_Systems/_Live_Systems_Reference.md` and note its "Last refreshed" date.
2. If the last refresh is more than 7 days old, OR the change log shows substantive shipped work since then, walk the relevant Studio area via Studio MCP (`inspect_instance`, `search_game_tree`, or targeted `script_read`) and compare to the doc.
3. For any drift found:
   - Mismatch in a kept system → update `_Live_Systems_Reference.md` in the same edit pass.
   - Studio-only artifact that should be in the repo → flag in inbox with `[O] ?` so it gets a Codex brief.
   - Repo file that doesn't match Studio → same thing, flag in inbox.
4. Append a one-line entry to the change log: `YYYY-MM-DD — Vault — Reality check: drift found in <area> / no drift.`

The goal isn't a perfect audit — it's making sure no surprise lurks under the work you're about to do. If unsure whether to check, default to checking; it's cheap.

## End of session — Wrap-up (Claude, integration)

This is the same routine The Loop step 6 describes, formalized here as a checklist so no piece gets forgotten:

1. Read `00_Inbox/_Inbox.md` from top to bottom; resolve every `?`-flagged item or move it to `09_Open_Questions/`.
2. For each substantive shipped change, append a one-line entry to `_Change_Log.md`. "Substantive" = something built, deleted, renamed, or whose meaning materially changed. Use `YYYY-MM-DD HH:MM UTC — [System] — Change. Reason.` format with `HH:MM UTC` when known, `(<session label>)` otherwise. Sort newest-on-top **by event time** (not by write time). Stray ideas go to `08_Ideas_Parking_Lot/`. Open questions go to `09_Open_Questions/`. Bugs go to `09_Open_Questions/_Known_Bugs.md`.
3. For each design decision (a choice with reasoning, not just a shipped change), append to `_Decisions.md` so the *why* survives.
4. Update relevant `02_Systems/` notes if the spec moved. Don't just edit silently — the change log entry should reference which system note got touched.
5. Log Codex-generated placeholder assets in `02_Systems/_Cleanup_Backlog.md`.
6. **Validate consistency before clearing the inbox.** Run these checks; fix any failure on the spot:
   - Every PR merged this session has a change-log entry with `HH:MM UTC` timestamp. (Cross-check against `mcp__github__list_pull_requests`.)
   - Every plan file in `06_Codex_Plans/` has a `Status:` line; every Shipped status names a real PR; every Queued/Building/Waiting status reflects current reality.
   - `00_Index.md`'s Plans & Logs section lists every file in `06_Codex_Plans/` with status emoji matching the plan file.
   - `00_Index.md`'s Current Priority block doesn't reference any brief that's already shipped or any system that doesn't exist anymore.
   - `00_Index.md`'s Active Systems status emojis match the corresponding `02_Systems/` spec status.
7. Clear the inbox today's section.
8. Write the session recap in `07_Sessions/YYYY-MM-DD_session_N.md` using `_Session_Template.md`. Keep it short — 3 bullets per heading is plenty.
9. If the workflow itself changed (a routine added or modified), update this file.

---

# Codex Review Template

When Codex pushes a branch and hands back, Claude follows the routine in `docs/Sad Cave Dev/Sadcave/_Review_Template.md` before giving the user a verdict. The template covers: reading the diff via GitHub MCP, parsing Codex's inbox notes, deciding if an independent playtest is needed, translating to plain English, and the verdict format. Don't skip steps based on "this looked small" — review is universal per the anti-patterns below.

---

# Anti-patterns (things that will break the workflow)

- **Inbox never gets integrated** → vault drifts, becomes useless. Mitigation: integration at end of every session by default.
- **System notes get edited mid-build without going through inbox** → Opus and the user both editing the same note simultaneously. Mitigation: during active building, observations go to inbox; system notes get updated only at integration.
- **Codex implements without a brief** → vault doesn't reflect what was built. Mitigation: every system going to Codex gets a `06_Codex_Plans/` file first.
- **Codex edits design surfaces** → silent drift, design conversation skipped. Mitigation: convention-only — Codex's instructions tell it to write only to inbox. Opus reverts unauthorized edits during integration if it happens.
- **Change log fills up with stray thoughts** → loses signal. Mitigation: only substantive shipped changes go in change log; ideas go to parking lot, questions go to open questions.
- **Codex playtests but writes perfunctory observations** → playtest theater, no real validation. Mitigation: format expectation in Build Loop step 5 ("errors, expected behavior confirmed, anything weird"). If a playtest note is just `[C] Playtested: ok`, treat it as unverified — Opus playtests during review.
- **Generated placeholder assets accumulate untracked** → asset bloat over time, no one remembers what's placeholder vs final. Mitigation: integration logs Codex-generated placeholders to `_Cleanup_Backlog.md`; when real art ships, the placeholder swap gets flagged in the inbox so the entry can be retired.
- **Opus skips reviewing because the task seemed small** → bugs slip through that the user can't catch (the user does not script). Mitigation: review is universal, not risk-graded. Every Codex task gets read by Opus and gets a plain-English verdict before the user accepts.
- **The user reads code to verify Codex's work** → user can't script, can't catch real problems, gets stuck pretending to evaluate something they can't read. Mitigation: Opus reviews and gives a verdict. The user decides based on the verdict, not the code.
- **Studio gets edited as if it were the source of truth** → repo and Studio drift, work gets lost. Mitigation: scripts live in the repo; non-script Studio state (lighting, placement, properties) is for testing/feel and either gets committed via Rojo or documented as "Studio-only intentional."
- **Codex pushes directly to `main`** → bypasses review, bad code lands in canonical history, hard to roll back. Mitigation: branch-and-merge workflow is mandatory. Codex always works on `codex/<task-name>` and only pushes that branch. Only the user merges to `main`, only after Opus review.
