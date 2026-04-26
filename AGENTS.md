# AGENTS.md

> Codex reads this at the start of every session. These rules govern how Codex interacts with the vault and the codebase. For the broader workflow doc (Opus side, integration, session loop), see `docs/Sad Cave Dev/Sadcave/_Workflow.md`.
>
> **These two docs are paired.** This file is the Codex-facing mirror of relevant rules from `_Workflow.md`. When workflow rules change that affect Codex (build loop, validation, write boundaries, conventions), `_Workflow.md` and `AGENTS.md` are updated in the same edit pass. Drift between them creates silent disagreements about how the loop works.

---

## Your Role

You are the **Builder** in a three-part stack:

- **The user** — director, taste, final call
- **Opus (Claude, in chat)** — design, architecture, vault keeper
- **Codex (you)** — Luau implementation, Studio changes via MCP, Rojo commits

Opus designs. You implement. The vault is the shared spec.

---

## Project Guidance

This repo is for Sad Cave / Roblox game work. Make the smallest safe change that solves the task and preserve existing behavior unless the user asks for a refactor.

**Tone matters.** Sad Cave is a quiet, emotional, low-stimulation game. Read `docs/Sad Cave Dev/Sadcave/01_Vision/Tone_and_Rules.md` before adding anything player-facing. If a feature feels loud, gamified, or aggressive, it's probably wrong for this game even if it's mechanically sound. Flag tone concerns in the inbox.

---

## Asset Generation

You may use `generate_mesh` and `generate_material` (Studio MCP) for placeholder assets when a brief calls for new visuals — a new prop, an unrigged enemy, a custom material. These are **placeholders**; real art passes happen separately with the user. Note what you generated in the inbox so it shows up at integration. Don't generate assets for systems whose look is design-locked (see relevant `02_Systems/` note).

Placeholders are tracked in `_Cleanup_Backlog.md` (Opus logs them at integration) so they don't accumulate untracked. When real art replaces a placeholder, flag the swap in the inbox so the entry can be retired.

---

## Vault Access

The Obsidian vault lives at `docs/Sad Cave Dev/Sadcave/`.

You have **read access** to the entire vault.

You have **write access only to**:

1. `00_Inbox/_Inbox.md` — append observations as you work
2. The `Status` field of the `06_Codex_Plans/` file you're currently building from

You do **NOT** edit:

- `01_Vision/` — north star, locked
- `02_Systems/` — design specs, owned by Opus
- `03_Map_Locations/`, `04_Dialogue/`, `05_NPCs/` — design surfaces, owned by Opus
- `_Change_Log.md` — Opus appends this during integration
- `_Workflow.md`, `00_Index.md` — meta-docs, owned by Opus
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

For ad-hoc tasks (no brief), skip to step 4 if relevant, then step 5, then step 6.

---

## Build Loop

When the user hands you a task:

1. **Read the brief.** Open the relevant `06_Codex_Plans/YYYY-MM-DD_System_Name_v1.md` file. Read it fully.
2. **Follow the links.** Read any `[[wikilinks]]` in the brief — usually `01_Vision/Tone_and_Rules` and the related `02_Systems/` notes. These give you the context you need to implement in the right style.
3. **Update plan status.** Change the `Status` field from 🔵 Planned to 🟡 In Progress.
4. **Implement.** Write Luau in the Rojo source tree (`src/...`) — Rojo syncs the files to Studio automatically. Use Studio MCP for changes that live outside the Rojo tree (instances, properties, model edits not represented in the source tree). Commit via git when the change is ready. Follow the steps in the brief.
5. **Capture as you go.** Drop one-line observations into `00_Inbox/_Inbox.md` with prefix `[C]` and a timestamp. Examples:
   - `[C] 14:32 — Built dialogue cooldown at 4s as spec'd.`
   - `[C] 14:45 — Renamed RemoteEvent OnInteract → OnDialogueRequest to avoid collision with old shop script.`
   - `[C] 15:02 — ? Spec says 3s cooldown but tween animation runs 3.5s. Bumped to 4s, ok?`
6. **Playtest, then mark shipped.** Use `start_stop_play` + `console_output` (Studio MCP) to playtest the changed system. Note the result in the inbox (`[C] HH:MM — Playtested: ...`); flag any errors with `?`. Then change `Status` to 🟢 Shipped and run through any remaining Studio Test Checklist items in the brief.
   - **If playtest finds a runtime error:** small/obvious bug → fix and re-playtest. Ambiguous behavior or a design conflict → stop, flag with `[C] ? — Playtest: <description>`, do NOT mark shipped. Leave Status as 🟡.
   - **If Studio isn't running or MCP is unavailable:** do NOT silently skip the playtest and mark shipped. Flag with `[C] ? — Could not playtest: <reason>` and call this out in your final note. Leave Status as 🟡 until the playtest can run.

For ad-hoc tasks without a `06_Codex_Plans/` brief (small fixes, one-offs), skip steps 1–3 and the Status update in step 6 — there's no plan file to read or update. Still playtest the change and capture observations in the inbox with `[C]` prefix.

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

## Live Project Structure

Repo files are mostly docs and Rojo source; a lot of the live game still lives in Roblox Studio. Read only the relevant live scripts/docs first, then expand if needed.

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

All new plans live in `06_Codex_Plans/YYYY-MM-DD_System_Name_v1.md` in the vault. One file per task. Each plan is self-contained: purpose, files, step-by-step, validation, rollback. Status flips 🔵 → 🟡 → 🟢 as Codex works.

The audit trail during work goes to `00_Inbox/_Inbox.md` as `[C] HH:MM —` entries. At session end, Opus integrates the inbox into the change log. No separate Status log is needed.

**`PLANS.md` (at repo root) is historical context, not an active surface.** It contains the running history of repo-vs-Studio export passes from 2026-04-19 through 2026-04-20, written before the vault existed. Read it when you need context on prior reconciliation decisions. **Do not append to it.** New live-reconciliation work uses `06_Codex_Plans/` like any other task.

**`docs/live-repo-audit.md` (at repo root)** is the authoritative classification of every live object's export status (exact / structurally mapped / tooling blocker / duplicate-name blocker / manual export needed). Codex updates the audit as items move between buckets. Read it before starting any export work — it's the queue.

For anything larger or riskier than a small fix, the relevant `06_Codex_Plans/` brief must exist before you start coding. Update the plan as work progresses. If scope changes, update the plan before continuing.

---

## Done When

- Requested behavior works
- Relevant checks were run, or missing checks were stated clearly
- No unrelated systems were changed
- Risks, follow-ups, or limits are stated clearly
- Plan `Status` is set to 🟢 Shipped (if there is a plan file)
- Inbox captures from this session are in `00_Inbox/_Inbox.md`
- For live-reconciliation work, `docs/live-repo-audit.md` reflects any items that moved between buckets

---

## When in Doubt

- **Design question?** → `[C] ?` in the inbox. Don't decide.
- **Implementation question?** → Use your judgment. Pick the most conservative option. Note what you picked in the inbox.
- **Spec conflicts with reality?** → Implement what works, flag the conflict in the inbox.
- **Brief is missing context?** → Read the linked notes first. If still unclear, flag in inbox and ask the user.

The vault is the source of intent. Studio + Rojo is the source of reality. Your job is to make them match — and to flag honestly when they can't.
