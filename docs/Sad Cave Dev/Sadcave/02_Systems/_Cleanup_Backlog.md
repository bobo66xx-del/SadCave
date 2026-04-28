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

### Placeholder TitleMenu — swap target for the polished v2 menu

The TitleMenu and the small `titles` toggle button shipped in PR #14 (2026-04-28 08:31 UTC) are **deliberate placeholders** — `src/StarterGui/TitleMenu/TitleMenuController.client.lua` and `src/StarterGui/TitlesToggleButton/TitlesToggleController.client.lua` are programmatic ugly-but-functional UIs whose explicit purpose is to let the data flow (manual equip, ownership view, locked hints) be tested end-to-end without spending design time before real titles are flowing through. The polished v2 TitleMenu is its own future Codex brief that drops in over the placeholder; Tyler will run a focused design session for it (per `_Decisions.md` 2026-04-28 — "TitleMenu build approach — placeholder first, polished menu deferred").

**What needs to happen when the polished menu lands:**
- Replace the `src/StarterGui/TitleMenu/` files with the polished implementation (could keep the same ScreenGui name to preserve `ResetOnSpawn = false` and the toggle button's instance lookup).
- Either replace `src/StarterGui/TitlesToggleButton/` with a new entry-point design or refactor it to fire a `BindableEvent` instead of poking `playerGui.TitleMenu.Root.Visible` directly (the placeholder's coupling is one of three carry-forward notes from PR #14's review).
- Voice-pass on the locked-row hint copy — current placeholder hints (e.g. "rest for a long while" for `fell_asleep_here`, "visit late at night" for `up_too_late`) telegraph achievement conditions more directly than the spec's "do something special" fallback. Tyler may want subtler/different voice in the polished pass.
- Replace the rebuild-on-every-event row rendering with a diff pattern (placeholder destroys+recreates all 56 rows on every `TitleDataUpdated` fire — fine at one player, target-of-opportunity for polish).
- Retire this entry once the polished menu ships.

**Decision needed:** none yet — Tyler picks the polished-menu design session timing.

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
