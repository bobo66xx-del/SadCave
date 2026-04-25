# PLANS.md

## Purpose
Use this file for complex features, risky changes, UI rewrites, system refactors, or anything touching multiple systems.

## Required sections
1. Goal
2. Scope
3. Non-goals
4. Files/systems likely touched
5. Risks / no-touch systems
6. Step-by-step implementation plan
7. Validation plan
8. Status log

## Rules
- Do not start major implementation until the plan exists.
- Update the plan as work progresses.
- If scope changes, update the plan before continuing.
- Record what was completed, what was not, and any follow-up work.

---

## Goal
Fix the mobile `TitleMenu` filter-row overlap in the local Rojo-managed slice while keeping desktop behavior unchanged and preserving the current visual style as closely as possible.

## Scope
- Update only `src/StarterGui/TitleMenu`
- Patch the compact/mobile filter-row width-fitting logic in `main/LocalScript.client.lua`
- Keep desktop behavior unchanged

## Non-goals
- No edits to live Studio objects
- No migration of `ReplicatedStorage.TitleConfig`, `ReplicatedStorage.TitleEffectPreview`, `ReplicatedStorage.TitleRemotes`, or any server-side title systems
- No changes to `ShopMenu` or any UI system outside `StarterGui.TitleMenu`

## Files/systems likely touched
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\PLANS.md`
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\src\StarterGui\TitleMenu\**`

## Risks / no-touch systems
- `ReplicatedStorage.TitleConfig`
- `ReplicatedStorage.TitleEffectPreview`
- `ReplicatedStorage.TitleRemotes`
- `ServerScriptService.TitleService`
- Any live purchase, entitlement, datastore, or title equip pipeline behavior
- Mobile compact-mode tab styling could drift if the safe-fit logic becomes too aggressive on very narrow widths
- `ShopMenu` remains live and should not be edited as part of this fix

## Step-by-step implementation plan
1. Patch the compact/mobile filter-row width-fitting logic so final button widths never exceed available row width
2. Use the smallest compact-mode adjustments needed, such as a smaller fallback text size and safer minimum widths
3. Leave desktop behavior unchanged
4. Validate the resulting width math against narrow mobile row widths before any further sync/playtest

## Validation plan
- Simulate the updated compact/mobile filter-row width math against narrow row widths
- Verify the final total widths do not exceed available row width on those samples
- Verify only files under `src/StarterGui/TitleMenu` changed for this fix
- No automated install/build/test commands are confirmed in this repo
- No Studio playtest will be run by Codex in this source-only step; validation will be by source diff plus width-math verification

## Status log
- 2026-04-19: Re-read `AGENTS.md` and confirmed `Title` shared systems remain no-touch for this export
- 2026-04-19: Confirmed `src/StarterGui` is currently an empty file placeholder and must become a folder for the first UI slice
- 2026-04-19: Inspected the live `StarterGui.TitleMenu` subtree and `game.StarterGui.TitleMenu.main.LocalScript`
- 2026-04-19: Implementation started
- 2026-04-19: Replaced the empty `src/StarterGui` placeholder file with a real folder tree for `TitleMenu`
- 2026-04-19: Added minimal `init.meta.json` files for the recreated `StarterGui.TitleMenu` UI hierarchy
- 2026-04-19: Copied the live `game.StarterGui.TitleMenu.main.LocalScript` into `src/StarterGui/TitleMenu/main/LocalScript.client.lua`
- 2026-04-19: Added `$ignoreUnknownInstances: true` to the mapped service roots in `default.project.json` so this remains a safe partial Rojo slice
- 2026-04-19: Audited the local `TitleMenu` slice and confirmed the remaining safety gap is missing live UI properties in `init.meta.json` files
- 2026-04-19: Property export implementation started
- 2026-04-19: Exported the live non-default `StarterGui.TitleMenu` UI properties into the existing local `init.meta.json` files only within `src/StarterGui/TitleMenu`
- 2026-04-19: Verified that only three `UICorner` metadata files remain class-only because their live property values match defaults
- 2026-04-19: Measured the current live `TitleMenu` row metrics and confirmed the local template height already matches the normalized runtime height; only row padding still differs
- 2026-04-19: ShopMenu dependency reduction implementation started
- 2026-04-19: Updated `src/StarterGui/TitleMenu/main/mainframe/ScrollingFrame/UIListLayout/init.meta.json` so local row padding matches the previously normalized live spacing
- 2026-04-19: Removed the `ShopMenu` row-metric lookup from `src/StarterGui/TitleMenu/main/LocalScript.client.lua` and replaced it with local-owned row metric defaults
- 2026-04-19: Verified by source diff that no `ShopMenu` references remain in the local `TitleMenu` script and that the local padding now matches the measured live normalized value
- 2026-04-19: Audited the mobile filter-row regression and confirmed it is in the existing compact filter-width fitting logic, not the recent local row-metric decoupling
- 2026-04-19: Mobile filter-row overlap fix implementation started
- 2026-04-19: Patched the compact filter-row fitting logic to widen the mobile row slightly, add a smaller fallback text size, lower the compact minimum width, and guarantee the final fitted widths cannot exceed available row width
- 2026-04-19: Validated the updated compact width math against live `StarterGui.TitleMenu` button text/fonts in Studio for row widths 180, 160, 150, 140, 130, 120, 110, 100, 90, and 80; all samples finished with zero overflow

---

## Goal
Export the live `StarterGui.SadCaveMusicGui` subtree into a new local Rojo-managed slice under `src/StarterGui/SadCaveMusicGui` without changing any server, remote, launcher, or world-display contracts.

## Scope
- Recreate only the live `StarterGui.SadCaveMusicGui` hierarchy locally
- Export the live LocalScript sources for the two Music GUI client scripts
- Preserve the existing live object names, structure, and UI metadata for this subtree
- Resolve the missing local `MusicPanel.HideButton` contract inside the local Music GUI slice before first sync

## Non-goals
- No edits to `StarterGui.currencyui`
- No edits to `ServerScriptService.SadCaveMusicPauseData`
- No edits to remotes under `ReplicatedStorage`
- No edits to world BillboardGui objects under `Workspace`
- No sync back to Studio in this step

## Files/systems likely touched
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\PLANS.md`
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\src\StarterGui\SadCaveMusicGui\**`

## Risks / no-touch systems
- `StarterGui.currencyui` contains live launcher scripts that open and close `SadCaveMusicGui`; those launcher contracts must remain unchanged in this export
- `ServerScriptService.SadCaveMusicPauseData` owns the persisted paused/minimized/panel-position preference remotes and must remain untouched
- `MusicWorldDisplayController` depends on the existing `Workspace.@main.recordplayer.BillboardGui` path contract
- The live `MusicGuiController` source references `MusicPanel.HideButton`, but that object was not present in the current `StarterGui.SadCaveMusicGui` subtree export and should be treated as a pre-sync risk

## Step-by-step implementation plan
1. Export the live `StarterGui.SadCaveMusicGui` hierarchy, serializable UI properties, and LocalScript sources from Roblox Studio
2. Recreate the subtree locally using the existing folder-plus-`init.meta.json` Rojo convention
3. Add the two client script source files under the new local slice
4. Audit the generated local slice for missing live instances or metadata before any future sync

## Validation plan
- Verify the local file tree mirrors the live `StarterGui.SadCaveMusicGui` object tree
- Verify the two LocalScript files match the live Studio sources
- Verify the local slice now contains `StarterGui.SadCaveMusicGui.MusicPanel.HideButton` so the existing controller path is internally complete before sync
- Verify no files outside `PLANS.md` and `src/StarterGui/SadCaveMusicGui` are changed
- No automated install/build/test commands are confirmed in this repo
- No Studio sync or Studio playtest will be run in this source-export-only step

## Status log
- 2026-04-19: Re-read `AGENTS.md` and confirmed the Music GUI export must stay scoped to `StarterGui.SadCaveMusicGui`
- 2026-04-19: Inspected the live `StarterGui.SadCaveMusicGui` subtree, `MusicGuiController`, `MusicWorldDisplayController`, and related Music GUI dependencies in Studio
- 2026-04-19: Confirmed the Music GUI is mostly client-side, with server persistence isolated to `ServerScriptService.SadCaveMusicPauseData`
- 2026-04-19: Confirmed the local Rojo convention from `src/StarterGui/TitleMenu` is folder-per-instance with `init.meta.json` plus `.client.lua` for LocalScripts
- 2026-04-19: Property export started for the first local `SadCaveMusicGui` slice
- 2026-04-19: Recreated the live `StarterGui.SadCaveMusicGui` hierarchy locally under `src/StarterGui/SadCaveMusicGui`
- 2026-04-19: Exported the live `MusicGuiController` and `MusicWorldDisplayController` sources into local `.client.lua` files
- 2026-04-19: Verified the only pre-existing file modified for this export is `PLANS.md`; all other changes are new files under `src/StarterGui/SadCaveMusicGui`
- 2026-04-19: Confirmed the live `MusicGuiController` still references `MusicPanel.HideButton`, but no `HideButton` instance was present in the exported live subtree; this remains the main pre-sync risk to validate in Studio before syncing
- 2026-04-19: HideButton contract patch started for the local `SadCaveMusicGui` slice
- 2026-04-19: Added a local `StarterGui.SadCaveMusicGui.MusicPanel.HideButton` plus `UICorner` to satisfy the existing controller contract without changing any script logic or external dependencies
- 2026-04-19: Verified by local file-tree audit that the new `HideButton` path exists and that no files outside `PLANS.md` and `src/StarterGui/SadCaveMusicGui` were changed for this patch

---

## Goal
Redesign the local Rojo-managed `StarterGui.SadCaveMusicGui` slice into a cleaner, more modern dark-premium Sad Cave presentation while preserving all current behavior, object paths, script contracts, remote usage, and world-display dependencies.

## Scope
- Update only `src/StarterGui/SadCaveMusicGui`
- Refresh the authored UI layout and metadata for `MiniButton`, `MusicPanel`, and their child controls
- Preserve the existing object names that `MusicGuiController` and `MusicWorldDisplayController` already use
- Keep drag/minimize/play/pause/next/volume behavior intact unless a purely visual refactor requires small local script layout adjustments

## Non-goals
- No edits to `StarterGui.currencyui`
- No edits to `ServerScriptService.SadCaveMusicPauseData`
- No edits to `ReplicatedStorage` remotes or attributes
- No edits to `Workspace.@main.recordplayer.BillboardGui` contracts
- No changes to playlist logic, persistence behavior, or music selection rules

## Files/systems likely touched
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\PLANS.md`
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\src\StarterGui\SadCaveMusicGui\**`

## Risks / no-touch systems
- `MusicGuiController.client.lua` depends on exact object names such as `MusicPanel`, `MiniButton`, `Controls`, `PlayPause`, `Next`, `Volume`, `SliderBack`, `SliderFill`, `Knob`, `SongLabel`, and `HideButton`; those contracts must not drift
- `MusicWorldDisplayController.client.lua` must keep working against `SoundService.SadCaveAmbient` and `Workspace.@main.recordplayer.BillboardGui.Songtitle.Songtime`
- The panel still relies on runtime-created `UIScale` for `MusicPanel`; redesign work must preserve that behavior or replace it with an equivalent local-only path without changing user-facing behavior
- The design should stay visually aligned with Sad Cave’s dark premium mood and not become bright, arcade-like, or overly glossy

## Step-by-step implementation plan
1. Audit the current local Music GUI structure and define a visual direction based on existing Sad Cave dark UI cues from `TitleMenu` and the current live music slice
2. Redesign the panel hierarchy in place without renaming any controller-facing objects, using stronger spacing, clearer hierarchy, richer shadowing, and cleaner typography while keeping the current compact footprint practical
3. Refresh the `MiniButton` into a more intentional collapsed control that still matches the existing minimize/open behavior
4. Adjust local script assumptions only if needed for layout polish, and only inside `src/StarterGui/SadCaveMusicGui`
5. Review all local metadata and script references to confirm no external contracts changed before any future Studio sync

## Design direction
- Make the panel feel like a premium ambient audio card rather than a basic utility box
- Keep the palette in charcoal, soft black, smoky gray, and restrained off-white text, with one subtle cool accent only where it clarifies interactivity
- Separate information into a small header, a prominent current-track area, and a cleaner control zone
- Give the volume control a more deliberate track/knob treatment and improve the visual relationship between the play/pause and next controls
- Keep the minimized state elegant and understated so it reads as part of the same system

## Validation plan
- Verify the redesigned local tree still contains every existing controller-facing object path
- Verify any local script changes remain confined to `src/StarterGui/SadCaveMusicGui`
- Verify no files outside `PLANS.md` and `src/StarterGui/SadCaveMusicGui` are changed
- Manually inspect metadata for position/size overlap risks before sync
- No automated install/build/test commands are confirmed in this repo
- No Studio sync or Studio playtest will be run during the planning-only step

## Status log
- 2026-04-19: Re-read `AGENTS.md` and audited the local `src/StarterGui/SadCaveMusicGui` slice before redesign planning
- 2026-04-19: Confirmed the redesign can stay fully local to `src/StarterGui/SadCaveMusicGui` while preserving all external behavior and contracts
- 2026-04-19: Identified the current design weaknesses to address in implementation: flat utility styling, weak hierarchy, cramped control spacing, and an under-designed minimized state
- 2026-04-19: Wrote the Music GUI redesign plan before any visual implementation edits
- 2026-04-19: Music GUI redesign implementation started inside `src/StarterGui/SadCaveMusicGui`
- 2026-04-19: Refreshed the panel, minimized button, labels, controls, slider, and shadow styling while preserving all existing object names and script contracts
- 2026-04-19: Added local-only decorative UI objects (`UIStroke`, `TopAccent`, `HeaderDivider`) to strengthen the dark premium presentation without changing behavior paths
- 2026-04-19: Validated that all Music GUI `init.meta.json` files still parse successfully after the redesign and that no script changes were required
- 2026-04-19: Second visual polish pass started to improve contrast, button clarity, title hierarchy, and volume-row intentionality without changing behavior
- 2026-04-19: Completed the second visual polish pass with stronger card contrast, clearer primary/secondary buttons, a cleaner volume rail, and improved title hierarchy while preserving all object names and behavior contracts
- 2026-04-19: Final visual-only polish pass started to increase panel presence against the cave background and make the compact/mobile-scaled layout feel more intentional

---

## Goal
Restyle the local Rojo-managed `StarterGui.SadCaveMusicGui` slice so it follows the same panel logic and visual language as the live animation UI family, while preserving all existing Music GUI behavior, object names, and controller contracts.

## Scope
- Update only `src/StarterGui/SadCaveMusicGui`
- Use the live animation UI under `StarterGui.currencyui.maincanvas.mainframe.poseui` as the primary layout and styling reference
- Rework `MusicPanel`, `MiniButton`, and existing child metadata so the Music GUI reads like an integrated side panel rather than a floating standalone card
- Preserve play/pause, next, volume, now-playing, drag, minimize, and persistence behavior

## Non-goals
- No edits to `StarterGui.currencyui`
- No edits to `ServerScriptService`
- No edits to remotes or `Workspace` contracts
- No changes to `MusicGuiController.client.lua` or `MusicWorldDisplayController.client.lua` unless a tiny local-only layout adjustment becomes absolutely necessary

## Files/systems likely touched
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\PLANS.md`
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\src\StarterGui\SadCaveMusicGui\**`

## Risks / no-touch systems
- `MusicGuiController.client.lua` depends on exact object names and paths such as `MusicPanel`, `MiniButton`, `Controls`, `PlayPause`, `Next`, `Volume`, `SliderBack`, `SliderFill`, `Knob`, `SongLabel`, and `HideButton`
- The Music GUI must still open correctly from the existing `currencyui` launcher without any launcher-side edits
- The volume row and compact/mobile scaling must remain readable after the flatter side-panel relayout
- Decorative objects can be simplified, but existing objects should not be removed if the controller may rely on them later

## Step-by-step implementation plan
1. Flatten the `MusicPanel` treatment so it matches the animation UI family: broader side-panel feel, simpler surface, reduced card-like chrome, and clearer edge-aligned structure
2. Re-layout the title and now-playing area into a cleaner panel header that feels like the animation UI title zone
3. Rebuild the control area into stronger, more integrated rectangular controls plus a flatter volume row
4. Simplify or tone down purely decorative metadata so the surviving panel reads as part of the same UI family
5. Validate that all controller-facing paths remain unchanged and that every `init.meta.json` still parses cleanly

## Validation plan
- Re-check the live animation UI structure before editing so the restyle follows the real panel family instead of guesswork
- Verify the local Music GUI still contains every controller-facing object path after the metadata pass
- Parse every `init.meta.json` under `src/StarterGui/SadCaveMusicGui`
- Verify no files outside `PLANS.md` and `src/StarterGui/SadCaveMusicGui` changed
- No automated install/build/test commands are confirmed in this repo
- No Studio sync or Studio playtest will be run in this local restyle step

## Status log
- 2026-04-19: Re-read `AGENTS.md` and compared the live animation UI family against the local `SadCaveMusicGui` slice
- 2026-04-19: Confirmed the current Music GUI still reads as a separate floating card and should be flattened into the same side-panel language as `poseui`
- 2026-04-19: Wrote the animation-family restyle plan before making any local metadata edits
- 2026-04-19: Reworked the local `SadCaveMusicGui` metadata into a flatter left-side panel with simpler chrome, integrated title treatment, fuller button row, and a cleaner volume rail while keeping all object names and scripts unchanged
- 2026-04-19: Validated that all 35 `init.meta.json` files under `src/StarterGui/SadCaveMusicGui` still parse successfully after the restyle

---

## Goal
Fix the local `StarterGui.SadCaveMusicGui` layout collisions so the Music panel and minimized button no longer cover the live `currencyui` HUD lane, including the shards balance, the side icon rail, and the Music launcher button, on both desktop and mobile.

## Scope
- Update only `src/StarterGui/SadCaveMusicGui`
- Reposition `MusicPanel` and `MiniButton` defaults away from the bottom-left HUD lane
- Add local-only responsive placement logic if needed to keep the default layout clean on desktop and mobile
- Preserve dragging, minimize behavior, persistence, and all object/script contracts

## Non-goals
- No edits to `StarterGui.currencyui`
- No edits to `ServerScriptService`
- No edits to remotes or `Workspace` contracts
- No redesign of playback, minimize, or drag behavior

## Files/systems likely touched
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\PLANS.md`
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\src\StarterGui\SadCaveMusicGui\MusicPanel\init.meta.json`
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\src\StarterGui\SadCaveMusicGui\MiniButton\init.meta.json`
- `C:\Users\bobo6\OneDrive\Documents\Sad Cave\src\StarterGui\SadCaveMusicGui\MusicGuiController.client.lua`

## Risks / no-touch systems
- The live `currencyui` HUD geometry must only be used as a reference for validation; do not modify it
- `MusicGuiController.client.lua` must keep drag persistence and minimize behavior intact
- Persisted panel positions should keep working, but the collision-prone legacy default should not continue forcing a bad layout

## Step-by-step implementation plan
1. Move the authored `MusicPanel` and `MiniButton` defaults out of the bottom-left HUD lane
2. Add local responsive default-position rules so desktop and mobile can use different safe right-side offsets
3. Preserve persistence by only replacing clearly legacy or unsafe default placements rather than removing persisted positioning entirely
4. Validate the resulting bounds against the live shards HUD and menu rail geometry for desktop and mobile sample viewports

## Validation plan
- Parse the updated local metadata JSON
- Verify the local script still references the same controller-facing object paths
- Compare desktop and mobile sample panel bounds against the live `currencyui.mainframe` + `menuframe` lane and confirm positive horizontal clearance
- No automated install/build/test commands are confirmed in this repo
- No Studio sync or Studio playtest will be run in this local-only step

## Status log
- 2026-04-19: Re-read `AGENTS.md` and audited the current local panel/minibutton placement against the live `currencyui` HUD geometry
- 2026-04-19: Confirmed the current authored bottom-left placement overlaps the shards HUD and side rail lane, especially after the panel was restyled into a wider 304px layout
- 2026-04-19: Moved the authored `MusicPanel` and `MiniButton` defaults from bottom-left to bottom-right and added responsive managed defaults in `MusicGuiController.client.lua`
- 2026-04-19: Preserved drag persistence by only replacing clearly legacy default placements or offscreen saved positions; custom persisted placements still win
- 2026-04-19: Validated the new default layout against live `currencyui` HUD geometry for `1920x1080`, `1366x768`, `430x932`, and `393x852`; the panel clears the menu lane by `1242.6px`, `877.2px`, `138.1px`, and `107.9px` respectively

---

## Goal
Apply SadCave migration Phase 0 and Phase 1 only so the repo begins representing the live shared title/shop contract layer without changing live gameplay behavior.

## Scope
- Convert `src/ReplicatedStorage` and `src/ServerScriptService` from placeholder roots into real source directories
- Migrate only the shared title/shop layer recovered from `place-backups/SadCave-before-rojo.rbxlx`
- Include `TitleEffectPreview` only because the backup confirms both `TitleMenu` and `ShopMenu` require it

## Non-goals
- No migration of `CashLeaderstats`
- No migration of `LevelLeaderstats`
- No migration of `ShopService`
- No migration of `TitleService`
- No migration of `DailyRewardsServer`
- No migration of `NoteSystemServer`
- No migration of `FavoritePromptPersistence`
- No migration of `currencyui`
- No migration of `bruh`
- No unrelated UI edits

## Files/systems likely touched
- `C:\Projects\SadCave\PLANS.md`
- `C:\Projects\SadCave\src\ReplicatedStorage\TitleConfig.lua`
- `C:\Projects\SadCave\src\ReplicatedStorage\TitleEffectPreview.lua`
- `C:\Projects\SadCave\src\ReplicatedStorage\ShopCatalog.lua`
- `C:\Projects\SadCave\src\ReplicatedStorage\TitleRemotes\**\init.meta.json`
- `C:\Projects\SadCave\src\ReplicatedStorage\ShopRemotes\**\init.meta.json`
- `C:\Projects\SadCave\src\ReplicatedStorage`
- `C:\Projects\SadCave\src\ServerScriptService`

## Risks / no-touch systems
- `TitleRemotes` and `ShopRemotes` names must match live exactly
- `TitleConfig`, `ShopCatalog`, and `TitleEffectPreview` must be copied without redesign or normalization drift
- `TitleEffectPreview` is shared behavior for both `TitleMenu` and `ShopMenu`; a bad copy would break both UIs
- `src\ServerScriptService` should become a real directory, but no server authority scripts should be migrated in this slice

## Step-by-step implementation plan
1. Remove the placeholder file roots for `src\ReplicatedStorage` and `src\ServerScriptService`
2. Recreate `src\ReplicatedStorage` as a real Rojo source tree with only the shared title/shop modules and remotes
3. Recreate `src\ServerScriptService` as an empty real directory only, with no migrated server logic
4. Preserve remote instance names and classes exactly as recovered from the backup
5. Stop after Phase 0 and Phase 1 and report any unresolved dependency that still blocks a safe sync

## Validation plan
- Confirm `src\ReplicatedStorage` and `src\ServerScriptService` are directories after the patch
- Confirm the created remote trees exactly match backup names and classes
- Confirm `TitleMenu` and `ShopMenu` local code both require `TitleEffectPreview`
- Confirm no out-of-scope server scripts or UI systems were migrated
- No automated install/build/test commands are confirmed in this repo
- No Studio sync or Studio playtest will be run in this migration step

## Status log
- 2026-04-20: Audited the backup place file and confirmed the exact shared title/shop modules and remotes needed for Phase 1
- 2026-04-20: Confirmed `TitleEffectPreview` is a required shared dependency because both live `TitleMenu` and `ShopMenu` require it from `ReplicatedStorage`
- 2026-04-20: Began the minimum-change Phase 0 and Phase 1 migration plan before making any repo changes

---

## Goal
Reconcile the repo against the currently connected live Roblox Studio session only, starting with the Rojo sync contract and the exact live-accessible `StarterPlayer` slice.

## Scope
- Use the connected live Studio session as the only structural source of truth
- Do not use `place-backups` to restore, infer, or overwrite current content
- Repair the Rojo sync contract first
- Export only content that is exact from current live/session-accessible tooling
- Record everything else in a live-to-repo audit manifest as `manual export needed`

## Non-goals
- No backup-driven reconstruction
- No inferred or placeholder server logic
- No creative UI redesigns or refactors
- No broad non-live-verified metadata rewrites

## Files/systems likely touched
- `C:\Projects\SadCave\PLANS.md`
- `C:\Projects\SadCave\default.project.json`
- `C:\Projects\SadCave\docs\live-repo-audit.md`
- `C:\Projects\SadCave\src\StarterPlayer\**`
- `C:\Projects\SadCave\src\ReplicatedStorage\TipProductConfig.lua`
- `C:\Projects\SadCave\src\StarterGui\currencyui\init.meta.json`
- `C:\Projects\SadCave\src\StarterGui\currencyui\maincanvas\init.meta.json`
- `C:\Projects\SadCave\src\StarterGui\SadCaveMusicGui\init.meta.json`

## Risks / no-touch systems
- `ServerScriptService` authority scripts must not be recreated unless their exact live source is exported from the current session
- Existing local UI slices may already drift from live; only live-verified sync-contract fixes should be applied in this pass
- Any live object whose exact class, path, name, and source/content are not all verified must stay out of repo sync changes
- Windows paths cannot safely represent some Roblox names exactly, such as the live folder `environment change `

## Step-by-step implementation plan
1. Capture the live top-level service coverage map and the current repo/Rojo coverage map
2. Build a live-to-repo audit manifest with `correct`, `missing`, `wrong`, `extra`, and `manual export needed` statuses
3. Fix the Rojo sync contract by mapping `StarterCharacterScripts` and replacing the broken `StarterPlayerScripts` file path with a real source tree
4. Export the exact live-accessible `StarterPlayer` scripts that can be copied without approximation
5. Add only small exact live-accessible shared modules outside `StarterPlayer` when they are directly verified in this pass
6. Mark all remaining unreconciled live objects as `manual export needed` rather than approximating them

## Validation plan
- Confirm `default.project.json` now maps both `StarterPlayerScripts` and `StarterCharacterScripts`
- Confirm `src\StarterPlayer\StarterPlayerScripts` is a real directory tree, not a zero-byte file
- Confirm exported script files match live class, parent path, name, and enabled state
- Confirm no repo content was restored from backup place files
- No automated install/build/test commands are confirmed in this repo
- Studio validation in this pass is limited to live hierarchy/source inspection, not a sync/playtest

## Status log
- 2026-04-20: Replaced the backup-driven reconciliation assumption with a strict live-only reconciliation rule
- 2026-04-20: Confirmed the current repo sync contract is broken because `StarterCharacterScripts` is unmapped and `src\StarterPlayer\StarterPlayerScripts` is a zero-byte file
- 2026-04-20: Verified exact live script source for the exportable `StarterPlayer` scripts using the connected Studio session
- 2026-04-20: Began the first live-only implementation pass with sync-contract fixes, exact `StarterPlayer` export, and an audit manifest
- 2026-04-20: Re-verified the suspicious `StarterPlayer` classes against live and confirmed `PromptFavorite` is still a `Script`, `RainScript` is still a `LocalScript`, and `environment change ` is still a trailing-space `Folder`
- 2026-04-20: Exported exact live `ReplicatedStorage` trees for `ReportRemotes`, `Remotes`, `NoteSystem`, `Global_Events`, `report`, `Spawn`, `Bonk`, `NameValue`, `RunValue`, `Speed`, `Admin`, and `EButton`
- 2026-04-20: Exported exact live `StarterGui` trees for `Teleport Button`, `GUIToggle`, and `notificationUI`
- 2026-04-20: Exported the exact live `ServerScriptService.report.reportHandler` subtree so `src\ServerScriptService` is now a real source tree instead of only a deleted placeholder root
- 2026-04-20: Identified current tooling blockers for several remaining live trees, especially missing `AnchorPoint` serialization for centered GUI layouts and duplicate-name path collisions under some live parents
- 2026-04-20: Confirmed the local `ShopCatalog.lua` and `TitleEffectPreview.lua` already match the current live modules exactly; confirmed `TitleConfig.lua` had a one-line blank-line drift and patched it to match live
- 2026-04-20: Re-verified duplicate-name collisions directly from the live connector; `Purchase`, `SoftShutdown`, `Menu`, and `ScreenGui` still surface as ambiguous duplicate live paths
- 2026-04-20: Confirmed `IntroScreen` and `NoteUI` still cannot be exported exactly because current live tooling returns `null` for key centered-node `AnchorPoint` values
- 2026-04-20: Exported exact live standalone `ServerScriptService` authority scripts for `ReportHandler`, `CashLeaderstats`, `LevelLeaderstats`, `TitleService`, `ShopService`, `NoteSystemServer`, `DailyRewardsServer`, `FavoritePromptPersistence`, and disabled `TextChatServiceHandler`
- 2026-04-20: Confirmed the remaining highest-priority unresolved exports are the `RainScript` subtree, `NameTagScript Owner`, duplicate-name server/UI trees, and GUI/template trees blocked by missing centered-layout serialization
- 2026-04-20: Exported the live `StarterPlayer.StarterPlayerScripts.RainScript` root script, `Rain` module, and all 15 static value children into a new local Rojo subtree under `src\StarterPlayer\StarterPlayerScripts\RainScript`
- 2026-04-20: Exported the live `ServerScriptService.NameTagScript Owner` source into the repo as a structurally mapped local file pending final byte-exact re-diff
- 2026-04-20: Re-checked `ReplicatedStorage.NameTag` and confirmed the blocker is still real; child label `AnchorPoint` and related centered layout properties continue to return `null` from current live tooling
- 2026-04-20: Measured the newly transcribed standalone server files against live line counts and confirmed they are structurally mapped but not yet byte-exact; none of the newly transcribed standalone server files cleared the final exact-format re-diff in this pass
- 2026-04-20: Documented the duplicate-name-safe Rojo mapping strategy for future use (`unique filesystem name + properties.Name = live name`) but confirmed it still cannot be applied to current duplicate trees because the connector does not expose unique per-instance identities
- 2026-04-20: Re-ran the final exactness check for every structurally mapped source file and confirmed all 12 still fail byte-exact line-count comparison against live
- 2026-04-20: Re-ran the live blocker checks and captured the exact missing connector data for `NameTag`, `IntroScreen`, `NoteUI`, `UIGradient`, and `Rose`
- 2026-04-20: Re-ran duplicate/path blocker checks for `Purchase`, `SoftShutdown`, `Menu`, `ScreenGui`, `ShopItems.Book.Handle.WeldConstraint`, `AdminServerManager.Admin.Background.TextLabel`, and `environment change `
- 2026-04-20: Finalized `docs/live-repo-audit.md` so every audited gap now lands in one of five buckets: exact, structurally mapped but not byte-exact, true tooling blocker, duplicate-name/path blocker, or manual export still required

---

## Goal
Reduce the `manual export still required` backlog by exporting the highest-value live systems that are still representable exactly with current live/session tooling, using `docs/live-repo-audit.md` as the authoritative queue.

## Scope
- Work only from the current `manual export still required` backlog in `docs/live-repo-audit.md`
- Prioritize these systems in order:
  1. `StarterGui.currencyui`
  2. `StarterGui.ShopMenu`
  3. `StarterGui.tipui`
  4. `StarterGui.SadCaveMusicGui`
  5. `StarterGui.Settings`
  6. `StarterGui.settingui`
  7. `StarterGui.Custom Inventory`
  8. `ServerScriptService.Shop`
  9. `ServerScriptService.Custom Chat Script`
  10. `ServerScriptService.AdminGamePass`
  11. `ServerScriptService.AntiExploit`
  12. `ServerScriptService.SadCaveMusicPauseData`
  13. `ServerScriptService.ToolPickupService`
- Export only what is faithfully representable from the live Studio session and current connector output
- Shrink `docs/live-repo-audit.md` after each item or batch

## Non-goals
- No re-audit of already-proven tooling blockers unless the connector exposes new data
- No low-priority backlog work while higher-priority load-bearing systems remain unresolved
- No guessed metadata, placeholder logic, or inferred script content
- No live Studio edits

## Files/systems likely touched
- `C:\Projects\SadCave\PLANS.md`
- `C:\Projects\SadCave\docs\live-repo-audit.md`
- `C:\Projects\SadCave\src\StarterGui\currencyui\**`
- `C:\Projects\SadCave\src\StarterGui\ShopMenu\**`
- `C:\Projects\SadCave\src\StarterGui\tipui\**`
- `C:\Projects\SadCave\src\StarterGui\SadCaveMusicGui\**`
- `C:\Projects\SadCave\src\StarterGui\Settings\**`
- `C:\Projects\SadCave\src\StarterGui\settingui\**`
- `C:\Projects\SadCave\src\StarterGui\Custom Inventory\**`
- `C:\Projects\SadCave\src\ServerScriptService\Shop.server.lua`
- `C:\Projects\SadCave\src\ServerScriptService\Custom Chat Script\**`
- `C:\Projects\SadCave\src\ServerScriptService\AdminGamePass.server.lua`
- `C:\Projects\SadCave\src\ServerScriptService\AntiExploit.server.lua`
- `C:\Projects\SadCave\src\ServerScriptService\SadCaveMusicPauseData.server.lua`
- `C:\Projects\SadCave\src\ServerScriptService\ToolPickupService.server.lua`

## Risks / no-touch systems
- The current audit remains the contract for what is exact, blocked, or still manual-export-only; do not silently widen scope
- Many high-priority UI trees are large and may still expose partial property data; export only the exact-safe subset
- Server authority scripts must stay out of repo if their live source cannot be captured exactly
- Preserve all live names, classes, parent paths, enabled states, remote names, and current source ordering

## Step-by-step implementation plan
1. Re-read the current audit backlog and local repo coverage for the top-priority items
2. For each priority item, inspect the exact live subtree and determine whether current tooling exposes exact-safe structure, scripts, and runtime-relevant metadata
3. Export the exact-safe item into `src` using the existing Rojo conventions
4. If an item is blocked, record the precise blocker immediately in the audit and move to the next priority
5. After each completed item or logical batch, shrink the `manual export still required` list in `docs/live-repo-audit.md`
6. Stop only when the remaining high-priority items are reduced to proven blockers or still-unfinished exact export work

## Validation plan
- Verify each exported item against the live path, class, subtree shape, and script source from the connected Studio session
- Validate every edited `init.meta.json` file with local JSON parsing
- Re-check `docs/live-repo-audit.md` after each batch so the backlog visibly shrinks
- No automated install/build/test commands are confirmed in this repo
- Studio validation in this pass is limited to live hierarchy/source/property inspection, not a sync/playtest unless explicitly run

## Status log
- 2026-04-20: Closure-mode pass started with `docs/live-repo-audit.md` as the authoritative backlog
- 2026-04-20: Folded the previous export batch into the audit so `tipui` and `Settings` now sit under duplicate-name/path blockers and `ShopMenu`, `SadCaveMusicGui`, `Shop`, and `AntiExploit` now sit under structurally mapped but not byte-exact
- 2026-04-20: Confirmed from the live connector that `settingui`, `Custom Inventory`, `Custom Chat Script`, `AdminGamePass`, `SadCaveMusicPauseData`, and `ToolPickupService` remain the next highest-value export candidates after `currencyui`
- 2026-04-20: Exported live `ServerScriptService` backlog items `AdminGamePass`, `SadCaveMusicPauseData`, `ToolPickupService`, and the full `Custom Chat Script` subtree into `src`
- 2026-04-20: Validated the new server exports with local line counts against live (`124`, `190`, `133`, and `71`) and re-parsed all `init.meta.json` files successfully
- 2026-04-20: Re-checked `Custom Inventory` and confirmed the main remaining weight is the `InventoryController.SETTINGS` module at `534` lines; re-checked `settingui` and confirmed its script sources are live-accessible and still exportable in a future pass
- 2026-04-20: Re-ran the full live `StarterGui.settingui` tree, script sources, and UI property payloads as a closure-mode dedicated pass
- 2026-04-20: Confirmed `settingui` is not exact-safe to export from current tooling because the connector omits `AnchorPoint` on multiple centered layout nodes (`mainui2`, `title`, `ScrollingFrame`, `mainui2_ShadowPng`, `ShadowImage`, and centered spacer labels)
- 2026-04-20: Left `settingui` out of `src` and moved it from the manual-export backlog into the audit's true-tooling-blocker section rather than guessing a shifted UI layout
- 2026-04-20: Re-ran the live `StarterGui.currencyui` tree with the current session and confirmed only the root `ScreenGui` plus the two direct client scripts are exact-safe to represent locally without guessing UI layout
- 2026-04-20: Exported `game.StarterGui.currencyui.LocalScript` and `game.StarterGui.currencyui.anim` into `src\StarterGui\currencyui` and verified their local line counts match live (`68` and `190`)
- 2026-04-20: Removed the old local `currencyui\maincanvas` scaffold because the current connector omits `AnchorPoint` on the centered `maincanvas` root, making the shared HUD/menu subtree unsafe to sync faithfully
- 2026-04-20: Classified `currencyui.maincanvas` as a true layout-data blocker and `currencyui.maincanvas.mainframe.poseui.emotescrip` as a numbered-output-only source blocker in the audit rather than leaving `currencyui` in the manual-export queue
- 2026-04-20: Re-ran the full live `StarterGui.Custom Inventory` tree and verified the exact source files under `InventoryController` plus the current visual subtree property payloads
- 2026-04-20: Exported the exact-safe `Custom Inventory` source slice into `src\StarterGui\Custom Inventory`: the root `ScreenGui`, `InventoryController`, and `InventoryController.SETTINGS`
- 2026-04-20: Verified the exported `Custom Inventory` source file line counts match live (`156` and `534`) and re-parsed all `init.meta.json` files successfully
- 2026-04-20: Classified the remaining `Custom Inventory` visual subtrees as true layout-data blockers because the connector omits `AnchorPoint` on centered nodes in `Inventory`, `hotBar`, and the `toolButton` template
- 2026-04-20: Closure-review-only pass re-read `docs\live-repo-audit.md` and sorted the remaining manual-export backlog into likely-next, probable-blocker, and low-priority groups without exporting any new systems
- 2026-04-20: Ranked the next closure targets as `ServerScriptService.Theme`, `ServerScriptService.OverheadTagsToggleServer`, and `StarterGui.fridge-ui`; these remain the biggest manual-export gaps still keeping the repo from practical source-of-truth status
