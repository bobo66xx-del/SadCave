# StarterGui UI Hierarchy

> **Role of this doc:** snapshot of *what UI currently exists* in `StarterGui`, not *what should exist*. Reference for Codex when working on UI.
>
> **Last refreshed:** 2026-04-27 — after Tyler's heavy cleanup pass that deleted most of the legacy `StarterGui` ScreenGuis. Pre-cleanup snapshot from 2026-04-19 was stale enough that this doc has been rewritten rather than appended.
>
> **Production note:** this doc reflects the *testing place*. Production may still hold the larger pre-cleanup UI surface.
>
> **Update cadence:** refresh whenever the UI surface changes meaningfully. Not updated during normal design work.

---

## Top-level systems (post-cleanup): 4

> Listed in alphabetical order. Each is the top-level `ScreenGui` object name as it appears in `StarterGui`.

### `NoteUI` [`ScreenGui`]

The writable-notes UI. Paired with `NoteSystemServer` + `ReplicatedStorage.NoteSystem.*`. Lets a player edit a note tied to a `Workspace.NoteInteraction` spot via `ProximityPrompt`.

- `NoteUI` [`ScreenGui`]
  - `MainFrame` [`Frame`]
    - `NoteCard` [`Frame`]
      - `EditButton` [`ImageButton`] (Corner, Stroke)
      - `NoteInput` [`TextBox`] (Padding)
      - `CancelButton` [`TextButton`] (Glyph, Corner)
      - `PostButton` [`TextButton`] (Corner, Stroke)
      - `NoteText` [`TextLabel`]
      - `StatusLabel` [`TextLabel`]
      - Corner, PaperGradient
  - `NoteUIClient` [`LocalScript`]

### `XPBar` [`ScreenGui`]

The XP Progression MVP UI. Bottom-of-screen ambient bar. Listens to `ReplicatedStorage.Progression.XPUpdated` and `LevelUp` remotes. Built programmatically by `XPBarController.client.lua`.

- `XPBar` [`ScreenGui`] — `IgnoreGuiInset = true`, `ResetOnSpawn = false`, `DisplayOrder = 0`
  - `XPBarController` [`LocalScript`]
  - All visual elements (`Background`, `Fill`, `LevelLabel`, `TitleLabel`) are constructed at runtime — not edit-time children.

### Other UI surfaces (verify in next session)

The cleanup pass deleted the bulk of `StarterGui` (TitleMenu, ShopMenu, the dual `Menu` ScreenGuis, `Settings`, `IntroScreen`, `Custom Inventory`, `ComputerUI`, `fridge-ui`, `SadCaveMusicGui`, `bruh`, `TTTUI`, `NotificationTHingie`, `ScreenGui` orphans). What's *intended* to remain is `NoteUI` + `XPBar`. If `tipui`, `currencyui`, `notificationUI`, `Teleport Button`, `TPUI`, `MainUI`, `GUIToggle`, or any other pre-cleanup surface is still present, treat it as undocumented and verify with Studio MCP before assuming intent — **flag in the inbox** if any unexpected ScreenGui shows up.

---

## Removed in 2026-04-27 Cleanup

Audit trail. None of these are in the testing-place `StarterGui` anymore.

- `ComputerUI` — print-button + note-box panel
- `Custom Inventory` — hotbar + inventory grid
- `IntroScreen` — startup splash
- `MainUI` — version-stamp wrapper
- `Menu` (×2 duplicates) — paired with the deleted button rail
- `NotificationTHingie` — dev artifact
- two generic `ScreenGui` orphans
- `Settings` — legacy settings panel
- `ShopMenu` — paired with the deleted `ShopService`
- `TTTUI` — Trouble-in-Terrorist-Town template leftover
- `TitleMenu` — paired with the deleted v1 title pipeline
- `bruh` — debug/analytics overlay
- `fridge-ui` — combat-shop adjacent food UI
- `SadCaveMusicGui` — music control panel
- `currencyui` — primary HUD with shards display + side menu rail (deletion of currency UI follows the deletion of `CashLeaderstats` and `Shards`)
- `tipui` — tip / donation purchase panel (verify; may have been kept if donations are intentionally preserved — see `_Cleanup_Backlog.md` "Donations" entry)
- `notificationUI` — notification banner system (verify; was kept-pending depending on whether `Global_Events.Notification_Event` is still actively used)
- `Teleport Button`, `TPUI`, `GUIToggle` — small utility surfaces; verify presence in next session

The ones marked "verify" are uncertain — the cleanup log in `_Inbox` doesn't itemize which UI was kept by name, only the categories. The next time anyone touches `StarterGui`, walk the live tree once and update this doc.

---

## Conventions

When new UI is added:
- New ScreenGuis go into the repo at `src/StarterGui/<Name>/` with an `init.meta.json` declaring the ScreenGui properties (typically `ResetOnSpawn = false`).
- Client scripts inside the UI go in the same folder as `<Name>.client.lua` or `init.client.lua`.
- Update this doc with the new ScreenGui's name and a one-paragraph description in the next integration pass.
