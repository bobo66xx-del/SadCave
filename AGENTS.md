# AGENTS.md

> Codex reads this at the start of every session. These rules govern how Codex interacts with the vault and the codebase. For the broader workflow doc (Opus side, integration, session loop), see `docs/Sad Cave Dev/Sadcave/_Workflow.md`.

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

## Build Loop

When the user hands you a task:

1. **Read the brief.** Open the relevant `06_Codex_Plans/YYYY-MM-DD_System_Name_v1.md` file. Read it fully.
2. **Follow the links.** Read any `[[wikilinks]]` in the brief — usually `01_Vision/Tone_and_Rules` and the related `02_Systems/` notes. These give you the context you need to implement in the right style.
3. **Update plan status.** Change the `Status` field from 🔵 Planned to 🟡 In Progress.
4. **Implement.** Write the Luau, modify Studio via MCP, commit through Rojo. Follow the steps in the brief.
5. **Capture as you go.** Drop one-line observations into `00_Inbox/_Inbox.md` with prefix `[C]` and a timestamp. Examples:
   - `[C] 14:32 — Built dialogue cooldown at 4s as spec'd.`
   - `[C] 14:45 — Renamed RemoteEvent OnInteract → OnDialogueRequest to avoid collision with old shop script.`
   - `[C] 15:02 — ? Spec says 3s cooldown but tween animation runs 3.5s. Bumped to 4s, ok?`
6. **Update plan status when done.** Change `Status` to 🟢 Shipped. Run through the Studio Test Checklist in the brief. Note any failures in the inbox.

For ad-hoc tasks without a `06_Codex_Plans/` brief (small fixes, one-offs), skip steps 1–3 and 6. Still capture observations in the inbox with `[C]` prefix.

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

Do not modify these without an explicit request and an Opus-written plan:

- **DataStores / saved player data:** `LevelLeaderstats`, `TitleService`, `DailyRewardsServer`, `FavoritePromptPersistence`, `NoteSystemServer`. Note: `CashLeaderstats` and `ShopService` are slated for removal — they're frozen, not extended (see Cleanup Backlog below).
- **Monetization / entitlement:** `TipProductConfig`, tip purchase UI/scripts, gamepass checks in `TitleService`, `LevelLeaderstats`, admin-related purchase/access scripts
- **Admin / moderation / reports:** `AdminServerManager`, `ReportHandler`, `ReplicatedStorage.Admin`, `ReplicatedStorage.ReportRemotes`
- **Live networking contracts:** `TitleRemotes`, `NoteSystem`, `ReportRemotes`, `ReplicatedStorage.Remotes`, daily reward remotes. Note: `ShopRemotes` and `ReplicatedStorage.Remotes.Shop` are slated for removal with the legacy Shop.
- **Title / overhead tag pipeline:** `TitleConfig`, `TitleService`, `NameTagScript Owner`. Note: this no-touch warning is about the shared title pipeline, not the locally managed `StarterGui.TitleMenu` UI.

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

Use manual Roblox Studio validation. Preferred workflow:

- inspect the affected live objects/scripts in Studio first
- make the smallest change
- run a Studio playtest focused on the changed system
- if UI changed, verify the exact screen(s) involved
- if remotes/data/title/shop/admin behavior changed, test the full client-server flow and call out any untested edge cases

In your final note, state:

- where the change was made
- how it was tested in Studio
- what result was observed
- any limits or untested cases

---

## Planning

This project has two planning surfaces. Use the right one for the task:

- **`06_Codex_Plans/YYYY-MM-DD_System_Name_v1.md` (in the vault)** — design-driven tasks Opus hands off to Codex. Each plan is self-contained: purpose, files, step-by-step, validation, rollback. Status flips 🔵 → 🟡 → 🟢 as Codex works.
- **`PLANS.md` (at repo root)** — ongoing live-reconciliation work. Contains a running history of repo-vs-Studio export passes dating back to 2026-04-19. Each plan inside follows a Goal/Scope/Non-goals/Risks/Steps/Validation/Status format. Codex appends to the active plan's Status log as it works. New live-reconciliation plans get appended to the bottom of `PLANS.md` separated by `---`.

**`docs/live-repo-audit.md` (at repo root)** is the authoritative classification of every live object's export status (exact / structurally mapped / tooling blocker / duplicate-name blocker / manual export needed). Codex updates the audit as items move between buckets. Read it before starting any export work — it's the queue.

For anything larger or riskier than a small fix, the relevant plan must exist before you start coding. Update the plan as work progresses. If scope changes, update the plan before continuing.

---

## Done When

- Requested behavior works
- Relevant checks were run, or missing checks were stated clearly
- No unrelated systems were changed
- Risks, follow-ups, or limits are stated clearly
- Plan `Status` is set to 🟢 Shipped (if working from a `06_Codex_Plans/` brief), or the active `PLANS.md` plan's Status log is updated (if doing live-reconciliation work)
- Inbox captures from this session are in `00_Inbox/_Inbox.md`
- For live-reconciliation work, `docs/live-repo-audit.md` reflects any items that moved between buckets

---

## When in Doubt

- **Design question?** → `[C] ?` in the inbox. Don't decide.
- **Implementation question?** → Use your judgment. Pick the most conservative option. Note what you picked in the inbox.
- **Spec conflicts with reality?** → Implement what works, flag the conflict in the inbox.
- **Brief is missing context?** → Read the linked notes first. If still unclear, flag in inbox and ask the user.

The vault is the source of intent. Studio + Rojo is the source of reality. Your job is to make them match — and to flag honestly when they can't.
