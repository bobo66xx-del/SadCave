# Live Systems Reference

> **Role of this doc:** snapshot of *what currently exists* in Studio, not *what should exist* (that's the spec — see individual `02_Systems/` notes). This is reference material for Codex and Opus when working on or near a live system.
>
> **Source:** live Roblox Studio inspection of `ReplicatedStorage`, `ServerScriptService`, `StarterPlayer`, and `StarterGui`, plus the local Rojo `TitleMenu` source in `src/StarterGui/TitleMenu`, on 2026-04-19.
>
> **Update cadence:** refresh after major resync work, or when a live system's structure materially changes. Not updated during normal design work.
>
> **Relationship to the audit:** [the live-repo-audit](../../../../live-repo-audit.md) (in `docs/live-repo-audit.md` at repo root) tracks each live object's *export status* (exact / structurally mapped / blocker / manual). This doc is about *what each system does*. The two are complementary.
>
> **Cleanup awareness:** entries marked 🔴 are slated for removal per [[_Cleanup_Backlog]]. Don't extend them.

## How To Read This

- Confirmed facts: directly observed from the connected Studio hierarchy or script contents.
- Assumptions / likely responsibilities: reasonable inferences from names, code usage, remotes, and hierarchy, but not fully proven by every dependency in the place.

## Service Snapshots

### `ReplicatedStorage`

Confirmed facts:
- Contains shared remotes, config modules, GUI templates, tools, and value templates.
- Notable exact objects:
  - `ReplicatedStorage.Admin`
  - `ReplicatedStorage.Global_Events`
  - `ReplicatedStorage.NoteSystem`
  - `ReplicatedStorage.Remotes`
  - `ReplicatedStorage.ReportRemotes`
  - 🔴 `ReplicatedStorage.ShopItems` — legacy combat-tool shop, see [[_Cleanup_Backlog]]
  - 🔴 `ReplicatedStorage.ShopRemotes` — paired with legacy Shop, see [[_Cleanup_Backlog]]
  - `ReplicatedStorage.TitleRemotes`
  - 🔴 `ReplicatedStorage.ShopCatalog` — legacy Shop catalog, see [[_Cleanup_Backlog]]
  - `ReplicatedStorage.TipProductConfig`
  - `ReplicatedStorage.TitleConfig`
  - `ReplicatedStorage.TitleEffectPreview`
  - `ReplicatedStorage.NameTag`
  - `ReplicatedStorage.EButton`
  - `ReplicatedStorage.RunValue`
  - `ReplicatedStorage.NameValue`

### `ServerScriptService`

Confirmed facts:
- Contains the main authoritative server systems.
- Notable exact scripts / folders:
  - 🔴 `ServerScriptService.CashLeaderstats` — legacy currency, see [[_Cleanup_Backlog]] (off-tone, slated for removal once XP_Progression ships)
  - `ServerScriptService.LevelLeaderstats`
  - `ServerScriptService.TitleService`
  - 🔴 `ServerScriptService.ShopService` — legacy Shop authority, see [[_Cleanup_Backlog]]
  - `ServerScriptService.NoteSystemServer`
  - `ServerScriptService.DailyRewardsServer`
  - `ServerScriptService.NameTagScript Owner`
  - `ServerScriptService.TextChatServiceHandler`
  - `ServerScriptService.AdminServerManager`
  - `ServerScriptService.ReportHandler`
  - `ServerScriptService.FavoritePromptPersistence`
  - `ServerScriptService.AFK`
  - `ServerScriptService.Theme`
  - `ServerScriptService.Custom Chat Script`
  - `ServerScriptService.AvItems`

### `StarterPlayer`

Confirmed facts:
- `StarterPlayer.StarterCharacterScripts` contains `Sprint`.
- `StarterPlayer.StarterPlayerScripts` contains:
  - `AFKLS`
  - `AutomaticPrompt`
  - `ChatBubbleDarkTheme`
  - `CoreGuiBackpackDisabler`
  - `DisableCoreUI`
  - `Levelup`
  - `LocalScript`
  - `MessageMaker`
  - `MobileLightingCompensation`
  - `OldChatBubbleTheme`
  - `PromptFavorite`
  - `RainScript`
  - `SunRayRemove`
  - `Theme`
  - `camera`
  - `environment change ` (trailing space — see audit's duplicate-name/path blockers)

## Major Systems

### Titles

Confirmed facts:
- `StarterGui.TitleMenu` is now locally managed through Rojo from `src/StarterGui/TitleMenu`.
- Shared config is in `ReplicatedStorage.TitleConfig`.
- Client/server title networking is in `ReplicatedStorage.TitleRemotes`.
- Exact title remotes:
  - `ReplicatedStorage.TitleRemotes.GetTitleData`
  - `ReplicatedStorage.TitleRemotes.EquipTitle`
  - `ReplicatedStorage.TitleRemotes.TitleDataUpdated`
- Main server authority is `ServerScriptService.TitleService`.
- `TitleService` uses `MarketplaceService`, `DataStoreService`, and `ReplicatedStorage.TitleConfig`.
- `TitleService` persists equipped titles in DataStore `EquippedTitleV1`.
- `TitleConfig` defines:
  - `DEFAULT_TITLE_ID = "newcomer"`
  - `TITLE_PACK_GAMEPASS_ID = 1797105034`
  - title categories `level`, `shop`, `gamepass`, and `special`
  - ordered title definitions
  - visual effect definitions for titles
  - special assignments such as `developer_plus` and `builder_plus`
- `TitleService` checks level-based ownership, gamepass ownership, shop-owned title flags, and special attribute access.
- `TitleService` waits on `LevelLoaded` and `ShopOwnershipLoaded` before building title payloads.
- `ServerScriptService.NameTagScript Owner` requires `ReplicatedStorage.TitleConfig` and renders equipped titles into nametags.
- The shared title pipeline still remains live in Studio under `ReplicatedStorage` and `ServerScriptService`.
- The local `TitleMenu` client still depends on live `TitleConfig`, `TitleEffectPreview`, and `TitleRemotes`.
- The local `TitleMenu` no longer reads `ShopMenu` row metrics; row sizing is self-contained in the local `TitleMenu` slice.
- The local `TitleMenu` mobile filter row now uses a safer self-contained fit path to avoid button overlap on narrow touch widths.

Assumptions / likely responsibilities:
- This is the canonical title ownership/equip pipeline for the game.
- `ReplicatedStorage.TitleEffectPreview` likely exists to preview the same title visual effect definitions in UI, but I did not inspect that module directly.

### 🔴 Shop Titles / Shards Shop *(legacy — see [[_Cleanup_Backlog]])*

Confirmed facts:
- Shared catalog is `ReplicatedStorage.ShopCatalog`.
- Server authority is `ServerScriptService.ShopService`.
- Exact shop remotes:
  - `ReplicatedStorage.ShopRemotes.GetShopData`
  - `ReplicatedStorage.ShopRemotes.BuyShopItem`
  - `ReplicatedStorage.ShopRemotes.ShopDataUpdated`
- `ShopCatalog` currently contains ordered items in category `title` with `priceShards`, `displayName`, and `linkedTitleId`.
- `ShopService` persists ownership in DataStore `ShopInventory_v1`.
- `ShopService` creates per-player folders:
  - `player.ShopOwnedItems`
  - `player.ShopOwnedTitles`
- `ShopService` reads and writes the player's `Shards` `IntValue`.
- `ShopService` fires `TitleRemotes.TitleDataUpdated` after shop changes so title UI/state refreshes.
- `ReplicatedStorage.ShopItems` also exists and contains tools:
  - `Book`
  - `Gun`
  - `Rocket Launcher`
  - `Saber`
  - `Scythe`
- Each listed shop tool has a `Price` value under it.

Assumptions / likely responsibilities:
- The current shard shop logic in `ShopCatalog` and `ShopService` is focused on title purchases, while `ReplicatedStorage.ShopItems` looks like a separate or older physical-item shop path.
- `ServerScriptService.Shop` may be a legacy or supplemental shop script, but I did not inspect it.

### 🔴 Currency / Shards / Session Rewards *(CashLeaderstats slated for removal — see [[_Cleanup_Backlog]])*

Confirmed facts:
- Main economy persistence script is `ServerScriptService.CashLeaderstats`. **This is the legacy "Cash" currency system; off-tone and slated for removal once XP_Progression ships and the level-up trigger dependency is cut.**
- `CashLeaderstats` creates:
  - `player.Shards`
  - `player.TimePlayed`
  - `player.TotalTimePlayed`
  - `player.Revisits`
- It uses DataStores:
  - `ShardsSave`
  - `CashSave`
  - `ShardsMigration_v1`
  - `TotalTimePlayedSave`
  - `RevisitsSave`
- It migrates old cash data into shard data if shard data is missing.
- It autosaves `Shards` and `TotalTimePlayed`.
- It grants passive shard income every 60 seconds.
- It grants session milestone shard rewards at:
  - 10 minutes
  - 20 minutes
  - 30 minutes
- `ServerScriptService.DailyRewardsServer` also grants `Shards`, with:
  - cooldown `24 * 60 * 60`
  - reward amount `150`
  - DataStore `DailyRewards_LastClaim_v1`

Assumptions / likely responsibilities:
- `Shards` is the primary current soft currency across the title shop and daily rewards systems.
- `DonationAmount` and `DonationLeaderstats` likely feed parallel donation/tip counters, but I did not inspect those scripts.

### Level Progression

Confirmed facts:
- Main level progression script is `ServerScriptService.LevelLeaderstats`.
- `LevelLeaderstats` creates `player.Level` if missing and sets attribute `LevelLoaded`.
- It persists levels in DataStore `LevelSave`.
- It increments level every 60 seconds.
- It checks gamepass `2110249546` and awards:
  - `+2` level per minute if owned
  - `+1` level per minute otherwise
- `TitleService` uses level values to determine title ownership.
- `StarterPlayer.StarterPlayerScripts.Levelup` listens to `ReplicatedStorage.Remotes.LevelUp` and posts a system chat message when level-up events fire.

Assumptions / likely responsibilities:
- Level is used both as progression and as a title unlock gate.
- Another server script may fire `ReplicatedStorage.Remotes.LevelUp`; `LevelLeaderstats` itself does not appear to fire that remote in the portion inspected.

### Nametags / Overhead Tags / Title Effects

Confirmed facts:
- Nametag template is `ReplicatedStorage.NameTag` (`BillboardGui`).
- `ServerScriptService.NameTagScript Owner` clones `ReplicatedStorage.NameTag` onto character heads.
- It creates or ensures:
  - `workspace.NameTags`
  - `ReplicatedStorage.RebuildOverheadTags` (`BindableEvent`)
  - `ReplicatedStorage.OverheadTagsEnabled` (`BoolValue`)
- It syncs:
  - display name
  - level
  - equipped title
  - premium icon visibility
- It ensures player-level copies of:
  - `RunValue`
  - `NameValue`
- It uses title effect data from `TitleConfig` and applies shimmer / pulse / glow / flicker / tint behavior to title text.
- `ServerScriptService.AFK` creates `ReplicatedStorage.AfkEvent` and appends `[AFK]` to nametag text in `workspace.NameTags`.
- `StarterPlayer.StarterPlayerScripts.AFKLS` fires `AfkEvent` when the game window loses or gains focus.
- `ServerScriptService.OverheadTagsToggleServer` creates `ReplicatedStorage.OverheadTagsToggle` (RemoteEvent), `ReplicatedStorage.OverheadTagsEnabled` (BoolValue, default `true`), and `ReplicatedStorage.RebuildOverheadTags` (BindableEvent). However, its `OnServerEvent` handler is a **no-op** — the server does not toggle global state. Overhead tag visibility is a **client-side preference only**. The server remote exists solely for backward compatibility with older clients that may still fire it. This is the intended design — the original implementation incorrectly made it a global server toggle, and it was later corrected to client-only.

Assumptions / likely responsibilities:
- This is the canonical nametag/overhead-tag pipeline for the game.
- `ReplicatedStorage.TitleEffectPreview` likely exists to preview the same title visual effect definitions in UI, but I did not inspect that module directly.

### Notes / Writable Notes

Confirmed facts:
- Shared remotes are in `ReplicatedStorage.NoteSystem`.
- Exact note remotes:
  - `ReplicatedStorage.NoteSystem.SubmitNote`
  - `ReplicatedStorage.NoteSystem.NoteUpdated`
  - `ReplicatedStorage.NoteSystem.NoteResult`
- Main server script is `ServerScriptService.NoteSystemServer`.
- `NoteSystemServer` uses:
  - DataStore `NoteSystem`
  - key `CurrentNotes`
  - `Workspace.NoteInteraction`
  - `TextService` filtering
- Important note rules enforced on the server:
  - `COOLDOWN_SECONDS = 60`
  - `MAX_NOTE_LENGTH = 120`
  - `MIN_LEVEL_TO_EDIT_NOTE = 5`
  - player must be near the note spot's `ProximityPrompt`
- Notes are keyed by `SpotId` attributes on workspace parts.

Assumptions / likely responsibilities:
- This is a world-note posting system tied to interactable note spots in the map.

### Daily Rewards

Confirmed facts:
- Main server script is `ServerScriptService.DailyRewardsServer`.
- It creates or maintains `ReplicatedStorage.DailyRewardsRemotes`.
- Exact newer remotes:
  - `ReplicatedStorage.DailyRewardsRemotes.GetStatus`
  - `ReplicatedStorage.DailyRewardsRemotes.Claim`
- Exact legacy aliases also maintained directly under `ReplicatedStorage`:
  - `ReplicatedStorage.DailyRewardStatus`
  - `ReplicatedStorage.ClaimDailyReward`
- Claiming is server-authoritative and awards shards immediately after validation.

Assumptions / likely responsibilities:
- The script is intentionally preserving backwards compatibility for an older daily rewards UI.

### Reports / Moderation Reports

Confirmed facts:
- Shared report remotes live in `ReplicatedStorage.ReportRemotes`.
- Exact report remotes:
  - `CheckUserAdmin`
  - `ClearReports`
  - `FilterReport`
  - `SendUserReport`
  - `ViewAllReports`
- Main server script is `ServerScriptService.ReportHandler`.
- `ReportHandler` uses DataStore `Game__OFFICIAL__Reports` with key `Reports97`.
- `ReportHandler` stores reports as JSON using `HttpService`.
- `ReportHandler` hardcodes admin name access via `admins = {"vesbus"}`.
- `ReplicatedStorage.report.Settings` also exists as a `ModuleScript`.
- `ServerScriptService.report.reportHandler` also exists as a second report-related script path.

Assumptions / likely responsibilities:
- There may be two report implementations or an older/newer split between `ReportHandler` and `report.reportHandler`.
- `ReplicatedStorage.report.Settings` likely feeds report UI or moderation options, but I did not inspect it directly.

### Admin Tools / Ban / Kick Panel

Confirmed facts:
- Shared admin folder is `ReplicatedStorage.Admin`.
- Exact shared admin objects:
  - `ReplicatedStorage.Admin.Admin` (`RemoteEvent`)
  - `ReplicatedStorage.Admin.ThemeColor` (`Color3Value`)
  - `ReplicatedStorage.Admin.Template` (`TextButton`)
- Main server script is `ServerScriptService.AdminServerManager`.
- `AdminServerManager`:
  - requires `WebhookService`
  - uses DataStore `bans`
  - clones `script.Admin` into `PlayerGui` for admins
  - listens to `ReplicatedStorage.Admin.Admin.OnServerEvent`
  - supports actions including `Kick`, `Ban`, `Tp`, `Bring`, `Freeze`, `UnFreeze`, and `Stats`
- Hardcoded admin user IDs in `AdminServerManager` are:
  - `1132193781`
  - `2764931356`
- The embedded admin GUI under the script contains:
  - `Admin` (`ScreenGui`)
  - `AdminClientManager` (`LocalScript`)
  - `OpenClose.Open` (`LocalScript`)

Assumptions / likely responsibilities:
- `AdminGamePass` is probably a separate unlock or entitlement path for admin-related access, but I did not inspect it.

### Chat Styling

Confirmed facts:
- Main modern chat handler is `ServerScriptService.TextChatServiceHandler`.
- It reads config from `ServerScriptService.Custom Chat Script`.
- Exact config folders under `Custom Chat Script`:
  - `AllUserFriends`
  - `Gamepasses`
  - `Users`
- `TextChatServiceHandler` applies:
  - name color
  - chat color
  - tag prefixes
- It uses gamepass ownership checks through `MarketplaceService`.

Assumptions / likely responsibilities:
- `ServerScriptService.ChatTag` and `ServerScriptService.Custom Chat Script` likely represent older or supplemental chat-tag implementations around the same domain.

### Favorite Prompt / Place Favorite Tracking

Confirmed facts:
- Client script is `StarterPlayer.StarterPlayerScripts.PromptFavorite`.
- Server script is `ServerScriptService.FavoritePromptPersistence`.
- They communicate using `ReplicatedStorage.FavoritePromptShown` (`RemoteEvent`), which the server creates if missing.
- Client prompt settings include:
  - `YourPlaceID = 5895908271`
  - `FavDelay = 600`
  - attributes `FavoritePromptDataReady` and `CanShowFavoritePrompt`
- `FavoritePromptPersistence` integrates with:
  - `Workspace.Avalog.Avalog.Packages.Avalog`
  - `PlayerDataStore`
  - `PlayerDataStore.Actions.SetFavoritePromptShown`
- The server marks prompt eligibility on player attributes and patches persistent profile state after the prompt is shown.

Assumptions / likely responsibilities:
- Avalog is the primary profile/data framework for at least some persistent profile fields, separate from the direct DataStore scripts used elsewhere.

### Theme / Lighting Color

Confirmed facts:
- `ReplicatedStorage.Remotes.Theme` exists as a `RemoteEvent`.
- `ServerScriptService.Theme` listens to that remote and only allows user IDs `1132193781` or `1` to update `game.Lighting.AfterPulseColor.Value`.
- `StarterPlayer.StarterPlayerScripts.Theme` updates parts under `Workspace.Theme` every render step based on `Lighting.AfterPulseColor.Value`.

Assumptions / likely responsibilities:
- This is a live color-theme override system for the environment, probably intended for owner/admin control.

### Weather / Rain

Confirmed facts:
- `StarterPlayer.StarterPlayerScripts.RainScript` requires `RainScript.Rain` (`ModuleScript`).
- `RainScript` manages a generated rain system through local values stored under the script:
  - `Color`
  - `Direction`
  - `Transparency`
  - `SpeedRatio`
  - `IntensityRatio`
  - `LightInfluence`
  - `LightEmission`
  - `Volume`
  - `SoundId`
  - texture values
  - collision constraint values
- It creates:
  - `RainEnabledState` (`BoolValue`)
  - `SetRainEnabled` (`BindableFunction`)
- It enables rain by default.

Assumptions / likely responsibilities:
- Weather is client-rendered rather than server-simulated.

### Movement / Camera / Core Client Setup

Confirmed facts:
- `StarterPlayer.StarterCharacterScripts.Sprint` tween-adjusts humanoid `WalkSpeed` on left shift.
- `Sprint` reads `plr.RunValue.Value`.
- `ServerScriptService.NameTagScript Owner` ensures a per-player `RunValue` by cloning the template from `ReplicatedStorage.RunValue`.
- `StarterPlayer.StarterPlayerScripts.camera` forces `CurrentCamera.CameraType = Custom` and sets the camera subject to the humanoid on spawn.
- `StarterPlayer.StarterPlayerScripts.AutomaticPrompt` waits 10 seconds, then prompts non-members to join group `8106647`.
- `StarterPlayer.StarterPlayerScripts.CoreGuiBackpackDisabler` and `DisableCoreUI` exist in hierarchy.

Assumptions / likely responsibilities:
- `CoreGuiBackpackDisabler`, `DisableCoreUI`, and `MobileLightingCompensation` are startup quality-of-life / presentation scripts for the player client, but I did not inspect their code directly.

## Notable Exact Objects By Domain

### Shared remotes

Confirmed facts:
- `ReplicatedStorage.Remotes.LevelUp`
- `ReplicatedStorage.Remotes.Players`
- `ReplicatedStorage.Remotes.Prompt`
- `ReplicatedStorage.Remotes.Random`
- 🔴 `ReplicatedStorage.Remotes.Shop` — paired with legacy Shop, see [[_Cleanup_Backlog]]
- `ReplicatedStorage.Remotes.SongID`
- `ReplicatedStorage.Remotes.Theme`
- `ReplicatedStorage.Remotes.TimeSync`
- `ReplicatedStorage.Global_Events.Notification_Event`

Assumptions / likely responsibilities:
- `Players`, `Prompt`, `Random`, `SongID`, and `TimeSync` are real networking entry points, but their exact gameplay contracts were not inspected in this pass.

### Shared GUI templates / replicated assets

Confirmed facts:
- `ReplicatedStorage.NameTag` is the overhead nametag template.
- `ReplicatedStorage.EButton` is a `BillboardGui`.
- `ReplicatedStorage.Rose` is a `Tool`.
- `ReplicatedStorage.UIGradient.Script` exists under a replicated `UIGradient` object.

Assumptions / likely responsibilities:
- `EButton` is probably a shared world-interaction prompt billboard.
- `Rose` and some `ShopItems` tools may be starter items, purchasables, or map pickups depending on other scripts not inspected here.

## Unreviewed Or Partially Reviewed Scripts

Confirmed facts:
- The following exact scripts exist in `ServerScriptService` but were not read in this documentation pass:
  - `AnimToggle`
  - `AntiExploit`
  - `AreaDiscoveryBadge`
  - `ChatTag`
  - `Colide off`
  - `Commands`
  - `DelayedStarterTools`
  - `DiscordLogs`
  - 🔴 `DonationAmount` — see [[_Cleanup_Backlog]]
  - 🔴 `DonationLeaderstats` — see [[_Cleanup_Backlog]]
  - `GenerateSeatMarkers`
  - `HealthChanger`
  - `InviteFriends`
  - `NoticeNew`
  - `OverheadTagsToggleServer`
  - 🔴 two `Purchase` scripts — duplicates, see [[_Cleanup_Backlog]]
  - `RefreshCommand`
  - `RemoveFF`
  - `Reset`
  - `SadCaveMusicPauseData`
  - `Script` (generic name — likely orphan)
  - 🔴 `Shop` — see [[_Cleanup_Backlog]]
  - 🔴 three `SoftShutdown` scripts — duplicates, see [[_Cleanup_Backlog]]
  - `ToolPickupService`
- The following exact client scripts exist in `StarterPlayerScripts` but were not read in this pass:
  - `ChatBubbleDarkTheme`
  - `CoreGuiBackpackDisabler`
  - `DisableCoreUI`
  - `LocalScript`
  - `MessageMaker`
  - `MobileLightingCompensation`
  - `OldChatBubbleTheme`
  - `SunRayRemove`

Assumptions / likely responsibilities:
- There are still important systems here that could materially change the architecture map after a second inspection pass, especially around monetization, shutdown flow, pickups, and client presentation.

## Validation

Confirmed facts:
- This document was updated from live Roblox Studio hierarchy inspection plus direct script reads from:
  - `ReplicatedStorage`
  - `ServerScriptService`
  - `StarterPlayer`

Assumptions / likely responsibilities:
- None in this section.
