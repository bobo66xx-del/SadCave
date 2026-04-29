# Title — Polished Menu + Nametag Visual — Codex Plan

**Date:** 2026-04-29
**Status:** 🔵 Queued
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/title-polish-pass` *(once started)*
**Related Systems:** [[../02_Systems/Title_System]], [[../02_Systems/NameTag_Status]], [[../01_Vision/Tone_and_Rules]]

**Driving notes:** This is the polished-menu pass that drops in over the placeholder TitleMenu shipped in PR #14 plus the nametag visual rework that flips the BillboardGui's vertical zones. Designed 2026-04-29 in a Tyler-led design session. Full design spec lives in `02_Systems/Title_System.md` § "Polished Pass — Drawer + Title-Above-Name" — read it first; this brief translates that section into implementation steps.

Headline shape:

- **Nametag flips:** title row goes ABOVE the name (currently below). Smaller, softer, lowercase, warm-grey at ~0.75 opacity. The `glow` effect changes treatment from `UIStroke`-as-border to a soft underglow halo. `tint`/`shimmer`/`pulse` rebalance to lower contrast for the smaller top-position role. Server-side title plumbing untouched.
- **Menu becomes a right-side drawer:** ~34% screen width, slides in from right with the world dimmed-but-visible behind it (no blur). Category-sectioned inside. Click-to-commit. Slim edge tab on the right replaces the top-right `titles` button as the entry point. Four close paths (click outside, ESC, internal x, re-click the tab).
- **Locked-row hint copy** uses mixed voice: mechanical for `level` / `gamepass` / `presence` / `exploration` (concrete actions players need to know); indirect-poetic for `achievement` and `seasonal` (12 hand-written lines). Voice rule + lines are in § 6.
- **Studio cleanup ride-along:** delete the stale duplicate `TitleConfig` ModuleScript and stale duplicate `TitleRemotes` Folder under `ReplicatedStorage` (caught 2026-04-29 during AchievementTracker review playtest, logged in `_Open_Questions.md`). Tyler picked "roll cleanup into this brief" so it lands with code that's already touching the title surface.

Server contract is untouched: `EquipTitle` / `UnequipTitle` RemoteEvents, `TitleData` DataStore, server-side ownership re-resolution, 1s rate limit, `equippedManually` / `migratedFromV1` / `lastEquipTime` state, `notificationOnly` payloads, auto-equip-highest behavior, migration code — all stay. This brief is a UI / nametag visual rewrite plus a Studio cleanup step.

---

## 1. Purpose

Replace the placeholder TitleMenu (shipped PR #14) with the polished drawer design. Flip the nametag's BillboardGui vertical layout so the title sits above the name as a quiet epigraph rather than below as a label. Apply the mixed-voice locked-row hint pass. Delete the two stale duplicate Studio instances (`TitleConfig`, `TitleRemotes`) caught during AchievementTracker review.

After this brief ships:

- The placeholder's `_Cleanup_Backlog.md` entry can retire.
- The duplicate-instance entry in `_Open_Questions.md` can move to Resolved.
- The Title v2 player-facing surface is feature-complete on polish (only category activations remain: Presence next, then Exploration + Seasonal).

## 2. Player Experience

A player in the cave sees their character with a different nametag: a small lowercase title floating just above their display name, sitting like an epigraph rather than metadata stapled below. The title is at ~75% opacity; the name still anchors. Effects (`tint`, `shimmer`, `pulse`, `glow`) read more atmospheric — `glow` titles in particular show a soft halo around the title text rather than a hard outline.

When the player clicks the slim `titles` edge tab on the right side of the screen, the world dims slightly (~75% brightness) and a panel slides in from the right edge over ~0.3 seconds. The cave stays visible through the dim. Inside the panel, titles are sorted into category sections — `level`, `gamepass`, `presence`, `exploration`, `achievement`, `seasonal`. Each section shows the player's owned titles in that category first, then the locked titles in that category. Clicking an owned title equips it; the player sees their own nametag update through the dimmed view immediately. Clicking the currently-equipped title unequips back to auto-equip-highest.

Closing the drawer can happen four ways: click anywhere outside the panel, press ESC, click the small `x` inside the panel, or click the edge tab again. The panel slides out, the dim fades back to clear, the world is whole again.

Locked rows show a one-line hint of how to unlock — `reach level 50` for level titles, `from the title pack` for gamepass, `play for 24 hours` for presence, `find the deep cave` for exploration, atmospheric one-liners for achievements (`rest for a long while`, `stay until the early hours`) and seasonal (`only during certain times`).

## 3. Technical Structure

### Server responsibilities

Unchanged from PR #14. `TitleService.lua` continues to own ownership resolution, equip/unequip handlers, auto-equip-highest, migration, and the `TitleDataUpdated` payload path. No server-side rewrites in this brief.

`NameTagScript.server.lua` `ensureBillboardLayout` function is the only server-side edit — it builds the BillboardGui labels with the flipped vertical order. The watchdog, `applyTitlePayload`, and the `CharacterAdded` flow stay intact.

### Client responsibilities

- `TitleMenuController.client.lua` — full rewrite. Drawer shell, slide animation, dim overlay, category sections, click-to-commit, four close paths, BindableEvent decoupling, row diffing on `TitleDataUpdated`.
- `TitlesToggleController.client.lua` — full rewrite. Slim edge tab on the right, fires `TitleMenu.OpenRequested` BindableEvent, listens for `TitleMenu.CloseRequested` to update its toggle state.
- `NameTagEffectController.client.lua` — `glow` branch only. Replace the `UIStroke`-border treatment with the underglow halo. `tint`, `shimmer`, `pulse` keep their existing animations but with the slightly-reduced-contrast tweaks specified in § 5.

### Remote events / functions

No new remotes. No remote contract changes. `TitleRemotes.TitleDataUpdated`, `EquipTitle`, `UnequipTitle` all unchanged.

New BindableEvent for menu open/close decoupling:

- **`TitleMenu.OpenRequested`** (BindableEvent) — created at runtime by `TitleMenuController` on initialization, parented to the `TitleMenu` ScreenGui. The toggle controller fires this; the menu controller listens.
- **`TitleMenu.CloseRequested`** (BindableEvent) — parented to the same `TitleMenu` ScreenGui. Fired by the menu controller when it closes (so the toggle can update its visible state); also fired by the toggle when the player re-clicks it while the drawer is open.

Both BindableEvents live in the client GUI hierarchy (not in `ReplicatedStorage`) because they're purely client-local — no server cares about menu open/close state.

### DataStore keys touched

None. `TitleData` schema unchanged. No persistence changes.

## 4. Files / Scripts

### Modified

- `src/StarterGui/TitleMenu/TitleMenuController.client.lua` — full rewrite (current ~450 lines → similar order of magnitude after rewrite). Drawer shell, sections, rows, animation, close paths, BindableEvent.
- `src/StarterGui/TitlesToggleButton/TitlesToggleController.client.lua` — full rewrite (current ~62 lines → ~80-100 lines). Slim edge tab, hover lift animation, BindableEvent fire.
- `src/ServerScriptService/NameTagScript.server.lua` — `ensureBillboardLayout` function only. Flip vertical layout. ~30 lines changed in that function. `applyNameTag`, `buildBillboard`, `onPlayer`, the `Players.PlayerAdded` connection, and the watchdog all stay untouched.
- `src/StarterPlayer/StarterPlayerScripts/NameTagEffectController.client.lua` — `glow` effect branch only (~20 lines). The `tint`, `shimmer`, `pulse` branches get small contrast tweaks (~5 lines each). Helper functions and the rest of the controller untouched.

### Created

- None. The polished menu and toggle reuse the existing `StarterGui.TitleMenu` and `StarterGui.TitlesToggleButton` ScreenGuis (same names, same `ResetOnSpawn = false` and `IgnoreGuiInset = true` flags). The `init.meta.json` files for both stay as-is.

### Deleted (Studio-only, not in repo)

These exist as duplicate instances in the live testing place. Codex deletes them via Studio MCP after verification.

- `ReplicatedStorage.TitleConfig` — the **stale** duplicate (debug id `1_12808` per session 1's inspection, 13100 chars, missing the new constants `HEARD_THEM_ALL_MIN_NPCS`, `LAUNCH_WINDOW`, `GetAchievementTitleIds`).
- `ReplicatedStorage.TitleRemotes` — the **stale** duplicate (the empty Folder; the live one is the Rojo-managed one populated by `TitleService.Start`).

The new (kept) duplicates are the Codex-managed Rojo-synced ones: `TitleConfig` debug id `1_12807` with the new constants, and `TitleRemotes` populated at runtime.

## 5. Step-by-Step Implementation

Work on branch `codex/title-polish-pass`. Commit as you go. Push at the end.

### Step 1 — Studio reality-check before any code

1. Inspect `ReplicatedStorage` via Studio MCP `inspect_instance` and confirm there are two `TitleConfig` siblings and two `TitleRemotes` siblings. Note their debug ids.
2. `script_read` each `TitleConfig` and identify which one contains `HEARD_THEM_ALL_MIN_NPCS = 3`. That one is the **kept** copy (Rojo-managed). The other is the **stale** one and is the deletion target in step 8.
3. Inspect each `TitleRemotes` folder. The empty one is the stale duplicate; the populated one (with `TitleDataUpdated`, `EquipTitle`, `UnequipTitle` children at runtime) is kept.
4. Note the debug ids in inbox: `[C] HH:MM — TitleConfig kept=<id1> stale=<id2>; TitleRemotes kept=<id3> stale=<id4>.`
5. **Stop and flag with `[C] ?` if uncertain** about which is which. Do not delete in this step — deletion happens in step 8 after the rest of the build is done.

### Step 2 — Nametag layout flip

In `src/ServerScriptService/NameTagScript.server.lua`, rewrite `ensureBillboardLayout`:

1. BillboardGui size stays at `UDim2.new(0, 200, 0, 50)`. (48 is also fine if the gap fits cleanly; 50 is unchanged from current.)
2. Recreate the `TitleLabel` so it's first in the layout:
   - `Size = UDim2.new(1, 0, 0, 16)`
   - `Position = UDim2.new(0, 0, 0, 0)`
   - `Font = Enum.Font.Gotham`
   - `TextSize = 11`
   - `TextColor3 = Color3.fromRGB(225, 215, 200)` (default warm-grey; effect controller may overwrite per active effect)
   - `TextTransparency = 0.25` (this is the ~0.75 opacity)
   - `TextStrokeTransparency = 0.7`
   - `TextStrokeColor3 = Color3.fromRGB(0, 0, 0)`
   - `TextYAlignment = Enum.TextYAlignment.Bottom` (so the title hugs the gap above the name)
   - `BackgroundTransparency = 1`
3. Recreate the `NameLabel` so it's second:
   - `Size = UDim2.new(1, 0, 0, 28)`
   - `Position = UDim2.new(0, 0, 0, 19)` (16 title + 3 gap = 19)
   - `Font = Enum.Font.Gotham`
   - `TextSize = 16`
   - `TextColor3 = Color3.fromRGB(225, 215, 200)`
   - `TextStrokeTransparency = 0.6`
   - `TextStrokeColor3 = Color3.fromRGB(0, 0, 0)`
   - `TextYAlignment = Enum.TextYAlignment.Top`
   - `Text = displayName`
   - `BackgroundTransparency = 1`
4. Function stays idempotent — safe for the Avalog watchdog to call repeatedly. If a `NameLabel` or `TitleLabel` already exists with the wrong properties from a prior pre-polish layout, the function should overwrite the properties (not destroy and rebuild) to avoid flicker on respawn.
5. The sibling functions `buildBillboard`, `applyNameTag`, `onPlayer` need no changes. `applyTitlePayload(bb, payload)` continues to set `TitleEffect`, `TitleTintColor`, `TitleDisplay` attributes — the effect controller reads these.

Commit: `Flip nametag layout to title-above-name`.

### Step 3 — NameTagEffectController glow rebalance + contrast tweaks

In `src/StarterPlayer/StarterPlayerScripts/NameTagEffectController.client.lua`:

1. **`glow` branch rewrite.** Replace the existing `UIStroke` treatment (lines ~119-127) with an underglow halo:
   - Option A (try first): a `UIStroke` with `Thickness = 2`, `Transparency = 0.85`, `Color = tintColor`, `ApplyStrokeMode = Enum.ApplyStrokeMode.Border`. The thicker but very transparent stroke reads as a halo around the text rather than a sharp outline.
   - Option B (fallback if A doesn't read right): create a separate `Frame` parented to the `TitleLabel`, sized slightly larger than the text bounding box, with a `UIGradient` running a soft warm radial-style fade from `tintColor` at center to transparent at edges. Sit it behind the `TitleLabel` (`ZIndex` lower).
   - Codex picks A or B based on what reads as "ambient atmosphere, not bordered label." A is simpler — try first.
2. **`shimmer` contrast reduction.** In the existing `shimmer` branch, the gradient endpoints currently blend from `DEFAULT_COLOR` to `tintColor` at alpha 0.25 → 0.9 → 0.25. Tighten to 0.2 → 0.7 → 0.2 — the gradient still travels but with less contrast against the smaller, softer top-position title.
3. **`pulse` amplitude reduction.** In the existing `pulse` branch, change `brighten(tintColor, 0.08)` to `brighten(tintColor, 0.05)`. Same 1.5s period, gentler amplitude.
4. **`tint` unchanged** — the static color treatment still works correctly at the new opacity.
5. The default-color line `titleLabel.TextColor3 = DEFAULT_COLOR` (in the `none`/else branch) needs no change. The `TextTransparency` is set by `NameTagScript`; the effect controller doesn't override transparency.

Commit: `Rebalance nametag effects for top-position title row`.

### Step 4 — Toggle controller rewrite (slim edge tab + BindableEvent)

In `src/StarterGui/TitlesToggleButton/TitlesToggleController.client.lua`:

1. Rewrite to build a slim edge-tab on the right:
   - A `TextButton` parented to the ScreenGui.
   - `AnchorPoint = Vector2.new(1, 0.5)`, `Position = UDim2.new(1, 0, 0.5, 0)`, `Size = UDim2.new(0, 18, 0, 90)`.
   - `BackgroundColor3 = Color3.fromRGB(20, 18, 22)`, `BackgroundTransparency = 0.25`.
   - `UICorner` at `UDim.new(0, 4)` (full corner radius is fine — the right side will be off-screen so the rounded corners read only on the left edge).
   - `UIStroke` warm-grey at `Transparency = 0.82`, `Thickness = 1`.
   - Inside: a small rotated `TextLabel` reading `titles` — `Rotation = -90`, `Font = Enum.Font.Gotham`, `TextSize = 10`, `TextColor3 = Color3.fromRGB(225, 215, 200)`, `TextTransparency = 0.4`, `Size = UDim2.new(1, 0, 0, 60)`, anchored center, `BackgroundTransparency = 1`.
2. Hover behavior:
   - On `MouseEnter`: tween `BackgroundTransparency` from 0.25 → 0.15 over 0.15s sine ease, AND tween `Position` to `UDim2.new(1, 4, 0.5, 0)` (slides 4px out from the edge to invite the click).
   - On `MouseLeave`: reverse both tweens.
3. Click behavior:
   - On `MouseButton1Click`: check whether the drawer is currently open (track via a local `isOpen` boolean updated by the `CloseRequested` listener).
   - If closed: fire `TitleMenu.OpenRequested:Fire()`.
   - If open: fire `TitleMenu.CloseRequested:Fire()`.
4. BindableEvent setup:
   - Wait for the `TitleMenu` ScreenGui sibling under `PlayerGui` (`player:WaitForChild("PlayerGui"):WaitForChild("TitleMenu")`). Then `WaitForChild("OpenRequested", 5)` and `WaitForChild("CloseRequested", 5)` on the `TitleMenu`. The menu controller creates these on init.
   - If either BindableEvent doesn't appear within 5s, warn and fall back to the previous `playerGui.TitleMenu.Root.Visible` direct toggle (so the tab still works if `TitleMenuController` failed to load). This is a safety net, not the happy path.
5. Listen to `CloseRequested` to flip `isOpen = false` so re-clicks toggle correctly.
6. Mobile sanity: the 18-px-wide tab is small for thumbs but workable. If Codex sees an issue in mobile playtest, bump to 22 px wide and note it.

Commit: `Rewrite titles toggle as slim edge tab with BindableEvent`.

### Step 5 — Menu controller rewrite (drawer shell + sections + animation)

In `src/StarterGui/TitleMenu/TitleMenuController.client.lua`:

1. **Discard the existing programmatic build entirely** (Root frame, tabs, OwnedScroll/LockedScroll, click handlers, `clearRows`, `renderRows`, etc.). The new build has different shape.
2. **Create the BindableEvents first:**
   - `OpenRequested` (BindableEvent) parented to `script.Parent` (the `TitleMenu` ScreenGui).
   - `CloseRequested` (BindableEvent) parented to the same ScreenGui.
3. **Build the dim overlay:**
   - A `Frame` parented to the ScreenGui, full screen (`Size = UDim2.new(1, 0, 1, 0)`), `BackgroundColor3 = Color3.fromRGB(0, 0, 0)`, `BackgroundTransparency = 1` (starts invisible), `BorderSizePixel = 0`, `ZIndex = 10`. Name it `DimOverlay`.
   - The overlay also serves as the click-outside-to-close catcher. Make it a `TextButton` (or add an `InputBegan` listener) and on click fire `CloseRequested`.
4. **Build the drawer Root:**
   - A `Frame` parented to the ScreenGui named `Root`, `ZIndex = 20`. Anchor right edge: `AnchorPoint = Vector2.new(1, 0.5)`, resting `Position = UDim2.new(1, 0, 0.5, 0)`, off-screen `Position = UDim2.new(2, 0, 0.5, 0)` (one full screen width to the right).
   - `Size = UDim2.new(0.34, 0, 1, 0)` with a `UISizeConstraint` setting `MinSize = Vector2.new(320, 0)` and `MaxSize = Vector2.new(520, math.huge)`.
   - `BackgroundColor3 = Color3.fromRGB(20, 18, 22)`, `BackgroundTransparency = 0.05`.
   - `UICorner` at `UDim.new(0, 8)` (full corner — the right edge corners sit off-screen so only the left side reads as rounded).
   - `UIStroke` warm-grey at `Transparency = 0.82`, `Thickness = 1`.
   - `UIPadding` 12px each side.
5. **Build the drawer header:**
   - Title row at the top showing `your titles` (lowercase, Gotham 14, warm-grey full opacity), and a small `x` close button anchored top-right (Gotham 16, warm-grey muted, click fires `CloseRequested`).
6. **Build the drawer body — ScrollingFrame:**
   - Below the header, full remaining height. `ScrollBarThickness = 4`, `ScrollBarImageColor3 = Color3.fromRGB(110, 102, 94)`, `AutomaticCanvasSize = Enum.AutomaticSize.Y`, `CanvasSize = UDim2.new(0, 0, 0, 0)`.
   - `UIListLayout` vertical, `Padding = UDim.new(0, 6)`, `SortOrder = Enum.SortOrder.LayoutOrder`.
7. **Section + row construction:**
   - For each category in this fixed order: `level`, `gamepass`, `presence`, `exploration`, `achievement`, `seasonal`. Use a `CATEGORY_ORDER` table, same shape as the placeholder used.
   - Build a section header Frame with a `TextLabel` (Gotham 13, lowercase, warm-grey at 0.7 opacity, the lowercase category name) and a hairline `Frame` (1px tall, warm-grey at 0.85 transparency) below it.
   - Then iterate titles in that category. Owned titles first (sort by `levelRequired` / `hoursRequired` / `display` within the category), then locked titles.
   - Use `LayoutOrder` to keep the section order stable and titles within sections ordered.
8. **Owned row:**
   - `TextButton`, ~36px tall, `BackgroundColor3 = Color3.fromRGB(34, 30, 38)` at `BackgroundTransparency = 0.1`, `UICorner UDim.new(0, 6)`.
   - Title `display` text in Gotham 13 warm-grey, left-aligned with 12px left padding. Color the text with the title's `tintColor` if the title has an effect (`tint`/`shimmer`/`pulse`/`glow`) — the tint chip lives in the text itself. For `none` effect titles, use plain warm-grey.
   - Currently-equipped row gets a small `wearing` caption beneath the title text in Gotham 10 warm-grey at 0.5 opacity, right-aligned.
   - Hover: tween background to `Color3.fromRGB(42, 37, 47)` over 0.15s sine ease.
   - Click: if `title.id == equippedTitleId` then `UnequipTitle:FireServer()`, else `EquipTitle:FireServer(title.id)`. Same as placeholder.
9. **Locked row:**
   - `Frame` (not interactive), same dimensions, `BackgroundTransparency = 0.4` (more transparent).
   - Title `display` in Gotham 13 warm-grey at `TextTransparency = 0.4`.
   - Hint `TextLabel` right-aligned in Gotham 11 warm-grey at `TextTransparency = 0.4`, ~14px from right edge. Use the `getHint(title)` function — but rewrite it to use the new mixed-voice copy in § 6.
10. **Animation:**
    - On `OpenRequested`: tween `Root.Position` from off-screen → resting (0.3s, `Quart`, `Out`); simultaneously tween `DimOverlay.BackgroundTransparency` from 1 → 0.75 over 0.2s.
    - On `CloseRequested`: tween reverse — `Root.Position` from resting → off-screen (0.25s, `Quart`, `In`); simultaneously tween `DimOverlay.BackgroundTransparency` from 0.75 → 1 over 0.2s. After the position tween completes, hide the dim overlay's input-capturing if it's a TextButton (or just leave it transparent — at transparency 1 it captures clicks; if you want to disable click-through during closed state set `Active = false` after the close tween).
    - Drawer starts in the off-screen state. `Visible = true` always — the slide is what hides/shows it. Easier than tweaking `Visible`.
11. **ESC key:**
    - `UserInputService.InputBegan` listener — if `input.KeyCode == Enum.KeyCode.Escape` and the drawer is open, fire `CloseRequested`.
12. **Row diffing on `TitleDataUpdated`:**
    - On payload arrival, compute the new `ownedTitleIds` set. Compare to previous: which titles were added (newly owned), which removed (rare — only if a manual unequip-then-fall-back changes things). For added/removed, only re-create the affected row. The category-section structure stays put.
    - For `equippedTitleId` changes: hide the `wearing` caption on the previously-equipped row, show it on the newly-equipped row. No section rebuild.
    - This avoids the scroll-position reset problem when an unlock fires mid-session while the drawer is open.
    - **First-render is a full build** (the diff baseline is empty); subsequent renders are diffs.

Commit: `Rewrite TitleMenu as right-side drawer with category sections`.

### Step 6 — Hint copy rewrite

In `TitleMenuController.client.lua` (or a small helper module if it gets long), replace the `ACHIEVEMENT_HINTS` table and the `getHint` function with the mixed-voice rules in § 6 below. Keep `getHint` as the single point that maps a title → hint string; the function dispatches by category.

Commit: `Apply mixed-voice locked-row hint copy`.

### Step 7 — Local playtest pass

Use Studio MCP `start_stop_play` + `console_output` to playtest. Walk all the items in the Studio Test Checklist (§ 9). Capture each result in `00_Inbox/_Inbox.md` with `[C] HH:MM` lines.

If you hit a runtime error, small/obvious fixes happen on this step; ambiguous behavior or design conflict gets a `[C] ? — Playtest: <description>` flag and you stop.

### Step 8 — Studio cleanup (delete stale duplicates)

After the playtest passes, delete the two stale duplicates from Studio:

1. Re-confirm via `inspect_instance` that the kept `TitleConfig` is the one with `HEARD_THEM_ALL_MIN_NPCS`. If the new menu is reading the right one in playtest (the achievement-section locked rows show `heard them all` etc. with correct hint copy), that's also a runtime confirmation of which is which.
2. Delete the stale `TitleConfig` duplicate (the one without the new constants).
3. Delete the stale `TitleRemotes` duplicate (the empty Folder — the populated one is the live one, with `TitleDataUpdated`, `EquipTitle`, `UnequipTitle` children at runtime).
4. Re-inspect to confirm only one of each remains.
5. Brief follow-up playtest: re-run the menu open/close + equip/unequip checks to confirm nothing broke.
6. Capture in inbox: `[C] HH:MM — Deleted stale TitleConfig duplicate (was id <stale_id>); deleted stale TitleRemotes duplicate (was id <stale_id>). Re-inspected: one of each remains. Re-playtested menu open/equip/close — passed.`

**If at any point the kept-vs-stale identification is unclear**, flag with `[C] ?` and STOP. Do not delete the wrong one — losing the live `TitleConfig` would break ownership resolution.

### Step 9 — Push the branch

```
git push -u origin codex/title-polish-pass
```

Hand back to Tyler with:

- What you did
- What you tested (all checklist items)
- What you flagged with `?`
- Any deviations from the brief and why

## 6. Achievement Hint Copy (mixed voice)

The locked-row hints by category. Codex puts these in the rewritten `getHint` function.

### Mechanical (concrete-action categories)

| Category | Hint format | Example |
|----------|-------------|---------|
| `level` | `reach level <levelRequired>` | `reach level 50` |
| `gamepass` | (literal) | `from the title pack` |
| `presence` | `play for <hoursRequired> hour` (singular if 1) / `play for <hoursRequired> hours` (plural otherwise) | `play for 24 hours` |
| `exploration` | `find the <zoneId-with-underscores-replaced-by-spaces>` | `find the deep cave`, `find the outside` |

### Indirect / poetic (atmospheric categories)

**Achievement category — 12 hand-written lines, ID → hint:**

| ID | Hint |
|----|------|
| `said_something` | `say something to someone` |
| `sat_down` | `the first time you rest` |
| `left_a_mark` | `leave a note behind` |
| `came_back` | `come back another time` |
| `keeps_coming_back` | `keep finding your way back` |
| `part_of_the_walls` | `be here long enough to belong` |
| `heard_them_all` | `hear every voice` |
| `knows_every_chair` | `find a different seat each time` |
| `up_too_late` | `stay until the early hours` |
| `fell_asleep_here` | `rest for a long while` |
| `one_of_us` | `join the group` |
| `day_one` | `be here from the start` |

**Seasonal category — fallback:**

| Format | Example |
|--------|---------|
| `only during certain times` | (single fallback string for all seasonal titles for now; if Tyler later wants per-title voice, this becomes a hand-written table like achievement) |

If a title doesn't match any category branch (shouldn't happen with the v2 config), fall back to `keep exploring`. Same as placeholder.

## 7. Roblox Services Involved

- `Players` — for `LocalPlayer` and PlayerGui access
- `ReplicatedStorage` — for `TitleConfig` + `TitleRemotes`
- `RunService` — Heartbeat reaper in NameTagEffectController (existing)
- `TweenService` — drawer slide, dim fade, hover effects
- `UserInputService` — ESC key listener
- `ServerScriptService` — for `TitleService` require in NameTagScript (existing)

No new services. No `MarketplaceService`, no `DataStoreService`, no `Lighting` (no blur).

## 8. Security / DataStore Notes

- ⚠️ **No new server contract.** All client-server interaction is via existing `EquipTitle` / `UnequipTitle` RemoteEvents with their existing server-side ownership re-resolution and 1s rate limit (PR #14). This brief makes no security-relevant changes.
- ⚠️ **No new persistence.** `TitleData` schema unchanged. `equippedTitle`, `ownedTitleIds`, `equippedManually`, `migratedFromV1`, `lastEquipTime` all stay.
- ⚠️ **Click-to-commit on the new drawer goes through the same handlers as the placeholder.** Spam protection from PR #14's rate limit applies to the new menu unchanged.

## 9. Boundaries (do NOT touch)

- ⚠️ `TitleService.lua` — server-side title plumbing. **Do not modify.** All server-side logic stays as PR #14 + AchievementTracker shipped it.
- ⚠️ `AchievementTracker.lua` and `AchievementTrackerInit.server.lua` — just shipped in PR #20. Don't touch.
- ⚠️ `XPBarController.client.lua` — owns the level-up + new-title combined fade. **Do not modify.** The polished menu doesn't change the unlock notification path.
- ⚠️ `TitleConfig.lua` — title data. The schema and entries stay as-is. Do not add or remove titles in this brief.
- ⚠️ `EquipTitle` / `UnequipTitle` / `TitleDataUpdated` RemoteEvents — contracts stay.
- ⚠️ The Avalog `AncestryChanged` watchdog inside `NameTagScript.server.lua` — must remain functional. The watchdog calls `ensureBillboardLayout` repeatedly; the rewritten layout function stays idempotent so this still works.
- ⚠️ `_No_Touch_Systems.md` items broadly — read it before touching anything.
- ⚠️ The kept `TitleConfig` and `TitleRemotes` instances — only delete the **stale** duplicates per Step 8. Deleting the kept ones breaks the live game.

## 10. Studio Test Checklist

Walk each item; capture result in inbox per AGENTS.md Build Loop step 5.

### Nametag visual

- [ ] Spawn into the cave — your nametag shows your title row ABOVE your name (not below).
- [ ] Title row reads at lower opacity than the name; name is the visual anchor.
- [ ] For a title with `tint` effect (e.g. `slow_steps`): title text is statically tinted with the title's color.
- [ ] For a title with `shimmer` effect: gradient ping-pongs across the title text. Looks calmer than before (lower contrast).
- [ ] For a title with `pulse` effect: brightness oscillates gently. Smaller amplitude than before.
- [ ] For a title with `glow` effect: title reads as having ambient atmosphere around it (halo / soft underglow), not a hard outline. **If the result reads as a bordered label, fall back to Option B (separate halo Frame) per Step 3.**
- [ ] Respawn — nametag rebuilds with the flipped layout. No flicker.
- [ ] Avalog test (if reachable in playtest): if Avalog destroys the BillboardGui, the watchdog recreates it with the flipped layout intact.

### Drawer open/close

- [ ] On spawn, the slim edge tab on the right is visible (semi-transparent, lowercase rotated `titles` text).
- [ ] Hover the tab — background lifts slightly + tab inches outward 4px from the edge.
- [ ] Click the tab — drawer slides in from the right over ~0.3s with `Quart Out` easing. World dims to ~75% brightness over ~0.2s. No bounce.
- [ ] Click outside the drawer (on the dimmed area) — drawer slides out over ~0.25s. Dim fades back to clear.
- [ ] Re-open. Press ESC — drawer slides out.
- [ ] Re-open. Click the small `x` inside the drawer — drawer slides out.
- [ ] Re-open. Click the edge tab again — drawer slides out.

### Drawer content

- [ ] Drawer is divided into six category sections with quiet headers: `level`, `gamepass`, `presence`, `exploration`, `achievement`, `seasonal`.
- [ ] Each section shows owned titles first, then locked titles (or only one if the player has no owned in that category).
- [ ] Currently-equipped title shows the small `wearing` caption.
- [ ] Click an owned row that's not currently equipped — server commits, your nametag updates through the dimmed view (you can see the change live), `wearing` caption moves to the new row.
- [ ] Click the currently-equipped row — server unequips, auto-equip-highest takes over, nametag updates.
- [ ] Locked row hints match the spec table in § 6:
  - Level row: `reach level <N>`
  - Gamepass row: `from the title pack`
  - Presence row: `play for <N> hours`
  - Exploration row: `find the <zone>`
  - Achievement rows: the 12 hand-written lines (e.g. `rest for a long while`, `stay until the early hours`)
  - Seasonal rows: `only during certain times`

### Mid-session unlock interaction

- [ ] With the drawer closed, level up to a milestone that unlocks a new title — XPBar shows the combined `level N — new title: X` fade for 5s. (This path is untouched; just confirming it still works.)
- [ ] With the drawer **open**, level up to a milestone that unlocks a new title — XPBar still shows the fade (visible behind the drawer through the dim). The drawer's row diff updates: the newly-unlocked title appears in the owned section of its category without a scroll-position reset.

### Studio cleanup verification

- [ ] After Step 8: only one `TitleConfig` and one `TitleRemotes` instance under `ReplicatedStorage`.
- [ ] Re-run menu open + equip + unequip after deletion — passes.
- [ ] No `[Title*]` warnings or errors in console after deletion.

### Mobile (if you can run a mobile playtest)

- [ ] Edge tab is tappable.
- [ ] Drawer slide animation runs smoothly.
- [ ] Rows are tappable. The `UISizeConstraint` keeps the drawer at min 320px wide, so rows are still readable on phone.

## 11. Rollback Notes

If the polish pass breaks things post-merge:

- **Visual rollback:** revert the merge commit. PR #14's placeholder menu and below-name nametag layout come back. No DataStore impact (nothing was migrated; nothing in `TitleData` schema changed).
- **Partial rollback (nametag only):** revert just the `NameTagScript.server.lua` and `NameTagEffectController.client.lua` changes. The polished menu stays; the nametag goes back to title-below-name. Acceptable interim state if the drawer is fine but the nametag flip reads worse than expected.
- **Studio cleanup rollback:** if the wrong `TitleConfig` was deleted, `git checkout` the Rojo source and let Rojo re-sync the kept copy. Then manually verify the duplicates are gone or recreate the deleted-correct one if Rojo can't. Worst case: a session in Studio to rebuild from `src/ReplicatedStorage/TitleConfig.lua`. Mitigated by Step 1 + Step 8's verify-before-delete protocol.
- **Drawer state stuck open:** if any close path breaks and the drawer can't be dismissed, the player can still play around it (the world is visible behind). A character respawn (`/reset`) would not reset `ResetOnSpawn=false` ScreenGuis. Quick patch would be to reload the place — extreme fallback.

The brief is small enough scope that full revert is the simplest mitigation if anything goes wrong. No data risk.

---

## Notes for Codex

- Read `02_Systems/Title_System.md` § "Polished Pass — Drawer + Title-Above-Name" first. This brief implements that section; the spec is the design rationale.
- Read `02_Systems/NameTag_Status.md` § "Polished Pass — Title-Above-Name" for the nametag implementation order.
- Read `01_Vision/Tone_and_Rules.md` before writing any UI copy. Voice rules apply.
- The placeholder controller (`src/StarterGui/TitleMenu/TitleMenuController.client.lua` as it currently exists) is a useful read for the helper-function patterns (`makeDot`, `makeTitleText`, `getHint`, `setOwnedTitleIds`, `clearRows`) — pattern-borrow what helps, but the new shape is different enough that a clean rewrite is faster than a transform.
- The `tween` from `TweenService:Create` should always have `EasingStyle.Quart` or `EasingStyle.Sine` — never `Bounce`, `Elastic`, or `Back`. Tone Rule applies.
- Animations should be slow and deliberate — 0.3s slide-in, 0.25s slide-out, 0.2s dim fade. Do not speed these up to "feel snappier" — the slow pace is the design intent.
- Studio Test Checklist § 9 expects 21 items checked. If any flag a `?`, stop and capture the issue — don't push a partial pass.
