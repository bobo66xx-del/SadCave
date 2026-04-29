# Title Nametag + Edge Tab Desktop Refinement (Brief A) — Codex Plan

**Date:** 2026-04-29 (Iteration 1: 2026-04-29 review feedback merged into spec)
**Status:** 🟢 Shipped — PR #25 merged 2026-04-29 14:01:58 UTC, branch `codex/title-tag-tab-desktop-refinement`, head `9bca238`. Same-branch two-iteration loop: initial commit `4aef1de` matched the original brief (Claude review "safe to merge"); Tyler reviewed live and asked for tuning; iteration-1 commit `9bca238` incorporated five deltas (proportional size bump, 2.0s stillness threshold, halved distance + halved MaxDistance, tab fade-out-on-open, per-row menu dots); both reviews ran clean.
**Branch:** `codex/title-tag-tab-desktop-refinement` (merged)
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

- **`src/StarterPlayer/StarterPlayerScripts/NameTagEffectController.client.lua`** — handles desktop sizing, stillness fade, distance fade, and the new MaxDistance client-side override (Iteration 1).
- **`src/StarterGui/TitlesToggleButton/TitlesToggleController.client.lua`** — handles desktop sizing, notification dot, tactile press feedback, and the new tab fade-out-on-open behavior (Iteration 1).
- **`src/StarterGui/TitleMenu/TitleMenuController.client.lua`** — Iteration 1 adds per-row notification dots that mirror the tab dot pattern, plus listening for `OpenRequested` / `CloseRequested` to gate the clear-on-close behavior.

**No server-side files changed.** `NameTagScript.server.lua` stays untouched. `TitleService.lua` stays untouched. The MaxDistance halving is a client-side property override (BillboardGui properties are local to each client).

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

### Step 3 — Desktop nametag sizing (Iteration 1: proportional bump up)

In the controller chosen in Step 1, when attaching to a NameTag BillboardGui (existing `tryAttach` path):

- If `IS_DESKTOP`:
  - Set `billboard.Size = UDim2.new(0, 280, 0, 80)`
  - Set `titleLabel.TextSize = 16`
  - Set `titleLabel.Size = UDim2.new(1, 0, 0, 22)`
  - Set `titleLabel.Position = UDim2.new(0, 0, 0, 0)`
  - Set `nameLabel.TextSize = 25`
  - Set `nameLabel.Size = UDim2.new(1, 0, 0, 41)`
  - Set `nameLabel.Position = UDim2.new(0, 0, 0, 28)`
- If `IS_MOBILE`: leave the server-set baseline values alone.

`StudsOffset` stays untouched. **`MaxDistance` is set to 50 on every NameTag (both platforms) — see Step 5b.**

**Idempotency requirement.** The server's `ensureBillboardLayout` may re-apply on respawn or watchdog rebuild. The client's sizing pass needs to re-fire whenever a fresh BillboardGui appears. The existing `Workspace.DescendantAdded` listener already handles new tags; just include sizing in the same `tryAttach` path. If the watchdog re-uses an existing BillboardGui (which `ensureBillboardLayout` does — it reuses the existing `bb` and resizes it), you may need to also listen for `BillboardGui:GetPropertyChangedSignal("Size")` and re-apply on server resize. Test the respawn case during validation.

### Step 4 — Stillness fade on the title row (Iteration 1: longer running threshold)

Per viewed character on the local client:

- Track `velocityHighSince`, `velocityLowSince`, `currentStillnessFade`, `targetStillnessFade` per character (or per BillboardGui — equivalent).
- On Heartbeat, for each tracked BillboardGui:
  1. Read the adornee's character's `HumanoidRootPart.AssemblyLinearVelocity.Magnitude`.
  2. If magnitude > 10 stud/s: track `velocityHighSince` (set if nil, otherwise unchanged); reset `velocityLowSince = nil`.
  3. If magnitude ≤ 10 stud/s: track `velocityLowSince` (set if nil); reset `velocityHighSince = nil`.
  4. If `velocityHighSince` exists and `now - velocityHighSince ≥ 2.0` *(Iteration 1: was 1.0)*: target `stillnessFadeAmount = 1.0` (fully transparent).
  5. If `velocityLowSince` exists and `now - velocityLowSince ≥ 0.4`: target `stillnessFadeAmount = 0.0` (no fade).
- Smooth `currentStillnessFade` toward target over 0.6s using `moveToward` with `dt / STILLNESS_FADE_TIME` step.

The asymmetric thresholds (2.0s out, 0.4s back) are deliberately biased toward presence: you have to actually run sustained — not just walk briskly across an area — before the title commits to fading; but a brief stop returns it quickly. Per Iteration 1, the bar moved up because the original 1.0s felt too aggressive in playtest (title was fading during normal traversal pauses, not just sustained running).

**Edge cases:**
- Character may be nil (player respawning, joining, AvalogV2 mid-rebuild). Skip frame if `Adornee` parent or `HumanoidRootPart` is missing.
- The local player's own character: same logic applies. Title row fades on your own nametag if you sprint, returns when you stop. (Verify this feels good in playtest — if it's distracting to see your own title flicker while running, we can scope to non-local-player characters in Brief B. Default behavior: apply to all.)

### Step 5 — Distance fade on the title row

Per viewed character on the local client. **Iteration 1: thresholds halved + the BillboardGui's `MaxDistance` itself drops 100→50 (client-side override) so the whole tag disappears sooner.**

- On Heartbeat (or 10Hz):
  1. Compute `distance = (camera.CFrame.Position - billboard.Adornee.Position).Magnitude` (where camera is `Workspace.CurrentCamera`).
  2. Map distance to `distanceFadeAmount`:
     - `distance ≤ 20` *(was 40)*: `0.0`
     - `20 < distance ≤ 40` *(was 40-80)*: linear interpolation from `0.0` to `0.85`
     - `distance > 40` *(was >80)*: `1.0` (clamped) — but the BillboardGui itself disappears at `MaxDistance = 50` so the tag is gone by then anyway

### Step 5b — MaxDistance client-side override (Iteration 1: new)

When the controller attaches to a NameTag BillboardGui, override `MaxDistance` from the server's 100 → **50**. This applies on **both platforms** (mobile and desktop), not gated on `IS_DESKTOP`. BillboardGui properties are local to each client, so writing the override doesn't affect server state — it just changes what the local client sees.

Add the property listener so a server-side `ensureBillboardLayout` re-application doesn't reset it: listen to `billboard:GetPropertyChangedSignal("MaxDistance")` and re-write 50 if the property is observed at any value other than 50.

The combined effect: tags fade out gradually starting at 20 studs, fully invisible by 40 studs, and the BillboardGui itself stops rendering at 50 studs. Tyler's framing: "presence has a tighter range" — tags shouldn't show up from across the cave.

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
- If `IS_DESKTOP`, set `button.Size = UDim2.new(0, 24, 0, 120)` (vs mobile `(0, 18, 0, 90)`).
- Set `label.TextSize = 13` (vs mobile `10`).
- Set `label.Size = UDim2.new(1, 0, 0.67, 0)` (proportional to tab height — was offset on mobile).
- `TAB_RESTING_POSITION` and `TAB_HOVER_POSITION` stay the same — the 4px outward slide is a feel-thing, not a size-thing.
- All other tab properties (color, transparency, stroke, corner radius, rotation on label) stay unchanged.

**Iteration 1 leaves these values unchanged** — the desktop tab sizing already reads correctly per Tyler's review. The new tab behavior is hide-on-open (Step 8b).

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

### Step 8b — Tab fade-out when drawer opens, fade-in when it closes (Iteration 1: new)

Tyler's review feedback: the tab should disappear while the drawer is open, reappear when it closes. This drops the "re-click the tab to close" path — three close paths remain (click outside, ESC, internal `x`). Tyler explicitly accepted this trade in the iteration discussion.

In `TitlesToggleController.client.lua`:

- Track tab visibility state alongside the existing `isOpen` state.
- On `OpenRequested.Event`:
  - Existing: `isOpen = true; clearNotifyDot()`.
  - **New**: tween the tab `BackgroundTransparency` to 1.0 (fully transparent) and the label `TextTransparency` to 1.0, both over 0.2s ease-out sine. This duration is intentionally similar to the drawer's 0.3s slide-in so the two read as cross-fading. Also tween `UIStroke.Transparency` to 1.0 and `notifyDot.BackgroundTransparency` to 1.0 (so all visual elements of the tab fade together — though if the dot was visible, it gets cleared by `clearNotifyDot` already firing on open).
  - Disable tab's interactivity by setting `button.Active = false` (and/or `button.AutoButtonColor = false`, already set) so an accidental click on its invisible position doesn't fire.
- On `CloseRequested.Event`:
  - Existing: `isOpen = false`.
  - **New**: tween the tab + label + stroke transparencies back to their resting values (button background 0.25, label TextTransparency 0.4, stroke 0.82) over 0.25s ease-out sine. Set `button.Active = true` after the tween starts (so the player can click again immediately, even if the visual hasn't fully resolved).
- The fallback `fallbackDirectToggle` path also needs to apply the same tab visibility transitions when it flips `Root.Visible`.

**Edge case:** if `OpenRequested` fires while the tab is mid-fade-back (e.g., quick open-close-open), cancel the in-flight fade-back and start a fresh fade-out from the current state. Don't snap to a target. Use `TweenService` cancellation pattern: store the most recent `tabVisibilityTween` reference and cancel it before starting a new one.

**Hover/press during transitions:** while `isOpen == true`, the hover/press handlers should no-op (don't tween the tab back to a hover state — it's supposed to be invisible). Existing `MouseEnter`/`MouseLeave`/`MouseButton1Down`/`Up` handlers should add an `if isOpen then return end` guard at the top.

### Step 9 — Tactile press feedback on tab

In `TitlesToggleController.client.lua`:

- Add `MouseButton1Down` and `MouseButton1Up` handlers (in addition to the existing `MouseButton1Click`):
  - On `MouseButton1Down`: `TweenService:Create(button, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 }):Play()`
  - On `MouseButton1Up`: tween back to either `0.15` (if mouse is still inside button — hover state) or `0.25` (if mouse left — resting state). Track the hover state with the existing `MouseEnter`/`MouseLeave` handlers, e.g. a `hovering` boolean.

**Mobile gap is intentional.** Mobile uses `Activated` for the click via the implicit handling — no down/up dim. Acceptable for Brief A.

### Step 9b — Per-row notification dots in the TitleMenu (Iteration 1: new)

Tyler's review feedback: in addition to the dot on the tab, show a dot next to each unlocked title row in the menu so the player knows specifically *which* titles are new. Same warm-grey treatment as the tab dot, smaller scale to fit the row layout.

This work lives in `src/StarterGui/TitleMenu/TitleMenuController.client.lua`.

**State to track:**

- `unlockedThisSession = {}` — set of title IDs that unlocked during this session, as observed via `TitleDataUpdated` payload diffs against the previous payload's `OwnedTitleIds`.
- `dotsClearedFromMenu = {}` — set of title IDs whose menu-row dot has been cleared (so we don't re-show after the player has seen + closed the menu).

**Detect unlocks:**

- The TitleMenu controller already listens to `TitleRemotes.TitleDataUpdated` — extend the existing handler. Apply the same pattern as the tab controller: track `firstPayloadReceived` boolean, on first payload set the baseline silently, on subsequent payloads diff for new IDs and add them to `unlockedThisSession`.

**Render dots on rows:**

- For each owned-title row, when rendering, check whether `unlockedThisSession[titleId] == true and dotsClearedFromMenu[titleId] ~= true`. If yes, attach a small circular Frame to that row.
- Dot Frame name: `RowNotifyDot`, child of the row's TextButton/Frame.
- `Size = UDim2.new(0, 4, 0, 4)` (slightly smaller than the tab dot's 6×6 — the row is denser than the tab area).
- `BackgroundColor3 = Color3.fromRGB(225, 215, 200)` (warm grey, matching the tab dot).
- `AnchorPoint = Vector2.new(1, 0.5)`.
- `Position = UDim2.new(1, -10, 0.5, 0)` (10px from the right edge of the row, vertically centered).
- `BackgroundTransparency` pulses between 0.2 and 0.6 over a 2.5s sine cycle (matching the tab dot pulse).
- `BorderSizePixel = 0`.
- `ZIndex` one above the row's normal content.
- `UICorner` child with `CornerRadius = UDim.new(1, 0)` (full radius for circle).
- The dot does NOT replace any existing visual (the `wearing` caption, the per-title `tintColor` reading on text, etc.). It coexists.

**Row layout consideration:** the existing locked-row hint text is right-aligned in the row at ~14px from the right edge. The dot at `(1, -10, 0.5, 0)` would overlap that. **Critical**: only owned (unlocked) rows show dots — the locked rows showing hint text are by definition NOT in `unlockedThisSession`, so this collision can't happen. Sanity-check during build that `unlockedThisSession` only contains IDs the player owns.

**Clear-on-close behavior (Tyler's Option A):**

- The dots stay visible the entire time the menu is open — so the player actually sees them while browsing.
- When the menu closes after being open with dots visible: for every titleId in `unlockedThisSession`, set `dotsClearedFromMenu[titleId] = true` (mark as seen). The dots fade out via the same 0.4s ease-out sine pattern as the tab dot, then are destroyed.
- Listen on `CloseRequested.Event`. Iterate the dots, fade them out, mark cleared. Don't clear `unlockedThisSession` itself — the row diffing still uses it for "is this a freshly unlocked row." Just mark `dotsClearedFromMenu`.
- If a new title unlocks AFTER the player has closed the menu (next session-event), the dot appears for that new title only. The previously-seen titles stay clear.

**Edge case — title unlocks while menu is already open:** the row gets a dot in real-time (since the row diffing on `TitleDataUpdated` already triggers re-rendering of newly-owned rows per the polished pass build). Dot appears, pulses, clears on next close.

**Edge case — equipping a title with a dot:** the dot doesn't auto-clear on equip; it clears only on menu close. The player can equip a new title and still see its dot until they close. Acceptable per the design (the dot says "this is new this session," not "you haven't equipped it").

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

If your work touches anything outside `NameTagEffectController.client.lua`, `TitlesToggleController.client.lua`, and `TitleMenuController.client.lua` (other than read-only references), flag in inbox before proceeding.

## 9. Studio Test Checklist

### Sizing (Iteration 1: bigger desktop bumps)
- [ ] On desktop: nametag BillboardGui is visibly bigger than mobile (BillboardGui Size 280×80, title 16pt, name 25pt). Title text reads cleanly at normal third-person distance and at 30+ studs.
- [ ] On desktop: edge tab is visibly bigger (24×120, label 13pt); "titles" rotated text is readable, not squinty.
- [ ] On mobile (or via a `TouchEnabled` simulation): nametag and tab match PR #23 baseline values exactly. No desktop bumps applied.
- [ ] Respawn (kill yourself or use Roblox's reset) → nametag re-appears at the same desktop-bumped sizes (sizing controller re-fired correctly).
- [ ] Multi-player: spawn a second player (Studio playtest with 2 players) → both see each other's nametags sized for their own platform.

### Stillness fade (Iteration 1: longer running threshold)
- [ ] Stand still next to another player. Their title is visible at baseline transparency.
- [ ] Sprint past another player. Title row fades out only after ~2 seconds of sustained running (was ~1s pre-iteration).
- [ ] Walk briskly across a small area then stop — title should NOT fade out (you weren't sustained-running for 2 seconds).
- [ ] Stop after fade-out. Title row fades back in within ~0.4 second.
- [ ] Brief pause-and-go (stop for 0.2s, then walk again) does NOT trigger the fade-in — biased toward presence.
- [ ] Your own title row fades when you sprint sustained and returns when you stop. (If this feels distracting, flag with `?` — we can scope-out local-player in Brief B.)

### Distance fade (Iteration 1: halved distances + halved MaxDistance)
- [ ] Walk 10 studs from a player → title row at baseline (full visibility).
- [ ] Walk to ~30 studs → title row noticeably softer.
- [ ] Walk to ~45 studs → title row almost gone, name still visible.
- [ ] Walk past 50 studs → BillboardGui itself disappears (`MaxDistance = 50` from the new client-side override).
- [ ] Verify on second player too — both clients see their own version of the new MaxDistance, which matches.
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

### Tab fade-out-on-open (Iteration 1: new)
- [ ] Click the edge tab → drawer slides in AND tab fades to invisible at roughly the same pace.
- [ ] While drawer is open: hover the area where the tab used to be → no hover/press visual response (handlers are gated by `isOpen`).
- [ ] Click outside drawer → drawer slides out AND tab fades back to its resting state.
- [ ] ESC while drawer is open → same as above.
- [ ] Internal `x` close button → same as above.
- [ ] Re-click-the-tab close path is GONE (intentional — Tyler accepted this in iteration discussion).
- [ ] Quick open-close-open sequence: visual transitions cancel cleanly without snapping.

### Per-row notification dots in menu (Iteration 1: new)
- [ ] Trigger a title unlock during the session.
- [ ] Open the menu → tab dot clears, but the row for that newly-unlocked title in the menu shows a small warm-grey pulsing dot near its right edge.
- [ ] Browse — dot stays visible for the entire time the menu is open.
- [ ] Close the menu → dot fades out and stays cleared.
- [ ] Re-open the menu later → no dot for that title (already cleared).
- [ ] Trigger a SECOND unlock → tab dot reappears, and on opening the menu the new title's row shows a fresh dot (the previously-cleared one stays clean).
- [ ] Title that's already owned at session start: no dot ever (only triggers on session-time diffs).
- [ ] Locked rows in the menu: never get dots (only owned rows do).

### General regression
- [ ] Three close paths work (click outside drawer, ESC, internal `x`). Re-click-tab path is gone — confirm no visual artifact when trying to click where the (now invisible) tab is.
- [ ] All four effects (`tint`/`shimmer`/`pulse`/`glow`) still render correctly on the title row.
- [ ] Drawer slide animation unchanged (0.3s `Quart Out` open, 0.25s `Quart In` close).
- [ ] Six category sections render in order with correct rows.
- [ ] `wearing` caption still appears on the equipped row, separate from any notification dot.
- [ ] No new console errors. Console clean to `[NameTag] script ready` / `[TitleService] script ready` / any normal `[FavoritePrompt]` lines.

## 10. Rollback Notes

This brief is purely additive UI — no server contract changes, no DataStore writes, no migration. Rollback is a single git revert of the merge commit. After revert:

- Sizing returns to PR #23 baseline (mobile-matching values applied for everyone).
- Stillness/distance fades disappear; title row stays at constant baseline transparency.
- Notification dots (tab + menu rows) disappear; menu and tab get no signal on unlock.
- Tactile press feedback disappears; click works as before.
- Tab stays visible while drawer is open; re-click-tab close path returns.
- BillboardGui MaxDistance returns to server's 100 (tags visible from further away again).

No DataStore data lingers because nothing was persisted. No remote events to clean up because none were added.

If a single behavior is misbehaving (e.g. stillness fade flickering), the cleaner rollback is a follow-up commit reverting that specific block in the controller, not a full revert — the other behaviors stand on their own.

---

## Iteration 1 — Review Feedback (2026-04-29)

This section is the change log for iteration 1: what changed and why, captured for both Codex (so the reasoning travels with the spec) and the eventual change-log entry.

**Trigger:** Codex's first push (`4aef1de`) shipped clean against the brief's original values; Claude's review verdict was "safe to merge." Tyler reviewed the live state in Studio and asked for adjustments before merge — the body of the brief above has been amended with the iteration-1 final values.

**Deltas:**

1. **Desktop nametag size — Option A proportional bump.** Title 14→16, name 22→25, BillboardGui 240×64 → 280×80. Why: Tyler's playtest showed the nametag still reads small at distance even after the first bump. Proportional preserves the title-as-epigraph proportions; bumping just the title (Option B) would have made the title louder relative to the name, which isn't the design.
2. **Stillness threshold 1.0s → 2.0s.** Why: Tyler reported the title was fading during normal traversal pauses, not just sustained running. Doubling the threshold biases the fade-trigger toward "actually running" rather than "walked briskly for one second." Restore-on-stop stays at 0.4s (asymmetric bias toward presence is preserved).
3. **Distance fade halved + MaxDistance halved.** Bands move from 40-80-100 to 20-40-50; the BillboardGui's `MaxDistance` itself drops 100→50 via a client-side override on the new tag controller. Why: Tyler said tags were showing up "pretty far" — the polished pass is supposed to read as "presence has a tighter range," and 100-stud visibility didn't match the design intent. Combined with the size bump, this creates a "bigger nearby, gone sooner at distance" tradeoff that's coherent with the tone.
4. **Tab fade-out when drawer opens, fade-in when closes.** Drops the re-click-tab close path (Tyler accepted this). Why: visual cleanup — the tab is redundant while the drawer is open, and a fading element matches the drawer's slide-in/out rhythm better than a static persistent tab. Three close paths (outside-click, ESC, internal `x`) remain.
5. **Per-row notification dots in TitleMenu, clear on close.** Adds `TitleMenuController.client.lua` to the brief's scope. Mirrors the tab dot pattern with smaller geometry (4×4 vs 6×6). Why: tab dot says "you have new things"; menu dots say "specifically these new things." Tyler said the tab dot was working visually so the per-row extension is the natural next step. Clear-on-close (Option A) chosen over clear-on-open (which would flash the dots invisible during the 0.3s open animation — player wouldn't see them) and clear-on-equip (which would be too sticky).

**Held / not in iteration 1:** still no tracking adjustment on title text, still no first-time tab pulse. Both deferred per the original brief's "held" list.

**Same branch.** Codex iterates on `codex/title-tag-tab-desktop-refinement` with a follow-up commit. Same review cycle, single eventual merge.
