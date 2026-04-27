# No-Touch Systems

> **Role of this doc:** canonical list of systems that must NOT be modified without an explicit user request and an Opus-written plan in `06_Codex_Plans/`. Touching anything here without a plan risks player data loss, monetization breakage, moderation bypasses, or wire-protocol breaks with live clients.
>
> **Maintained by:** Opus, alongside system changes. When a no-touch system is renamed, removed, or a new one is added, this file is updated in the same edit pass as the relevant `02_Systems/` note.
>
> **Read by:** Codex (referenced from `AGENTS.md`) before starting any task that looks adjacent to player-state, monetization, moderation, or live networking. Opus reads it during design when proposing changes.
>
> **Relationship to other docs:**
> - [[_Cleanup_Backlog]] — systems slated for removal. Some entries here are also there (frozen-pending-removal); don't extend them, but they're still no-touch until cleanup runs.
> - [[_Live_Systems_Reference]] — snapshot of what currently exists in Studio. Use to verify a no-touch system's current name/location.

---

## How To Use This List

- **Before touching anything that looks adjacent to a no-touch system:** stop. Check that the user's task includes an explicit ask AND a plan in `06_Codex_Plans/` covering the change. If not, flag in the inbox with `[C] ?` and ask.
- **If a system on this list looks dead or renamed:** check `_Cleanup_Backlog.md` and `_Live_Systems_Reference.md` first. If it's genuinely gone, flag in the inbox so this file gets updated.
- **Maintenance:** when a no-touch system is added, renamed, or removed in real life, update this file in the same pass as the relevant `02_Systems/` note. Drift between this list and reality is the failure mode this doc exists to prevent.

---

## DataStores / Saved Player Data

These systems read or write persistent player data. Modifying them risks data loss, save corruption, or migration breakage.

- `LevelLeaderstats` — legacy time-based level system. **Frozen, pending replacement** by `XP_Progression` MVP. Still no-touch until cutover.
- `TitleService` — equipped titles + achievement flags via combined `TitleData` DataStore key.
- `DailyRewardsServer` — daily streak persistence.
- `FavoritePromptPersistence` — persisted favorite NPC prompt.
- `NoteSystemServer` — player note persistence.

> Note: `CashLeaderstats` and `ShopService` are slated for removal — they're frozen, not extended (see `_Cleanup_Backlog.md`).

## Monetization / Entitlement

These gate paid features. Mistakes here can hand out paid content for free or break legitimate purchases.

- `TipProductConfig` — developer product configs.
- Tip purchase UI/scripts (any script handling `MarketplaceService` callbacks for tips).
- Gamepass checks in `TitleService` and `LevelLeaderstats` (1.5x XP gamepass `2110249546`, etc.).
- Admin-related purchase/access scripts.

## Admin / Moderation / Reports

These enforce platform safety and admin authority. Bugs here can leak admin access or break moderation.

- `AdminServerManager`
- `ReportHandler`
- `ReplicatedStorage.Admin`
- `ReplicatedStorage.ReportRemotes`

## Live Networking Contracts

These remotes are spoken by live clients in production. Renaming or changing the wire format breaks players in active sessions.

- `TitleRemotes`
- `NoteSystem`
- `ReportRemotes`
- `ReplicatedStorage.Remotes`
- Daily reward remotes

> Note: `ShopRemotes` and `ReplicatedStorage.Remotes.Shop` are slated for removal with the legacy Shop (see `_Cleanup_Backlog.md`). Still no-touch until cleanup runs.

## Title / Overhead Tag Pipeline

The shared pipeline that drives title display and overhead tag rendering. Locked because tags are visible to all players and any rendering bug is highly visible.

- `TitleConfig`
- `TitleService`
- `NameTagScript Owner`

> **Scope note:** this applies to the *shared title pipeline*, NOT the locally-managed `StarterGui.TitleMenu` UI (which is Rojo-managed in `src/StarterGui/TitleMenu` and live-edited as part of normal work).

---

## Change Log for This File

> Append-only. Newest on top. One line per change.

- 2026-04-25 — Created. Content migrated from `AGENTS.md` "Critical No-Touch Systems" section to give the list a single canonical home that gets maintained alongside the `02_Systems/` notes.
