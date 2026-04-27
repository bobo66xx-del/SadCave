# Daily Rewards

**Status:** ⚫ Removed — deleted from testing place 2026-04-27 during cleanup pass. No replacement currently planned.

> **Why removed:** the Tone & Rules audit flagged daily rewards systems as a classic retention mechanic that clashes with Sad Cave's design rules (no excessive currencies, no "streak broken" pressure). Tyler removed `DailyRewardsServer` and the `DailyRewardsRemotes` during the 2026-04-27 cleanup. The `DailyRewards_LastClaim_v1` DataStore is no longer read from or written to by any live script.
>
> **If a return-acknowledgement experience is wanted later** (the tone-aligned alternative this doc previously sketched — a quiet visual cue when a returning player enters, no streak counter), that's a fresh design conversation, not a revival of this system. Reach for the parking lot first.
>
> Kept as historical record because the change log and `_Cleanup_Backlog` reference daily rewards by this doc's name.

---

## Purpose
Reward players who return — currently grants "shards" on a 24-hour cooldown.

## Player Experience
Open UI → claim daily reward → cooldown timer until next claim.

---

## Real Architecture (as built)

### Server
- **`ServerScriptService.DailyRewardsServer`**
  - 24-hour cooldown
  - Grants shard payouts
  - **DataStore key:** `DailyRewards_LastClaim_v1`
  - Exposes RemoteFunctions: `GetStatus`, `Claim`
  - Legacy aliases: `DailyRewardStatus`, `ClaimDailyReward`

---

## ⚠️ Tone Review Needed

Daily rewards systems are a **classic retention mechanic** that can clash with Sad Cave's design rules. Things to check:

1. **What are "shards" used for?** If they're just a vestigial currency — cut it. (Per [[../01_Vision/Tone_and_Rules]]: no excessive currencies.)
2. **Does the UI shame players for missing days?** ("Streak broken!", "Don't miss tomorrow!") — this is the opposite of Sad Cave's mood.
3. **Is there a cleaner version?** — quiet acknowledgement of return ("you came back") instead of a transaction.

### Tone-aligned alternative (proposal)
Replace mechanical daily-reward UX with:
- A **quiet visual cue** when a returning player enters (subtle particle, soft sound, brief acknowledgement from QuietKeeper)
- No streak counters
- No obligation to claim

---

## Open Questions
- What do shards actually do? (Need to check Shop / other systems.)
- Is there current Marketplace/monetization tied to daily rewards?
- Which UI surfaces this? (Probably part of the legacy menu system.)

## Related
- [[_Cleanup_Backlog]]
- [[../01_Vision/Tone_and_Rules]]
