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
