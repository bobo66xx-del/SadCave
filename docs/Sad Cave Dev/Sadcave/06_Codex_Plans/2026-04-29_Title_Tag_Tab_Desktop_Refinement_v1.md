# Title Nametag + Edge Tab Desktop Refinement (Brief A) — Codex Plan

**Date:** 2026-04-29
**Status:** 🔵 Queued
**Branch:** `codex/title-tag-tab-desktop-refinement` *(once started)*
**Related Systems:** [[../02_Systems/Title_System]] § "Desktop Refinement Pass" · [[../02_Systems/NameTag_Status]] § "Desktop Refinement Pass"

---

## 1. Purpose

Polish-on-polish refinement to the Title v2 player-facing surface that shipped via PR #23. Two problems to solve:

1. **Desktop sizing.** Tyler's playtest of PR #23 showed the nametag (title-above-name stack) and the slim edge tab read undersized on desktop monitors while reading correctly on mobile. Bump both elements ~25-37% per axis on desktop only; mobile sizing stays unchanged.
2. **Presence-tied behaviors on the title row.** Add four refinements that tie the title to Sad Cave's "presence rewards stillness" core thesis: title fades when the viewed character is moving fast, title fades with viewer distance, the edge tab gets a notification dot when a new title unlocks, and the tab gives tactile press feedback on click.

This is one of two briefs splitting the design call. **Brief B** (deferred, no file yet) covers the medium-polish items — background-aware stroke tuning, breath between rows, hover affordance, edge anchor recess, drawer-dim while menu open. Brief B ships after Brief A merges and Tyler has played with the new sizes.

## 2. Player Experience

- On desktop, the nametag (the floating "title / name" stack above each player) reads larger and more legible — both close-up and at distance. On mobile it stays exactly as PR #23 shipped.
- On desktop, the small `titles` tab on the right edge of the screen is bigger and easier to spot. On mobile it stays unchanged.
- When you sprint or run fast, your title row fades out; when you slow down or stop for half a second, it fades back in. Your name stays visible at all times. This applies to every character you see, not just your own — anyone running through your view loses their title row, anyone sitting still keeps it.
- As you walk further from another player, their title row softens and eventually disappears at distance; their name stays visible at standard fade.
- When you unlock a new title during a session, a small soft warm dot appears near the bottom of the right-edge tab and gently pulses. It goes away when you open the menu (any way you open it).
- When you click the right-edge tab on desktop, the tab dims briefly to confirm the click before the drawer slides in.

No remote contract changes, no DataStore changes, no `TitleConfig` data changes. The visible surface is the only thing changing.

## 3. Technical Structure

- **Server responsibilities:** none new. `ServerScriptService.NameTagScript` and its `ensureBillboardLayout` keep building the BillboardGui at the existing baseline (mobile-sized) values.
- **Client responsibilities:**
  - Per-client platform detection at startup (`UserInputService.TouchEnabled and not UserInputService.MouseEnabled` — canonical project pattern from `XPBarController.client.lua`).
  - Per-client per-character size adjustment of every NameTag BillboardGui observed in `Workspace`.
  - Per-client per-character title-row transparency control combining stillness fade + distance fade with the existing effect rendering.
  - Per-client edge-tab desktop sizing.
  - Per-client edge-tab notification dot — listens for `TitleRemotes.TitleDataUpdated` and detects new entries in `OwnedTitleIds` vs the previous payload.
  - Per-client tactile press feedback on the tab (desktop only).
- **Remote events / functions:** none new. Reuses the existing `TitleRemotes.TitleDataUpdated` payload for the dot trigger.
- **DataStore keys touched:** none.

## 4. Files / Scripts

- **`src/StarterPlayer/StarterPlayerScripts/NameTagEffectController.client.lua`** — extend (or split into a sibling) to handle desktop sizing, stillness fade, and distance fade. See Step 1 for the architectural recommendation.
- **`src/StarterGui/TitlesToggleButton/TitlesToggleController.client.lua`** — extend with desktop sizing, notification dot, and tactile press feedback.
- **`src/StarterGui/TitleMenu/TitleMenuController.client.lua`** — read-only here. The menu's open/close paths fire the `OpenRequested` / `CloseRequested` BindableEvents that the tab already listens to; we use those same events to clear the dot.

**No server-side files changed.** `NameTagScript.server.lua` stays untouched. `TitleService.lua` stays untouched.

## 5. Step-by-Step Implementation (for Codex)

### Step 1 — Decide controller layout for nametag-side work

The new behaviors (sizing, stillness fade, distance fade) all touch the same TextLabels that `NameTagEffectController.client.lua` already manipulates. Two options:

- **(A) Extend `NameTagEffectController.client.lua`.** Add platform detection at top, sizing pass alongside `tryAttach`, per-character per-frame transparency multiplier loop. Cleanest if the multiplier composes well with the existing effect transparency assumptions.
- **(B) Add sibling `NameTagPresenceController.client.lua`.** Keeps effects separate from sizing/fade. Cleaner separation but requires a coordination mechanism (the fade controller writes to TextTransparency; the effect controller writes to TextColor3 — they coexist as long as fade respects effect baselines).

**Recommendation: (A), but with care.** Extending the existing controller avoids two scripts racing to write `TextTransparency` and lets baseline-transparency reads happen in the same place that sets them. If you go (B), make sure the fade controller does **not** override `TextColor3` ever — that's the effect controller's domain.

Whichever path: the per-effect baseline `TextTransparency` (currently the implicit 0.25 used at server build time) needs to be tracked explicitly so the fade can multiply onto it. Suggested: store the baseline as an attribute on the BillboardGui (`TitleBaselineTransparency` — number) when the controller attaches, then compute applied transparency as `baseline + (1.0 - baseline) * fadeAmount` where `fadeAmount` is 0..1 from the multiplied stillness * distance factors.

### Step 2 — Platform detection

Reuse the canonical pattern from `XPBarController.client.lua`:

```lua
local UserInputService = game:GetService("UserInputService")
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IS_DESKTOP = not IS_MOBILE
```

Compute once at script start. Don't re-check per frame — the input mode of the running session doesn't change.

### Step 3 — Desktop nametag sizing

In the controller chosen in Step 1, when attaching to a NameTag BillboardGui (existing `tryAttach` path or sibling):

- If `IS_DESKTOP`:
  - Set `billboard.Size = UDim2.new(0, 240, 0, 64)`
  - Set `titleLabel.TextSize = 14`
  - Set `titleLabel.Size = UDim2.new(1, 0, 0, 20)`
  - Set `titleLabel.Position = UDim2.new(0, 0, 0, 0)`
  - Set `nameLabel.TextSize = 22`
  - Set `nameLabel.Size = UDim2.new(1, 0, 0, 36)`
  - Set `nameLabel.Position = UDim2.new(0, 0, 0, 25)`
- If `IS_MOBILE`: leave the server-set baseline values alone.

`StudsOffset` and `MaxDistance` stay untouched.

**Idempotency requirement.** The server's `ensureBillboardLayout` may re-apply on respawn or watchdog rebuild. The client's sizing pass needs to re-fire whenever a fresh BillboardGui appears. The existing `Workspace.DescendantAdded` listener already handles new tags; just include sizing in the same `tryAttach` path. If the watchdog re-uses an existing BillboardGui (which `ensureBillboardLayout` does — it reuses the existing `bb` and resizes it), you may need to also listen for `BillboardGui:GetPropertyChangedSignal("Size")` and re-apply on server resize. Test the respawn case during validation.

### Step 4 — Stillness fade on the title row

Per viewed character on the local client:

- Track `lastVelocityCheckTime`, `velocityHighSince`, `velocityLowSince`, `currentFadeAmount` per character (or per BillboardGui — equivalent).
- On a Heartbeat or 30Hz timer, for each tracked BillboardGui:
  1. Read the adornee's character's `HumanoidRootPart.AssemblyLinearVelocity.Magnitude`.
  2. If magnitude > 10 stud/s: track `velocityHighSince` (set if nil, otherwise unchanged); reset `velocityLowSince = nil`.
  3. If magnitude ≤ 10 stud/s: track `velocityLowSince` (set if nil); reset `velocityHighSince = nil`.
  4. If `velocityHighSince` exists and `now - velocityHighSince ≥ 1.0`: target `stillnessFadeAmount = 1.0` (fully transparent).
  5. If `velocityLowSince` exists and `now - velocityLowSince ≥ 0.4`: target `stillnessFadeAmount = 0.0` (no fade).
- Smooth `currentStillnessFade` toward target over 0.6s using a tween or per-frame lerp.

**Edge cases:**
- Character may be nil (player respawning, joining, AvalogV2 mid-rebuild). Skip frame if `Adornee` parent or `HumanoidRootPart` is missing.
- The local player's own character: same logic applies. Title row fades on your own nametag if you sprint, returns when you stop. (Verify this feels good in playtest — if it's distracting to see your own title flicker while running, we can scope to non-local-player characters in Brief B. Default behavior: apply to all.)

### Step 5 — Distance fade on the title row

Per viewed character on the local client:

- On the same loop as stillness (10Hz is fine, no need for full Heartbeat — distance changes slowly):
  1. Compute `distance = (camera.CFrame.Position - billboard.Adornee.Position).Magnitude` (where camera is `Workspace.CurrentCamera`).
  2. Map distance to `distanceFadeAmount`:
     - `distance ≤ 40`: `0.0`
     - `40 < distance ≤ 80`: linear interpolation from `0.0` to `0.85` (so that at 80 studs, title is at multiplier 0.85)
     - `distance > 80`: `1.0` (or clamped to 1.0 at `MaxDistance` — the BillboardGui will hide entirely at `MaxDistance = 100` per its existing setting)

### Step 6 — Compose stillness + distance + effect baseline

Total title transparency this frame:

```
fadeAmount = math.min(1.0, math.max(stillnessFadeAmount, distanceFadeAmount))
            -- OR multiplicative: 1.0 - (1.0 - stillnessFadeAmount) * (1.0 - distanceFadeAmount)
            -- Pick whichever feels right; both compose without weird interactions.

appliedTransparency = baselineTransparency + (1.0 - baselineTransparency) * fadeAmount
titleLabel.TextTransparency = appliedTransparency
```

**Recommendation: multiplicative composition** — feels more natural (a far-away running player fades more than either alone) but won't over-fade past full transparency. Either works; document which you picked in inbox.

The name row stays at server baseline transparency. Optional: at distance > 80, also fade name from baseline to 0.5 — Codex's call. If included, do it the same multiplicative way and document.

### Step 7 — Desktop edge-tab sizing

In `TitlesToggleController.client.lua`:

- Reuse the same `IS_DESKTOP` pattern.
- If `IS_DESKTOP`, override the existing `button.Size = UDim2.new(0, 18, 0, 90)` to `UDim2.new(0, 24, 0, 120)`.
- Override `label.TextSize = 10` to `13`.
- Override `label.Size = UDim2.new(1, 0, 0, 60)` to `UDim2.new(1, 0, 0.67, 0)` (proportional to tab height — was offset, becomes scale).
- `TAB_RESTING_POSITION` and `TAB_HOVER_POSITION` stay the same — the 4px outward slide is a feel-thing, not a size-thing.
- All other tab properties (color, transparency, stroke, corner radius, rotation on label) stay unchanged.

### Step 8 — Notification dot on the tab

Add a child Frame on the tab that represents the unlock dot:

- `Frame` named `NotifyDot`
- `AnchorPoint = Vector2.new(0.5, 1)`
- `Position = UDim2.new(0.5, 0, 1, -8)` (8px from the bottom of the tab, horizontally centered)
- `Size = UDim2.new(0, 6, 0, 6)`
- `BackgroundColor3 = Color3.fromRGB(225, 215, 200)` (warm grey, same as the label)
- `BackgroundTransparency = 1.0` (hidden by default)
- `BorderSizePixel = 0`
- `ZIndex = 32` (above the label)
- `UICorner` child with `CornerRadius = UDim.new(1, 0)` (full radius for a circle)

Listening for unlocks:

- Wait for `ReplicatedStorage:WaitForChild("TitleRemotes"):WaitForChild("TitleDataUpdated")`.
- Track a per-session `previousOwnedSet = {}` and `firstPayloadReceived = false`.
- On each `TitleDataUpdated` payload, extract `OwnedTitleIds` (or whatever the field is named — verify against current shape):
  - If `firstPayloadReceived == false`: set `previousOwnedSet` to the payload's owned set, set `firstPayloadReceived = true`, do NOT trigger the dot.
  - Else: diff against `previousOwnedSet`. If any new ID, fire the dot show. Update `previousOwnedSet` to the new payload set.

When showing the dot:

- Tween `BackgroundTransparency` from 1.0 to 0.4 over 0.3s ease-out sine.
- Start a sustained sine pulse: ping-pong `BackgroundTransparency` between 0.2 and 0.6 over 2.5s (looped, infinite).

When clearing the dot:

- Listen for `OpenRequested:Fire()` from the tab's own click path AND for any other `TitleMenu` ScreenGui's `OpenRequested.Event` (e.g. future hotkey).
- Cancel the sustained pulse tween.
- Fade `BackgroundTransparency` from current to 1.0 over 0.4s ease-out sine.

**Edge case:** if the menu is already open when an unlock fires, the dot still triggers. The user opens the menu next time → dot clears as expected. (If you want to clear immediately when an unlock fires while menu is open, that's a small extra case; default behavior is the simpler always-trigger-then-clear-on-next-open.)

### Step 9 — Tactile press feedback on tab

In `TitlesToggleController.client.lua`:

- Add `MouseButton1Down` and `MouseButton1Up` handlers (in addition to the existing `MouseButton1Click`):
  - On `MouseButton1Down`: `TweenService:Create(button, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 }):Play()`
  - On `MouseButton1Up`: tween back to either `0.15` (if mouse is still inside button — hover state) or `0.25` (if mouse left — resting state). Track the hover state with the existing `MouseEnter`/`MouseLeave` handlers, e.g. a `hovering` boolean.

**Mobile gap is intentional.** Mobile uses `Activated` for the click via the implicit handling — no down/up dim. Acceptable for Brief A.

### Step 10 — Verify and playtest

Run a Studio playtest covering the Test Checklist below. Do all of these in the same playtest if possible — they exercise overlapping paths.

## 6. Roblox Services Involved

`UserInputService`, `Workspace`, `Players`, `RunService`, `TweenService`, `ReplicatedStorage`. No `DataStoreService` involvement. No `Lighting`. No `MarketplaceService`.

## 7. Security / DataStore Notes

- ⚠️ Validation: not applicable — no remote events fired with user-supplied data. Reads from `TitleRemotes.TitleDataUpdated` are server-authoritative; client just observes.
- ⚠️ DataStore retry/pcall: not applicable — no DataStore writes.
- ⚠️ Rate limits: not applicable — local-only computation.

## 8. Boundaries (do NOT touch)

- `src/ServerScriptService/NameTagScript.server.lua` — stays exactly as-is. No layout changes server-side.
- `src/ServerScriptService/TitleService.lua` — no changes.
- `src/ServerScriptService/TitleServiceInit.server.lua` — no changes.
- `src/ReplicatedStorage/TitleConfig.lua` — no data changes.
- `src/ReplicatedStorage/TitleRemotes/*` — no contract changes.
- `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua` — unrelated.
- `src/StarterPlayer/StarterPlayerScripts/AchievementClient.client.lua` — unrelated.
- All `02_Systems/_No_Touch_Systems.md` entries — unrelated.

If your work touches anything outside `NameTagEffectController.client.lua` and `TitlesToggleController.client.lua` (other than read-only references and adding a sibling controller file if you take Step 1's option B), flag in inbox before proceeding.

## 9. Studio Test Checklist

### Sizing
- [ ] On desktop: nametag BillboardGui is visibly bigger than mobile. Title text reads cleanly at normal third-person distance and at 30+ studs.
- [ ] On desktop: edge tab is visibly bigger; "titles" rotated text is readable, not squinty.
- [ ] On mobile (or via a `TouchEnabled` simulation): nametag and tab match PR #23 baseline values exactly. No desktop bumps applied.
- [ ] Respawn (kill yourself or use Roblox's reset) → nametag re-appears at the same desktop-bumped sizes (sizing controller re-fired correctly).
- [ ] Multi-player: spawn a second player (Studio playtest with 2 players) → both see each other's nametags sized for their own platform.

### Stillness fade
- [ ] Stand still next to another player. Their title is visible at baseline transparency.
- [ ] Sprint past another player (or have them sprint past you). Title row fades out within ~1 second.
- [ ] Stop. Title row fades back in within ~0.4 second.
- [ ] Brief pause-and-go (stop for 0.2s, then walk again) does NOT trigger the fade-in — biased toward presence.
- [ ] Your own title row fades when you sprint and returns when you stop. (If this feels distracting, flag with `?` — we can scope-out local-player in Brief B.)

### Distance fade
- [ ] Walk 30 studs from a player → title row at baseline.
- [ ] Walk to ~60 studs → title row noticeably softer.
- [ ] Walk to ~90 studs → title row almost gone, name still visible.
- [ ] Walk past 100 studs → BillboardGui itself disappears (existing `MaxDistance` behavior, unchanged).
- [ ] Composition with stillness: a far-away running player has a title that's both faded by distance AND fade-out by stillness — should look fully gone, not a half-state.

### Notification dot
- [ ] First payload on join: no dot (dot is hidden after the first `TitleDataUpdated`).
- [ ] Trigger a title unlock during the session (level up across a milestone, or — if you're testing without level grind — manually grant via attaching to a known unlock path). Dot appears near the bottom of the tab and pulses.
- [ ] Open the menu via the tab → dot fades to invisible within 0.4s.
- [ ] Open and close the menu → dot stays invisible (it was already cleared).
- [ ] Trigger another unlock → dot reappears.

### Tactile press
- [ ] Click and hold the tab on desktop → tab visibly dims to deeper opacity within 50ms.
- [ ] Release the click → tab returns to hover or resting state depending on cursor position.
- [ ] Mobile (touch device or simulation): no down/up dim — tap still works to open menu, no visual press feedback. (Acceptable.)

### General regression
- [ ] All four close paths still work (click outside drawer, ESC, internal `x`, re-click tab).
- [ ] All four effects (`tint`/`shimmer`/`pulse`/`glow`) still render correctly on the title row.
- [ ] Drawer slide animation unchanged (0.3s `Quart Out` open, 0.25s `Quart In` close).
- [ ] Six category sections render in order with correct rows.
- [ ] `wearing` caption still appears on the equipped row.
- [ ] No new console errors. Console clean to `[NameTag] script ready` / `[TitleService] script ready` / any normal `[FavoritePrompt]` lines.

## 10. Rollback Notes

This brief is purely additive UI — no server contract changes, no DataStore writes, no migration. Rollback is a single git revert of the merge commit. After revert:

- Sizing returns to PR #23 baseline (mobile-matching values applied for everyone).
- Stillness/distance fades disappear; title row stays at constant baseline transparency.
- Notification dot disappears; tab gets no signal on unlock.
- Tactile press feedback disappears; click works as before.

No DataStore data lingers because nothing was persisted. No remote events to clean up because none were added.

If a single behavior is misbehaving (e.g. stillness fade flickering), the cleaner rollback is a follow-up commit reverting that specific block in the controller, not a full revert — the other behaviors stand on their own.
