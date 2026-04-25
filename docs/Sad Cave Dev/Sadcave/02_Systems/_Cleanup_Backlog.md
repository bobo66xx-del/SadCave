# Cleanup Backlog

Legacy systems and template leftovers to remove or refactor. Do not extend these — strip them.

Each item has: what it is, what to remove, and what to be careful of.

---

## 🔴 Shop System (combat items)

**What it is:**
- `ServerScriptService.Shop` + `ServerScriptService.ShopService`
- `ReplicatedStorage.ShopCatalog`
- `ReplicatedStorage.ShopItems` — Saber, Scythe, Book, Gun, Rocket Launcher (each with `Price` IntValue)
- `ReplicatedStorage.ShopRemotes`
- `StarterGui.ShopMenu`

**Why it goes:** Saber/Scythe/Gun/Rocket Launcher clash hard with Sad Cave's tone (no flashy/combat items, no aggressive monetization).

**Removal plan:**
1. Inventory which items are actually purchasable in-game right now (some may be dead code)
2. Remove combat items from `ShopItems`
3. Decide: kill the entire Shop UI, or keep the framework for tone-aligned cosmetic items only (e.g. lanterns, calm decorative tools)
4. Audit any reference to `ShopRemotes` or `ShopService` elsewhere
5. Remove `StarterGui.ShopMenu`
6. Update `TitleConfig` if any "shop" category titles depend on shop purchases (30 shop titles exist)

**Watch out for:**
- Player save data — if anything records owned items via DataStore, decide if that gets cleared or migrated
- `TipProductConfig` — if this is connected to the shop, evaluate together

---

## 🔴 Cash Currency

**What it is:**
- `ServerScriptService.CashLeaderstats`
- Likely tied to the Shop above

**Why it goes:** Vision rule — no excessive currencies. Sad Cave shouldn't have a cash economy.

**Removal plan:**
1. Find all references to `Cash` (grep `CashLeaderstats`, `Cash.Value`, `leaderstats.Cash`)
2. Remove the leaderstat
3. Remove any earning sources (probably tied to the legacy XP source — verify before removing)
4. Confirm no shop dependency before deletion

**Watch out for:**
- ⚠️ If `CashLeaderstats` is currently the source that feeds level-up triggers, removing it before [[XP_Progression]] is built will leave players unable to level up. Build the new XP system first, swap, then remove.

---

## 🟡 Donations

**What it is:**
- `ServerScriptService.DonationLeaderstats`
- `ServerScriptService.DonationAmount`
- `ReplicatedStorage.TipProductConfig`

**Status:** Donations are different from "Cash" — they're a Robux-funded support feature. Decide separately whether donations stay.

**Decision needed:**
- ✅ Keep donations as a gentle support option (low-key tip jar fits the tone)
- ❌ Remove if it adds visual clutter or social pressure

For now: **document, don't remove.** Visit later.

---

## 🔴 Duplicate / Cluttered Files

**Duplicates found:**
- Multiple SoftShutdown scripts (`ServerScriptService.SoftShutdown` + `ReplicatedFirst.SoftShutdownClient` is correct, but check for additional copies)
- Multiple Menu ScreenGuis in `StarterGui` — verify which is current
- Lighting configurations: `v1`, `V2`, `final`, `build` (all in `Lighting`) — only one should be active

**Cleanup plan:**
1. Identify the canonical version of each duplicate
2. Move others to a `_legacy/` folder for one session, run the game
3. If nothing breaks, delete

---

## 🟡 Combat Tools in Inventory

**What it is:** `Custom Inventory` ScreenGui in `StarterGui` may surface combat tools from the Shop.

**Action:** Audit after Shop cleanup. Inventory itself can stay — just make sure it only displays tone-appropriate items.

---

## 🟡 TTTUI

**What it is:** `StarterGui.TTTUI` — looks like a "Trouble in Terrorist Town" UI from a template.

**Action:** Confirm it's unused, then remove.

---

## ⚪ Tech Debt to Watch

- `Avalog` analytics package in Workspace — large external integration; confirm it's still wanted before extending it
- `Brushtool2_Plugin_Storage` in ServerStorage — leftover from the Brushtool plugin; can probably be deleted
- Many tree models with similar names (`MapleTree`, `MapleTree2`, `MapleTree 3`, `MapleTree.5`) — clean up duplicates when you next touch the map
- `Workspace.bruh` analytics frame — looks like a debug overlay; remove from production

---

## Removal Order (recommended)

1. **First:** Build [[XP_Progression]] so you don't break leveling when Cash goes
2. Remove combat items from Shop
3. Remove Cash currency
4. Decide on Daily Rewards tone alignment ([[Daily_Rewards]])
5. Cleanup duplicates (SoftShutdown, Menu, Lighting configs)
6. Remove TTTUI and other obvious dead UI
7. Audit `Avalog` and tree duplicates last
