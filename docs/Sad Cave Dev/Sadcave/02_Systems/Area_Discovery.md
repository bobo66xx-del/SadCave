# Area Discovery

**Status:** 🔵 Planned — prior `AreaDiscoveryBadge` script deleted from testing place 2026-04-27. `Workspace.InsideZones` parts may or may not still exist (verify before building). The XP Progression follow-up `Discovery` source will likely supersede the badge-only design entirely.

> **Recovery note:** the original badge-awarding system used `BadgeService` against zone-touch events, with no DataStore (badges handled their own persistence via Roblox). Badge IDs already live in the Roblox cloud and are still owned by players who earned them — deleting the script doesn't revoke past awards. Re-enabling badge-awarding later is a matter of restoring or rewriting the script; the badge IDs themselves don't need new design work.
>
> When building the XP `Discovery` source, the natural choice is to combine: one script awards both the badge (cloud) and the XP (DataStore). Reverses the earlier "keep them separate" recommendation — with the legacy script gone, a unified rewrite is cheaper than restoring two.

---

## Purpose
Reward players for finding new areas. Currently awards Roblox badges. Will also feed XP into [[XP_Progression]].

## Player Experience
Player walks into a new zone for the first time → badge awarded silently. No pop-up that breaks mood — just a quiet moment.

---

## Real Architecture (as built)

### Server
- **`ServerScriptService.AreaDiscoveryBadge`**
  - Auto-awards badges via `BadgeService` when players touch zone parts
  - No DataStore (badges handle their own persistence via Roblox)

### Zones
- **`Workspace.InsideZones`** — folder of part-based zones
- Touching a zone part triggers badge award

---

## Extension Plan (for XP integration)

When [[XP_Progression]] is built, this script either:
- **Option A (preferred):** stays as the badge-awarding system, and a new `Discovery` source module under `ProgressionService` watches the same zones and grants XP separately
- **Option B:** refactor into a single discovery service that both awards badge and grants XP

Lean toward Option A — keeps responsibilities separate, lets badges and XP evolve independently.

---

## Design Notes
- Zone entry should be **silent** — no toast, no sound, no UI flash
- Subtle confirmation only: maybe a gentle camera ease, faint particle bloom, or location title fade-in
- Each zone should have a name worth seeing — match the tone of [[Title_System]] level titles

## Open Questions
- How many zones are currently defined? (Need to count `InsideZones` children.)
- Are the zones aligned with named locations in [[../03_Map_Locations/_Map_Overview]]?
- Should a "title fade-in" appear when entering a notable zone? (Park in [[../08_Ideas_Parking_Lot/_Parking_Lot]] for now.)

## Related
- [[XP_Progression]]
- [[../03_Map_Locations/_Map_Overview]]
