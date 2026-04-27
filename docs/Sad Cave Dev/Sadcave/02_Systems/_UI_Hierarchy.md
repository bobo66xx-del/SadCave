# StarterGui UI Hierarchy

> **Role of this doc:** snapshot of *what UI currently exists* in `StarterGui`, not *what should exist*. Reference for Codex when working on UI.
>
> **Last refreshed:** 2026-04-27 — after Tyler's heavy cleanup pass that deleted most of the legacy `StarterGui` ScreenGuis. Pre-cleanup snapshot from 2026-04-19 was stale enough that this doc has been rewritten rather than appended.
>
> **Production note:** this doc reflects the *testing place*. Production may still hold the larger pre-cleanup UI surface.
>
> **Update cadence:** refresh whenever the UI surface changes meaningfully. Not updated during normal design work.

---

## Top-level source-bearing ScreenGuis (audit-confirmed 2026-04-27 refresh): 5

> Listed in alphabetical order. Each is a top-level source-bearing `ScreenGui` object name as it appears in `StarterGui`. The 2026-04-27 audit refresh found three live ScreenGuis we didn't expect (drift, see below) — bringing the count from the 2 we believed (`NoteUI`, `XPBar`) to 5 actually present.

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

### `Game Version` [`ScreenGui`]

Undocumented surface — discovered by the 2026-04-27 audit refresh. Not on any prior keep-list and not in the cleanup-removed list either. Contains a single 1-line `ShowGameVersion` LocalScript.

- `Game Version` [`ScreenGui`]
  - `ShowGameVersion` [`LocalScript`] (1 line)

**Status:** unknown intent. Tyler decision pending: keep (in which case it should be exported to `src/`) or delete (in which case clean up the testing place). Tracked in `docs/live-repo-audit.md` Manual Export queue.

### `IntroScreen` [`ScreenGui`]

**Drift:** the 2026-04-27 cleanup pass listed `IntroScreen` as deleted, but the audit refresh found it's still live in `StarterGui`. Either Tyler's cleanup missed this entry or it's been re-created since. Current MCP inspector cannot expose enough faithful UI detail for a safe export — classified as a tooling blocker in the audit.

**Status:** drift, decision pending. Tyler choices: delete (matches the cleanup intent) or document as kept (matches current reality).

### `Menu` [`ScreenGui`]

**Drift:** the cleanup pass listed two duplicate `Menu` ScreenGuis as deleted, but the audit refresh found one still live. Contains a 1-line `LocalScript` plus a 30-line `MainScript`. Needs a keep/delete decision.

**Status:** drift, decision pending — same as `IntroScreen`.

### Other UI surfaces (verify if drift recurs)

If `tipui`, `currencyui`, `notificationUI`, `Teleport Button`, `TPUI`, `MainUI`, `GUIToggle`, or any other pre-cleanup surface beyond the three above shows up in a future audit, treat it as drift and **flag in the inbox**.

---

## Removed in 2026-04-27 Cleanup

Audit trail. None of these are in the testing-place `StarterGui` anymore.

- `ComputerUI` — print-button + note-box panel
- `Custom Inventory` — hotbar + inventory grid
- ~~`IntroScreen` — startup splash~~ ❌ **NOT actually removed** — audit refresh 2026-04-27 found it still live. See drift entry above.
- `MainUI` — version-stamp wrapper
- ~~`Menu` (×2 duplicates) — paired with the deleted button rail~~ ⚠️ **One copy still live** — audit refresh 2026-04-27 found a `Menu` ScreenGui still present. See drift entry above.
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
