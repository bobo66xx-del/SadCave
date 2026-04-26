# Sad Cave — Index

> Quiet emotional Roblox exploration / hangout game.
> Mood, presence, subtle social interaction, peaceful discovery.

---

## 🎯 Current Priority

**Build the new XP progression system, then redesign the title system on top of it.** Replaces the legacy time-only level system with one that rewards presence, exploration, and light interaction.

Active focus:
- [ ] Ship XP Progression MVP — `ProgressionService` + `PresenceTick` + `XPBar`. See [[06_Codex_Plans/2026-04-25_XP_Progression_MVP_v1]].
- [ ] Then: follow-up briefs for Discovery/Conversation sources, AchievementTracker, and Title System v2.

Recently completed:
- ✅ Live reconciliation top-priority queue cleared (session 3, 2026-04-25). See [[06_Codex_Plans/2026-04-25_Live_Reconciliation_Continuation_v1]].

---

## ⚠️ Active Cleanup Backlog

Legacy systems to remove (do NOT extend these):
- Shop with Saber/Scythe/Gun/Rocket Launcher → see [[02_Systems/_Cleanup_Backlog]]
- `CashLeaderstats` and `DonationLeaderstats` → see [[02_Systems/_Cleanup_Backlog]] (Cash removal blocked until XP Progression ships)
- Duplicate SoftShutdown scripts, duplicate Menu ScreenGuis
- Old `LevelLeaderstats` and `Levelup` chat notification — retired by XP Progression MVP

---

## 🧭 Quick Links

### Vision
- [[01_Vision/Tone_and_Rules]]
- [[01_Vision/Project_Overview]]

### Active Systems
- [[02_Systems/Dialogue_System]] — 🟢 Shipped
- [[02_Systems/Title_System]] — 🔵 Planned (v2 redesign; v1 still live until v2 ships)
- [[02_Systems/Level_System]] — 🟡 Shipped, being replaced by [[02_Systems/XP_Progression]]
- [[02_Systems/XP_Progression]] — 🟡 Building (MVP plan written, ready for Codex)
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
