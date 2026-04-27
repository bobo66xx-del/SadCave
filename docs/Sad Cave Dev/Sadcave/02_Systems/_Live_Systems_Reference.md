# Live Systems Reference

> **Role of this doc:** snapshot of *what currently exists* in the testing-place Studio, not *what should exist* (the per-system specs in `02_Systems/` cover that). Reference material for Codex and Opus when working on or near a live system.
>
> **Last refreshed:** 2026-04-27 — after Tyler's heavy testing-place cleanup pass that deleted most of the legacy systems. Reality-checked again 2026-04-27 (Cowork session 4): one drift caught and reconciled — the nametag actually renders `name + level`, not `name-only` (see Nametags entry below).
>
> **Update cadence:** refresh after major resync work, or when a live system's structure materially changes. Not updated during normal design work.
>
> **Production note:** this doc reflects the *testing place*. If the live production place still runs the older systems, that's a separate reality. Several systems below note "production may differ."
>
> **Cleanup awareness:** entries listed below are the *kept* systems. Anything previously documented here that's not below was deleted in the 2026-04-27 cleanup; see the "Removed in 2026-04-27 Cleanup" section near the bottom for the audit trail.

---

## How To Read This

- Confirmed facts: directly observed from the connected Studio hierarchy or script contents on 2026-04-27.
- Repo-backed: file in the Rojo source tree under `src/`. These survive cleanup automatically and are the canonical source.
- Studio-only: lives only in the testing place (typically Workspace state or stub instances). Not currently in the repo.

---

## Service Snapshots

### `ServerScriptService` (kept set)

Repo-backed:
- `NameTagScript.server.lua` — robust nametag, attaches BillboardGui to `HumanoidRootPart` with `AncestryChanged` watchdog (Avalog-safe). Built in Studio 2026-04-27, in repo via Rojo. **Renders two labels: `NameLabel` (player's display name, top 60%) and `LevelLabel` (`"level N"` from leaderstats `Level`, bottom 40%).** Hooks `leaderstats.Level.Changed` to update the level row live. See [[NameTag_Status]].
- `NoteSystemServer.server.lua` — server authority for the writable-notes feature. Saved player data — no-touch.
- `FavoritePromptPersistence.server.lua` — Avalog-tied favorite-prompt persistence. No-touch.
- `ReportHandler.server.lua` — top-level moderation report handler. No-touch.
- `report/reportHandler.server.lua` — secondary report handler under the `report/` folder.
- `ToolPickupService.server.lua` — pickup logic; expects `Workspace.ToolPickups` (an empty Folder Tyler created post-cleanup so the service stops yielding).
- `RemoveFF.server.lua` — disables ForceField on player spawn.
- `Reset.server.lua` — `/re` chat command reapplies the player's avatar description.
- `SoftShutdown.server.lua` — graceful shutdown teleport flow. Only one canonical `SoftShutdown` existed in Studio when exported.
- `Progression/Driver.server.lua` — runs the 60-second XP tick loop; hooks Players events. No-touch.
- `Progression/ProgressionService.lua` — XP grant API + level computation + DataStore + migration. No-touch.
- `Progression/Sources/PresenceTick.lua` — three-state tick (sitting/active/AFK). No-touch.

Studio-only / kept-in-place but not in repo:
- `DiscordLogs` — webhook/log integration. Left Studio-only because live `LogsSettings` contains a Discord webhook credential; export needs a secret-rotation/config plan.
- Dialogue scripts — `DialogueDirector` and the dialogue server-side runtime (verify exact name in Studio before next dialogue work).

### `ReplicatedStorage` (kept set)

Repo-backed:
- `Progression/` — folder containing `LevelCurve.lua`, `SourceConfig.lua`, `XPUpdated` (RemoteEvent), `LevelUp` (RemoteEvent). Shared XP plumbing.
- `AfkEvent/init.meta.json` — RemoteEvent fired by `AfkDetector` on window focus changes.
- `DialogueData.lua` — dialogue content/config module exported from Studio.
- `DialogueRemotes/` — dialogue wire-contract RemoteEvents: `PlayPlayerDialogue`, `PlayCharacterDialogue`, `PlayerDialogueChoiceSelected`, `RequestCharacterConversation`.
- `NoteSystem/` — note system remotes (`SubmitNote`, `NoteUpdated`, `NoteResult`).
- `ReportRemotes/` — report remotes (`CheckUserAdmin`, `ClearReports`, `FilterReport`, `SendUserReport`, `ViewAllReports`).
- `Global_Events/Notification_Event/` — generic notification event. Used by remaining notification scripts.
- `report/Settings.lua` — report config module.

Studio-only:
- Whatever else exists for Notes / Reports / Prompts that's still wired through the kept set. When a new task touches these, verify with Studio MCP before assuming.

### `StarterPlayer.StarterPlayerScripts` (kept set)

Repo-backed:
- `AfkDetector.client.lua` — fires `AfkEvent` on `WindowFocused` / `WindowFocusReleased`. Built in Studio 2026-04-27, in repo via Rojo.
- `MobileLightingCompensation.client.lua` — adjusts lighting for mobile clients.
- `SunRayRemove.client.lua` — removes/manages sun rays.
- `PromptGroup.client.lua` — prompts the local player to join the group if they are not already a member.
- `PromptFavorite.client.lua` — client favorite prompt partner to server-side `FavoritePromptPersistence`. Exported from a live `Script` object as `.client.lua` because the source uses `Players.LocalPlayer` and client-only prompt APIs.
- `NpcDialogueClient.client.lua` — NPC dialogue client UI/bubble handling.
- `PlayerDialogueClient.client.lua` — player dialogue subtitle/client handling.

Studio-only:
- `environment change ` — trailing-space Folder, not a script. No source to export; left in Studio pending lighting/environment audit.

### `StarterGui` (kept set)

Repo-backed:
- `XPBar/` — ScreenGui + `XPBarController.client.lua`. The bottom-of-screen ambient bar. No-touch (just shipped).

### `Workspace` (kept set, partial inventory)

Studio-only:
- `ToolPickups` — empty Folder placeholder created 2026-04-27 so `ToolPickupService` stops yielding.
- `SeatMarkers` — read by `PresenceTick` for the sitting boost. **Updated 2026-04-27 audit refresh:** the folder now has at least one child — a `Seat` with a `CustomSitAnimScript`. The sitting boost is now testable end-to-end. Drift caught by the audit; previous note (0 children) was stale.
- `QuietKeeperNPC` — the QuietKeeper rig (BlackKnight wings + skeletal horns). See [[../05_NPCs/QuietKeeper]].
- Cave entrance props — `FirePit`, `Fireflies`, `fast Fireflies`, `Specks`, `SunRayParts`, `Lantern`, `ReadabilityLighting`, foliage and flower variants, `Waterfall`, `Crate`, `Fence`, `NoteInteraction`, `CameraScenes`. See [[../03_Map_Locations/Cave_Entrance]].

---

## Major Systems (post-cleanup)

### XP Progression

The single source of truth for level/XP. Server: `ServerScriptService.Progression.{Driver, ProgressionService, Sources.PresenceTick}`. Shared: `ReplicatedStorage.Progression.{LevelCurve, SourceConfig, XPUpdated, LevelUp}`. Client: `StarterGui.XPBar.XPBarController`. DataStore: `ProgressionData` (combined key). See [[XP_Progression]] for the full spec; see [[../06_Codex_Plans/2026-04-25_XP_Progression_MVP_v1]] for the build brief.

### Nametags (name + level)

Single server script `NameTagScript.server.lua` builds a BillboardGui with two TextLabels: a name row (display name) and a level row (`"level N"` pulled from leaderstats `Level`, updates live via `:GetPropertyChangedSignal("Value")`). Plus `AfkEvent` + `AfkDetector` for AFK state, consumed by the XP Driver. See [[NameTag_Status]] for what's intentionally absent post-cleanup (titles, distance fade, dialogue-hide, per-player toggle). **Note:** the level row renders the same level the XPBar displays — this is a duplicated surface flagged for Tyler's review (see inbox 2026-04-27 session 4).

### Notes / Writable Notes

`NoteSystemServer` + `ReplicatedStorage.NoteSystem.*` + `StarterGui.NoteUI` (UI) + `Workspace.NoteInteraction` (world). DataStore: `NoteSystem` / `CurrentNotes`. Rules: 60s cooldown, 120 char max, level 5+ to edit, must be near the prompt. **Note:** the level gate currently relies on the leaderstats `Level` value populated by `ProgressionService`. Confirm during next playtest.

### Reports / Moderation

`ReportHandler` + `report/reportHandler` + `ReplicatedStorage.ReportRemotes`. DataStore: `Game__OFFICIAL__Reports` / `Reports97`. Hardcoded admin: `vesbus`. No-touch.

### Favorite Prompt

Pair: `FavoritePromptPersistence` (server, ties into Avalog `PlayerDataStore`) + `PromptFavorite` (client). RemoteEvent: `ReplicatedStorage.FavoritePromptShown`. Settings: `YourPlaceID = 5895908271`, `FavDelay = 600`. No-touch.

### Dialogue (kept; verify next session)

Server: `DialogueDirector` (verify exact name). Shared: `ReplicatedStorage.DialogueData` (single source of truth for all dialogue), `ReplicatedStorage.DialogueRemotes.*` (`PlayPlayerDialogue`, `PlayCharacterDialogue`, `PlayerDialogueChoiceSelected`, `RequestCharacterConversation`). Client: `StarterPlayerScripts.NpcDialogueClient` + `PlayerDialogueClient`. See [[Dialogue_System]].

### Tool Pickups

`ToolPickupService.server.lua` + `Workspace.ToolPickups` (empty Folder). Verify the service's behavior with the empty folder in the next playtest.

---

## Removed in 2026-04-27 Cleanup

For audit-trail purposes. None of these exist in the testing place anymore. Re-introducing any of them is a fresh design conversation, not a restoration.

**Server scripts deleted:**
- `LevelLeaderstats` — replaced by `ProgressionService`.
- `TitleService` (and the entire title-pipeline rendering inside `NameTagScript Owner`).
- `ShopService` — combat-shop authority.
- `AdminServerManager` — admin tool with hardcoded admin user IDs.
- `AreaDiscoveryBadge` — badge-on-zone-entry.
- `DailyRewardsServer` — daily shard claim.
- `Theme` (server) — admin-driven `AfterPulseColor` override.
- `OverheadTagsToggleServer` — no-op handler tied to a client-only preference.
- `AFK` — replaced by `AfkEvent` + `AfkDetector` plus the XP Driver listener.
- `AnimToggle`, `AntiExploit`, `Custom Chat Script`, `TextChatServiceHandler`, `CashLeaderstats`, `DonationLeaderstats`, `DonationAmount`, `Purchase` (×2 duplicates), `Shop`, multiple `SoftShutdown` duplicates, `NameTagScript Owner` (the old title-rendering nametag).

**Client scripts deleted:**
- `Levelup` — replaced by `XPBar` level-up animation.
- `AFKLS` — replaced by `AfkDetector`.
- `Theme` (client) — paired with the deleted server Theme.
- `Sprint` — left-shift walk-speed adjustment (not consistent with hangout pacing).
- `BackpackCoreGuiController` — backpack UI tweak.

**Shared (`ReplicatedStorage`) objects deleted:**
- `TitleConfig`, `TitleEffectPreview`, `TitleRemotes`, `ShopCatalog`, `ShopRemotes`, `ShopItems`, `Admin`, `RebuildOverheadTags`, `OverheadTagsEnabled`, `OverheadTagsToggle`, `DailyRewardsRemotes`, `DailyRewardStatus`, `ClaimDailyReward`, `Remotes.Shop`, `Remotes.LevelUp` (legacy chat-fed level remote).

**StarterGui (UI) deleted:**
- `TitleMenu`, `ShopMenu`, `Menu` (×2 duplicates), `Settings` (legacy), `IntroScreen`, `Custom Inventory`, `ComputerUI`, `fridge-ui`, `SadCaveMusicGui`, `bruh` (debug/analytics overlay), `TTTUI` (template leftover), `NotificationTHingie`, two generic `ScreenGui` orphans.

**Workspace deleted:**
- `NameTags` folder (was scaffolding for the old pipeline).

---

## Validation

Confirmed facts in this document come from:
- `00_Inbox/_Inbox.md` (2026-04-27 evening section — Tyler's cleanup log)
- Repo `src/` directory tree (verified 2026-04-27)
- Studio MCP `inspect_instance` checks for `NameTagScript`, `AfkEvent`, `AfkDetector`, `Workspace.ToolPickups` (all four confirmed present in the live testing place)
- Cross-referencing with `default.project.json` to confirm Rojo coverage of the kept repo set

Anything not confirmed by one of the above is marked "verify" in the relevant entry. Tyler or Codex should resolve those during the next session that touches that area.
