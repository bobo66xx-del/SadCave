# Daily Rewards

**Status:** 🟢 Shipped — review for tone fit

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
