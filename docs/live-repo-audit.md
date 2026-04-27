# Live Repo Audit - Testing Place

**Last refreshed:** 2026-04-27 (Codex, brief `2026-04-27_Live_Repo_Audit_Refresh_v1`)
**Auditor:** Codex
**Place:** `Testing cave` (Studio id observed this pass: `b00d97e0-2ec5-45ea-b49e-22fdff7d8c5b`)
**Repo:** `SadCaveV2` at `main` baseline, audit branch `codex/live-repo-audit-refresh`

Authoritative classification of the testing place's top-level live objects against the current Rojo `src/` tree.

## Legend

- **Exact** - present in `src/` and live source/structure matches the repo. Source comparisons used live `Source` checksums against the repo's LF canonical content; the Windows working tree may show CRLF, but `git ls-files --eol` shows these files are stored as LF in the Git index.
- **Structurally mapped** - present in `src/`, but not byte-exact or not fully exact.
- **Studio-only (intentional)** - deliberately left outside `src/`.
- **Manual export needed** - should be reviewed for export or cleanup because live state is not represented in `src/`.
- **Tooling blocker** - current MCP tooling does not expose enough unambiguous information for faithful export.

## ServerScriptService

| Object | Class | Repo path | Bucket | Notes |
|--------|-------|-----------|--------|-------|
| `DialogueDirector` | Script | `src/ServerScriptService/DialogueDirector.server.lua` | Exact | 679 live lines; verified against the restored PR #5 source. |
| `DiscordLogs` | Script | None | Studio-only (intentional) | Deferred secret-bearing logger. Did not read or echo `LogsSettings`; see `2026-04-27_DiscordLogs_Secret_Refactor_v1`. |
| `FavoritePromptPersistence` | Script | `src/ServerScriptService/FavoritePromptPersistence.server.lua` | Exact | 95 live lines; no-touch saved-player-data system. |
| `NameTagScript` | Script | `src/ServerScriptService/NameTagScript.server.lua` | Exact | 126 live lines; minimal post-cleanup nametag script. |
| `NoteSystemServer` | Script | `src/ServerScriptService/NoteSystemServer.server.lua` | Exact | 249 live lines; no-touch note persistence authority. |
| `Progression` | Folder | `src/ServerScriptService/Progression/` | Exact | Contains `Driver` (138 lines), `ProgressionService` (437 lines), and `Sources/PresenceTick` (19 lines); no-touch XP system. |
| `RemoveFF` | Script | `src/ServerScriptService/RemoveFF.server.lua` | Exact | 7 live lines. |
| `report` | Folder | `src/ServerScriptService/report/` | Exact | Contains `reportHandler` (57 live lines). |
| `ReportHandler` | Script | `src/ServerScriptService/ReportHandler.server.lua` | Exact | 75 live lines; no-touch moderation/report authority. |
| `Reset` | Script | `src/ServerScriptService/Reset.server.lua` | Exact | 29 live lines. |
| `SoftShutdown` | Script | `src/ServerScriptService/SoftShutdown.server.lua` | Exact | 85 live lines. |
| `ToolPickupService` | Script | `src/ServerScriptService/ToolPickupService.server.lua` | Exact | 134 live lines; expects `Workspace.ToolPickups`. |

## ReplicatedStorage

| Object | Class | Repo path | Bucket | Notes |
|--------|-------|-----------|--------|-------|
| `AfkEvent` | RemoteEvent | `src/ReplicatedStorage/AfkEvent/init.meta.json` | Exact | RemoteEvent for AFK focus state. |
| `DialogueData` | ModuleScript | `src/ReplicatedStorage/DialogueData.lua` | Exact | 236 live lines. |
| `DialogueRemotes` | Folder | `src/ReplicatedStorage/DialogueRemotes/` | Exact | Contains `PlayCharacterDialogue`, `PlayerDialogueChoiceSelected`, `PlayPlayerDialogue`, `RequestCharacterConversation`. |
| `Global_Events` | Folder | `src/ReplicatedStorage/Global_Events/` | Exact | Contains `Notification_Event` RemoteEvent. |
| `NameTag` | BillboardGui | None | Tooling blocker | Live BillboardGui used by `NameTagScript`; not in repo. Current inspector returned insufficient property detail for faithful GUI export. |
| `NoteSystem` | Folder | `src/ReplicatedStorage/NoteSystem/` | Exact | Contains `NoteResult`, `NoteUpdated`, `SubmitNote` RemoteEvents. |
| `Progression` | Folder | `src/ReplicatedStorage/Progression/` | Exact | Contains `LevelCurve` (72 lines), `SourceConfig` (44 lines), `LevelUp`, and `XPUpdated`. |
| `report` | Folder | `src/ReplicatedStorage/report/` | Exact | Contains `Settings` (37 live lines). |
| `ReportRemotes` | Folder | `src/ReplicatedStorage/ReportRemotes/` | Exact | Contains five RemoteFunctions: `CheckUserAdmin`, `ClearReports`, `FilterReport`, `SendUserReport`, `ViewAllReports`. |
| `Rose` | Tool | None | Manual export needed | Tool asset is live in ReplicatedStorage but not represented in `src/`; decide export vs cleanup. |

## StarterGui

| Object | Class | Repo path | Bucket | Notes |
|--------|-------|-----------|--------|-------|
| `Game Version` | ScreenGui | None | Manual export needed | Unexpected live ScreenGui not in `src/` or `_UI_Hierarchy`; contains one 1-line `ShowGameVersion` LocalScript. |
| `IntroScreen` | ScreenGui | None | Tooling blocker | Present in Studio even though `_UI_Hierarchy` says it was deleted; old audit noted missing layout properties, and current inspector still does not expose enough faithful UI detail. |
| `Menu` | ScreenGui | None | Manual export needed | Present in Studio even though `_UI_Hierarchy` says it was deleted; contains `LocalScript` (1 line) and `MainScript` (30 lines). Needs keep/delete decision. |
| `NoteUI` | ScreenGui | None | Tooling blocker | Kept note UI but not in `src/`; current inspector does not expose enough faithful UI detail for a safe export. Contains `NoteUIClient` (319 lines). |
| `XPBar` | ScreenGui | `src/StarterGui/XPBar/` | Exact | Contains `XPBarController` (221 live lines); visual children are built at runtime. |

## StarterPlayer.StarterPlayerScripts

| Object | Class | Repo path | Bucket | Notes |
|--------|-------|-----------|--------|-------|
| `AfkDetector` | LocalScript | `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua` | Exact | 16 live lines. |
| `environment change ` | Folder | None | Studio-only (intentional) | Empty trailing-space folder; no source to export. |
| `MobileLightingCompensation` | LocalScript | `src/StarterPlayer/StarterPlayerScripts/MobileLightingCompensation.client.lua` | Exact | 118 live lines. |
| `NpcDialogueClient` | LocalScript | `src/StarterPlayer/StarterPlayerScripts/NpcDialogueClient.client.lua` | Exact | 825 live lines. |
| `PlayerDialogueClient` | LocalScript | `src/StarterPlayer/StarterPlayerScripts/PlayerDialogueClient.client.lua` | Exact | 568 live lines. |
| `PromptFavorite` | LocalScript | `src/StarterPlayer/StarterPlayerScripts/PromptFavorite.client.lua` | Exact | 69 live lines; client-side favorite prompt implementation. |
| `PromptFavorite` | Script | None | Tooling blocker | Duplicate top-level name beside the LocalScript; not represented in `src/` and ambiguous by normal dot-path addressing. |
| `PromptGroup` | LocalScript | `src/StarterPlayer/StarterPlayerScripts/PromptGroup.client.lua` | Exact | 14 live lines. |
| `SunRayRemove` | LocalScript | `src/StarterPlayer/StarterPlayerScripts/SunRayRemove.client.lua` | Exact | 70 live lines. |

## StarterPlayer.StarterCharacterScripts

No top-level children observed.

## Workspace

`Workspace` is not mapped in `default.project.json`. The live testing place currently has **2,444** top-level Workspace children, so this section groups non-source map geometry per the brief and breaks out source-bearing or workflow-relevant roots.

| Object | Class | Repo path | Bucket | Notes |
|--------|-------|-----------|--------|-------|
| `Avalog` | Folder | None | Manual export needed | Source-bearing dependency folder with 453 Lua source containers; `FavoritePromptPersistence` depends on Avalog storage. Needs explicit dependency/export decision. |
| `Leader2` | Model | None | Manual export needed | Source-bearing Workspace model with 20 Lua source containers; not documented in the kept set. |
| `Model` (2 duplicates) | Model | None | Tooling blocker | Two duplicate-named source-bearing roots, each with `Part.Script`; normal dot-path addressing is ambiguous. |
| `playerBugReportSystem` | Folder | None | Manual export needed | Source-bearing report package/import folder with 8 Lua source containers; not represented in `src/`. |
| `ReportGUI` | Model | None | Manual export needed | Source-bearing model with `READ ME` and `ReportHandler` scripts; not represented in `src/`. |
| `Rig` (2 duplicates) | Model | None | Tooling blocker | Two duplicate-named rigs, each with an `Animate` LocalScript; normal dot-path addressing is ambiguous. |
| `SeatMarkers` | Folder | None | Manual export needed | Kept XP sitting folder, but live now has a `Seat` child with `CustomSitAnimScript`; `_Live_Systems_Reference` still says this folder had 0 children. |
| `toggle Lantern` (2 duplicates) | Model | None | Tooling blocker | Two duplicate-named lantern models, each with `LanternToggleController`; normal dot-path addressing is ambiguous. |
| `ToolPickups` | Folder | None | Studio-only (intentional) | Empty folder created so `ToolPickupService` stops yielding. |
| `Truss` | TrussPart | None | Manual export needed | Contains `ReportGUI.READ ME` Script; not represented in `src/`. |
| `WelcomeBadge` | Script | None | Manual export needed | Top-level Workspace Script not represented in `src/` or the current kept-set docs. |
| `QuietKeeperNPC` | Model | None | Studio-only (intentional) | NPC/world rig with no Lua source containers; Workspace world state is Studio-only until a map export plan exists. |
| Non-source map/world geometry | Mixed | None | Studio-only (intentional) | Remaining top-level Workspace map, prop, terrain, camera, animation, and visual instances grouped here; no repo mapping exists for Workspace. |

## Lighting

Skipped per brief: no Lua source containers observed. Live top-level children are `build` and `final` Configuration objects.

## SoundService

Skipped per brief: no top-level children and no Lua source containers observed.

## Summary

| Bucket | Audit rows |
|--------|-----------:|
| Exact | 27 |
| Structurally mapped | 0 |
| Studio-only (intentional) | 5 |
| Manual export needed | 10 |
| Tooling blocker | 7 |
| **Total classified rows** | **49** |

Workspace note: the total above counts grouped Workspace rows, not every individual map part. The live Workspace has 2,444 top-level children; most non-source world geometry is intentionally grouped.

### Manual Export / Cleanup Queue

- `ReplicatedStorage.Rose`
- `StarterGui.Game Version`
- `StarterGui.Menu`
- `Workspace.Avalog`
- `Workspace.Leader2`
- `Workspace.playerBugReportSystem`
- `Workspace.ReportGUI`
- `Workspace.SeatMarkers` child script drift
- `Workspace.Truss`
- `Workspace.WelcomeBadge`

### Tooling Blockers

- `ReplicatedStorage.NameTag`
- `StarterGui.IntroScreen`
- `StarterGui.NoteUI`
- duplicate `StarterPlayer.StarterPlayerScripts.PromptFavorite` Script
- duplicate source-bearing `Workspace.Model` roots
- duplicate source-bearing `Workspace.Rig` roots
- duplicate source-bearing `Workspace.toggle Lantern` roots

### Drift Flags For Inbox / Review

- `Testing cave` Studio id is currently `b00d97e0-2ec5-45ea-b49e-22fdff7d8c5b`, not the older id listed in `Environments.md`.
- `StarterGui.IntroScreen` and `StarterGui.Menu` are present in live Studio even though `_UI_Hierarchy.md` says they were deleted.
- `Workspace.SeatMarkers` now has a `Seat` child and `CustomSitAnimScript`; `_Live_Systems_Reference.md` says the folder had 0 children.
- `Workspace` contains multiple source-bearing systems that are not in `src/` and not cleanly covered by the current kept-set docs.
