# No-Touch Systems

> **Role of this doc:** canonical list of systems that must NOT be modified without an explicit user request and an Opus-written plan in `06_Codex_Plans/`. Touching anything here without a plan risks player data loss, monetization breakage, moderation bypasses, or wire-protocol breaks with live clients.
>
> **Last refreshed:** 2026-04-27 — pruned heavily after the testing-place cleanup deleted most of the previously-listed systems.
>
> **Maintained by:** Opus, alongside system changes. When a no-touch system is renamed, removed, or a new one is added, this file is updated in the same edit pass as the relevant `02_Systems/` note.
>
> **Read by:** Codex (referenced from `AGENTS.md`) before starting any task that looks adjacent to player-state, monetization, moderation, or live networking. Opus reads it during design when proposing changes.
>
> **Production note:** if production still runs the pre-cleanup systems, the *production* no-touch list is broader than what's below. This doc reflects the testing place. Production cutover plans need their own no-touch reasoning.
>
> **Relationship to other docs:**
> - [[_Cleanup_Backlog]] — items completed during the 2026-04-27 cleanup pass.
> - [[_Live_Systems_Reference]] — snapshot of what currently exists in Studio.

---

## How To Use This List

- **Before touching anything that looks adjacent to a no-touch system:** stop. Check that the user's task includes an explicit ask AND a plan in `06_Codex_Plans/` covering the change. If not, flag in the inbox with `[C] ?` and ask.
- **If a system on this list looks dead or renamed:** check `_Cleanup_Backlog.md` and `_Live_Systems_Reference.md` first. If it's genuinely gone, flag in the inbox so this file gets updated.
- **Maintenance:** when a no-touch system is added, renamed, or removed in real life, update this file in the same pass as the relevant `02_Systems/` note.

---

## DataStores / Saved Player Data

These systems read or write persistent player data. Modifying them risks data loss, save corruption, or migration breakage.

- **`ProgressionService`** (`src/ServerScriptService/Progression/ProgressionService.lua`) — XP / level / time-played / revisits / discovered-zones via combined `ProgressionData` DataStore key. Just shipped (2026-04-27); especially fragile until follow-up briefs land.
- **`NoteSystemServer`** (`src/ServerScriptService/NoteSystemServer.server.lua`) — player note persistence via `NoteSystem` DataStore.
- **`FavoritePromptPersistence`** (`src/ServerScriptService/FavoritePromptPersistence.server.lua`) — Avalog-tied favorite-prompt persistence. Touches `Workspace.Avalog.Avalog.Packages.Avalog.PlayerDataStore`.

> Note: `LevelSave` is now read by `ProgressionService` only during migration. The legacy `LevelLeaderstats` script that wrote it is deleted; the DataStore key itself still holds historical data and shouldn't be casually wiped.

## Monetization / Entitlement

- **Gamepass `2110249546`** check inside `ProgressionService.GrantXP` — `1.5x` XP multiplier. Renaming or removing the check can hand out the boost for free or revoke it from paying players. Cache logic must not be re-broken.
- **`TipProductConfig`** (in `ReplicatedStorage`, if still present — verify) and any tip / donation purchase scripts. **Pending decision** in `_Cleanup_Backlog.md` — no removal until that decision is made.

## Moderation / Reports

These enforce platform safety. Bugs here can leak admin access or break moderation flows.

- **`ReportHandler`** (`src/ServerScriptService/ReportHandler.server.lua`) — top-level report handler. Hardcoded admin: `vesbus`. Persists to `Game__OFFICIAL__Reports` / `Reports97` via `HttpService` JSON.
- **`report/reportHandler`** (`src/ServerScriptService/report/reportHandler.server.lua`) — secondary report handler. Both kept; relationship between them is not fully documented yet (see [[_Live_Systems_Reference]] note).
- **`ReplicatedStorage.ReportRemotes.*`** — `CheckUserAdmin`, `ClearReports`, `FilterReport`, `SendUserReport`, `ViewAllReports`. Remote names are wire-contracts; renaming breaks live clients.

## Live Networking Contracts

Remotes spoken by live clients. Renaming or changing argument shapes breaks players in active sessions.

- **`ReplicatedStorage.NoteSystem.*`** — `SubmitNote`, `NoteUpdated`, `NoteResult`. Live wire contract.
- **`ReplicatedStorage.ReportRemotes.*`** — see Moderation above.
- **`ReplicatedStorage.Progression.*`** — `XPUpdated`, `LevelUp`. Just shipped; payload shapes (especially `XPUpdated`'s `{totalXP, level, xpForCurrentLevel, xpForNextLevel}`) are now consumed by `XPBarController`.
- **`ReplicatedStorage.AfkEvent`** — fired by `AfkDetector` (client) and listened to by the XP `Driver` (server). Renaming breaks the AFK presence-tick state.

---

## Removed from this list in 2026-04-27 cleanup

These were on the prior version of this doc but the underlying systems have been deleted:

- `LevelLeaderstats` (deleted)
- `TitleService`, `TitleConfig`, `TitleRemotes` (deleted)
- `DailyRewardsServer` and daily reward remotes (deleted)
- `AdminServerManager` and `ReplicatedStorage.Admin` (deleted)
- `NameTagScript Owner` (the old title-rendering nametag, deleted; replaced by minimal `NameTagScript`)
- Gamepass checks inside `LevelLeaderstats` (script deleted; the gamepass check now lives only in `ProgressionService`)

---

## Change Log for This File

> Append-only. Newest on top. One line per change.

- 2026-04-27 — Heavy refresh post-cleanup. Removed entries for deleted systems (`LevelLeaderstats`, `TitleService`, `DailyRewardsServer`, `AdminServerManager`, old `NameTagScript Owner`, `Custom Chat Script`'s gamepass check). Added entries for `ProgressionService`, `Progression.*` remotes, and `AfkEvent`. Production note added.
- 2026-04-25 — Created. Content migrated from `AGENTS.md` "Critical No-Touch Systems" section to give the list a single canonical home that gets maintained alongside the `02_Systems/` notes.
