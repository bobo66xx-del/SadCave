# Live-to-Repo Audit (Final Form)

Source of truth: the currently connected live Roblox Studio session on 2026-04-20.

Rules used in this audit:
- The live Studio session is the only structural authority.
- `place-backups` were not used to restore, infer, or overwrite current repo content.
- A live object is only marked `exact and in repo` when its current live class, parent path, name, and exportable source/content were verified from current session-accessible tooling.
- If current tooling does not provide an exact-safe export path, the item stays out of repo sync changes and is classified below as a blocker or `manual export still required`.

## Coverage Snapshot

| Live area | Exact and in repo | Structurally mapped but not byte-exact | Remaining status |
|---|---:|---:|---|
| `StarterPlayer` live scripts | `15 / 17` (`88.2%`) | `1 / 17` (`5.9%`) | `environment change ` is a path blocker |
| `ReplicatedStorage` top-level children | `18 / 22` (`81.8%`) | `0 / 22` | Remaining 4 are proven blockers |
| `StarterGui` top-level `ScreenGui` instances | `4 / 24` (`16.7%`) | `2 / 24` (`8.3%`) | Remaining 18 are blockers or manual export still required |
| `ServerScriptService` top-level children | `5 / 44` (`11.4%`) | `14 / 44` (`31.8%`) | Remaining 25 are blockers or manual export still required |

## Completed Exact Exports

### StarterPlayer

- `game.StarterPlayer.StarterCharacterScripts.Sprint` -> `src/StarterPlayer/StarterCharacterScripts/Sprint.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.Levelup` -> `src/StarterPlayer/StarterPlayerScripts/Levelup.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.MessageMaker` -> `src/StarterPlayer/StarterPlayerScripts/MessageMaker.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.OldChatBubbleTheme` -> `src/StarterPlayer/StarterPlayerScripts/OldChatBubbleTheme/init.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.Theme` -> `src/StarterPlayer/StarterPlayerScripts/Theme/init.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.camera` -> `src/StarterPlayer/StarterPlayerScripts/camera.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.LocalScript` -> `src/StarterPlayer/StarterPlayerScripts/LocalScript.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.AutomaticPrompt` -> `src/StarterPlayer/StarterPlayerScripts/AutomaticPrompt.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.SunRayRemove` -> `src/StarterPlayer/StarterPlayerScripts/SunRayRemove.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.ChatBubbleDarkTheme` -> `src/StarterPlayer/StarterPlayerScripts/ChatBubbleDarkTheme/init.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.AFKLS` -> `src/StarterPlayer/StarterPlayerScripts/AFKLS.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.DisableCoreUI` -> `src/StarterPlayer/StarterPlayerScripts/DisableCoreUI.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.CoreGuiBackpackDisabler` -> `src/StarterPlayer/StarterPlayerScripts/CoreGuiBackpackDisabler.client.lua`
- `game.StarterPlayer.StarterPlayerScripts.PromptFavorite` -> `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.server.lua`
- `game.StarterPlayer.StarterPlayerScripts.MobileLightingCompensation` -> `src/StarterPlayer/StarterPlayerScripts/MobileLightingCompensation.client.lua`

### ReplicatedStorage

- `game.ReplicatedStorage.TitleConfig` -> `src/ReplicatedStorage/TitleConfig.lua`
- `game.ReplicatedStorage.ShopCatalog` -> `src/ReplicatedStorage/ShopCatalog.lua`
- `game.ReplicatedStorage.TitleEffectPreview` -> `src/ReplicatedStorage/TitleEffectPreview.lua`
- `game.ReplicatedStorage.TipProductConfig` -> `src/ReplicatedStorage/TipProductConfig.lua`
- `game.ReplicatedStorage.TitleRemotes` -> `src/ReplicatedStorage/TitleRemotes`
- `game.ReplicatedStorage.ShopRemotes` -> `src/ReplicatedStorage/ShopRemotes`
- `game.ReplicatedStorage.ReportRemotes` -> `src/ReplicatedStorage/ReportRemotes`
- `game.ReplicatedStorage.Remotes` -> `src/ReplicatedStorage/Remotes`
- `game.ReplicatedStorage.NoteSystem` -> `src/ReplicatedStorage/NoteSystem`
- `game.ReplicatedStorage.Global_Events` -> `src/ReplicatedStorage/Global_Events`
- `game.ReplicatedStorage.report` -> `src/ReplicatedStorage/report`
- `game.ReplicatedStorage.Spawn` -> `src/ReplicatedStorage/Spawn`
- `game.ReplicatedStorage.Bonk` -> `src/ReplicatedStorage/Bonk`
- `game.ReplicatedStorage.NameValue` -> `src/ReplicatedStorage/NameValue`
- `game.ReplicatedStorage.RunValue` -> `src/ReplicatedStorage/RunValue`
- `game.ReplicatedStorage.Speed` -> `src/ReplicatedStorage/Speed`
- `game.ReplicatedStorage.Admin` -> `src/ReplicatedStorage/Admin`
- `game.ReplicatedStorage.EButton` -> `src/ReplicatedStorage/EButton`

### StarterGui

- `game.StarterGui.TitleMenu` -> `src/StarterGui/TitleMenu`
- `game.StarterGui.Teleport Button` -> `src/StarterGui/Teleport Button`
- `game.StarterGui.GUIToggle` -> `src/StarterGui/GUIToggle`
- `game.StarterGui.notificationUI` -> `src/StarterGui/notificationUI`

### ServerScriptService

- `game.ServerScriptService.report` -> `src/ServerScriptService/report`
- `game.ServerScriptService.report.reportHandler` -> `src/ServerScriptService/report/reportHandler.server.lua`
- `game.ServerScriptService.AdminGamePass` -> `src/ServerScriptService/AdminGamePass.server.lua`
- `game.ServerScriptService.SadCaveMusicPauseData` -> `src/ServerScriptService/SadCaveMusicPauseData.server.lua`
- `game.ServerScriptService.ToolPickupService` -> `src/ServerScriptService/ToolPickupService.server.lua`
- `game.ServerScriptService.Custom Chat Script` -> `src/ServerScriptService/Custom Chat Script`

## Structurally Mapped But Not Byte-Exact

These files are live-verified for class, parent, name, and overall source coverage, but they cannot be upgraded to `exact and in repo` because the current repo copy still fails the final byte-exact re-diff.

| Live path | Repo path | Local lines | Live lines | Exact reason it stays non-exact |
|---|---|---:|---:|---|
| `game.StarterPlayer.StarterPlayerScripts.RainScript` | `src/StarterPlayer/StarterPlayerScripts/RainScript/init.client.lua` | `61` | `72` | Root script source is present, but line-count mismatch proves the local file is not byte-exact yet |
| `game.StarterPlayer.StarterPlayerScripts.RainScript.Rain` | `src/StarterPlayer/StarterPlayerScripts/RainScript/Rain.lua` | `1002` | `1074` | Module source is present, but line-count mismatch proves the local file is not byte-exact yet |
| `game.ServerScriptService.ReportHandler` | `src/ServerScriptService/ReportHandler.server.lua` | `69` | `74` | Transcribed live source still needs a final exact-format re-diff |
| `game.ServerScriptService.CashLeaderstats` | `src/ServerScriptService/CashLeaderstats.server.lua` | `197` | `231` | Transcribed live source still needs a final exact-format re-diff |
| `game.ServerScriptService.LevelLeaderstats` | `src/ServerScriptService/LevelLeaderstats.server.lua` | `84` | `99` | Transcribed live source still needs a final exact-format re-diff |
| `game.ServerScriptService.TitleService` | `src/ServerScriptService/TitleService.server.lua` | `480` | `575` | Transcribed live source still needs a final exact-format re-diff |
| `game.ServerScriptService.ShopService` | `src/ServerScriptService/ShopService.server.lua` | `250` | `289` | Transcribed live source still needs a final exact-format re-diff |
| `game.ServerScriptService.NoteSystemServer` | `src/ServerScriptService/NoteSystemServer.server.lua` | `203` | `248` | Transcribed live source still needs a final exact-format re-diff |
| `game.ServerScriptService.DailyRewardsServer` | `src/ServerScriptService/DailyRewardsServer.server.lua` | `137` | `161` | Transcribed live source still needs a final exact-format re-diff |
| `game.ServerScriptService.FavoritePromptPersistence` | `src/ServerScriptService/FavoritePromptPersistence.server.lua` | `77` | `94` | Transcribed live source still needs a final exact-format re-diff |
| `game.ServerScriptService.TextChatServiceHandler` | `src/ServerScriptService/TextChatServiceHandler/init.server.lua` | `150` | `175` | Disabled-state metadata is exact, but the script source still fails the final exact-format re-diff |
| `game.ServerScriptService.NameTagScript Owner` | `src/ServerScriptService/NameTagScript Owner.server.lua` | `766` | `915` | Transcribed live source still needs a final exact-format re-diff |
| `game.ServerScriptService.Theme` | `src/ServerScriptService/Theme.server.lua` | `9` | `9` | Live line counts match, but the current connector only exposes numbered conversational output, so a byte-exact raw-source diff is unavailable |
| `game.ServerScriptService.OverheadTagsToggleServer` | `src/ServerScriptService/OverheadTagsToggleServer.server.lua` | `35` | `35` | Live line counts match, but the current connector only exposes numbered conversational output, so a byte-exact raw-source diff is unavailable |
| `game.StarterGui.ShopMenu` | `src/StarterGui/ShopMenu` | `108` | `133` | The live subtree and launcher script are now represented locally, but `main.LocalScript` still fails the final exact re-diff |
| `game.StarterGui.SadCaveMusicGui` | `src/StarterGui/SadCaveMusicGui` | `649 / 65` | `645 / 78` | The repo tree now matches the live structure much more closely, but both controller scripts still fail the final exact re-diff |
| `game.StarterGui.currencyui.LocalScript` | `src/StarterGui/currencyui/LocalScript.client.lua` | `68` | `68` | Live line counts match, but the current connector only exposes numbered conversational output, so a byte-exact raw-source diff is unavailable |
| `game.StarterGui.currencyui.anim` | `src/StarterGui/currencyui/anim.client.lua` | `190` | `190` | Live line counts match, but the current connector only exposes numbered conversational output, so a byte-exact raw-source diff is unavailable |
| `game.StarterGui.Custom Inventory.InventoryController` | `src/StarterGui/Custom Inventory/InventoryController/init.client.lua` | `156` | `156` | Live line counts match, but the current connector only exposes numbered conversational output, so a byte-exact raw-source diff is unavailable |
| `game.StarterGui.Custom Inventory.InventoryController.SETTINGS` | `src/StarterGui/Custom Inventory/InventoryController/SETTINGS.lua` | `534` | `534` | Live line counts match, but the current connector only exposes numbered conversational output, so a byte-exact raw-source diff is unavailable |
| `game.ServerScriptService.Shop` | `src/ServerScriptService/Shop/init.server.lua` | `4` | `5` | Disabled live script is represented locally, but the copied source still differs by one live blank line |
| `game.ServerScriptService.AntiExploit` | `src/ServerScriptService/AntiExploit/init.server.lua` | `7` | `8` | Disabled live script is represented locally, but the copied source still differs by one live blank line |

Notes:
- `RainScript` also includes 15 exact static value children in repo, but the subtree still cannot be promoted to exact while its two source files remain non-exact.
- No file in this section could be upgraded in the final re-diff pass.

## True Tooling Blockers

These gaps are blocked by missing or unusable data from current live/session-accessible tooling, not by missing repo work.

| Live path | Exact missing connector data | Why that prevents faithful repo export |
|---|---|---|
| `game.ReplicatedStorage.NameTag` | `AnchorPoint` returns `null` for `LowerText`, `HandleTag`, and `UpperText`; `TextXAlignment` also returns `null` for those same labels | The nametag labels are centered and their faithful placement depends on layout/alignment values the connector is not exposing |
| `game.StarterGui.IntroScreen` | `AnchorPoint` returns `null` for `TitleLabel`, `SubtitleLabel`, and `CommandHint` | The live labels sit on centered `Position.X.Scale = 0.5` placements, so missing `AnchorPoint` makes exact reproduction unsafe |
| `game.StarterGui.NoteUI` | `AnchorPoint` returns `null` for `MainFrame`, `NoteCard`, `NoteInput`, and `PostButton` | The note card uses centered frame placement and button/input positioning, so missing `AnchorPoint` blocks faithful layout export |
| `game.StarterGui.settingui` | The current `get_instance_properties` payload omits `AnchorPoint` for multiple centered nodes, including `game.StarterGui.settingui.mainui2`, `game.StarterGui.settingui.mainui2.title`, `game.StarterGui.settingui.mainui2.ScrollingFrame`, `game.StarterGui.settingui.mainui2_ShadowPng`, `game.StarterGui.settingui.mainui2_ShadowPng.ShadowImage`, `game.StarterGui.settingui.mainui2.ScrollingFrame.Spacer.label`, `game.StarterGui.settingui.mainui2.ScrollingFrame.Spacer1.label`, and `game.StarterGui.settingui.mainui2.ScrollingFrame.misc.label` | These nodes all use centered `Position` values such as `0.5`, so without the corresponding `AnchorPoint` the local UI would be shifted and no longer be a faithful repo export; current tooling also omits `AnchorPoint` on the same centered `TitleMenu` control nodes, so inference is not safe |
| `game.StarterGui.currencyui.maincanvas` | The current `get_instance_properties` payload omits `AnchorPoint` on the shared panel root even though `game.StarterGui.currencyui.maincanvas` uses `Position = UDim2.new(0.5, 0, 0.5, 0)` with `Size = UDim2.new(1, 0, 1, 0)` | `maincanvas` is the ancestor for the shards HUD, launcher rail, pose panel, and music panel, so without its exact layout anchor the whole UI subtree would shift and no longer be a faithful repo export |
| `game.StarterGui.currencyui.maincanvas.mainframe.poseui.emotescrip` | `get_script_source` exposes the `1030`-line live script only as numbered conversational output; no raw source payload is available from the current connector | Even if the `maincanvas` layout blocker were resolved, this script still cannot be safely promoted to a byte-exact repo export from current tooling alone |
| `game.StarterGui.fridge-ui` | `AnchorPoint` returns `null` for centered nodes `game.StarterGui.fridge-ui.main`, `game.StarterGui.fridge-ui.main.mainframe`, and `game.StarterGui.fridge-ui.main.mainframe.itemframe` | These centered containers define the fridge panel and item-grid placement, so exporting the subtree without their exact anchors would shift the UI away from live |
| `game.StarterGui.Custom Inventory.Inventory` | The current `get_instance_properties` payload omits `AnchorPoint` for the centered inventory panel even though `game.StarterGui.Custom Inventory.Inventory` uses `Position.X.Scale = 0.5` and the inner `Frame` also uses centered `Position` values (`X = 0.501055181`, `Y = 0.54903686`) | The inventory panel and its scrolling contents cannot be exported faithfully without their exact layout anchors, so syncing this subtree would shift the whole panel |
| `game.StarterGui.Custom Inventory.hotBar` | The current `get_instance_properties` payload omits `AnchorPoint` even though `game.StarterGui.Custom Inventory.hotBar` uses a centered `Position.X.Scale = 0.5` bottom bar placement | The hotbar is a load-bearing runtime container; without its exact anchor the entire slot row would shift and no longer match live |
| `game.StarterGui.Custom Inventory.InventoryController.toolButton` | The `toolButton` template contains centered visual children such as `toolIcon` with `Position = UDim2.new(0.5, 0, 0.5, 0)`, but the connector does not expose the corresponding `AnchorPoint` | This template is cloned at runtime for every slot, so exporting it without exact centered-child layout data would misplace slot visuals across the whole inventory system |
| `game.ReplicatedStorage.UIGradient` | `Color` and `Transparency` are exposed only as flattened strings (`\"0 1 0 0 0 1 1 0.74902 0 0 \"`, `\"0 0 0 1 0 0 \"`) while the live `UIGradient` also has a child `Script` | That flattened sequence payload is not a trusted exact Rojo-safe serialization for the live object combination |
| `game.ReplicatedStorage.Rose` | The connector only exposed root `Tool` metadata (`Name`, `ClassName`, `Enabled`, `Parent`, `ChildCount`) and not the exact grip, transform, part, or mesh property payload needed for the full tool | Without the full 3D/tool property set, a repo export would be incomplete and potentially behaviorally wrong |

## Duplicate-Name/Path Blockers

Current name-safe strategy once unique identity is available:
- represent each duplicate live object as a folder
- use unique filesystem names such as `Purchase__dup01`
- set `init.meta.json` `properties.Name` to the real live name
- keep source in `init.server.lua`, `init.client.lua`, or `init.lua` inside that folder

This preserves exact live identity in Rojo without forcing unique live names. I did not apply it yet because the connector still cannot uniquely address the affected live instances.

| Affected live path(s) | Why the connector still cannot uniquely address them | Name-safe mapping once identity is available |
|---|---|---|
| `game.ServerScriptService.Purchase` | `search_files` returns two live `Script` siblings with the exact same path string, one enabled and one disabled, but no unique per-instance handle | `src/ServerScriptService/Purchase__dup01/init.server.lua` and `Purchase__dup02/init.server.lua`, each with `properties.Name = "Purchase"` |
| `game.ServerScriptService.SoftShutdown` | `search_files` returns three live `Script` siblings with the exact same path string and no unique per-instance handle | `src/ServerScriptService/SoftShutdown__dup01/init.server.lua`, `__dup02`, `__dup03`, each with `properties.Name = "SoftShutdown"` |
| `game.StarterGui.Menu` | `search_files` returns two top-level `ScreenGui` instances with the same exact path string | `src/StarterGui/Menu__dup01` and `Menu__dup02`, each with `properties.Name = "Menu"` |
| `game.StarterGui.ScreenGui` | `search_files` returns two top-level `ScreenGui` instances with the same exact path string | `src/StarterGui/ScreenGui__dup01` and `ScreenGui__dup02`, each with `properties.Name = "ScreenGui"` |
| `game.ReplicatedStorage.ShopItems.Book.Handle.WeldConstraint` | `search_files` returns five `WeldConstraint` children with the exact same path string under one parent | `src/ReplicatedStorage/ShopItems/.../WeldConstraint__dupNN/init.meta.json`, each with `properties.Name = "WeldConstraint"` |
| `game.ServerScriptService.AdminServerManager.Admin.Background.TextLabel` | `get_project_structure` surfaces repeated child `TextLabel` entries at the same connector path, so the subtree is ambiguous end-to-end | Folder-per-duplicate export with `properties.Name = "TextLabel"` once the connector exposes unique instance identity |
| `game.StarterGui.tipui.mainui.title`; `game.StarterGui.tipui.mainui.ScrollingFrame.tipframe5.title`; `game.StarterGui.tipui.mainui.ScrollingFrame.tipframe10.title`; `game.StarterGui.tipui.mainui.ScrollingFrame.tipframe100.title`; `game.StarterGui.tipui.mainui.ScrollingFrame.tipframe1000.title`; `game.StarterGui.tipui.mainui.ScrollingFrame.tipframe10000.title` | Each of those live paths is surfaced twice by the connector with the same exact path string, so the sibling labels cannot be uniquely addressed for export | Folder-per-duplicate export such as `title__dup01` and `title__dup02` with `properties.Name = "title"` once unique instance identity is available |
| `game.StarterGui.Settings.Frame.Settings.ScrollingFrame.Diffuse` | The connector surfaces two `Diffuse` frames at the same exact path and collapses the subtree under them into one ambiguous path space | Folder-per-duplicate export such as `Diffuse__dup01` and `Diffuse__dup02` with `properties.Name = "Diffuse"` once unique instance identity is available |
| `game.StarterPlayer.StarterPlayerScripts.environment change ` | The live folder name ends with a trailing space, which Windows paths cannot represent safely | A path-safe folder name such as `environment change__pathsafe` with `properties.Name = "environment change "` once path escaping is supported safely in the workflow |

## Manual Export Still Required

These items are not proven tooling blockers. They remain outside the repo because they have not been exported exactly yet.

### Highest-priority load-bearing systems still outside repo

- None currently assigned; the 2026-04-25 trio was reclassified into structural export or tooling-blocker buckets.

### Likely exportable next

- `game.ServerScriptService.Commands`
- ~~`game.ServerScriptService.DonationLeaderstats`~~ — **decision pending in cleanup backlog; do NOT export until Donations decision resolves. If Donations stay, export then; if Donations go, never export.**
- ~~`game.ServerScriptService.DonationAmount`~~ — **same as above; tied to the Donations decision.**
- `game.ServerScriptService.ChatTag`
- `game.ServerScriptService.InviteFriends`
- `game.ServerScriptService.AvItems`
- `game.ServerScriptService.DelayedStarterTools`

### Probably true tooling blocker after first exactness pass

- `game.StarterGui.ComputerUI`
- `game.StarterGui.MainUI`
- `game.StarterGui.NotificationTHingie`
- `game.StarterGui.TPUI`
- `game.StarterGui.TTTUI`
- `game.StarterGui.bruh`

### Low priority / non-core exact-safe candidates still not exported

- `game.ServerScriptService.AFK`
- `game.ServerScriptService.Colide off`
- `game.ServerScriptService.DiscordLogs`
- `game.ServerScriptService.GenerateSeatMarkers`
- `game.ServerScriptService.HealthChanger`
- `game.ServerScriptService.NoticeNew`
- `game.ServerScriptService.RefreshCommand`
- `game.ServerScriptService.RemoveFF`
- `game.ServerScriptService.Reset`
- `game.ServerScriptService.Script`
- `game.ServerScriptService.AnimToggle`
- `game.ServerScriptService.AreaDiscoveryBadge`

## Repo-Completeness Verdict

- The repo does not yet contain everything that can be faithfully represented with current tooling.
- Important gameplay, config, UI, and server systems are still outside repo, especially the blocked `currencyui.maincanvas` subtree, the blocked `Custom Inventory` visual subtrees (`Inventory`, `hotBar`, and `toolButton`), `ShopMenu`, `tipui`, `SadCaveMusicGui`, `Settings`, `settingui`, `Shop`, and `AntiExploit`.
- `Theme` and `OverheadTagsToggleServer` are now represented locally, but both remain structurally mapped rather than byte-exact because the current connector still exposes numbered conversational source output instead of a raw-source payload.
- The remaining gaps are now fully classified. Every audited gap is one of:
  - `exact and in repo`
  - `structurally mapped but not byte-exact`
  - `true tooling blocker`
  - `duplicate-name/path blocker`
  - `manual export still required`
- Because `manual export still required` items remain, the reconciliation is not complete yet.

## Outside the Current Sync Surface

- `game.Workspace`
- Other DataModel services outside the current Rojo project boundary
