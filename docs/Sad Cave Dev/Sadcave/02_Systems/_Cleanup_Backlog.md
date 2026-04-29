# Cleanup Backlog

> **Last refreshed:** 2026-04-27 — Tyler executed most of this list during the testing-place cleanup pass. The remaining items are documented below.
>
> **What this doc is for:** legacy systems and template leftovers slated for removal or refactor. Don't extend anything listed here as still-pending — strip it.

---

## ✅ Completed in 2026-04-27 Cleanup

For the audit trail. Each of these is gone from the testing place. None of them need further removal work.

- **🔴 Combat-tool Shop** — `Shop`, `ShopService`, `ShopCatalog`, `ShopItems` (Saber/Scythe/Gun/Rocket Launcher/Book), `ShopRemotes`, `ShopMenu` UI, `Remotes.Shop` — all deleted.
- **🔴 Cash currency** — `CashLeaderstats`, `ShardsSave` writes, session shard milestones, `Shards` IntValue sources — deleted. `Shards` no longer exists in player state.
- **🔴 Daily Rewards** — `DailyRewardsServer`, `DailyRewardsRemotes`, `DailyRewardStatus`, `ClaimDailyReward` — deleted. Tone-aligned alternative is parking-lot territory; not in active queue.
- **🔴 Title v1 pipeline** — `TitleService`, `TitleConfig`, `TitleEffectPreview`, `TitleRemotes`, `TitleMenu` UI, plus the title-rendering side of `NameTagScript Owner` — deleted. v2 redesign in [[Title_System]] now builds on a blank slate.
- **🔴 Admin tools** — `AdminServerManager`, `ReplicatedStorage.Admin` (and embedded admin GUI) — deleted. **Reports system kept** (`ReportHandler`, `ReportRemotes`).
- **🔴 Theme color override** — `ServerScriptService.Theme` + `StarterPlayerScripts.Theme` + `Remotes.Theme` — deleted. `Workspace.Theme` parts (if any) are now decorative-only with no script driving them.
- **🔴 Sprint** — `StarterCharacterScripts.Sprint` — deleted. Walk speed is default.
- **🔴 Area Discovery (badge-only version)** — `AreaDiscoveryBadge` deleted. See [[Area_Discovery]] — the XP follow-up `Discovery` source will reintroduce both badge + XP in a unified rewrite.
- **🔴 Old level system** — `LevelLeaderstats`, `Levelup` chat client, `Remotes.LevelUp` — deleted. See [[Level_System]] for the historical record. `LevelSave` DataStore is read once during migration in `ProgressionService` then ignored thereafter.
- **🔴 Old AFK plumbing** — `AFK` server, `AFKLS` client — deleted. New `AfkEvent` + `AfkDetector` replace them.
- **🔴 Duplicate / template UI** — `Menu` (×2), `Settings` (legacy), `IntroScreen`, `Custom Inventory`, `ComputerUI`, `fridge-ui`, `SadCaveMusicGui`, `bruh`, `TTTUI`, `NotificationTHingie`, two generic `ScreenGui` orphans — deleted.
- **🔴 Backpack tweak** — `BackpackCoreGuiController` deleted.
- **🔴 SoftShutdown duplicates** — kept one canonical `SoftShutdown`; duplicates deleted.
- **🔴 Custom chat scripts** — `Custom Chat Script`, `TextChatServiceHandler`, `ChatTag` — deleted (chat now uses Roblox defaults).

---

## 🟡 Still Pending Decision

### Placeholder TitleMenu — retired 2026-04-29 (PR #23)

The placeholder TitleMenu and `titles` toggle button shipped in PR #14 were retired by **PR #23 (merged 2026-04-29 10:48:45 UTC, branch `codex/title-polish-pass`)**. `TitleMenuController.client.lua` was rewritten as the polished right-side drawer with six category sections, mixed-voice locked hints, BindableEvent decoupling, row diffing on `TitleDataUpdated`, and four close paths. `TitlesToggleController.client.lua` was rewritten as a slim 18×90px right-edge tab with rotated `titles` text. All three carry-forwards from PR #14's review (BindableEvent decoupling, voice-pass hints, row diffing) were folded into the polish-pass spec and shipped in the same brief. No further action needed — entry kept for the audit trail of when this transitioned.

### Donations / Tips

`TipProductConfig` and any `tipui` / `tipframe*` ScreenGui (verify if `tipui` survived the cleanup).

**Status:** decision still pending from before the cleanup. Tyler hadn't decided whether donations stay.

**Decision needed:**
- ✅ Keep donations as a gentle support option (low-key tip jar fits the tone)
- ❌ Remove if it adds visual clutter or social pressure

For now: **document, don't remove.** Visit when the tone-fit pass reaches monetization.

### Dialogue (kept; verify scope)

The kept set per the cleanup log is "dialogue scripts." Multiple components plausibly fall under that label: `DialogueDirector`, `NpcDialogueClient`, `PlayerDialogueClient`, `DialogueData`, the four `DialogueRemotes`. Next session that touches dialogue should walk the live tree and confirm each piece is still live and as expected. No removal pending — this is just a verification task.

---

## ⚪ Tech Debt to Watch (low priority)

- `Avalog` analytics package in Workspace — large external integration tied into `FavoritePromptPersistence`. No removal action; just don't touch `PlayerDataStore` paths casually.
- `Brushtool2_Plugin_Storage` in ServerStorage — leftover from the Brushtool plugin; can probably be deleted whenever someone is in there.
- Duplicate tree models in Workspace — `MapleTree`, `MapleTree2`, `MapleTree 3`, `MapleTree.5`, etc. Polish during next map pass, no urgency.
- Stale lighting configs — there used to be `Lighting.v1`, `V2`, `final`, `build`. With `Theme` deleted there's no script driving any of them; verify which one is currently active and consider naming it (`Lighting.Presets.Cave` etc.) per the [[Cave_Outside_Lighting]] proposal.

---

## Removal Order (no longer needed)

The original ordered removal plan is moot — Tyler did most of it in one pass. The remaining work is the Donations decision (when monetization gets a fresh tone-fit conversation) and any small follow-up cleanup that surfaces during normal work.
