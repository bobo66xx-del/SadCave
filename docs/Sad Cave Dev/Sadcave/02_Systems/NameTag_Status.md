# NameTag / Status System

**Status:** 🟢 Shipped — name + title build live as of PR #12 (merged 2026-04-28 06:10 UTC, branch `codex/title-v2-mvp1`) + PR #13 (merged 2026-04-28 07:22 UTC, branch `codex/title-v2-mvp1-followup`) + PR #23 (merged 2026-04-29 10:48:45 UTC, branch `codex/title-polish-pass`) + **PR #25 (merged 2026-04-29 14:01:58 UTC, branch `codex/title-tag-tab-desktop-refinement`)**. PR #12 added the title row back at height 50 with two stacked labels; PR #13 cleaned up how `NameTagScript` reaches into `TitleService` (direct `require`); PR #23 flipped the layout so the title sits *above* the name and rebalanced `glow` to an ambient halo; **PR #25 (Desktop Refinement Pass) added per-client desktop sizing (BillboardGui 280×80, title 16pt, name 25pt), stillness fade tied to `presence rewards stillness` (title fades after sustained running > 2.0s, restores on stop), distance fade (title softens 20-40 studs, BillboardGui hides at MaxDistance 50 via client override), per-tab notification dot on title unlock, per-row notification dots in TitleMenu, edge tab cross-fades with drawer open/close (re-click-tab close path replaced by three remaining: outside-click, ESC, internal `x`).**

---

## Purpose
Show each player's display name and current title above their character via a BillboardGui. The title row is the visible surface for the cosmetic title system — soft, lowercase, often with a subtle effect (tint / shimmer / pulse / glow). Level visibility lives on the XPBar (bottom of screen), not on the nametag.

## Player Experience

Above each player floats two stacked TextLabels — the player's current equipped title on top in lowercase, smaller and softer than the name; then a 2-3px breathing gap; then the player's display name underneath in soft warm-grey at full opacity, anchoring the eye. The title reads as a quiet epigraph rather than a label stapled below the name. For most titles the title row is plain text at ~75% opacity; for titles with `tint` it's statically tinted with the title's `tintColor`; for `shimmer`, `pulse`, or `glow` titles a subtle per-frame animation runs on the client (with `glow` rendering as a soft ambient halo via a thickened low-opacity `UIStroke`, not a hard border). Spawning and respawning re-apply the nametag from the player's persisted `TitleData.equippedTitle`. Title changes mid-session (milestone level-up unlocks a new title, gamepass purchase, manual equip via the polished TitleMenu drawer) update the title row in place.

---

## Real Architecture (as built, post-PR #12 + PR #13 + PR #14 + PR #23)

### Server
- **`ServerScriptService.NameTagScript`** (Script — file in repo: `src/ServerScriptService/NameTagScript.server.lua`)
  - Builds the BillboardGui programmatically and adornes it to each character's `HumanoidRootPart`
  - BillboardGui: `Size UDim2.new(0, 200, 0, 50)`, `StudsOffset Vector3.new(0, 3, 0)`, `MaxDistance = 100`, `AlwaysOnTop = true`
  - Two stacked TextLabels — title on top, name below (post-PR #23):
    - `TitleLabel` (`Size UDim2.new(1, 0, 0, 16)`, `Position UDim2.new(0, 0, 0, 0)`): `Gotham 11`, color `(225, 215, 200)` (overwritten by `NameTagEffectController` per the active effect), `TextTransparency 0.25` (= ~0.75 opacity), stroke `(0, 0, 0)` at transparency 0.7, `TextYAlignment = Bottom`, text = the equipped title's `display`
    - `NameLabel` (`Size UDim2.new(1, 0, 0, 28)`, `Position UDim2.new(0, 0, 0, 19)`): `Gotham 16`, color `(225, 215, 200)`, stroke `(0, 0, 0)` at transparency 0.6, `TextYAlignment = Top`, text = `player.DisplayName`
  - Reads the player's current title payload by directly requiring `TitleService` (post-PR #13: `local TitleService = require(ServerScriptService:WaitForChild("TitleService"))`). Both `getTitlePayload` and `applyTitlePayload` are thin pass-throughs to `TitleService.GetPlayerTitlePayload` / `TitleService.ApplyTitlePayloadToBillboard`.
  - Sets BillboardGui attributes on each apply: `TitleEffect` (string: `none` / `tint` / `shimmer` / `pulse` / `glow`), `TitleTintColor` (Color3), `TitleDisplay` (string). The client-side `NameTagEffectController` reads these and runs the effect animation.
  - Disables Roblox's default `Humanoid.DisplayDistanceType` so it doesn't compete with the BillboardGui
  - Watches via `AncestryChanged` and re-applies the BillboardGui if it's destroyed (Avalog-safe). After re-creation, the title payload is re-applied so the title row is correct on the rebuilt BillboardGui.
  - `ensureBillboardLayout` is idempotent — safe for the watchdog to call repeatedly without stacking duplicate labels.
  - **No leaderstats hook.** NameTagScript itself does not read `leaderstats.Level`; the level surface lives in the XPBar. Title-vs-level reactivity is handled by `TitleService` watching `leaderstats.Level:GetPropertyChangedSignal("Value")` (re-attached on `CharacterAdded` per PR #13) and firing `TitleRemotes.TitleDataUpdated`, which the client applies to the BillboardGui.
- **`ServerScriptService.TitleService`** (ModuleScript — file in repo: `src/ServerScriptService/TitleService.lua`) — owns title ownership resolution, auto-equip, manual equip via `EquipTitle` / `UnequipTitle` RemoteEvents (PR #14), DataStore persistence (`TitleData` key), production-cutover migration via `EquippedTitleV1` (PR #14), and the live update path. Public API: `Start()`, `GetPlayerTitlePayload(player)`, `ApplyTitlePayloadToBillboard(billboard, payload)`. See [[Title_System]] for full responsibilities.
- **`ServerScriptService.TitleServiceInit`** (Script — file in repo: `src/ServerScriptService/TitleServiceInit.server.lua`) — three-line runtime starter that requires the module, calls `Start()`, prints `[TitleService] script ready`.

### Client
- **`StarterPlayer.StarterPlayerScripts.NameTagEffectController`** (LocalScript — file in repo: `src/StarterPlayer/StarterPlayerScripts/NameTagEffectController.client.lua`) — watches Workspace for any BillboardGui named `NameTag`, reads `TitleEffect` and `TitleTintColor` attributes, runs the appropriate effect animation on the `TitleLabel`. Effects: `none` (default warm color), `tint` (static color), `shimmer` (UIGradient ping-pong tween, 3s period, endpoints 0.2/0.7/0.2 post-PR #23 for lower contrast at the smaller top-position role), `pulse` (TweenService brightness oscillation, 1.5s cycle, `brighten` amount 0.05 post-PR #23), `glow` (UIStroke Thickness 2, Transparency 0.85, `ApplyStrokeMode.Border` — ambient halo treatment post-PR #23, replacing the prior bordered-label treatment at thickness 1 / transparency 0.55). `AttributeChanged` listeners restart the animation on title change. `AncestryChanged` cleans up on destruction. Heartbeat reaper handles stale billboards.
- **`StarterGui.TitleMenu`** (ScreenGui, `ResetOnSpawn=false` — file in repo: `src/StarterGui/TitleMenu/`) — polished right-side drawer UI post-PR #23. Slides in from the right edge (~34% width, `Quart Out 0.3s`) over a world-dimming overlay (no blur, ~75% brightness via 0.2s sine fade). Six category sections (`level`, `gamepass`, `presence`, `exploration`, `achievement`, `seasonal`) with quiet headers + hairlines, owned-then-locked within each section, currently-equipped row shows a soft `wearing` caption. Click-to-commit on owned rows; locked rows show one-line mixed-voice hints (mechanical for level/gamepass/presence/exploration, indirect-poetic for achievement and seasonal). Four close paths wired (click outside via dim overlay TextButton, ESC via `UserInputService.InputBegan`, internal `x` close button, `CloseRequested` BindableEvent). Row diffing on `TitleDataUpdated` keyed off `ownedTitleIds` deltas — only changed rows replace, scroll position preserved on mid-session unlocks. Built programmatically by `TitleMenuController.client.lua`.
- **`StarterGui.TitlesToggleButton`** (ScreenGui, `ResetOnSpawn=false` — file in repo: `src/StarterGui/TitlesToggleButton/`) — slim 18×90px right-edge tab post-PR #23 with rotated `titles` text (Gotham 10, warm-grey at 0.4 opacity), anchored to the right edge of the screen. Hover lifts the tab outward to `(1, 4, 0.5, 0)` and bumps background opacity from 0.25 → 0.15 (0.15s sine ease). Click fires `OpenRequested` or `CloseRequested` BindableEvents on the `TitleMenu` ScreenGui depending on state, with a fallback to direct `Root.Visible` toggle if the bindables don't appear within 5s.

### Linked AFK plumbing
- **`ReplicatedStorage.AfkEvent`** (RemoteEvent, repo: `src/ReplicatedStorage/AfkEvent/init.meta.json`) — fired by client when window focus changes
- **`StarterPlayerScripts.AfkDetector`** (LocalScript, repo: `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua`) — fires `AfkEvent:FireServer(true/false)` on `WindowFocused` / `WindowFocusReleased`
- The XP Progression `Driver` listens to `AfkEvent.OnServerEvent` to flip the player's AFK state for the presence tick. NameTagScript itself does **not** show AFK status visually right now — that's a follow-up if/when wanted.

### Retired (deleted in 2026-04-27 cleanup, before Title v2)
- `ServerScriptService.NameTagScript Owner` (the old title-rendering nametag from v1)
- `ServerScriptService.OverheadTagsToggleServer` (no-op server handler tied to a client-only preference)
- `ServerScriptService.AFK` (replaced by `AfkEvent` + `AfkDetector` plus the XP Driver's listener)
- `StarterPlayer.StarterPlayerScripts.AFKLS` (replaced by `AfkDetector`)
- `Workspace.NameTags` folder (was scaffolding for the old pipeline)
- `ReplicatedStorage.RebuildOverheadTags`, `ReplicatedStorage.OverheadTagsEnabled`, `ReplicatedStorage.OverheadTagsToggle` (companion remotes/values for the old pipeline)

---

## What's Missing vs Pre-Cleanup

- ❌ Distance fade (was unverified pre-cleanup, simply absent now)
- ❌ Hide-during-dialogue (was an open question pre-cleanup; still open)
- ❌ Per-player toggle (was the `GUIToggle` ScreenGui; UI was deleted with the legacy menu pass)

Title row and level row are NOT on this list anymore: title row returned in PR #12 (Title v2 MVP-1); level row was deliberately removed by PR #9 (2026-04-27) because the XPBar covers level visibility — that decision stands. The remaining ❌ items are intentional gaps, not bugs.

---

## Design Notes
- The title row is the only visible surface for cosmetic titles — by design (see `_Decisions.md` 2026-04-28 — "Title-on-nametag stays"). Don't add titles to the XPBar or the menu-only — they need to be socially visible to other players.
- Avalog watchdog must stay — without it, nametags vanish for any player whose character flow touches Avalog. PR #9, PR #12, and PR #14 all verified the watchdog was preserved through their changes.
- After a class-swap of `TitleService` from Script → ModuleScript in PR #13, Studio retained the orphaned old `TitleService` Script instance — Rojo doesn't reach across class boundaries to delete it. Codex manually deleted the orphan during PR #13's playtest. Worth remembering for any future class-swap work in this area.
- If a future brief wants to surface anything beyond name + title on the nametag (status icons, achievement badges, hide-during-dialogue), update this spec first and let the brief follow.

## Polished Pass — Title-Above-Name (🟢 Shipped via PR #23, 2026-04-29 10:48:45 UTC)

The polished menu + nametag visual pass flipped the BillboardGui's vertical zones. **Pre-PR #23**: NameLabel on top (28px tall), TitleLabel below (18px tall). **Post-PR #23 (live)**: TitleLabel on top (16px tall, Gotham 11 lowercase warm-grey at TextTransparency 0.25), 2-3px breathing gap, NameLabel anchored at Position `(0, 0, 0, 19)` (28px tall, Gotham 16, full warm-grey). The reframe is *title-as-epigraph* not *title-as-label* — see `Title_System.md` § "Polished Pass — Drawer + Title-Above-Name" for the full design intent and decision history.

What changes in `NameTagScript.server.lua` `ensureBillboardLayout` (in implementation order, captured here so the Codex brief can pull from it directly):

- Title row TOP: Gotham 11, lowercase, warm-grey at ~0.75 opacity, centered, `TextYAlignment = Bottom` so it hugs the gap above the name. Size ~16px tall, `Position UDim2.new(0, 0, 0, 0)`.
- 2-3px breathing gap (no butt-edge).
- Name row BOTTOM: Gotham 16, full warm-grey, centered, `TextYAlignment = Top`. Size ~28px tall, `Position UDim2.new(0, 0, 0, ~19)`.
- BillboardGui height target ~48 (current 50 also fine — the spec is "the rows fit cleanly with breathing gap," not a strict pixel count).
- `StudsOffset Vector3.new(0, 3, 0)` and `MaxDistance = 100` unchanged. Watchdog and `ensureBillboardLayout` idempotency unchanged.

What changes in `NameTagEffectController.client.lua`:

- `tint`, `shimmer`, `pulse` keep their existing animations but at slightly lower contrast — the title is smaller and at lower baseline opacity now, so full-contrast effects over-fight the eye.
- `glow` swaps from the current `UIStroke`-as-border treatment to a soft low-opacity halo *under* the title text. Implementable as a transparent `UIStroke` at high transparency (~0.85) with thicker lineweight, or as a UIGradient applied to a slightly enlarged background frame behind the title text. The spec is "ambient halo, not bordered label" — Codex picks the cleanest implementation.
- The `TitleEffect` / `TitleTintColor` / `TitleDisplay` attribute contract on the BillboardGui is unchanged — only the rendering of `glow` differs.

**No server-side title plumbing changes.** TitleService, the equip/unequip flow, the auto-equip-highest behavior, and the migration code all stay intact. The polished pass is purely a UI / nametag visual rewrite.

The Player Experience text at the top of this spec describes the *currently shipped* layout (title below the name). It will get rewritten in the same edit pass that ships the polished build, so the spec describes live reality. Until then, the polished design lives only in this subsection and in the cross-referenced Title_System spec.

## Desktop Refinement Pass — Sizing + Stillness/Distance Fades (🟢 Shipped via PR #25, designed 2026-04-29, Iteration 1 final)

Shipped via PR #25 (`codex/title-tag-tab-desktop-refinement`, head `9bca238`, merged 2026-04-29 14:01:58 UTC). Two-iteration same-branch loop. Final values: bigger proportional desktop bump (title 16 / name 25 / 280×80), longer stillness threshold (2.0s sustained-high), halved distance fade with halved MaxDistance (20-40-50), tab fades out when drawer opens, per-row notification dots in the menu. Full design in [[Title_System]] § "Desktop Refinement Pass" — this section mirrors the nametag-relevant bits.

### Architecture shift — sizing moves client-side

The current build sets all nametag sizing on the **server** in `NameTagScript.server.lua` `ensureBillboardLayout`. Desktop-vs-mobile is a per-client property (it's about the viewing player's device, not the viewed player's), so size adjustment has to happen client-side. The refinement pass introduces a client controller that:

- Detects local platform once at startup using `UserInputService.TouchEnabled and not UserInputService.MouseEnabled` (canonical project pattern from `XPBarController.client.lua`).
- For every NameTag BillboardGui it observes (via the existing `Workspace.DescendantAdded` pattern already used by `NameTagEffectController`), applies desktop-scale sizing if local platform is desktop. Mobile clients see the server's baseline (mobile-sized) layout.
- Re-applies on respawn — server's `ensureBillboardLayout` runs when a fresh BillboardGui is needed, the client's controller picks up the new BillboardGui from `DescendantAdded` and re-applies its sizing.

Codex's call whether to extend `NameTagEffectController.client.lua` or add a sibling controller (e.g. `NameTagPresenceController.client.lua`) — see brief for the recommendation.

### Desktop sizing values (Iteration 1: proportional bump up)

Mobile values stay at PR #23 baseline. Iteration 1 bumped desktop further than the initial pass — first round used title 14 / name 22 / 240×64; live review felt still small at distance, bumped proportionally.

| Element | Mobile (baseline) | Desktop (Iteration 1 final) |
|---------|-------------------|-----------------------------|
| `BillboardGui.Size` | `(0, 200, 0, 50)` | `(0, 280, 0, 80)` |
| `TitleLabel.TextSize` | 11 | 16 |
| `TitleLabel.Size.Y.Offset` | 16 | 22 |
| `TitleLabel.Position.Y.Offset` | 0 | 0 |
| `NameLabel.TextSize` | 16 | 25 |
| `NameLabel.Size.Y.Offset` | 28 | 41 |
| `NameLabel.Position.Y.Offset` | 19 | 28 |
| `StudsOffset` | `(0, 3, 0)` | `(0, 3, 0)` (unchanged) |
| `MaxDistance` | 100 (server) | **50 (client-side override, BOTH platforms)** |

The MaxDistance override applies to mobile too, not just desktop. The server's value stays at 100 (so server-replicated property reads still see 100 for any tooling), but the client tag controller writes 50 to every observed NameTag's MaxDistance and re-applies if the property is reset.

### Stillness fade on the title row (Iteration 1: longer running threshold)

Title fades out when the viewed character is sprinting / running fast (sustained), fades back in when they slow down. Name row stays unchanged. Per-character per-client state.

- Out trigger: `humanoidRootPart.AssemblyLinearVelocity.Magnitude > 10 stud/s` sustained **`≥ 2.0s`** *(Iteration 1: was 1.0s)* → fade title `TextTransparency` from baseline (~0.25) to 1.0 over 0.6s ease-out sine.
- Return trigger: velocity `< 10 stud/s` sustained `≥ 0.4s` → fade back over 0.6s ease-out sine.
- Asymmetry (2.0s out / 0.4s back) biases toward "presence-rewarding" — you have to actually run sustained, not just walk briskly through, before the title commits to fading; but a brief stop returns it quickly.

This is the **thesis move**: UI behavior tied to Sad Cave's "presence rewards stillness" core. Composes with effect transparency (multiplies, doesn't replace).

### Distance fade on the title row (Iteration 1: halved bands + halved MaxDistance)

Title softens as viewer's camera moves further from the viewed character. Iteration 1 halved both the fade bands and the BillboardGui's MaxDistance.

- 0–20 studs *(was 0–40)*: title at baseline.
- 20–40 studs *(was 40–80)*: title fades linearly to 0.85.
- 40–50 studs: title fully transparent; BillboardGui itself disappears at MaxDistance = 50 *(was 100)*.
- 10Hz update cadence. Composes multiplicatively with stillness fade and effect transparency.

Combined with the size bump above, the design intent is "bigger nearby, gone sooner at distance" — coherent with the polished pass's tone of presence-with-a-tighter-range.

### Coupling concern with effects

`NameTagEffectController.client.lua` already manipulates `TextColor3` and stroke per active effect. The new fade behaviors adjust `TextTransparency`. They're orthogonal axes and compose, but the controller managing fade should *read* the effect's baseline transparency (not assume hardcoded 0.25) and fade between baseline and 1.0. If Codex chooses to extend `NameTagEffectController` rather than add a sibling, the existing effect logic needs to expose its baseline as a tracked value rather than implicit per-branch.

### Brief B items (deferred, no file yet)

Captured in [[Title_System]] § "Desktop Refinement Pass" → "Brief B": background-aware stroke tuning, breath between rows, hover affordance on tab, edge anchor recess, drawer-dim while menu open. Ships after Brief A in its own brief on its own branch.

## Related
- [[XP_Progression]] (drives the presence-tick AFK state and emits the level changes that TitleService observes)
- [[Title_System]] (owns the title definitions, ownership resolution, equip/unequip flow that feeds the title row here)
- [[../06_Codex_Plans/2026-04-28_Title_v2_MVP1_v1]] (PR #12 — the build that put the title row in place)
- [[../06_Codex_Plans/2026-04-28_Title_v2_MVP1_Followup_v1]] (PR #13 — the cleanup that swapped `_G.SadCaveTitleService` for direct `require` and added respawn-resilient level watching)
- [[../06_Codex_Plans/2026-04-28_Title_v2_MVP2_v1]] (PR #14 — manual equip via the placeholder TitleMenu + production-cutover migration)
- [[../06_Codex_Plans/2026-04-27_NameTag_Strip_Level_Row_v1]] (PR #9 — the level-row strip that immediately preceded Title v2 and explains why level isn't on the nametag)
