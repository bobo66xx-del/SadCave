# Sad Cave — Index

> Quiet emotional Roblox exploration / hangout game.
> Mood, presence, subtle social interaction, peaceful discovery.

---

## 🎯 Current Priority

**Expand the map with more places to chill/explore, then build a smooth XP/progression system that rewards presence, exploration, and light interaction.**

Active focus this week:
- [ ] Continue live-only reconciliation — next priority items per [the audit](../../live-repo-audit.md): `fridge-ui`, `Theme`, `OverheadTagsToggleServer`. See [[06_Codex_Plans/2026-04-25_Live_Reconciliation_Continuation_v1]].

---

## ⚠️ Active Cleanup Backlog

Legacy systems to remove (do NOT extend these):
- Shop with Saber/Scythe/Gun/Rocket Launcher → see [[02_Systems/_Cleanup_Backlog]]
- `CashLeaderstats` and `DonationLeaderstats` → see [[02_Systems/_Cleanup_Backlog]]
- Duplicate SoftShutdown scripts, duplicate Menu ScreenGuis

---

## 🧭 Quick Links

### Vision
- [[01_Vision/Tone_and_Rules]]
- [[01_Vision/Project_Overview]]

### Active Systems
- [[02_Systems/Dialogue_System]] — 🟢 Shipped
- [[02_Systems/Title_System]] — 🟢 Shipped (cosmetic identity layer)
- [[02_Systems/Level_System]] — 🟡 Shipped, needs redesign
- [[02_Systems/XP_Progression]] — 🔵 Planned (current priority)
- [[02_Systems/NameTag_Status]] — 🟢 Shipped
- [[02_Systems/Area_Discovery]] — 🟢 Shipped (badges only, ready to extend)
- [[02_Systems/Daily_Rewards]] — 🟢 Shipped (review for tone fit)
- [[02_Systems/Cave_Outside_Lighting]] — 🔵 Planned
- [[02_Systems/Group_Member_Perks]] — ⚪ Idea
- [[02_Systems/_Cleanup_Backlog]] — Legacy systems to remove
- [[02_Systems/_Live_Systems_Reference]] — What's currently live in Studio (reference)
- [[02_Systems/_UI_Hierarchy]] — Live `StarterGui` structure (reference)

### Map
- [[03_Map_Locations/_Map_Overview]]

### NPCs
- [[05_NPCs/QuietKeeper]]

### Workflow & Capture
- [[_Workflow]] — how Opus + Codex + vault fit together (read this first on a fresh session)
- `AGENTS.md` (at repo root, `C:\Projects\SadCave\AGENTS.md`) — rules Codex follows when reading/writing the vault and the codebase
- `PLANS.md` (at repo root) — 🧊 historical context only; running history of repo-vs-Studio export passes from 2026-04-19 to 2026-04-20. Do not append.
- `docs/live-repo-audit.md` (at repo root) — authoritative export-status queue
- [[00_Inbox/_Inbox]] — unsorted captures, this session
- [[_Change_Log]] — append-only history of substantive changes

### Plans & Logs
- [[06_Codex_Plans/_Plan_Template]]
- [[07_Sessions/_Session_Template]]
- [[08_Ideas_Parking_Lot/_Parking_Lot]]
- [[09_Open_Questions/_Open_Questions]] — unresolved design decisions
- [[09_Open_Questions/_Known_Bugs]] — active bug tracker

---

## 🛠 Tools

- Roblox Studio (place: "Testing cave")
- Rojo repo: `SadCaveV2`
- Codex — implementation
- Claude Opus — planning, design, architecture
- Obsidian — this vault, project memory

---

## 📌 Status Legend

- 🟢 **Shipped** — live and working
- 🟡 **Building** — actively in progress
- 🔵 **Planned** — designed, not started
- ⚪ **Idea** — rough thought, not committed
- 🔴 **Cleanup** — legacy, to be removed
- ⚫ **Superseded** — plan written but replaced before execution; kept for history

---

## 📝 Notes

- Always check [[01_Vision/Tone_and_Rules]] before adding a new feature.
- Park stray ideas in [[08_Ideas_Parking_Lot/_Parking_Lot]] instead of expanding scope mid-task.
- Drop in-session captures into [[00_Inbox/_Inbox]] — Opus integrates at session end.
- Log every working session briefly in `07_Sessions/`.
- For **how the whole stack works** (Opus + Codex + vault), see [[_Workflow]].
