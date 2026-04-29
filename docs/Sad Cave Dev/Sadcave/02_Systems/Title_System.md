# Title System

**Status:** 🟡 Building — Title v2 player-facing surface is feature-complete except for the polished TitleMenu pass. MVP-1 shipped via PR #12 (2026-04-28 06:10 UTC, data + display layer). PR #13 (2026-04-28 07:22 UTC) cleaned up the TitleService architecture (ModuleScript pattern, respawn-resilient level watcher). MVP-2 shipped via PR #14 (2026-04-28 08:31 UTC, manual equip + placeholder menu + production-cutover migration). Polished TitleMenu is the only remaining v2 brief on the player-facing surface — it drops in over the placeholder; the placeholder is logged in `_Cleanup_Backlog.md` as the swap target.

> **Where we are:** Title v2 is **live and feature-complete** for the level + gamepass categories. Players see their auto-equipped highest title (or their manually-equipped choice) under their name, can open a small `titles` button in the top-right to browse owned + locked titles, can manually equip any owned title (which respects forever — auto-equip-highest is now first-time-only fallback), and milestone level-ups fire the combined `level N — new title: X` fade with a 5s hold even if they've manually equipped something else. Production-cutover migration code is shipped but un-exercised in testing (no v1 data exists there post-cleanup); production cutover gets its own brief later with a runtime migration test.
>
> **What is NOT live yet:** the achievement / presence / exploration / seasonal title categories are defined in `TitleConfig` (with `achievementId` / `hoursRequired` / `zoneId` / `seasonStart`+`seasonEnd` slots) but `TitleService` only actively checks level + gamepass right now. Each remaining category activates via its own follow-up brief: AchievementTracker first (12 achievement titles), then Presence (8 titles, needs `ProgressionData.totalTimePlayed` reliably tracked), then Exploration (6+ titles, couples with `Area_Discovery` and `Workspace.InsideZones`), then Seasonal infrastructure + day-one launch date.
>
> **Production caveat:** if the live production place still runs v1 with active players, `EquippedTitleV1` DataStore data still matters and the migration table below is what PR #14's migration code uses. The testing-place cleanup affects only the test environment. The migration is one-shot per player (sets `migratedFromV1 = true`), additive (never overwrites existing v2 data), and conservative (unmappable v1 titles fall back to `new_here`).
>
> **Build dependency (resolved):** XP_Progression MVP shipped 2026-04-27 (PR #1 + PRs #10, #11). All XP infrastructure is live — `ProgressionService`, `ProgressionData` DataStore, level computation, `LevelUp` RemoteEvent, sitting boost, gamepass multiplier. Title v2 reads `leaderstats.Level` (server-side observation via `:GetPropertyChangedSignal("Value")`) and `MarketplaceService:UserOwnsGamePassAsync` for the cosmetic title gamepass `1797105034` — the non-invasive observation path since `ProgressionService` is no-touch.

---

## Purpose

Titles are the **cosmetic identity layer** of Sad Cave. They appear under the player's name and reflect time spent, places found, things done, and personal style. Collecting titles is part of the experience — not a grind, but a quiet record of presence.

## Player Experience

- Your title sits **above** your name on the nametag: lowercase, soft, smaller than the name — like a quiet epigraph above a chapter, not a label stapled below (decided 2026-04-29 polish-pass design session; flipped from the original v2 below-the-name placement to read as part of identity rather than metadata)
- You earn titles by being in the cave — leveling up, finding areas, doing things for the first time, coming back over time
- Some titles have subtle visual flair (a slow color shift, a gentle glow) — never flashy
- You choose which title to wear from a menu. Your collection grows as you play.
- Seeing someone with a rare title should feel like noticing something — not like seeing a leaderboard flex
- When you unlock a new title: brief text fades above the XP bar — `new title: still here` — holds 5s, then gone
- When a level-up coincides with a title unlock at the same milestone (e.g. reaching level 10 unlocks `still here`), the two messages merge into a single combined fade reading `level 10 — new title: still here`. Same 5s hold. One moment for the milestone, not two stacked notifications.
- The XPBar's hover-show behavior (level/XP reveal on hover via `HoverDetector`) stays at the current 2s — only the level-up + title-unlock fade duration moves to 5s

---

## Title Categories

Six sources of titles. Each category has its own unlock logic.

### 1. Level Milestones
Unlock at specific levels (driven by [[XP_Progression]]).

### 2. Exploration
Unlock by discovering specific areas in `Workspace.InsideZones`. Ties into [[Area_Discovery]].

### 3. Presence
Unlock at total time-spent milestones (cumulative hours in-game). Tracked via `ProgressionData.totalTimePlayed`.

### 4. Achievements
Unlock by doing something for the first time — first conversation, first sit, first note written, first return visit, etc.

### 5. Seasonal / Limited-Time
Unlock during specific time windows (events, holidays, anniversaries). Once earned, kept forever. Cannot be earned after the window closes.

### 6. Gamepass
Unlock by purchasing the cosmetic title gamepass. Cosmetic only — never gates progression or emotional content.

---

## Title List (v2)

> **Naming rules:** lowercase with spaces. Emotional, internal, atmospheric. Should read like a state of mind, not a rank. No shouting, no flex, no generic game words.
>
> IDs use `snake_case` internally (e.g. `still_here`). Display uses spaces (e.g. `still here`).
>
> Every title has an assigned `tintColor` — a soft, low-saturation Color3 used by the `tint`, `shimmer`, `pulse`, and `glow` effects. Titles with effect `none` still have a tintColor defined for consistency (used if the title is later promoted to a higher effect tier).

### Level Milestones (~20 titles)

> Pacing is based on XP curve `A=45, B=0.55, C=1.15` with ~18 XP/min active play. See [[XP_Progression]] for full pacing table.

| Level | ID | Display | Effect | Tint | Active play time |
|-------|----|---------|--------|------|-----------------|
| 1 | `new_here` | new here | none | warm white `(255, 245, 235)` | ~2 min |
| 5 | `settling_in` | settling in | none | warm white `(255, 245, 235)` | ~13 min |
| 10 | `still_here` | still here | none | soft cream `(245, 235, 215)` | ~27 min |
| 20 | `quiet_one` | quiet one | none | soft cream `(245, 235, 215)` | ~1 hr |
| 35 | `slow_steps` | slow steps | tint | pale gold `(235, 220, 180)` | ~2 hrs |
| 50 | `familiar_face` | familiar face | tint | pale gold `(235, 220, 180)` | ~3 hrs |
| 75 | `low_light` | low light | tint | warm amber `(225, 200, 155)` | ~6 hrs |
| 100 | `half_awake` | half awake | shimmer | soft amber `(215, 190, 140)` | ~9 hrs (~3 days) |
| 150 | `soft_hours` | soft hours | shimmer | warm rose `(220, 190, 175)` | ~18 hrs (~6 days) |
| 200 | `worn_in` | worn in | shimmer | dusty copper `(210, 180, 150)` | ~29 hrs (~10 days) |
| 300 | `deep_water` | deep water | pulse | muted teal `(170, 200, 200)` | ~63 hrs (~3 weeks) |
| 400 | `long_shadow` | long shadow | pulse | cool grey `(180, 185, 195)` | ~110 hrs (~5 weeks) |
| 500 | `cathedral_dark` | cathedral dark | pulse | deep warm `(195, 170, 145)` | ~171 hrs (~2 months) |
| 700 | `fading_signal` | fading signal | glow | pale silver `(200, 200, 210)` | ~339 hrs (~4 months) |
| 1000 | `last_one_here` | last one here | glow | soft gold `(220, 205, 160)` | ~710 hrs (~8 months) |
| 1500 | `after_everything` | after everything | glow | warm ash `(200, 190, 180)` | ~1,659 hrs (~1.5 years) |
| 2000 | `gone_quiet` | gone quiet | glow | faded ivory `(210, 205, 195)` | ~3,047 hrs (~3 years) |
| 3000 | `nowhere_else` | nowhere else | glow | moonstone `(195, 200, 210)` | ~7,211 hrs |
| 5000 | `end_of_the_hall` | end of the hall | glow | deep ember `(200, 170, 140)` | ~21,457 hrs |
| 10000 | `always_was_here` | always was here | glow | pale flame `(225, 200, 165)` | ~94,720 hrs |

**Design intent for pacing:**
- First 3 titles in the first session — instant sense of progress
- `familiar face` (level 50) after a few sessions — player feels known
- `half awake` (level 100) after about a week — first real milestone
- `cathedral dark` (level 500) after months — dedication signal
- `last one here` (level 1000) after most of a year — rare, impressive
- `always was here` (level 10000) — mythic. Nobody will see this for a very long time. When someone has it, it means something.
- Anything past level 2000 is effectively "lifetime player" territory

### Exploration (~6+ titles, expand as map grows)

| Zone | ID | Display | Effect | Tint |
|------|----|---------|--------|------|
| First zone discovered | `first_step` | first step | none | soft green `(200, 220, 200)` |
| Cave entrance | `went_inside` | went inside | none | cool stone `(190, 195, 200)` |
| Deep cave area | `further_in` | further in | tint | deep blue-grey `(170, 180, 195)` |
| Rooftop / high point | `above_it_all` | above it all | tint | sky pale `(200, 210, 225)` |
| Hidden room | `found_something` | found something | shimmer | warm secret `(215, 200, 180)` |
| All current zones | `everywhere_once` | everywhere once | pulse | earth gold `(210, 200, 170)` |

> Exploration titles grow with the map. When new zones are added, new titles can be added here. The system supports arbitrary zone → title mappings.

### Presence (total time played, ~8 titles)

| Hours | ID | Display | Effect | Tint |
|-------|----|---------|--------|------|
| 1 hr | `one_hour_in` | one hour in | none | warm white `(255, 245, 235)` |
| 3 hrs | `losing_track` | losing track | none | soft cream `(245, 235, 215)` |
| 8 hrs | `no_rush` | no rush | tint | pale sand `(230, 220, 200)` |
| 24 hrs | `full_day` | full day | tint | warm clay `(220, 200, 175)` |
| 72 hrs | `three_days_deep` | three days deep | shimmer | dusty rose `(215, 195, 185)` |
| 168 hrs | `a_whole_week` | a whole week | pulse | warm stone `(205, 195, 180)` |
| 500 hrs | `not_going_anywhere` | not going anywhere | glow | aged gold `(210, 200, 165)` |
| 1000 hrs | `lived_here` | lived here | glow | deep warmth `(200, 185, 160)` |

### Achievements (~12 titles)

| Achievement | ID | Display | Effect | Tint |
|-------------|----|---------|--------|------|
| First conversation completed | `said_something` | said something | none | soft lilac `(210, 200, 220)` |
| First time sitting 30s+ | `sat_down` | sat down | none | warm wood `(215, 200, 180)` |
| First note written | `left_a_mark` | left a mark | none | ink grey `(190, 190, 200)` |
| First return visit (2nd session) | `came_back` | came back | none | warm welcome `(225, 215, 200)` |
| Talked to every NPC | `heard_them_all` | heard them all | shimmer | quiet violet `(200, 190, 215)` |
| Sat at 5 different seats | `knows_every_chair` | knows every chair | tint | soft leather `(210, 195, 175)` |
| 10 return visits | `keeps_coming_back` | keeps coming back | tint | warm amber `(225, 210, 180)` |
| 50 return visits | `part_of_the_walls` | part of the walls | shimmer | deep stone `(195, 190, 185)` |
| Played at 3am local time | `up_too_late` | up too late | shimmer | pale midnight `(180, 185, 210)` |
| AFK for 19 continuous minutes | `fell_asleep_here` | fell asleep here | tint | sleep blue `(190, 200, 215)` |
| Joined the group | `one_of_us` | one of us | tint | warm belonging `(220, 210, 195)` |
| Played during first week of v2 launch | `day_one` | day one | pulse | ember `(215, 185, 155)` |

### Seasonal / Limited-Time (~4 initial, grow over time)

| Window | ID | Display | Effect | Tint |
|--------|----|---------|--------|------|
| Halloween event | `hollow_night` | hollow night | pulse | muted orange `(210, 180, 150)` |
| Winter event | `cold_quiet` | cold quiet | shimmer | ice blue `(190, 210, 225)` |
| Anniversary (game birthday) | `been_a_year` | been a year | glow | warm gold `(225, 210, 170)` |
| Valentine's / kindness event | `soft_spot` | soft spot | shimmer | blush `(220, 200, 200)` |

> Seasonal titles are added to `TitleConfig` before events. The unlock window is defined by start/end timestamps in config. Once earned, permanent.

### Gamepass (~6 titles)

> All gamepass titles use the existing cosmetic title gamepass ID `1797105034`. One purchase unlocks all six.

| ID | Display | Effect | Tint |
|----|---------|--------|------|
| `believer` | believer | shimmer | warm faith `(220, 210, 190)` |
| `quiet_donor` | quiet donor | tint | gentle green `(195, 215, 195)` |
| `black_glass` | black glass | glow | obsidian `(160, 160, 170)` |
| `soft_static` | soft static | pulse | pale electric `(195, 200, 220)` |
| `velvet_dark` | velvet dark | glow | deep plum `(180, 165, 185)` |
| `after_hours` | after hours | shimmer | late night `(185, 185, 205)` |

> Gamepass titles are cosmetic flex — the only titles that cost money. They should feel premium but not obnoxious. No gameplay advantage.

---

## Total: ~60 titles at launch

| Category | Count | Grows? |
|----------|-------|--------|
| Level | 20 | Rarely (if level cap changes) |
| Exploration | 6+ | Yes, with map |
| Presence | 8 | Rarely |
| Achievements | 12 | Yes, as features are added |
| Seasonal | 4+ | Yes, each event |
| Gamepass | 6 | Yes, with new passes |

---

## Effects System

Four effect types, applied to the title text on the nametag. All subtle — never particle explosions, never screen-filling.

| Effect | What it does | Used for |
|--------|-------------|----------|
| `none` | Plain text, tintColor applied as static text color | Early / common titles |
| `tint` | Soft color tint on the title text using tintColor | Mid-tier titles |
| `shimmer` | Slow left-to-right color sweep using tintColor, very low opacity | Notable titles |
| `pulse` | Gentle brightness oscillation of tintColor, ~3s cycle | Rare titles |
| `glow` | Soft constant glow around text in tintColor, low intensity | Rarest / highest titles |

**Rules:**
- Effects should be visible but never distracting at a glance
- A room full of players with effects should still feel calm
- Effect intensity does NOT scale with level — a `glow` on a level 10000 title looks the same as `glow` on a gamepass title
- All colors are low-saturation, soft. No bright neons, no pure white.

---

## Technical Structure

### TitleConfig v2

`ReplicatedStorage.TitleConfig` gets rewritten. New structure:

```lua
-- Each title entry
{
    id = "still_here",           -- unique snake_case ID
    display = "still here",      -- what shows on nametag (lowercase with spaces)
    category = "level",          -- level | exploration | presence | achievement | seasonal | gamepass
    effect = "none",             -- none | tint | shimmer | pulse | glow
    tintColor = Color3.fromRGB(245, 235, 215),  -- soft color for effect rendering
    -- Unlock conditions (one per category type):
    levelRequired = 10,          -- for category "level"
    zoneId = nil,                -- for category "exploration" (matches InsideZones child name)
    hoursRequired = nil,         -- for category "presence"
    achievementId = nil,         -- for category "achievement" (matches AchievementTracker key)
    seasonStart = nil,           -- for category "seasonal" (Unix timestamp)
    seasonEnd = nil,             -- for category "seasonal" (Unix timestamp)
    gamepassId = nil,            -- for category "gamepass"
}
```

`TitleConfig` remains a shared ModuleScript readable by both client (for UI/effects) and server (for ownership checks).

### TitleService v2

`ServerScriptService.TitleService` gets rewritten. Responsibilities:

- **Ownership resolution:** given a player, compute which titles they own based on:
  - Level (from `ProgressionService`)
  - Discovered zones (from `ProgressionData.discoveredZones`)
  - Total time played (from `ProgressionData.totalTimePlayed`)
  - Achievements (from `TitleData.achievements`)
  - Current date vs seasonal windows (server time)
  - Gamepass ownership (from `MarketplaceService`, gamepass ID `1797105034`)
- **Equip/unequip:** persist equipped title ID in `TitleData.equippedTitle`
- **Real-time updates:** when a player earns a new title mid-session (levels up, discovers a zone, completes an achievement), fire `TitleDataUpdated` so client UI and XP bar notification refresh
- **DataStore:** uses `TitleData` key (combined with achievements — see below)

### DataStore: `TitleData`

Combined key for all title-related persistence:

```lua
{
    equippedTitle = "still_here",       -- currently worn title ID
    achievements = {                     -- achievement flags
        said_something = true,
        sat_down = true,
        came_back = true,
    },
}
```

> Combined into one key alongside achievements to minimize DataStore requests. See [[XP_Progression]] for the rationale on combining keys.

### AchievementTracker (new)

`ServerScriptService.Progression.AchievementTracker` (ModuleScript)

- Tracks per-player achievement flags
- Reads/writes the `achievements` field inside `TitleData`
- Fires a BindableEvent `AchievementUnlocked` when a new achievement completes — TitleService listens to this to refresh ownership and fire `TitleDataUpdated`
- Individual achievement checks hook into existing systems:
  - `said_something` → dialogue completion signal (same hook as conversation XP source)
  - `sat_down` → sitting detection (same hook as PresenceTick sitting check)
  - `left_a_mark` → note system's `SubmitNote` success
  - `came_back` → `ProgressionData.revisits >= 2`
  - `keeps_coming_back` → `ProgressionData.revisits >= 10`
  - `part_of_the_walls` → `ProgressionData.revisits >= 50`
  - `up_too_late` → client sends UTC offset on join, server checks if player's local time is 3am–5am
  - `fell_asleep_here` → AFK duration ≥ 19 continuous minutes (sits just inside Roblox's 20-min idle auto-disconnect, so the title is reachable). Implementation note: the existing `AfkDetector` is focus-based (window focus loss); for "fell asleep at the keyboard" semantics, AchievementTracker likely wants idle detection (`Player.Idled` event or input-timestamp tracking) rather than the focus-based `AfkDetector`. Decide at AchievementTracker brief time.
  - `one_of_us` → `GroupService:GetGroupsAsync` check on join (group `8106647`)
  - `knows_every_chair` → count of unique `SeatMarker` seats sat in (tracked in memory per session, checked against threshold of 5)
  - `heard_them_all` → count of unique NPCs conversed with (checked against total NPC count)
  - `day_one` → server checks join date against v2 launch window (first 7 days after v2 ships)

### TitleMenu UI v2

`StarterGui.TitleMenu` gets redesigned. Changes from v1:

- **Filter tabs:** `owned` | `locked`
- **Remove:** `shop`, `all`, `level`, `gamepass` tabs (simplified — two tabs is enough for launch, category filters can be added later if players want them)
- **Owned tab:** shows all titles the player has earned, sorted by category then rarity
- **Locked tab:** shows all titles the player hasn't earned yet, each with a short hint of how to unlock ("reach level 50", "discover the deep cave", "play for 24 hours", "complete your first conversation")
- **Newly unlocked:** subtle highlight on titles earned this session
- **Style:** same dark/clean/premium aesthetic, lowercase display names, tintColor shown as a small color dot or subtle border accent per title

**Build approach (decided 2026-04-28):** the MVP slice ships a *placeholder* TitleMenu — functional but visually minimal — so the earn → equip → display data pipeline can be tested end-to-end without UI polish on the critical path. The polished v2 TitleMenu is a separate brief and a separate focused design session Tyler runs later, once real titles are flowing through real data. Placeholder gets logged in `_Cleanup_Backlog.md` when built so it doesn't quietly become permanent. The two-tab `owned` | `locked` simplification, lowercase display, and tintColor-as-subtle-accent principles are the design constraints the polished pass should respect.

### NameTag Integration

`NameTagScript Owner` already reads `TitleConfig` and applies effects. Changes needed:

- Read from v2 `TitleConfig` format (new field names: `display` instead of computed from ID, `tintColor` instead of hard-coded)
- Effect rendering logic stays the same (shimmer/pulse/glow/tint are already implemented) — just map to the per-title `tintColor`

---

## Polished Pass — Drawer + Title-Above-Name (designed 2026-04-29)

**Status:** 🔵 Design-locked, ready for a Codex brief. No code written yet.

This is the design that drops in over the placeholder menu and lifts the nametag from "title row stapled below the name" to "title sitting above the name like an epigraph." Replaces the placeholder TitleMenu and reorders the BillboardGui labels. Captured here as the canonical design; the Codex brief in `06_Codex_Plans/` translates this into implementation steps and validation.

### Design intent

- **Title-as-identity, not title-as-metadata.** The current build reads as "name with a label attached." The polished pass reframes the title as the lens through which you see the person — like a museum nameplate or a chapter epigraph. Tyler's framing: *"sits in the name like someone actually cares."*
- **The cave doesn't disappear when you open the menu.** A right-side drawer with the world dimmed-but-visible behind it lets the player watch their own nametag update as they pick — the moment of equipping a title is anchored in the world they're in, not abstracted to a modal.
- **Categories make the collection legible.** Six sources of titles → six visible sections. The drawer should let a player see "I have 4 of 12 achievement titles" at a glance, which the flat placeholder list doesn't communicate.
- **Voice carries through.** Locked-row hints use mixed voice — concrete categories stay mechanical; achievement and seasonal categories speak in indirect-poetic one-liners that match the in-cave tone.

### Nametag — title above the name

The BillboardGui's two stacked TextLabels swap vertical order. The new layout:

| Row | Position | Size | Font | Color | Opacity | Notes |
|-----|----------|------|------|-------|---------|-------|
| `TitleLabel` (top) | `(0, 0)` | `(1, 0, 0, ~16)` | Gotham 11 | warm-grey `(225, 215, 200)` baseline; tinted per `tintColor` for `tint`/`shimmer`/`pulse`/`glow` titles | ~0.75 (slightly transparent — title whispers) | lowercase; `TextYAlignment = Bottom` so the title hugs the gap above the name |
| (gap) | — | 2-3px breathing space | — | — | — | not a butt-edge; small visible separation |
| `NameLabel` (bottom) | below title | `(1, 0, 0, ~28)` | Gotham 16 | warm-grey `(225, 215, 200)` | full | unchanged from current; `TextYAlignment = Top` |

BillboardGui height stays around 48-50 (`(0, 200, 0, 48)` is a good target — current 50 also fine). `StudsOffset Vector3.new(0, 3, 0)` and `MaxDistance = 100` unchanged. Watchdog and `ensureBillboardLayout` idempotency requirements unchanged.

**Effect rebalance for the new top position:**

- `tint` — unchanged. Static color on the title text.
- `shimmer` — keep the UIGradient ping-pong tween (3s period) but lower contrast: the gradient endpoints sit closer to baseline warm-grey. The title is smaller now and at lower opacity, so the same shimmer at full contrast would over-fight the eye for the small-text role.
- `pulse` — keep the brightness oscillation (1.5s period) but with a smaller amplitude (e.g. brighten by 0.05 instead of 0.08).
- `glow` — **swap the treatment.** Currently a `UIStroke` border around the text. New treatment: a soft low-opacity halo *under* the title text — implementable as a transparent UIStroke at higher transparency (~0.85) with thicker lineweight, *or* as a UIGradient applied to a slightly enlarged background frame behind the title text. Goal: the title reads as having atmosphere around it, not a label outline. Codex picks the cleanest implementation; the spec is "ambient halo, not bordered label."
- Effect attributes (`TitleEffect`, `TitleTintColor`, `TitleDisplay`) on the BillboardGui stay the same — only the rendering changes.

The tint chip / per-title color reads on the title text directly. No separate dot, no chip element.

### Menu — right-side drawer

A new `StarterGui.TitleMenu` shape that replaces the placeholder modal. Old `TitleMenuController.client.lua` gets rewritten; the placeholder programmatic build (Root frame + tabs + scrolls) is fully discarded.

**Shell:**

- ScreenGui properties unchanged: `ResetOnSpawn = false`, `IgnoreGuiInset = true`, `DisplayOrder = 20`.
- Root Frame anchored to the right edge: `AnchorPoint = (1, 0.5)`, `Position = (1, 0, 0.5, 0)`, `Size = (~0.34, 0, 1, 0)` (target ~34% screen width, full height). UISizeConstraint `MinSize = (320, 0)`, `MaxSize = (520, math.huge)` for cross-resolution sanity.
- Slide-in animation: `Position` tweens from `(1, screenWidth, 0.5, 0)` (off-screen right) → `(1, 0, 0.5, 0)` (resting). 0.3s, `Enum.EasingStyle.Quart`, `Enum.EasingDirection.Out`.
- Slide-out: reverse, 0.25s, `Enum.EasingStyle.Quart`, `Enum.EasingDirection.In`.
- Background: same warm-dark palette as placeholder — `BackgroundColor3 (20, 18, 22)` at `BackgroundTransparency = 0.05` (slightly more opaque than placeholder for readability), `UICorner` only on the left edge if Roblox supports per-corner radius (otherwise full radius), `UIStroke` warm-grey at high transparency for a hairline edge.
- World dim: a sibling Frame parented to the same ScreenGui (or a separate `BlurFrame` ScreenGui) covering the full screen at `BackgroundColor3 (0, 0, 0)` with `BackgroundTransparency = 0.75` (so the cave dims to ~75% brightness). Fades from `1.0 → 0.75` over 0.2s on open, reverses on close. **No blur** — `Lighting.BlurEffect` is not used here.

**Internal layout:**

- Drawer is divided into category sections. Section order: `Level`, `Gamepass`, `Presence`, `Exploration`, `Achievement`, `Seasonal`. (This matches the `CATEGORY_ORDER` table the placeholder already uses.)
- Each section header: lowercase category name in Gotham 13, warm-grey at 0.7 opacity, with a hairline rule below at warm-grey 0.85 transparency. e.g. `level`, `gamepass`, etc.
- Within each section: owned titles first (sorted by `levelRequired` / `hoursRequired` / `display`), then locked titles in the same category (same sort).
- Each title row:
  - Owned: TextButton, ~36px tall, full width, `BackgroundColor3 (34, 30, 38)` at `BackgroundTransparency = 0.1`, soft `UICorner (0, 6)`. Title `display` text in Gotham 13 warm-grey, left-aligned with 12px left padding. Per-title `tintColor` reads on the title text itself (no separate dot). The currently-equipped title gets a quiet "wearing" caption beneath the title text in Gotham 10 warm-grey at 0.5 opacity. Hover: background lifts to `(42, 37, 47)` over 0.15s sine ease.
  - Locked: Frame, same dimensions, `BackgroundTransparency = 0.4` (more transparent — locked rows recede). Title `display` in Gotham 13 warm-grey at 0.4 opacity. Hint text right-aligned in Gotham 11 warm-grey at 0.6 opacity, ~14px from right edge. Locked rows are not interactive; no hover state.
- ScrollingFrame with `ScrollBarThickness = 4`, `ScrollBarImageColor3 (110, 102, 94)`, `AutomaticCanvasSize = Y`. Padding via `UIPadding`: 12px top, 16px bottom, 12px left, 12px right. UIListLayout: vertical, `Padding = UDim.new(0, 4)` between rows, `Padding = UDim.new(0, 12)` between sections (handled by per-section header insets).

**Interaction:**

- Click-to-commit. Click an owned row → fire `EquipTitle:FireServer(titleId)`. The 1s server-side rate limit (already in place from PR #14) handles spam.
- Click the currently-equipped row → fire `UnequipTitle:FireServer()` to fall back to auto-equip-highest. (Same as placeholder.)
- The unlock-notification fade ("new title: X") and the equipped-state update on the nametag come from the existing `TitleDataUpdated` payload path. With the world visible behind the drawer, the player sees the nametag update *while still looking at the drawer* — that's the design intent.
- No hover-preview. Hover only changes the row's background color (for affordance), not the equipped title.

**Locked-row hint copy (mixed voice):**

| Category | Voice | Examples |
|----------|-------|----------|
| `level` | mechanical | `reach level 50`, `reach level 100` |
| `gamepass` | softer rephrase | `from the title pack` |
| `presence` | mechanical | `play for 24 hours`, `play for 100 hours` |
| `exploration` | atmospheric-light | `find the deep cave`, `find the outside` |
| `achievement` | indirect / poetic, hand-written per title | `rest for a long while` (`fell_asleep_here`), `stay until the early hours` (`up_too_late`), `the first time you sit` (`sat_down`), `say something to someone` (`said_something`), etc. — full table to write in the Codex brief; placeholder already has indirect copy for some, those carry through. |
| `seasonal` | atmospheric | `only during certain times`, or season-specific when the brief author wants to color-code |

The achievement category has 12 titles; each gets a unique line in the Codex brief. The brief author writes them; this spec captures the *voice rule* (indirect, poetic, lowercase, under 8 words ideally), not the lines themselves.

### Entry point — slim edge tab on the right

Replaces the top-right `titles` text button entirely. Old `StarterGui.TitlesToggleButton` ScreenGui + `TitlesToggleController.client.lua` get rewritten; the new shape:

- A thin tab anchored to the right edge of the screen at all times. Roughly: `AnchorPoint = (1, 0.5)`, `Position = (1, 0, 0.5, 0)`, `Size = (0, 18, 0, 90)` — 18px wide, 90px tall, vertically centered on the right edge.
- Visual: warm-dark background `(20, 18, 22)` at `BackgroundTransparency = 0.25`, `UICorner (0, 4)` on the left side only (or full corner with the right side clipped), warm-grey hairline `UIStroke`. A small lowercase vertical-text or rotated text reading `titles` (using `Rotation = -90` on a TextLabel) inside, Gotham 10 warm-grey at 0.6 opacity.
- Hover: background opacity lifts from 0.25 → 0.15 over 0.15s sine ease; the tab inches outward by a few pixels (`Position` tweens to `(1, 4, 0.5, 0)` — emerging slightly from the edge to invite the click).
- Click: opens the drawer (slide-in animation above). Visible state of the tab persists; the tab stays sticking out of the drawer's left edge so it can be clicked again to close.
- The tab + the drawer slide together. When the drawer is open, the tab is conceptually attached to the drawer's left edge (visually, it might just stay anchored at `(1, 0, 0.5, 0)` and the drawer slides over it — the tab remains the close affordance).

### Close paths

All four work — they're all natural for a side panel:

1. **Click outside the drawer.** A transparent click-catcher Frame covers the dimmed world area (left of the drawer) while the drawer is open. Click → close.
2. **ESC key.** `UserInputService.InputBegan` listener checks `Enum.KeyCode.Escape` while drawer is open.
3. **Small close button inside the drawer.** Top-right of the drawer, subtle `x` glyph in Gotham 14 warm-grey muted. Same shape as placeholder's close button.
4. **Re-click the entry tab.** The tab functions as a toggle — open if closed, close if open.

### Carry-forwards from placeholder review (folded into this design)

- **BindableEvent decoupling:** the entry tab fires a `TitleMenu.OpenRequested` BindableEvent (created in `ReplicatedStorage` or a local context as appropriate); the drawer controller listens to it. Closing fires `TitleMenu.CloseRequested`. The tab no longer pokes `playerGui.TitleMenu.Root.Visible` directly.
- **Row diffing on `TitleDataUpdated`:** instead of clearing all rows and rebuilding on every payload, the drawer controller diffs `ownedTitleIds` and `equippedTitle` against the previous render and updates only what changed. With ~60 titles this is a small speedup at low cost — but the bigger win is preventing scroll-position resets when a title unlock fires mid-session while the menu is open.
- **Hint-copy voice pass:** mixed-voice hint copy lands as part of this brief. Achievement + seasonal hints are the polish-pass author's job; level/gamepass/presence/exploration hints carry over with minor tweaks.

### What stays the same from PR #14

- Server contract — `EquipTitle` / `UnequipTitle` RemoteEvents, server-side ownership re-resolution, 1s rate limit, `equippedManually` / `migratedFromV1` / `lastEquipTime` state fields, `notificationOnly` payloads for unlock notifications when manually-equipped.
- Auto-equip-highest behavior (gamepass priority over level), level watcher self-heal on respawn, migration code for production cutover.
- `TitleConfig.lua` (the data source).
- `TitleRemotes.TitleDataUpdated` payload shape.
- `NameTagEffectController.client.lua` reads `TitleEffect` / `TitleTintColor` attributes from the BillboardGui — that contract stays. Only the *visual rendering* of the `glow` effect changes (UIStroke → underglow halo).
- `TitleService.lua` (no server-side changes for this brief).
- The XPBar's combined level-up + new-title fade.

### Out of scope for this brief

- Mobile touch gesture polish (swipe-to-open the drawer from the right edge) — note as a follow-up if Tyler wants it later. Click-the-tab works on touch, just lacks the gesture richness.
- Per-title detail view (click a title to see its category, unlock condition, when you earned it) — the hint text on locked rows + the section context already do most of this; a deeper detail surface can be a follow-up brief.
- Title preview on hover (we explicitly chose click-to-commit). If players ask for it later, it's a small addition to this controller.
- Filter / search inside the drawer — the categorized layout removes most of the need; if the title roster grows past ~80, revisit.
- Toggle button mobile-vs-desktop variant — the slim edge tab works on both; mobile may want it slightly wider for thumb hits, but that's a tweak inside this brief, not a follow-up.

### Where this goes next

Tyler decides when to write the Codex brief. The brief lives at `06_Codex_Plans/YYYY-MM-DD_Title_Polished_Menu_Nametag_v1.md` (date when written) and translates this section into:
- Files touched (rewrites of `TitleMenuController.client.lua`, `TitlesToggleController.client.lua`, `NameTagScript.server.lua` `ensureBillboardLayout`, `NameTagEffectController.client.lua` `glow` branch only).
- Step-by-step build order.
- Studio Test Checklist (visual checks across mobile + desktop, all 4 close paths, equip + unequip + auto-equip-highest interactions, all 4 effects rendered correctly).
- Achievement hint copy table (12 lines to write).

When the brief lands, this section's status moves from 🔵 Design-locked to 🟡 Building. When the PR ships, the placeholder's `_Cleanup_Backlog.md` entry retires.

---

## Migration Plan

### Status

PR #14 (2026-04-28 08:31 UTC) shipped the migration code; PR #17 (2026-04-29 03:08 UTC) verified it at runtime against synthetic DataStore data. All three migration cases were exercised — known v1 mapped to v2 (`regular → familiar_face`), unmapped v1 fell back to `new_here` (`saber_owner` test case), and `migratedFromV1=true` set on every case so re-reads don't happen. The production-cutover brief (later) flips the live cutover flag with a soak period + rollback plan + Tyler's go-ahead per `01_Vision/Environments.md`.

### Tooling surface

`TitleService.LoadAndMigrateForUserId(userId, storeKeyPrefix)` is a small public function on the TitleService module (added by PR #17). It builds a stub `{UserId = ...}` and calls the existing `loadTitleData` / `migrateFromV1` path so synthetic players or one-off mass-migration tooling can exercise migration without a real player join. Not called during normal player flow. The optional `storeKeyPrefix` parameter keys both `TitleData` and `EquippedTitleV1` DataStores under a prefixed namespace, isolating probe runs from any real player data.

### Player data

- **Equipped title:** Players with a title equipped in `EquippedTitleV1` get migrated. On first join under v2:
  1. Read `EquippedTitleV1`
  2. Look up in the migration table (see below). If found, map to the new ID. If not (e.g. a removed shop title), reset to `new_here`.
  3. Save to `TitleData.equippedTitle`
  4. Stop reading `EquippedTitleV1` after migration period

- **Owned shop titles:** Players who purchased shop titles with shards lose access to those specific titles (shop is being removed). This is acceptable — shards are a legacy currency being cut. No refund mechanism needed since shards have no real-money value.

- **Gamepass titles:** Players who own gamepass `1797105034` keep access — the same gamepass now unlocks the six new gamepass titles instead of the old ones.

### Title ID mapping (v1 → v2)

Full migration table — maps each v1 level title to the nearest v2 equivalent by tier:

```lua
MIGRATION = {
    -- v1 level titles → v2 level titles (by nearest tier)
    newcomer = "new_here",
    visitor = "settling_in",
    night_owl = "quiet_one",
    late_arrival = "quiet_one",
    local_title = "familiar_face",   -- "local" is a Lua keyword
    dim_room = "low_light",
    city_kid = "familiar_face",
    half_known = "familiar_face",
    regular = "familiar_face",
    slow_burn = "slow_steps",
    after_dark = "low_light",
    hush_hour = "soft_hours",
    socialite = "half_awake",
    stillwater = "soft_hours",
    spotlight = "half_awake",
    passing_lights = "worn_in",
    trendsetter = "worn_in",
    deep_end = "deep_water",
    downtown = "deep_water",
    night_bloom = "deep_water",
    runway = "long_shadow",
    blackglass = "long_shadow",
    icon = "cathedral_dark",
    cathedral_hush = "cathedral_dark",
    city_icon = "cathedral_dark",
    last_light = "fading_signal",
    neon_soul = "fading_signal",
    superstar = "last_one_here",
    prismatic = "last_one_here",
    divine = "after_everything",
    immortal = "gone_quiet",
    legend = "nowhere_else",
    -- Shop/special titles with no v2 equivalent → nil (resets to "new_here")
}
```

**Principle:** map to the v2 title whose level threshold is closest to (or lower than) the v1 threshold. Players never lose progress — their level is preserved via XP migration, and they immediately unlock all v2 titles their level qualifies for. The migration table only affects which title is *equipped* — ownership is recomputed from level.

### Rollback

- Keep v1 `TitleConfig`, `TitleService`, and `EquippedTitleV1` DataStore intact during v2 rollout
- v2 uses new DataStore keys (`TitleData`), so v1 data is never overwritten
- If v2 breaks, re-enable v1 scripts — players revert to their old equipped title

---

## Dependency on XP_Progression

Title System v2 **depends on** XP_Progression being built first (or simultaneously), because:

- Level titles need `ProgressionService` to know the player's level
- Presence titles need `ProgressionData.totalTimePlayed`
- Achievement titles share hooks with XP sources (conversation, sitting, discovery)
- Discovery titles need `ProgressionData.discoveredZones`

**Build order (post-XP-MVP, as of 2026-04-28):**

XP Progression MVP shipped in PR #1 (2026-04-27) and was tuned in PR #10 + PR #11 (2026-04-28). All XP infrastructure (`ProgressionService`, `LevelCurve`, `SourceConfig`, `PresenceTick`, XPBar) is live; level/XP/leaderstats work end-to-end with sitting boost, gamepass multiplier, and AFK rate. Title v2 builds onto that. Build order below assumes XP is shipped — the original spec's MVP steps 1–3 are no longer relevant to plan against.

**Title v2 MVP-1 (first Codex brief — data + display, no manual equip):**

1. `TitleConfig v2` — data module with all 60 title definitions baked in (every category's metadata in the file). Active categories on first ship: **level + gamepass only**. Other categories defined but not yet checked.
2. `TitleService v2` — server ownership resolution (level + gamepass), auto-equip the player's highest-tier earned title on join, write `TitleData.equippedTitle` to DataStore. No manual equip/unequip yet.
3. `TitleRemotes/` — `TitleDataUpdated` RemoteEvent only.
4. NameTag v2 — BillboardGui height bump 30 → ~50, add lowercase title `TextLabel` row beneath the name, render with `tintColor` + effect (effect logic re-pointed at v2 `TitleConfig` shape).
5. XPBar update — combined-fade format (`level N — new title: X`), 5s hold for unlock notifications, retime existing level-up animation hold to 5s for consistency, wire up `TitleDataUpdated` listener (the TODO at line 220 of `XPBarController.client.lua` is the integration point).

What MVP-1 ships visibly: a player joining the testing place sees a lowercase title under their name (auto-equipped to their highest-earned level title). When they level up to a milestone (e.g. level 10 → `still here`), the combined fade reads `level 10 — new title: still here` for 5 seconds above the XPBar.

**Title v2 MVP-2 (second Codex brief — placeholder menu + manual equip + migration):**

6. `TitleService` extension — equip/unequip handlers; `EquipTitle` / `UnequipTitle` RemoteEvents in `TitleRemotes/`.
7. Placeholder TitleMenu — `ScrollingFrame` with two `TextButton` tabs (owned / locked), `TextLabel` rows for each title, small color dot for `tintColor`, dark background. Functional, ugly-but-not-embarrassing. Logged in `_Cleanup_Backlog.md` as swap target for the polished menu later.
8. Migration — read `EquippedTitleV1` once per player on join, map via the migration table below, write to `TitleData.equippedTitle`. Testing-place-irrelevant (no v1 data exists there post-cleanup) but lands in MVP-2 alongside the manual-equip surface so production cutover is one config flip away.

What MVP-2 ships visibly: players can open the (placeholder) menu, see what they own and what's locked, and manually equip any owned title. Manual choice replaces auto-equip-highest from MVP-1.

**Follow-up briefs (post-MVP-2):** see *Category Activation Sequence* below — the canonical ordering anchored to the felt-shape map in [[../01_Vision/Player_Experience_Arcs]]. Polished TitleMenu and v1 retirement run as parallel tracks alongside the category activations.

---

## Category Activation Sequence

Re-ordered 2026-04-28 session_4 against [[../01_Vision/Player_Experience_Arcs]]. The four inactive categories (Achievement / Presence / Exploration / Seasonal) don't all serve the same horizon, and the diagnosed weakest stretch — days 3–7 of the return arc — should drive what activates first.

### 1. AchievementTracker + Achievement category — *next*

**Why first:** The Achievement category contains the highest concentration of beats that fall in days 3–7 of the return arc — the weakest stretch. `said_something`, `sat_down`, `came_back`, `knows_every_chair` (5 different seats), `keeps_coming_back` (10 return visits), `heard_them_all`, `up_too_late` — these are the surfaces that turn a passive return visit into a small earned moment. The first three fire in session 1–2 and lead the player into the loop. The middle batch fires in days 3–7 and fills the diagnosed gap.

**Loyalty seeding:** `part_of_the_walls` (50 return visits) and `fell_asleep_here` are long-tail beats that seed the loyalty arc from the same brief. Two arcs served by one activation.

**Costs:** ~12 titles needs ~12 hook implementations across existing systems (dialogue, sitting, notes, return counter, group join, idle detection). The hooks are mapped in this spec already (Achievements section). The biggest open choice is the focus-vs-idle implementation for `fell_asleep_here` — resolve at brief time.

**Brief shape:** AchievementTracker ModuleScript + per-achievement hook-up + TitleConfig metadata for each. ~1 Codex session at the size of recent v2 work.

### 2. Presence category — *second*

**Why second:** Presence titles are time-spent milestones (1hr / 3hr / 8hr / 24hr / 72hr / 168hr / 500hr / 1000hr). The 3-hour and 8-hour titles land squarely in days 3–7 alongside the achievement beats — they reinforce the same gap from a different angle. Long-tail (500hr / 1000hr) seeds loyalty.

**Why not first:** Presence on its own is *just a counter against thresholds*. It's mechanical recognition. Pairing it with Achievement first means the player is already in the rhythm of "things being noticed" by the time Presence ticks — the time titles land softer.

**Costs:** Cheapest of the four to ship — single counter, no new hook authoring. Confirm `ProgressionData.totalTimePlayed` is being tracked reliably in current `ProgressionService` before the brief; augment first if missing.

**Brief shape:** Verify-and-augment `totalTimePlayed` + activate Presence ownership check in TitleService. Smaller than AchievementTracker.

### 3. Exploration category — *paired with Outside + Area_Discovery*

**Why third:** Exploration titles need somewhere to explore. With only [[../03_Map_Locations/Cave_Entrance]] built and [[../03_Map_Locations/Outside]] still planned, shipping the category now would activate maybe 2 of 6 titles. Wait until at least Outside is built and ideally one more zone exists, so the category lands with 4+ active surfaces.

**This is paired work, not a single brief:**
- Build [[../03_Map_Locations/Outside]] (map work, requires Tyler-led design session for layout/feel)
- Build [[Area_Discovery]] (currently 🔵 Planned — needs `Workspace.InsideZones` to exist; verify in Studio before brief)
- Activate Exploration title category in TitleService (small, last)

The Area_Discovery system also feeds the XP "Discovery" source, so this paired work resolves a stuck dependency for the XP curve as well.

**Brief shape:** Three briefs minimum, possibly four. The largest body of work in the activation sequence.

### 4. Seasonal — *last, gated by Seasonal_Layer infrastructure*

**Why last:** Seasonal is the highest-leverage loyalty surface ("I was here last winter") but the most complex to do well — calendar awareness, content authoring per season, real tone risk if it tilts toward "themed events." Activating it before days 3–7 is plugged means firing seasonal content into a return arc that hasn't been fixed; the seasonal beats won't land because there's no loyal-player density to receive them.

**Pre-requisite:** [[Seasonal_Layer]] (currently ⚪ Idea) graduates to a real system spec first. The Title_System Seasonal entries are the *output* surface of Seasonal_Layer — the calendar engine, environmental shifts, and NPC mood gating belong upstream.

**Special case:** the `day_one` title is technically Seasonal (limited window) but doesn't need full Seasonal_Layer to exist — it just needs the v2 launch date locked in and a 7-day window check. Ship `day_one` opportunistically with whichever activation falls closest to launch; treat the rest of the Seasonal category as gated.

**Brief shape:** Seasonal_Layer system spec → Seasonal_Layer build → Seasonal title category activation. Three steps over multiple sessions.

### Parallel tracks (run alongside the sequence)

These don't activate categories but improve the surrounding experience. Tyler picks when to slot each in:

- **Polished TitleMenu + nametag title visual** — Tyler-led design session. Drops in over the placeholder menu and lifts the nametag title-row into something that "sits in the name like someone actually cares." Best slotted *after* AchievementTracker ships, so the menu has 12 more titles to display when it gets its polish pass — a more meaningful proving ground.
- **v1 retirement** — once v2 has been stable for some time, drop the `EquippedTitleV1` DataStore reads from migration code. Low priority; can wait until after the full activation sequence completes.

### What this sequence does for the felt-shape map

- **Arrival arc:** mostly unchanged — already works. Achievement firsts give a small lift in session 1.
- **Return arc days 3–7 (the weakest stretch):** AchievementTracker + Presence between them put 5–8 distinct beats into this window. This is the diagnosed gap closing.
- **Loyalty arc:** seeded from day one (long-tail Achievement + Presence titles), then powered up by Exploration once the world is bigger, then sealed by Seasonal as the passport-stamp layer. Combined with [[QuietKeeper_Memory]], this gives loyal players multiple reinforcing surfaces of recognition.

Each brief is independently shippable. The sequence is a recommendation; if Tyler has a reason to swap the order, document it in `_Decisions.md` so future sessions know why.

---

## Security Notes

- ⚠️ Title ownership computed server-side only. Client reads the result, never claims ownership.
- ⚠️ Achievement flags are server-authoritative. Client cannot fire "I achieved X."
- ⚠️ Seasonal window checks use server time, not client time.
- ⚠️ `up_too_late` uses client-reported UTC offset — low security risk for a cosmetic title. Worst case: a player lies about their timezone and gets a title they didn't "earn." Acceptable.
- ⚠️ Gamepass checks via `MarketplaceService:UserOwnsGamePassAsync` — cached on join.
- ⚠️ All title/achievement data persisted in `TitleData` key, separate from progression data and from v1's `EquippedTitleV1`.

---

## Open Questions (resolved)

- ~~Title unlock notification~~ → Brief text fade above XP bar: `new title: still here`, holds **5s** (bumped from 2s during 2026-04-28 walkthrough — 2s was too short to land). Same style as level-up text. **Collision with level-up at the same milestone:** merges into a single combined fade `level N — new title: X`, also 5s. Hover-show on XPBar stays 2s; only the unlock notification moves to 5s.
- ~~Time-of-day achievements (up_too_late)~~ → Client sends UTC offset on join, server computes local time. 3am–5am local time window.
- ~~How many gamepass IDs?~~ → One gamepass (`1797105034`), unlocks all six gamepass titles.
- ~~Filter tabs in TitleMenu~~ → `owned` + `locked` only for v2 launch. Category filters can come later.
- ~~"glass hour" rename~~ → `gone quiet`
- ~~"permanent resident" rename~~ → `always was here`
- ~~"neon haze" rename~~ → `soft static`
- ~~`fell_asleep_here` focus-vs-idle implementation~~ → **Idle**, via Roblox's `Player.Idled` event (default 20-minute mouse/keyboard inactivity). Tyler decided 2026-04-29 during AchievementTracker brief design pass. Idle is closer to the "fell asleep at the keyboard" semantics than focus-loss (which is just "switched windows"). Server-side hook on `player.Idled:Connect`; the 20-minute default is comfortably ≥ the 19-minute spec target. Implementation lives in [[../06_Codex_Plans/2026-04-29_AchievementTracker_v1]].

## Open Questions (remaining)

- **"day one" title:** exact v2 launch date needed to define the 7-day window. Set this before shipping seasonal/achievement titles.

---

## Related

- [[XP_Progression]]
- [[Level_System]]
- [[Area_Discovery]]
- [[NameTag_Status]]
- [[Daily_Rewards]]
- [[Dialogue_System]]
- [[_Cleanup_Backlog]]
