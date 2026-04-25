# Group / Member Perks

**Status:** ⚪ Idea — confirmed not built

No `GetRankInGroup` or group ID references found anywhere in the codebase. This is greenfield.

---

## Purpose
Reward Roblox group members with subtle, mood-appropriate perks. Drives community without compromising tone.

## Player Experience
Group members get **small, gentle** signals: maybe a faint nametag accent, a quiet ambient effect option, exclusive sitting spots, or a small XP bonus. Nothing flashy. Nothing that makes non-members feel locked out of the *experience*.

---

## What's Already Built (related)
- `Custom Chat Script` — has VIP and ADMIN gamepass configs (NameColor, ChatColor, Tag) under `AllUserFriends` and `Gamepasses` folders
- This is gamepass-based, not group-based — different system

## What's Missing
- No group membership check
- No perk service
- No nametag accent for group members
- No perk config

---

## Hard Rules
- ❌ No exclusive areas (would split the player base)
- ❌ No major XP multipliers (turns it into a grind game)
- ❌ No badges or "VIP" energy
- ✅ Cosmetic-leaning, low-key, atmospheric

## Perk Ideas (draft, not committed)
- Subtle nametag accent color (small tweak to the existing `NameTag` BillboardGui)
- Small ambient particle effect option (off by default)
- Slight XP nudge from [[XP_Progression]] presence ticks (e.g. +5–10%, not 2x)
- One small dialogue acknowledgement from QuietKeeper for members (extend [[Dialogue_System]] via `DialogueData`)

---

## Proposed Technical Structure

### Server
- **`ServerScriptService.Membership.GroupPerkService`**
  - On player join: `Players:GetRankInGroup(GROUP_ID)` (with `pcall`)
  - Cache result on the player (attribute: `IsGroupMember`)
  - Other systems (NameTag, Progression) read this attribute

### Config
- **`ReplicatedStorage.Membership.PerkConfig`** — small config module
  - GROUP_ID
  - Tier definitions (if any)
  - Perk toggles

---

## Open Questions
- What's the group name and ID?
- One perk tier, or multiple ranks? (Lean: one — keeps it simple and avoids hierarchy energy)
- Do gamepass VIPs and group members get the same perks, or distinct treatments? (Lean: distinct, since the relationships are different)

## Related
- [[XP_Progression]]
- [[NameTag_Status]]
- [[Dialogue_System]]
