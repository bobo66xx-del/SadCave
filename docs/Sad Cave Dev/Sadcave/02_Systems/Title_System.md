# Title System

**Status:** 🟢 Shipped

The cosmetic identity layer. Players earn or buy titles that display under their name. **Titles are NOT the progression system** — they ride on top of level, but are decorative. See [[XP_Progression]] for the actual progression design.

---

## Purpose
Give players a quiet way to express identity and time spent in Sad Cave. Title names match the mood — "newcomer", "night_owl", "stillwater", "cathedral_hush" — they read like atmospheric labels, not RPG ranks.

## Player Experience
Title appears under name on the nametag. Players can equip from a list (TitleMenu UI). Title persists across sessions.

---

## Real Architecture (as built)

### Server
- **`ServerScriptService.TitleService`** — title ownership, equipping, persistence
  - Exposes: `GetTitleData`, `EquipTitle` (RemoteFunctions), `TitleDataUpdated` (RemoteEvent)
  - **DataStore key:** `EquippedTitleV1` (saves equipped title by userId)
  - Dependencies: `TitleConfig`, `MarketplaceService`

### Shared (ReplicatedStorage)
- **`TitleConfig`** (ModuleScript) — defines all 34 titles across 4 categories
  - Functions: `GetOrderedTitles`, `NormalizeTitleId`, `GetTitleById`, `GetDisplayName`, `GetRequirementText`, `GetCategory`, `GetEffect`, `GetBestLevelTitleId`, `PlayerHasSpecialAccess`
- **`TitleRemotes`** (Folder)
  - `GetTitleData` (RemoteFunction)
  - `EquipTitle` (RemoteFunction)
  - `TitleDataUpdated` (RemoteEvent)

### UI
- **`StarterGui.TitleMenu`** — title selection UI with filter tabs (all, level, shop, gamepass, owned)

### NameTag integration
- `NameTagScript Owner` reads `TitleConfig` to render the equipped title (with effects) on the BillboardGui

---

## All Titles (current)

### Level Titles (34 entries by level threshold)
| Level | Title |
|---|---|
| 0 | newcomer |
| 75 | visitor |
| 150 | night_owl |
| 225 | late_arrival |
| 300 | local |
| 400 | dim_room |
| 500 | city_kid |
| 625 | half_known |
| 750 | regular |
| 900 | slow_burn |
| 1000 | after_dark |
| 1200 | hush_hour |
| 1400 | socialite |
| 1600 | stillwater |
| 1800 | spotlight |
| 2100 | passing_lights |
| 2400 | trendsetter |
| 2700 | deep_end |
| 3000 | downtown |
| 3400 | night_bloom |
| 3800 | runway |
| 4300 | blackglass |
| 5000 | icon |
| 5750 | cathedral_hush |
| 6500 | city_icon |
| 7500 | last_light |
| 8500 | neon_soul |
| 12000 | superstar |
| 18000 | prismatic |
| 30000 | divine |
| 50000 | immortal |
| 100000 | legend |

### Other Categories
- **Gamepass:** 15 titles
- **Shop:** 30 titles _(see [[_Cleanup_Backlog]] — shop legacy is being reviewed)_
- **Special:** 2 titles

---

## Tone Notes

The level titles are **excellent** and on-brand:
- `night_owl`, `late_arrival`, `dim_room`, `slow_burn`, `hush_hour`, `stillwater`, `cathedral_hush`, `last_light` — these are atmospheric, calm, evocative
- A few feel off-brand: `superstar`, `prismatic`, `divine`, `immortal`, `legend`, `socialite`, `runway`, `spotlight`, `icon`, `trendsetter` — these tip into "flashy social game" rather than "quiet emotional space"

**Possible cleanup:** rename the high-level titles to match the tone of the early ones. Park this in [[../08_Ideas_Parking_Lot/_Parking_Lot]] for now — not blocking.

---

## Open Questions
- Are gamepass and shop titles intentional revenue streams? Worth keeping?
- Special titles — what gates them?
- Do title effects (particles, color, glow) get out of hand at high levels? Worth checking against [[../01_Vision/Tone_and_Rules]].

## Related
- [[Level_System]]
- [[NameTag_Status]]
- [[XP_Progression]]
