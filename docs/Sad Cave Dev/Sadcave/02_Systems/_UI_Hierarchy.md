# StarterGui UI Hierarchy

> **Role of this doc:** snapshot of *what UI currently exists* in `StarterGui`, not *what should exist*. Reference for Codex when working on UI.
>
> **Source:** live `StarterGui` inspection from the connected Roblox Studio place on 2026-04-19.
>
> **Update cadence:** refresh after major resync work. Not updated during normal design work.
>
> **Cleanup awareness:** several entries here are slated for removal per [[_Cleanup_Backlog]] — duplicate `Menu` ScreenGuis, duplicate generic `ScreenGui`s, `bruh`, `TTTUI`, `NotificationTHingie`, `Settings` (likely legacy vs canonical `settingui`).

Top-level systems: 24

Notes:
- Exact object names are preserved as they exist in `StarterGui`.
- Duplicate top-level names are listed as separate systems with an index so they can be distinguished in documentation without renaming them.
- Each system is grouped by its top-level `ScreenGui`.

## 1. `ComputerUI` [`ScreenGui`]

- `ComputerUI` [`ScreenGui`]
  - `main` [`CanvasGroup`]
    - `MainFrame` [`Frame`]
      - `PrintButton` [`ImageButton`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
        - `UICorner` [`UICorner`]
      - `NoteBox` [`TextBox`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
        - `UICorner` [`UICorner`]
        - `UITextSizeConstraint` [`UITextSizeConstraint`]
      - `CloseButton` [`TextButton`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `header` [`TextLabel`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `sub-header` [`TextLabel`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `UICorner` [`UICorner`]
      - `UIScale` [`UIScale`]
    - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
  - `LocalScript` [`LocalScript`]

## 2. `Custom Inventory` [`ScreenGui`]

- `Custom Inventory` [`ScreenGui`]
  - `hotBar` [`Frame`]
    - `Grid` [`UIGridLayout`]
  - `Inventory` [`ImageLabel`]
    - `Frame` [`ScrollingFrame`]
      - `Grid` [`UIGridLayout`]
      - `UIPadding` [`UIPadding`]
    - `SearchBox` [`TextBox`]
      - `UICorner` [`UICorner`]
    - `UICorner` [`UICorner`]
  - `InventoryController` [`LocalScript`]
    - `toolButton` [`ImageButton`]
      - `toolIcon` [`ImageLabel`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `toolAmount` [`TextLabel`]
        - `UIStroke` [`UIStroke`]
      - `toolName` [`TextLabel`]
        - `UIStroke` [`UIStroke`]
        - `UITextSizeConstraint` [`UITextSizeConstraint`]
      - `toolNumber` [`TextLabel`]
      - `UICorner` [`UICorner`]
      - `UIStroke` [`UIStroke`]
    - `SETTINGS` [`ModuleScript`]

## 3. `GUIToggle` [`ScreenGui`]

- `GUIToggle` [`ScreenGui`]
  - `EyeButton` [`ImageButton`]
    - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `UICorner` [`UICorner`]
    - `UIScale` [`UIScale`]
    - `UIStroke` [`UIStroke`]
  - `ToggleScript` [`LocalScript`]

## 4. `IntroScreen` [`ScreenGui`]

- `IntroScreen` [`ScreenGui`]
  - `Background` [`Frame`]
  - `IntroScript` [`LocalScript`]
  - `CommandHint` [`TextLabel`]
    - `UITextSizeConstraint` [`UITextSizeConstraint`]
  - `SubtitleLabel` [`TextLabel`]
    - `UITextSizeConstraint` [`UITextSizeConstraint`]
  - `TitleLabel` [`TextLabel`]
    - `UITextSizeConstraint` [`UITextSizeConstraint`]

## 5. `MainUI` [`ScreenGui`]

- `MainUI` [`ScreenGui`]
  - `MainFrame` [`CanvasGroup`]
    - `ver` [`TextLabel`]
      - `ShowGameVersion` [`LocalScript`]
    - `UIScale` [`UIScale`]

## 6. 🔴 `Menu` [`ScreenGui`] (first top-level `Menu` — duplicate, see [[_Cleanup_Backlog]])

- `Menu` [`ScreenGui`]
  - `Frame` [`Frame`]
    - `CloseButton` [`TextButton`]
      - `CloseMenuS` [`Script`]
    - `TextButton` [`TextButton`]
      - `LocalScript` [`LocalScript`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `TextButton` [`TextButton`]
      - `LocalScript` [`LocalScript`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `TextButton` [`TextButton`]
      - `LocalScript` [`LocalScript`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `TextButton` [`TextButton`]
      - `LocalScript` [`LocalScript`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `TextLabel` [`TextLabel`]
  - `MainScript` [`Script`]
  - `MenuButton` [`TextButton`]
    - `OpenMenuS` [`Script`]
    - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `UITextSizeConstraint` [`UITextSizeConstraint`]

## 7. 🔴 `Menu` [`ScreenGui`] (second top-level `Menu` — duplicate, see [[_Cleanup_Backlog]])

- `Menu` [`ScreenGui`]
  - `MainFrame` [`CanvasGroup`]
    - `LoadLabel` [`TextLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `LoadLabelUIScale` [`UIScale`]
  - `LocalScript` [`LocalScript`]
  - `MainScript` [`LocalScript`]
  - `Intro` [`Sound`]
    - `EqualizerSoundEffect` [`EqualizerSoundEffect`]
  - `Woosh` [`Sound`]
    - `EqualizerSoundEffect` [`EqualizerSoundEffect`]

## 8. `NoteUI` [`ScreenGui`]

- `NoteUI` [`ScreenGui`]
  - `MainFrame` [`Frame`]
    - `NoteCard` [`Frame`]
      - `EditButton` [`ImageButton`]
        - `Corner` [`UICorner`]
        - `Stroke` [`UIStroke`]
      - `NoteInput` [`TextBox`]
        - `Padding` [`UIPadding`]
      - `CancelButton` [`TextButton`]
        - `Glyph` [`TextLabel`]
        - `Corner` [`UICorner`]
      - `PostButton` [`TextButton`]
        - `Corner` [`UICorner`]
        - `Stroke` [`UIStroke`]
      - `NoteText` [`TextLabel`]
      - `StatusLabel` [`TextLabel`]
      - `Corner` [`UICorner`]
      - `PaperGradient` [`UIGradient`]
  - `NoteUIClient` [`LocalScript`]

## 9. 🔴 `NotificationTHingie` [`ScreenGui`] (likely dev artifact, see [[_Cleanup_Backlog]])

- `NotificationTHingie` [`ScreenGui`]
  - `Main` [`CanvasGroup`]
    - `LocalScript` [`LocalScript`]
    - `Sound` [`Sound`]
    - `Text` [`TextLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `UIScale` [`UIScale`]
    - `UIListLayout` [`UIListLayout`]

## 10. `SadCaveMusicGui` [`ScreenGui`]

- `SadCaveMusicGui` [`ScreenGui`]
  - `MusicPanel` [`Frame`]
    - `Controls` [`Frame`]
      - `Volume` [`Frame`]
        - `SliderBack` [`Frame`]
          - `Knob` [`Frame`]
            - `UICorner` [`UICorner`]
          - `SliderFill` [`Frame`]
            - `UICorner` [`UICorner`]
          - `UICorner` [`UICorner`]
        - `VolumeLabel` [`TextLabel`]
      - `Next` [`TextButton`]
        - `UICorner` [`UICorner`]
      - `PlayPause` [`TextButton`]
        - `UICorner` [`UICorner`]
    - `mainframe_ShadowPng` [`Frame`]
      - `ShadowImage` [`ImageLabel`]
    - `NowPlayingLabel` [`TextLabel`]
    - `SongLabel` [`TextLabel`]
    - `UICorner` [`UICorner`]
  - `MusicGuiController` [`LocalScript`]
  - `MusicWorldDisplayController` [`LocalScript`]
  - `MiniButton` [`TextButton`]
    - `UICorner` [`UICorner`]
    - `AutoUIScale` [`UIScale`]
    - `UIStroke` [`UIStroke`]

## 11. 🔴 `ScreenGui` [`ScreenGui`] (first generic-named — likely orphan, see [[_Cleanup_Backlog]])

- `ScreenGui` [`ScreenGui`]

## 12. 🔴 `ScreenGui` [`ScreenGui`] (second generic-named — likely orphan, see [[_Cleanup_Backlog]])

- `ScreenGui` [`ScreenGui`]
  - `LocalScript` [`LocalScript`]

## 13. 🔴 `Settings` [`ScreenGui`] (likely legacy vs canonical `settingui`, see [[_Cleanup_Backlog]])

- `Settings` [`ScreenGui`]
  - `Frame` [`Frame`]
    - `Settings` [`Frame`]
      - `ScrollingFrame` [`ScrollingFrame`]
        - `Diffuse` [`Frame`]
          - `CloseButton` [`TextButton`]
            - `LocalScript` [`LocalScript`]
            - `UICorner` [`UICorner`]
          - `Name` [`TextLabel`]
          - `UICorner` [`UICorner`]
        - `Diffuse` [`Frame`]
          - `CloseButton` [`TextButton`]
            - `LocalScript` [`LocalScript`]
            - `UICorner` [`UICorner`]
          - `Name` [`TextLabel`]
          - `UICorner` [`UICorner`]
        - `Shadows` [`Frame`]
          - `CloseButton` [`TextButton`]
            - `LocalScript` [`LocalScript`]
            - `UICorner` [`UICorner`]
          - `Name` [`TextLabel`]
          - `UICorner` [`UICorner`]
        - `UIListLayout` [`UIListLayout`]
      - `UICorner` [`UICorner`]
    - `Up` [`Frame`]
      - `Frame` [`Frame`]
        - `UICorner` [`UICorner`]
      - `ImageLabel` [`ImageLabel`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `CloseButton` [`TextButton`]
        - `LocalScript` [`LocalScript`]
        - `UICorner` [`UICorner`]
      - `TextLabel` [`TextLabel`]
    - `UICorner` [`UICorner`]

## 14. 🔴 `ShopMenu` [`ScreenGui`] (paired with legacy Shop, see [[_Cleanup_Backlog]])

- `ShopMenu` [`ScreenGui`]
  - `main` [`CanvasGroup`]
    - `mainframe` [`Frame`]
      - `ScrollingFrame` [`ScrollingFrame`]
        - `template` [`TextButton`]
          - `EquipedLabel` [`TextLabel`]
          - `TitleName` [`TextLabel`]
          - `TitleRequiredLevel` [`TextLabel`]
          - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
          - `UICorner` [`UICorner`]
        - `UICorner` [`UICorner`]
        - `UIListLayout` [`UIListLayout`]
      - `CurrentTitle` [`TextLabel`]
      - `header` [`TextLabel`]
      - `sub-header` [`TextLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `UICorner` [`UICorner`]
    - `mainframe_ShadowPng` [`Frame`]
      - `ShadowImage` [`ImageLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `LocalScript` [`LocalScript`]
    - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]

## 15. `TPUI` [`ScreenGui`]

- `TPUI` [`ScreenGui`]
  - `main` [`CanvasGroup`]
    - `loading circle` [`ImageLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `TPSOUND` [`Sound`]
    - `funfacttext` [`TextLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `tptext` [`TextLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
  - `LocalScript` [`LocalScript`]

## 16. 🔴 `TTTUI` [`ScreenGui`] (template leftover, see [[_Cleanup_Backlog]])

- `TTTUI` [`ScreenGui`]
  - `mainframe` [`CanvasGroup`]
    - `FRAME` [`Frame`]
      - `O` [`TextLabel`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
        - `UICorner` [`UICorner`]
      - `X` [`TextLabel`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
        - `UICorner` [`UICorner`]
      - `status` [`TextLabel`]
        - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
        - `UICorner` [`UICorner`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `UICorner` [`UICorner`]

## 17. `Teleport Button` [`ScreenGui`]

- `Teleport Button` [`ScreenGui`]
  - `TextButton` [`TextButton`]
    - `LocalScript` [`LocalScript`]
    - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]

## 18. `TitleMenu` [`ScreenGui`]

- `TitleMenu` [`ScreenGui`]
  - `main` [`CanvasGroup`]
    - `mainframe` [`Frame`]
      - `FilterTabs` [`Frame`]
        - `All` [`TextButton`]
          - `UICorner` [`UICorner`]
          - `TabStroke` [`UIStroke`]
        - `Gamepass` [`TextButton`]
          - `UICorner` [`UICorner`]
          - `TabStroke` [`UIStroke`]
        - `Level` [`TextButton`]
          - `UICorner` [`UICorner`]
          - `TabStroke` [`UIStroke`]
        - `Owned` [`TextButton`]
          - `UICorner` [`UICorner`]
          - `TabStroke` [`UIStroke`]
        - `Shop` [`TextButton`]
          - `UICorner` [`UICorner`]
          - `TabStroke` [`UIStroke`]
        - `UIListLayout` [`UIListLayout`]
      - `ScrollingFrame` [`ScrollingFrame`]
        - `template` [`TextButton`]
          - `EquipedLabel` [`TextLabel`]
          - `TitleName` [`TextLabel`]
          - `TitleRequiredLevel` [`TextLabel`]
          - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
          - `UICorner` [`UICorner`]
        - `UICorner` [`UICorner`]
        - `UIListLayout` [`UIListLayout`]
      - `CurrentTitle` [`TextLabel`]
      - `header` [`TextLabel`]
      - `sub-header` [`TextLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `UICorner` [`UICorner`]
    - `mainframe_ShadowPng` [`Frame`]
      - `ShadowImage` [`ImageLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
    - `LocalScript` [`LocalScript`]
    - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]

## 19. 🔴 `bruh` [`ScreenGui`] (dev/analytics overlay, see [[_Cleanup_Backlog]])

> Full subtree was extensive — preserved here in original detail. Contains analytics frame, daily rewards mirror frame, button frame, updates frame.

- `bruh` [`ScreenGui`]
  - `Frame` [`Frame`] *(analytics + daily rewards + updates panels)*
  - `Frame_ShadowPng` [`Frame`]
  - `upd` [`LocalScript`]

*Full subtree omitted from vault doc — reads as a debug overlay. Original ui-hierarchy.md in repo had full detail; if it's needed before deletion, restore from the audit.*

## 20. `currencyui` [`ScreenGui`]

> Large subtree — primary HUD. Contains shards display, side menu rail, pose/emote panel, music launcher, settings/avatar/title launchers.

- `currencyui` [`ScreenGui`]
  - `maincanvas` [`CanvasGroup`] *(blocked from exact export — see audit)*
    - `mainframe` [`Frame`]
      - `menuframe` [`Frame`] (Shop/Avatar/Hub/Music/Titles/dono/emote/settings buttons)
      - `poseui` [`Frame`] (Emotes + Poses scrolling frames, switch button)
      - `poseui_ShadowPng` [`Frame`]
      - `menubutton` [`TextButton`]
      - `ShardsValue` [`TextLabel`]
      - `madeby` [`TextLabel`]
      - `realtitle` [`TextLabel`]
    - `mainframe_ShadowPng` [`Frame`]
  - `LocalScript` [`LocalScript`]
  - `anim` [`LocalScript`]

## 21. `fridge-ui` [`ScreenGui`]

- `fridge-ui` [`ScreenGui`]
  - `main` [`CanvasGroup`]
    - `mainframe` [`Frame`]
      - `LocalScript` [`LocalScript`]
      - `itemframe` [`ScrollingFrame`]
        - 8 food item buttons (`bloxiade`, `burger`, `cake`, `chockymilk`, `cola`, `pizza`, `smore`, `taco`) — each with `setup` LocalScript, `itemname`, `itemprice`, `UICorner`
        - `UICorner` [`UICorner`]
        - `UIListLayout` [`UIGridLayout`]
      - `close` [`TextButton`]
      - `header` [`TextLabel`]
      - `sub-header` [`TextLabel`]
      - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
      - `UICorner` [`UICorner`]
    - `UIAspectRatioConstraint` [`UIAspectRatioConstraint`]
  - `close` [`Sound`]
  - `open` [`Sound`]

## 22. `notificationUI` [`ScreenGui`]

- `notificationUI` [`ScreenGui`]
  - `Interface` [`Folder`]
    - `Notifications` [`Frame`]
      - `UIListLayout` [`UIListLayout`]
  - `Scripting` [`Folder`]
    - `UIHandler` [`LocalScript`]
    - `NotificationsHandler` [`ModuleScript`]
      - `NotificationFrame` [`Frame`]

## 23. `settingui` [`ScreenGui`]

> Canonical settings UI per AGENTS.md. Live, but blocked from exact export — see audit.

- `settingui` [`ScreenGui`]
  - `mainui2` [`CanvasGroup`]
    - `ScrollingFrame` [`ScrollingFrame`] (8 setting frames + spacers + misc)
    - `title` [`TextLabel`]
  - `mainui2_ShadowPng` [`Frame`]

## 24. `tipui` [`ScreenGui`]

- `tipui` [`ScreenGui`]
  - `mainui` [`CanvasGroup`]
    - `LocalScript` [`LocalScript`]
    - `TipPurchase` [`LocalScript`]
    - `ScrollingFrame` [`ScrollingFrame`]
      - 5 tip frames (`tipframe5`, `tipframe10`, `tipframe100`, `tipframe1000`, `tipframe10000`)
    - `title` [`TextLabel`] (×2 — duplicate per audit)
  - `mainui_ShadowPng` [`Frame`]
  - `LocalScript` [`LocalScript`]

> *Full UI subtrees (especially `bruh` and `currencyui.maincanvas`) were collapsed here for readability. The original full-detail dump lives in `docs/live-repo-audit.md` and the ranges are referenced for export work there.*
