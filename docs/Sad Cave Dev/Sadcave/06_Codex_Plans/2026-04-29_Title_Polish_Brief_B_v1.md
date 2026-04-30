# Title Nametag + Edge Tab Polish (Brief B) — Codex Plan

**Date:** 2026-04-29
**Status:** 🟢 Shipped — PR #27 merged 2026-04-30 04:38:32 UTC, branch `codex/title-polish-brief-b`, head `d3c6958`. Codex pushed in one shot, no iterations. Claude review verdict was "looks good with two flags" — both flagged items were one-line revertable visual quirks, not blocking. Tyler accepted the trade and merged. Carry-forwards parked in inbox: (1) Step 0 bright-background test was skipped, stroke shipped at 0.5 unconditionally — effectively moot once Aura Pass cushion lands as the legibility solution; (2) edge recess fades preemptively with tab on drawer open — unnecessary motion (drawer fully occludes recess), one-line revert in any future polish touch on `TitlesToggleController.client.lua`.
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/title-polish-brief-b` (merged)
**Related Systems:** [[../02_Systems/Title_System]] § "Desktop Refinement Pass" → "Brief B" · [[../02_Systems/NameTag_Status]]

---

## 1. Purpose

Second of two briefs splitting the polished-pass design call (PR #23). **Brief A** shipped via PR #25 (2026-04-29 14:01 UTC) — desktop sizing, stillness fade, distance fade, tab notification dot, per-row menu dots, tactile press, tab fade-out-on-open. **Brief B** (this file) is the medium-polish bundle that ships after Brief A so its outcomes are informed by real-play feel.

Four items land in this brief. Each is independently small; together they tighten the visual surface another notch without changing the core architecture. No server changes, no remote contract changes, no DataStore writes.

**Originally a five-item bundle** — the fifth item (drawer-dim while menu open) is dropped. Brief A iteration 1 added "tab fade-out when drawer opens" which goes further than dim — the tab goes fully invisible while the drawer is open. Item #5 is now obsolete and noted as such in § "Out of scope" below.

## 2. Player Experience

- Title text on the nametag stays legible against bright backgrounds (sky, grass, sunlit walls). Currently the warm-grey title can wash out over high-luminance scenes; a stroke tightening keeps the text readable without making it loud.
- The breathing gap between the title row and the name row reads a touch more generous on mobile. (Desktop's gap already widened naturally with the size bump in Brief A.)
- The desktop edge tab gives a clearer hover signal — the rotated `titles` text gets slightly more present when the cursor is over it. Adds to the existing 4px outward slide.
- The edge tab feels anchored to the screen edge instead of floating against it. A thin recessed strip behind the tab where it meets the right edge gives it visual weight without making it loud.

No interaction model changes. No new menus. No new remotes. The visible polish layer only.

## 3. Technical Structure

- **Server responsibilities:** none new. `ServerScriptService.NameTagScript` and its `ensureBillboardLayout` keep building the BillboardGui at the existing baseline (mobile-sized) values. Brief B's mobile gap-widen (item 2) might justify a small server-side layout tweak; see Step 2 for the discussion.
- **Client responsibilities:**
  - Tighten title `TextStrokeTransparency` (item 1) — applied at attach time alongside Brief A's sizing pass.
  - Adjust mobile-only label heights / positions to widen the gap (item 2) — applied client-side with a `IS_MOBILE` gate, mirroring Brief A's `IS_DESKTOP` gate pattern.
  - Extend hover behavior on the edge tab (item 3) — adds a label transparency tween to the existing hover slide.
  - Add the recess strip behind the edge tab (item 4) — a sibling Frame to the existing tab button, anchored to the screen edge.
- **Remote events / functions:** none new.
- **DataStore keys touched:** none.

## 4. Files / Scripts

- **`src/StarterPlayer/StarterPlayerScripts/NameTagEffectController.client.lua`** — items 1 and 2. Already touched by Brief A (sizing, fades, MaxDistance override). Brief B extends the same `tryAttach` path with the stroke and gap adjustments.
- **`src/StarterGui/TitlesToggleButton/TitlesToggleController.client.lua`** — items 3 and 4. Already touched by Brief A (sizing, dot, tactile press, fade-out-on-open). Brief B extends with the hover-affordance label tween and the recess strip Frame.

**No server-side files changed.** `NameTagScript.server.lua` stays untouched. `TitleService.lua` stays untouched. `TitleConfig.lua` stays untouched. `TitleRemotes/*` stays untouched.

If Codex finds that item 1 (stroke) needs server-side coordination (e.g. the stroke should be set at server build time so Studio's preview renders it), flag in inbox before extending scope.

## 5. Step-by-Step Implementation (for Codex)

### Step 0 — Test first whether item 1 is even needed

Brief A iteration 1 bumped the title from 14pt to 16pt. The "title gets eaten on bright backgrounds" complaint that originated this item was observed at 14pt, possibly even at the smaller pre-Brief-A 11pt. **The bigger 16pt text may have already resolved it.**

Walk through the existing testing-place areas (cave interior, near the entrance with sky visible, near the grassy outside if accessible) with the live build. Capture two screenshots:

- Title against the cave interior dark backdrop (control)
- Title against the brightest area available in the testing place

If the title reads legibly in both, **drop item 1** and note in the inbox: `[C] HH:MM — Item 1 dropped: 16pt title reads legibly against bright backgrounds in [areas tested].` Skip Step 1 entirely.

If the title still gets eaten on bright backgrounds, proceed with Step 1 below.

### Step 1 — Background-aware stroke tuning on the title row (conditional, see Step 0)

Two implementation paths:

- **(A) Tighten `TextStrokeTransparency` only.** The TitleLabel currently has `TextStrokeTransparency = 0.7` (set server-side in `NameTagScript.server.lua` `ensureBillboardLayout`). A client-side override to 0.5 inside `NameTagEffectController.client.lua`'s `tryAttach` is the minimal change. Don't touch the server file. Mirror the override pattern Brief A used for `MaxDistance` — apply on attach, listen for the property change signal in case the server resets it.
- **(B) Replace `TextStrokeTransparency` with a `UIStroke`.** Finer control (color, thickness, ApplyStrokeMode separately). Costs adding a child to the TitleLabel. More invasive than (A).

**Recommendation: (A) — start with the client-side override of `TextStrokeTransparency` from 0.7 to 0.5.** If Codex's playtest still shows the title getting eaten with the override applied, fall back to (B) and document why in inbox. (A) costs ~3 lines; (B) costs ~10 lines plus a UIStroke instance.

Mobile vs desktop: the issue is background luminance, not platform. Apply on both. No `IS_DESKTOP` gate.

### Step 2 — Breath between rows (mobile-only adjustment)

Brief A's desktop sizing already widened the gap on desktop (title bottom y=22, name top y=28, so ~6px gap, up from the mobile baseline of 3px). Mobile is still at the original tight 3px gap. Item 2 widens the mobile gap to ~5px to match the desktop's natural breathing.

In `NameTagEffectController.client.lua`, in the `tryAttach` branch where `IS_MOBILE` (not `IS_DESKTOP`):

- Set `titleLabel.Size = UDim2.new(1, 0, 0, 16)` *(unchanged from server's value of 16, kept explicit)*
- Set `titleLabel.Position = UDim2.new(0, 0, 0, 0)` *(unchanged)*
- Set `nameLabel.Position = UDim2.new(0, 0, 0, 21)` *(was server's 19 → bump to 21 = ~5px gap)*
- BillboardGui Size stays at server's `(0, 200, 0, 50)` — the name still fits because the name's `Size.Y.Offset` of 28 + position 21 = 49, just inside the BillboardGui's 50px height.

**Alternative server-side path:** if Codex prefers, this could go in `NameTagScript.server.lua` `ensureBillboardLayout` directly — server-side baseline shifts. That's cleaner architecturally but adds a server-file edit to a brief that's otherwise client-only. Default: client-side override, matching Brief A's pattern. Flag in inbox if Codex finds the server-side path lands cleaner.

**Idempotency:** reuse the existing `BillboardGui:GetPropertyChangedSignal("Size")` listener Brief A added (or add a per-label position change listener) so a server respawn re-application doesn't reset the gap. Test the respawn case during validation.

### Step 3 — Hover affordance on the desktop tab

In `TitlesToggleController.client.lua`, extend the existing `MouseEnter` / `MouseLeave` handlers (which currently slide the tab outward by 4px and bump background opacity from 0.25 → 0.15):

- On `MouseEnter` (when not `isOpen`): tween `label.TextTransparency` from current to 0.2 over 0.15s ease-out sine. (Resting state is 0.4.)
- On `MouseLeave` (when not `isOpen`): tween `label.TextTransparency` back to 0.4 over 0.2s ease-out sine.
- The `isOpen` gate Brief A added stays — no hover response while drawer is open.

This is purely additive on top of Brief A's tab behavior. The existing slide and background tween still fire — item 3 just adds the label tween.

Mobile: no hover model. No-op for mobile, gate behind `IS_DESKTOP`.

### Step 4 — Edge anchor recess

In `TitlesToggleController.client.lua`, when the tab UI is built (before the `MouseEnter`/`Leave` handlers attach), add a sibling Frame named `EdgeRecess`:

- `Frame` named `EdgeRecess`, parent = same parent as the tab button (so it sits at the same z-layer behind the tab — ZIndex one below the button).
- `AnchorPoint = Vector2.new(1, 0.5)` *(anchors to right edge)*
- `Position = UDim2.new(1, 0, 0.5, 0)` *(flush against right edge of screen)*
- `Size = UDim2.new(0, 2, 0, 130)` *(2px wide, slightly taller than the desktop tab's 120px)*
  - **Mobile size:** `UDim2.new(0, 2, 0, 100)` *(taller than the mobile tab's 90px)*
- `BackgroundColor3 = Color3.fromRGB(15, 15, 17)` *(slightly darker than the tab's background, which itself is dark with 0.25 transparency)*
- `BackgroundTransparency = 0.25` *(matches the tab's resting transparency)*
- `BorderSizePixel = 0`
- `ZIndex` one below the tab button's ZIndex
- No UICorner — flat against the edge.

The recess does not change with hover or open/close states — it's a constant background anchor. It's visible all the time on both platforms. Mobile recess is sized to match the mobile tab's 90px height, plus slight overhang.

**Edge case — tab fade-out on open (Brief A iteration 1):** the recess does NOT fade out when the drawer opens. The drawer covers the right ~34% of the screen; the recess at the right edge is fully behind the drawer and therefore invisible while the drawer is open. No explicit fade-out logic needed — the drawer occlusion handles it. If Codex finds the recess pokes out from behind the drawer for any reason (drawer not full-height, edge alignment off), fade it out alongside the tab in `OpenRequested.Event`.

### Step 5 — Verify and playtest

Run a Studio playtest covering the Test Checklist below. Stillness fade, distance fade, tab dot, per-row menu dots, sizing, fade-out-on-open should all still work — Brief B is purely additive on top of Brief A's behaviors.

## 6. Roblox Services Involved

`UserInputService`, `Workspace`, `Players`, `RunService`, `TweenService`, `ReplicatedStorage`. No `DataStoreService`, no `Lighting`, no `MarketplaceService`.

## 7. Security / DataStore Notes

- ⚠️ Validation: not applicable — no remote events fired with user-supplied data.
- ⚠️ DataStore retry/pcall: not applicable — no DataStore writes.
- ⚠️ Rate limits: not applicable — local-only computation.

## 8. Boundaries (do NOT touch)

- `src/ServerScriptService/NameTagScript.server.lua` — stays exactly as-is. Stroke + gap adjustments live client-side in this brief. (If Codex finds a strong reason to move item 2 server-side, flag in inbox first.)
- `src/ServerScriptService/TitleService.lua` — no changes.
- `src/ServerScriptService/TitleServiceInit.server.lua` — no changes.
- `src/ReplicatedStorage/TitleConfig.lua` — no data changes.
- `src/ReplicatedStorage/TitleRemotes/*` — no contract changes.
- `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua` — unrelated.
- `src/StarterPlayer/StarterPlayerScripts/AchievementClient.client.lua` — unrelated.
- `src/StarterGui/TitleMenu/TitleMenuController.client.lua` — Brief B does not touch the menu. The per-row dots Brief A iteration 1 added stay as-is.
- All `02_Systems/_No_Touch_Systems.md` entries — unrelated.

If your work touches anything outside `NameTagEffectController.client.lua` and `TitlesToggleController.client.lua` (other than read-only references), flag in inbox before proceeding.

## 9. Studio Test Checklist

### Item 1 — Title stroke (conditional, only if Step 0 said "needed")
- [ ] Stand in the cave interior. Title reads legibly at standard third-person distance.
- [ ] Walk to the brightest area available in the testing place (near sky, sunlit walls, etc.). Title reads legibly there too.
- [ ] Title doesn't look "loud" against the dark interior backdrop — the stroke should be subtle, not a hard outline.
- [ ] Effects (`tint`, `shimmer`, `pulse`, `glow`) compose with the new stroke value without weirdness.

### Item 2 — Mobile gap widen
- [ ] Mobile (touch device or `TouchEnabled` simulation): the gap between the title row and the name row reads ~5px tall, not the original 2-3px tight stack.
- [ ] Mobile: the name row still fits within the BillboardGui height — no truncation, no clipping at the bottom.
- [ ] Desktop: the gap is unchanged from Brief A (~5px natural). No regression.
- [ ] Respawn → mobile gap re-applies on the rebuilt BillboardGui.

### Item 3 — Hover label affordance (desktop only)
- [ ] Hover the edge tab: the rotated `titles` text becomes more visible (transparency 0.4 → 0.2) within ~0.15s.
- [ ] Move cursor away: text returns to 0.4 within ~0.2s.
- [ ] Existing 4px outward slide and background tween still fire on hover. Item 3 adds, doesn't replace.
- [ ] While drawer is open: hover does nothing (Brief A's `isOpen` gate). Confirm cursor over the (invisible) tab area is silent.
- [ ] Mobile: no hover behavior. Tap still works to open menu. (Acceptable.)

### Item 4 — Edge anchor recess
- [ ] Both platforms: a thin 2px-wide darker strip is visible at the right edge of the screen, behind the tab.
- [ ] The strip stays visible during hover (it's a constant anchor, not a hover element).
- [ ] When the drawer opens: the recess gets covered by the drawer (since the drawer is full-height and right-anchored). Confirm no visual artifact peeking out from behind the drawer.
- [ ] Drawer closes: the recess is back, visible behind the tab as before.
- [ ] Multi-screen / different aspect ratios: the recess sits flush against the right edge regardless of viewport.

### General regression (everything Brief A shipped should still work)
- [ ] Stillness fade fires after sustained running > 2.0s, restores after ~0.4s of slowing down.
- [ ] Distance fade: title softens from 20-40 studs, BillboardGui hides at 50 studs.
- [ ] Tab fade-out-on-open: tab disappears when drawer opens, returns when it closes. Three close paths (outside-click, ESC, internal `x`) work.
- [ ] Tab notification dot: appears on session-time unlock, clears on menu open.
- [ ] Per-row notification dots: appear on session-time unlock, persist while menu open, clear on menu close.
- [ ] Tactile press feedback on tab click (desktop) still fires.
- [ ] Desktop sizing (BillboardGui 280×80, title 16, name 25, tab 24×120) still applied.
- [ ] All four effects (`tint`/`shimmer`/`pulse`/`glow`) render correctly on the title row.
- [ ] No new console errors. Console clean to `[NameTag] script ready` / `[TitleService] script ready` / any normal `[FavoritePrompt]` lines.

## 10. Rollback Notes

This brief is purely additive client-side UI polish — no server contract changes, no DataStore writes, no migration. Rollback is a single git revert of the merge commit. After revert:

- Title stroke returns to server's 0.7 (item 1 reverts to baseline).
- Mobile gap returns to original 2-3px (item 2 reverts to server's baseline positions).
- Tab hover returns to slide + background only — label stays at constant 0.4 (item 3 reverts).
- Edge recess strip disappears (item 4 reverts — Frame is destroyed by the revert).
- All Brief A behaviors (sizing, fades, dots, fade-out-on-open, tactile press) stay intact since they live in the same files but in different code paths.

If a single item is misbehaving (e.g. the recess strip looks wrong on a particular aspect ratio), the cleaner rollback is a follow-up commit reverting that specific block, not a full revert — the items stand on their own.

---

## Out of scope for Brief B

### Item 5 (drawer-dim while menu open) — DROPPED

The original design call had a fifth item: drop the tab opacity to ~50% while the drawer is open, restore on close. **This is now obsolete.** Brief A iteration 1 added "tab fade-out when drawer opens" which goes further — the tab fades to fully invisible (transparency 1.0), not just dimmed. Item 5 was a half-measure version of the behavior Brief A already shipped. No further work needed.

If a future review finds the full fade-out is too aggressive and a partial dim reads better, a one-line tween value change in `TitlesToggleController.client.lua` (the `OpenRequested.Event` handler) is the place to tune it. That's a separate decision, not a Brief B item.

### Held entirely (not in this brief, may revisit)

These were captured during the original design call as items requiring real-play data before committing. Brief A has shipped and Brief B follows; revisit only if the conditions below are met.

1. **Title-row letter tracking.** Whether the title's lowercase Gotham wants positive `TextLetterSpacing` to read more present at smaller sizes. Hold reasoning: at 14pt this was uncertain; at Brief A's 16pt it's even less likely to be needed. Default: hold. **Optional Codex exploration during Brief B playtest:** if you have time and curiosity, set `titleLabel.LetterSpacing = 0.5` on a single tag (live, no code edit needed — set via the command bar or via your local file mirror) and feel the difference. If it lands, flag with `[C] ?` and Tyler decides whether to ship in a Brief B iteration. Don't include it in the initial commit.
2. **First-time edge-tab pulse.** A single slow attention-pull on first character spawn (or first level-up) to signal "this exists." Hold reasoning: Brief A bumped the desktop tab to 24×120 and added the recess via Brief B item 4 — discoverability should be much better than the original 18×90 version. Held until real-play data shows players still missing the tab. If post-Brief-B telemetry/observation suggests discoverability is still an issue, write a separate brief for it.

### Unrelated to Brief B

- Server-side nametag changes — out of scope for both polish briefs. The polished pass + desktop refinement + Brief B all stay client-side per the original design split.
- Effect rebalances — `tint`/`shimmer`/`pulse`/`glow` continue per the polished pass.
- Mobile nametag size changes — only the gap widens (item 2). Heights and font sizes stay at PR #23 baseline.
- Drawer animation tweaks — the 0.3s `Quart Out` open / 0.25s `Quart In` close animations are unchanged.

---

## Notes for Tyler

- **Item 1 may not be needed.** Step 0 explicitly tells Codex to test the 16pt title against bright backgrounds first. If it reads cleanly, item 1 is dropped. This keeps the brief honest about what's actually a problem post-Brief-A, rather than shipping a fix in search of a problem.
- **Item 2 is mobile-only.** Desktop's gap widened naturally with the size bump. Mobile has been at the same 3px gap since PR #12; widening it to ~5px brings parity with the desktop feel.
- **Item 5 dropped explicitly.** If you remember the original design call having "drawer-dim" as item 5, that's right — and it's been superseded by Brief A iteration 1's tab fade-out-on-open. Documenting the drop here so the trail is clear in the eventual session recap.
- **Held items stay held.** Letter tracking and first-time pulse remain off the build queue. Codex has an optional letter-tracking exploration during the playtest, but only ships if it obviously lands. Default: hold both for real-play data.
- **Branch:** `codex/title-polish-brief-b`. Same review cycle as Brief A — Codex pushes, Claude reviews via the Codex Review Template, you give the merge call.
