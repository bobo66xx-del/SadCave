# Title System

**Status:** 🔵 Planned — redesign (v2)

> **Previous version:** v1 is currently live (🟢 Shipped). This spec describes the full replacement. v1 stays running until v2 ships. See migration plan at the bottom.

---

## Purpose

Titles are the **cosmetic identity layer** of Sad Cave. They appear under the player's name and reflect time spent, places found, things done, and personal style. Collecting titles is part of the experience — not a grind, but a quiet record of presence.

## Player Experience

- Your title sits under your name on the nametag: lowercase, soft, like a whispered label
- You earn titles by being in the cave — leveling up, finding areas, doing things for the first time, coming back over time
- Some titles have subtle visual flair (a slow color shift, a gentle glow) — never flashy
- You choose which title to wear from a menu. Your collection grows as you play.
- Seeing someone with a rare title should feel like noticing something — not like seeing a leaderboard flex
- When you unlock a new title: brief text fades above the XP bar — `new title: still here` — holds 2s, then gone

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
| AFK for 30+ minutes | `fell_asleep_here` | fell asleep here | tint | sleep blue `(190, 200, 215)` |
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
  - `fell_asleep_here` → AFK duration tracked by existing AFK system (30+ continuous minutes)
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

### NameTag Integration

`NameTagScript Owner` already reads `TitleConfig` and applies effects. Changes needed:

- Read from v2 `TitleConfig` format (new field names: `display` instead of computed from ID, `tintColor` instead of hard-coded)
- Effect rendering logic stays the same (shimmer/pulse/glow/tint are already implemented) — just map to the per-title `tintColor`

---

## Migration Plan

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

**Combined build order (MVP first):**

**MVP (first Codex brief):**
1. ProgressionService core + LevelCurve + SourceConfig + migration + save/load
2. PresenceTick source (three-state: sitting/active/AFK)
3. XP Bar UI (with level-up and title unlock notification support)

**Follow-up briefs:**
4. Discovery source
5. Conversation source
6. AchievementTracker
7. TitleConfig v2 + TitleService v2 (level titles only at first, then add other categories)
8. TitleMenu v2 (owned/locked tabs)
9. NameTag update (v2 TitleConfig format + per-title tintColor)
10. Migrate + retire v1

Each step is independently shippable. MVP replaces the old level system. Follow-ups layer on the new title system piece by piece.

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

- ~~Title unlock notification~~ → Brief text fade above XP bar: `new title: still here`, holds 2s, same style as level-up text.
- ~~Time-of-day achievements (up_too_late)~~ → Client sends UTC offset on join, server computes local time. 3am–5am local time window.
- ~~How many gamepass IDs?~~ → One gamepass (`1797105034`), unlocks all six gamepass titles.
- ~~Filter tabs in TitleMenu~~ → `owned` + `locked` only for v2 launch. Category filters can come later.
- ~~"glass hour" rename~~ → `gone quiet`
- ~~"permanent resident" rename~~ → `always was here`
- ~~"neon haze" rename~~ → `soft static`

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
