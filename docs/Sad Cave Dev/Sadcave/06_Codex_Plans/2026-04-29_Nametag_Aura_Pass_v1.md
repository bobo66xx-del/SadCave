# Nametag Aura Pass — Stillness Bloom — Codex Plan

**Date:** 2026-04-29
**Status:** 🔵 Queued
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/nametag-aura-pass` *(once started)*
**Related Systems:** [[../02_Systems/NameTag_Status]] § "Aura Pass — Stillness Bloom" (canonical design home) · [[../02_Systems/Title_System]]

---

## 1. Purpose

Biggest visual upgrade to the nametag since the polished pass (PR #23). Tyler's framing during the design call: nametags currently "look lame, kinda ugly, no aura." This brief gives them aura.

The nametag transforms from "two text labels stacked with strokes floating above the character" into a **layered atmospheric expression of player presence**:

- A soft dark cushion with a UIGradient vignette holds every nametag in a quiet bedding (always present, solves legibility universally — replaces Brief B's stroke tighten as the legibility solution)
- A faint warm edge bloom at the bottom of the cushion (always present, like candlelight rising)
- A slow vertical breath (1-2 px sine wave, 3.5s period, random phase per player so groups don't bob in unison)
- **Stillness-responsive bloom** (the thesis-move): when the viewed character has been still 5+ seconds, the cushion expands +10%, edge bloom strengthens, and a soft outer halo grows. Motion collapses it back to baseline within 0.6s. Other players see who's inhabiting the space (visibly bigger, warmer nametags) versus who's passing through (small, quiet baseline) — the literal visual expression of Sad Cave's "presence rewards stillness" thesis on the most-visible-to-others surface.
- Equipped title's `tintColor` faintly bleeds into the edge glow (15% mix) — your title literally gives off color
- Title row gets `TextLetterSpacing = 0.5` (the held item from Brief B's "held entirely" list — folds in here)
- Choreography: title-unlock pulse, staggered reveal on approach

Pure client-side. No server changes, no remote contract changes, no DataStore work.

**Read [[../02_Systems/NameTag_Status]] § "Aura Pass — Stillness Bloom" before starting.** That section is the canonical design — every visual decision, layer description, sizing value, and rationale lives there. This brief is the build instructions; the design is upstream.

## 2. Player Experience

- Every nametag now sits in a soft dark cushion with a faint warm glow at its bottom edge. Reads cleanly against any background — no more title text getting eaten by bright sky.
- Each nametag has a barely-perceptible vertical breath (1-2 pixels over 3.5s). You'd only notice it if you stared, but it makes the nametag feel alive in your peripheral vision. Each player's breath is offset from others so a group of nametags doesn't bob in unison.
- Stand still in front of another player's nametag for ~5 seconds. Watch their nametag gradually settle — the cushion grows slightly, the warm edge glow strengthens, a soft outer halo appears. They've been here. Their aura makes their presence visible.
- Walk past someone running. Their nametag is in baseline state — small, quiet, present but not blooming. They're passing through.
- Your equipped title's color (the existing `tintColor` system) faintly bleeds into your cushion's warm halo. So a "soft hours" title gives you a warmer aura, "long shadow" gives a darker one.
- When you unlock a new title mid-session, your cushion does a single soft outward pulse over 1.5 seconds, then settles back. Quiet celebration, no popping.
- The title row text is more deliberately spaced — the lowercase Gotham reads as more inscribed, less casual.

No remote contract changes, no DataStore changes, no `TitleConfig` data changes, no UI structural changes outside the BillboardGui. The visible surface is what's changing.

## 3. Technical Structure

- **Server responsibilities:** none new. `NameTagScript.server.lua` and `ensureBillboardLayout` keep building the BillboardGui at the existing baseline. The cushion, edge bloom, outer halo, breath, bloom state, tint bleed, and letterspacing all live client-side.
- **Client responsibilities:**
  - Per-client per-character aura layer creation and management (cushion + edge bloom + outer halo Frames as children of the BillboardGui)
  - Per-client breath animation (slow sine drift on the labels' vertical position)
  - Per-character per-frame bloom state machine (extends Brief A's velocity tracking)
  - Per-character per-frame transparency / size interpolation between Baseline and Bloomed states
  - Tint bleed computation on `TitleTintColor` attribute change
  - Letterspacing applied on `tryAttach`
  - Choreography hooks: title-unlock pulse (on `TitleEffect` or `TitleDisplay` attribute change), staggered reveal on distance fade reverse
- **Remote events / functions:** none new.
- **DataStore keys touched:** none.

For the full design rationale, layer-by-layer description, baseline values, color codes, and state-machine semantics, read [[../02_Systems/NameTag_Status]] § "Aura Pass — Stillness Bloom."

## 4. Files / Scripts

- **`src/StarterPlayer/StarterPlayerScripts/NameTagEffectController.client.lua`** — extend with all aura layer creation + animation. This file is already touched by Brief A (sizing, fades, MaxDistance override, property listeners) and Brief B (stroke override, mobile gap override). Aura Pass extends it further. Codex's call whether to (a) keep it as a single file or (b) split off a sibling `NameTagAuraController.client.lua` for the bloom-specific work — see Step 1.

**No server-side files changed.** `NameTagScript.server.lua`, `TitleService.lua`, `TitleConfig.lua`, `TitleRemotes/*` all stay untouched. No new client files unless Step 1's option B is chosen.

## 5. Step-by-Step Implementation (for Codex)

### Step 1 — Decide controller layout

`NameTagEffectController.client.lua` is currently the home for: title effects (tint/shimmer/pulse/glow), desktop sizing, mobile gap, MaxDistance override, stroke override, stillness fade, distance fade, and per-property change listeners. After Brief B it's already getting long.

Two options:
- **(A) Extend `NameTagEffectController` further.** Add aura layer creation in `applyEffect`, breath/bloom state in the per-character `controller` table, all the new transparency/size writes in the per-frame heartbeat. Largest single file, but keeps all per-nametag logic in one place.
- **(B) Add sibling `NameTagAuraController.client.lua`.** Keeps effects + sizing in the existing controller and moves cushion/bloom/breath/halo into a new sibling. Cleaner separation but the two scripts both observe `Workspace.DescendantAdded` for new BillboardGuis and both attach per-character state — coordination needed.

**Recommendation: (A), extend the existing controller.** Reasoning: the bloom state machine reuses Brief A's `velocityHighSince`/`velocityLowSince` per-character data, and the tint bleed reads the same `TitleTintColor` attribute the existing `applyEffect` uses. Keeping it in one file avoids duplicating the velocity tracking and the attribute-change listeners. The file gets longer (~600 lines after this brief) but stays single-purpose: "this is the file that owns nametag presentation."

If Codex strongly prefers (B) for code-organization reasons, OK to take it — document the choice in the inbox, make sure both scripts agree on per-character cleanup (when a BillboardGui is destroyed, both controllers' per-character state must clear).

### Step 2 — Create the aura layer Frames in `applyEffect`

Inside `applyEffect(billboard, titleLabel, nameLabel)` (the existing function in `NameTagEffectController`), after the existing `clearEffectChildren` call and before the effect-specific branches:

Create three child Frames of the BillboardGui (each with a UIGradient where noted). Build them once per `applyEffect` call; clean them up via the existing connection-disconnect pattern when the BillboardGui is destroyed.

#### `AuraCushion` Frame

```lua
local cushion = Instance.new("Frame")
cushion.Name = "AuraCushion"
cushion.AnchorPoint = Vector2.new(0.5, 0.5)
cushion.Position = UDim2.new(0.5, 0, 0.5, 0)
cushion.Size = UDim2.new(1, 30, 1, 24)  -- 15px horizontal padding, 12px vertical padding around the BillboardGui
cushion.BackgroundColor3 = Color3.fromRGB(15, 13, 18)
cushion.BackgroundTransparency = 0.55  -- baseline
cushion.BorderSizePixel = 0
cushion.ZIndex = 0  -- below labels (which are ZIndex 1+)
cushion.Parent = billboard

-- UIGradient — vignette approximation
-- Roblox's UIGradient is linear, not radial. Approximate the vignette by either:
--   (a) two crossed UIGradients on a parent + child Frame structure, OR
--   (b) a single UIGradient with a soft-edge ColorSequence + TransparencySequence
-- Codex picks the cleanest approach. Recommendation: (a) — child Frame inherits cushion size,
-- parent has horizontal gradient, child has vertical gradient, both go to transparency 1 at edges.
```

#### `EdgeBloom` Frame

```lua
local edgeBloom = Instance.new("Frame")
edgeBloom.Name = "EdgeBloom"
edgeBloom.AnchorPoint = Vector2.new(0.5, 1)  -- bottom-center anchor
edgeBloom.Position = UDim2.new(0.5, 0, 1, 0)  -- at the bottom of the cushion
edgeBloom.Size = UDim2.new(1, 0, 0.25, 0)  -- full width, 25% height of the cushion
edgeBloom.BackgroundColor3 = Color3.fromRGB(70, 50, 35)  -- warm amber, very dark
edgeBloom.BackgroundTransparency = 0.85  -- baseline very faint
edgeBloom.BorderSizePixel = 0
edgeBloom.ZIndex = 0  -- same layer as cushion
edgeBloom.Parent = cushion

local edgeBloomGradient = Instance.new("UIGradient")
edgeBloomGradient.Rotation = 90  -- vertical
edgeBloomGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),    -- top: fully transparent
    NumberSequenceKeypoint.new(1, 0),    -- bottom: solid (pre-cushion-transparency)
})
edgeBloomGradient.Parent = edgeBloom
```

#### `OuterHalo` Frame

```lua
local outerHalo = Instance.new("Frame")
outerHalo.Name = "OuterHalo"
outerHalo.AnchorPoint = Vector2.new(0.5, 0.5)
outerHalo.Position = UDim2.new(0.5, 0, 0.5, 0)
outerHalo.Size = UDim2.new(1.3, 0, 1.3, 0)  -- 130% of cushion size
outerHalo.BackgroundColor3 = Color3.fromRGB(70, 50, 35)  -- warm amber, matches edgeBloom
outerHalo.BackgroundTransparency = 0.92  -- baseline near-invisible
outerHalo.BorderSizePixel = 0
outerHalo.ZIndex = -1  -- below cushion
outerHalo.Parent = cushion  -- inherits the cushion's bloom-state size scaling

local outerHaloGradient = Instance.new("UIGradient")
-- Use a soft transparency sequence that goes from semi-opaque center to fully transparent edges
outerHaloGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.4, 0.5),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(0.6, 0.5),
    NumberSequenceKeypoint.new(1, 1),
})
outerHaloGradient.Parent = outerHalo
```

(The exact transparency sequence may need tuning during Studio playtest — start with the values above.)

Store references to all three Frames in the per-character `controller` table so the heartbeat update loop can write to them.

### Step 3 — Letterspacing on the title label

In `applyEffect`, after the layer Frames are created, set:

```lua
titleLabel.TextLetterSpacing = 0.5
```

Apply only to the title label. Name label stays at default tracking (0). Add a property listener so a server respawn re-application doesn't reset it (use the existing pattern from Brief B's stroke override).

### Step 4 — Breath layer

Add per-character breath state to the `controller` table:

```lua
controller.breathPhaseOffset = math.random() * math.pi * 2  -- random initial phase
controller.breathStartTime = os.clock()
```

In the heartbeat update loop (the existing `RunService.Heartbeat` callback that already runs `updateTitlePresenceFade`), add a breath calculation:

```lua
local breathTime = (os.clock() - controller.breathStartTime + controller.breathPhaseOffset) / 3.5  -- 3.5s period
local breathOffset = math.sin(breathTime * math.pi * 2) * 1.5  -- 1-2px range (using 1.5 for amplitude → -1.5 to +1.5 px)
controller.breathOffset = breathOffset
```

Then, when applying any size or position writes to the cushion / labels, add `breathOffset` pixels to the Y position. The cleanest implementation: shift the cushion's Position by `(0, 0, 0, breathOffset)` each frame.

Don't apply breath to the BillboardGui itself or the labels directly — apply to the cushion, since the labels are visually anchored on the cushion's vertical center. If the labels are at `Position UDim2.new(0, 0, 0, 0)` and the cushion is at `Position UDim2.new(0.5, 0, 0.5, 0)`, then shifting just the cushion shifts everything together.

Actually — re-think this: the labels are children of the BillboardGui, not of the cushion. If we shift the cushion, the labels stay still. Either:
- (a) Reparent the labels to the cushion (server scripts won't like this if they re-find the labels by `:FindFirstChild` — verify the server uses `:FindFirstChild` patterns rather than hardcoded paths)
- (b) Shift both the cushion AND the labels by the breath offset each frame

Recommendation: (b). Cleaner for compatibility with the server's `ensureBillboardLayout` pattern.

### Step 5 — Bloom state machine

Add per-character bloom state to the `controller` table:

```lua
controller.bloomState = "Baseline"  -- "Baseline" | "Bloomed" | "Settling"
controller.bloomLevel = 0  -- 0.0 = baseline, 1.0 = fully bloomed; current value (smoothed)
controller.bloomTargetLevel = 0  -- 0.0 or 1.0 depending on velocity state
```

The thresholds:
- `BLOOM_TRIGGER_DELAY = 5.0` seconds of low velocity (`< 10 stud/s`) before transitioning Baseline → Bloomed
- `BLOOM_COLLAPSE_DELAY = 0.4` seconds of high velocity (`> 10 stud/s`) before transitioning Bloomed → Baseline (matches Brief A's stillness fade collapse delay exactly)
- `BLOOM_FADE_TIME = 0.6` seconds for the smooth transition between states

In the heartbeat update loop:

```lua
-- Reuse Brief A's velocityLowSince / velocityHighSince per-character signals.
local now = os.clock()

if controller.velocityLowSince and (now - controller.velocityLowSince) >= BLOOM_TRIGGER_DELAY then
    controller.bloomTargetLevel = 1.0
elseif controller.velocityHighSince and (now - controller.velocityHighSince) >= BLOOM_COLLAPSE_DELAY then
    controller.bloomTargetLevel = 0.0
end

-- Smooth bloomLevel toward bloomTargetLevel
local bloomStep = if BLOOM_FADE_TIME > 0 then dt / BLOOM_FADE_TIME else 1
controller.bloomLevel = moveToward(
    controller.bloomLevel,
    controller.bloomTargetLevel,
    math.clamp(bloomStep, 0, 1)
)
```

(Reuse the existing `moveToward` helper from Brief A.)

Then apply `controller.bloomLevel` to the visual layer values:

```lua
-- Cushion
local cushionPaddingX = lerp(30, 50, controller.bloomLevel)  -- 100% → 110% padding
local cushionPaddingY = lerp(24, 40, controller.bloomLevel)
controller.cushion.Size = UDim2.new(1, cushionPaddingX, 1, cushionPaddingY)
controller.cushion.BackgroundTransparency = lerp(0.55, 0.4, controller.bloomLevel)

-- Edge bloom
controller.edgeBloom.BackgroundTransparency = lerp(0.85, 0.65, controller.bloomLevel)

-- Outer halo (transitions slightly slower — use a separate smoother)
local haloLevel = math.clamp(controller.bloomLevel * 1.15 - 0.15, 0, 1)  -- skews the halo to start at bloomLevel 0.15+ and finish at 1.0
controller.outerHalo.BackgroundTransparency = lerp(0.92, 0.85, haloLevel)
```

(Add a `lerp` helper if there isn't one already: `local function lerp(a, b, t) return a + (b - a) * t end`.)

### Step 6 — Tint bleed

In `applyEffect`, after reading `TitleTintColor`, compute a tint bleed and write to the edge bloom + outer halo:

```lua
local WARM_AMBER_BASELINE = Color3.fromRGB(70, 50, 35)
local TINT_BLEED_INTENSITY = 0.15

local function blendColor(fromColor, toColor, alpha)
    return Color3.new(
        fromColor.R + (toColor.R - fromColor.R) * alpha,
        fromColor.G + (toColor.G - fromColor.G) * alpha,
        fromColor.B + (toColor.B - fromColor.B) * alpha
    )
end

local _, tintColor = readEffectState(billboard)
local tintBleed = blendColor(WARM_AMBER_BASELINE, tintColor, TINT_BLEED_INTENSITY)
edgeBloom.BackgroundColor3 = tintBleed
outerHalo.BackgroundColor3 = tintBleed
```

(`blendColor` already exists in the controller from Brief A's shimmer effect — reuse it.)

The existing `TitleTintColor` attribute change listener already triggers an `applyEffect` re-call, which will recompute the bleed. No new listener needed.

### Step 7 — Choreography: title-unlock pulse

When the BillboardGui's `TitleDisplay` attribute changes mid-session (which means the player just equipped or unlocked a title), trigger a single 1.5s pulse:

- Tween the cushion size from current → 115% of current → back to current (over 0.75s + 0.75s, ease-out sine then ease-in sine)
- Tween the edge bloom transparency from current → current − 0.15 → back to current (same timing)

```lua
table.insert(connections, billboard:GetAttributeChangedSignal("TitleDisplay"):Connect(function()
    -- Skip the first call (initial set on attach) — only respond to changes after first set
    if controller.titleDisplaySetOnce then
        triggerUnlockPulse(controller)
    else
        controller.titleDisplaySetOnce = true
    end
end))
```

`triggerUnlockPulse` runs three short tweens that compose with the bloom state's current cushion size/transparency. Make sure the pulse doesn't fight the bloom state tweens — cancel any in-flight bloom-state tween on the cushion when a pulse fires, then let the pulse complete and the bloom state tween resume after.

**Edge case:** if the title changes from one to another (player swaps titles via menu), the pulse fires. If it's the player's first equip on join, the pulse should NOT fire (just the initial set). The `titleDisplaySetOnce` flag handles this — first call is the initial set; subsequent calls are real changes.

### Step 8 — Choreography: staggered reveal on approach

The existing distance fade fades the title row out at 20-40 studs and the BillboardGui hides at 50 studs (Brief A). On approach (camera moves from outside the fade band to inside), the title currently fades back in at the same rate as the distance fade reverses.

Add a 0.2s delay to the title's fade-in when transitioning from "fully faded out" to "fading in":

- Track the title's previous distance fade level. If current fade level is 0 (fully visible) and previous was 1 (fully faded), AND the bloom state hasn't been touched recently, schedule the title's TextTransparency tween to start 0.2s after the name's tween starts.

Implementation: track `controller.titleDistanceFadePrev` per character, compare to current `distanceFadeAmount`. If transition is from 1 → not-1 (fading in), delay the title-side transparency write by 0.2s.

This is a subtle effect — only fires when a player walks INTO recognition range. Don't over-engineer; if the simplest version (a `task.delay(0.2, ...)` wrapping the title transparency write on the transition frame) works, ship it.

**Edge case:** if the player walks back out of range during the 0.2s delay, cancel the delayed write so it doesn't fire after the title should have started fading out again. Use a token/sequence pattern (matches Brief A iteration 1's stillness fade tween cancellation).

### Step 9 — Performance pass

For every per-frame operation, profile mentally:
- Heartbeat update on 20 BillboardGuis = 20 * (velocity read + bloom state check + breath compute + 5 transparency writes + 1 size write + 1 position write) per frame. Should be well under 1ms.
- Tween instances accumulate during state transitions — make sure to cancel and disconnect properly when the BillboardGui is destroyed (existing cleanup pattern).
- UIGradient instances: don't create per-frame; create once in `applyEffect`, store references.

If anything feels expensive during profiling (`Stats:GetTotalMemoryUsageMb()` or visual frame-time spikes), flag and we can optimize. Default expectation: no perf hit.

### Step 10 — Verify and playtest

Run a Studio playtest covering the Test Checklist below. Important: this brief stacks on top of Brief B's behaviors. Brief B should stay merged (or your branch should be based on `main` after Brief B merges). If Brief B hasn't merged yet at the time you start, base on `main` and rebase/merge after Brief B lands.

## 6. Roblox Services Involved

`UserInputService` (existing platform detection from Brief A), `Workspace` (camera position for distance fade, BillboardGui descendant tracking), `Players` (existing), `RunService` (Heartbeat), `TweenService` (existing). No `DataStoreService` involvement. No `Lighting`. No `MarketplaceService`. No `HttpService`.

## 7. Security / DataStore Notes

- ⚠️ Validation: not applicable — no remote events fired with user-supplied data. Reads from `TitleTintColor` are server-authoritative.
- ⚠️ DataStore retry/pcall: not applicable — no DataStore writes.
- ⚠️ Rate limits: not applicable — local-only computation.
- ⚠️ Performance: monitor Studio playtest frame time. If the per-frame bloom/breath heartbeat causes any visible jank, flag in inbox.

## 8. Boundaries (do NOT touch)

- `src/ServerScriptService/NameTagScript.server.lua` — stays exactly as-is. The cushion and aura layers attach client-side via the existing `Workspace.DescendantAdded` listener.
- `src/ServerScriptService/TitleService.lua` — no changes.
- `src/ServerScriptService/TitleServiceInit.server.lua` — no changes.
- `src/ReplicatedStorage/TitleConfig.lua` — no data changes.
- `src/ReplicatedStorage/TitleRemotes/*` — no contract changes.
- `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua` — unrelated.
- `src/StarterPlayer/StarterPlayerScripts/AchievementClient.client.lua` — unrelated.
- `src/StarterGui/TitleMenu/*` — unchanged. The aura is per-nametag, not per-menu.
- `src/StarterGui/TitlesToggleButton/*` — unchanged. The edge tab work from Brief A and Brief B stays.
- All `02_Systems/_No_Touch_Systems.md` entries — unrelated.

If your work touches anything outside `NameTagEffectController.client.lua` (or the new sibling controller if Step 1 option B is chosen), flag in inbox before proceeding.

## 9. Studio Test Checklist

### Cushion + edge bloom (always present)
- [ ] Every nametag has a visible dark cushion behind the title + name labels
- [ ] Cushion fades to fully transparent at all edges (vignette effect)
- [ ] Faint warm glow at the bottom of the cushion (edge bloom)
- [ ] Cushion + edge bloom render correctly against bright sky AND dark cave walls — title legibility resolved across backgrounds (replaces the Brief B stroke tighten as the legibility solution)
- [ ] Mobile: cushion sized appropriately for the smaller mobile BillboardGui (200×50 baseline → cushion ≈ 230×74)
- [ ] Desktop: cushion sized appropriately for the desktop BillboardGui (280×80 from Brief A → cushion ≈ 310×104)
- [ ] Respawn: aura layers re-attach correctly to the new BillboardGui

### Breath
- [ ] Watch any nametag for 5-10 seconds: notice subtle 1-2px vertical drift over a 3.5s sine wave
- [ ] Multiple nametags visible simultaneously: each has a different phase offset (don't bob in unison)

### Bloom (stillness-responsive)
- [ ] Stand still in front of another player's character. After ~5 seconds, their nametag's cushion expands subtly (~10% growth), edge glow strengthens, soft outer halo appears
- [ ] Move (`> 10 stud/s` for 0.4s+): bloom collapses back to baseline within 0.6s
- [ ] Brief pause (stop for 1s, then walk again): bloom does NOT trigger (5s threshold not met)
- [ ] Sustained stillness (5+ seconds): full bloom state with cushion size 110%, transparency 0.4, edge bloom 0.65, outer halo 0.85
- [ ] Multiple players visible: each one's bloom state is independent (a still player blooms while a running player stays baseline)
- [ ] Local player's own nametag: blooms when they stand still, collapses when they move (default — Brief A's stillness fade applies to all, Aura Pass follows)

### Tint bleed
- [ ] Equip "soft hours" (warm-amber tint title): cushion's edge glow shifts slightly warmer
- [ ] Equip "long shadow" (darker tint): cushion's edge glow shifts slightly cooler
- [ ] Switch between titles via the TitleMenu drawer: tint bleed updates without a respawn
- [ ] Tint bleed magnitude is subtle (15% mix) — title's color is FELT, not stamped

### Letterspacing
- [ ] Title row text reads more deliberately spaced — visible if you compare side-by-side with a screenshot from before the brief
- [ ] Name row text is unchanged (no letterspacing applied)
- [ ] All four effects (`tint`/`shimmer`/`pulse`/`glow`) still render correctly with the new letterspacing

### Choreography
- [ ] Trigger a title unlock during the session (level up across a milestone, OR manually swap titles via the menu): cushion does a single 1.5s outward pulse
- [ ] Pulse doesn't fight the bloom state — if you're in Bloomed state when a pulse fires, the pulse extends from the bloomed size, then settles back to bloomed (not collapsed)
- [ ] Walk INTO recognition range of another player (from outside the 50-stud MaxDistance): name appears first, title eases in 0.2s later (subtle stagger)
- [ ] Walk OUT of range: standard distance fade behavior (Brief A) holds — title fades out before name as the BillboardGui approaches MaxDistance

### General regression (Brief A + B behaviors should still work)
- [ ] Stillness fade on the title row still fires after sustained running > 2.0s, restores after ~0.4s of slowing
- [ ] Distance fade still softens title at 20-40 studs, BillboardGui still hides at MaxDistance 50
- [ ] Edge tab fade-out-on-open still works (Brief A iteration 1)
- [ ] Tab notification dot still appears on session-time unlock, clears on menu open
- [ ] Per-row notification dots in TitleMenu still appear, persist while menu open, clear on close
- [ ] All four effects (`tint`/`shimmer`/`pulse`/`glow`) still render correctly on the title row
- [ ] Mobile gap from Brief B (5px between title and name on mobile) still applies
- [ ] No new console errors. Console clean to `[NameTag] script ready` / `[TitleService] script ready` / any normal `[FavoritePrompt]` / `[Progression]` lines

### Performance
- [ ] Frame time stays smooth with 5+ players visible simultaneously
- [ ] No memory growth across a 5+ minute Studio playtest
- [ ] No tween leak warnings or accumulation

## 10. Rollback Notes

This brief is purely additive client-side UI — no server contract changes, no DataStore writes, no migration. Rollback is a single git revert of the merge commit. After revert:

- Aura layers (cushion, edge bloom, outer halo) disappear; nametag returns to two text labels stacked over a transparent BillboardGui
- Breath disappears; labels stay still
- Bloom state machine disappears; no presence-rewards-stillness visual signal
- Letterspacing returns to default (0); title text reads less inscribed
- Tint bleed disappears; titles read in pure text-color only
- Choreography disappears; title unlocks happen instantly, approach reveals are simultaneous
- All Brief A + Brief B behaviors stay intact (sizing, fades, stroke override, mobile gap, edge tab, dots, tactile press) since they live in different code paths

If a single layer is misbehaving (e.g. the outer halo flickers, or breath feels too aggressive), the cleaner rollback is a follow-up commit reverting just that layer's block, not a full revert — the layers stand on their own.

---

## Notes for Tyler / Claude review

- **The cushion replaces Brief B's stroke fix as the legibility solution.** Brief B shipped `TextStrokeTransparency = 0.5` to help titles read against bright backgrounds. The cushion now does that job structurally (and adds atmosphere). Brief B's stroke change stays in place by default — see "Stroke decision" in the spec — but if it reads too heavy with the cushion present, drop to 0.7 in a follow-up. Not blocking for this brief.
- **Letterspacing is the held item from Brief B finally landing.** Tyler said "go all out" during the Aura Pass design call, so the letterspacing item folds in here rather than waiting for separate consideration.
- **The bloom is the thesis-move.** This is the piece that makes the Aura Pass genuinely original — UI behavior expressing presence-rewards-stillness as accumulated atmospheric weight. If anything during review reads off, weight feedback toward "is the bloom feeling right?" — that's the heart of the brief.
- **Open questions are listed in the spec** ([[../02_Systems/NameTag_Status]] § "Open questions for review"). Codex defaults are documented; Tyler can override during review.
- **Iteration likely.** This is a high-design brief. Brief A had a same-branch two-iteration loop because Tyler reviewed the live build and asked for tuning. Aura Pass might do the same. Codex pushes, Tyler reviews live, asks for adjustments → same-branch iteration 1 → second review → merge. Standard pattern; not a problem.
- **No production cutover risk.** This brief lives in the testing place. Production cutover is a separate brief. The Aura Pass will ship to production as part of the Title v2 cutover whenever that happens.
