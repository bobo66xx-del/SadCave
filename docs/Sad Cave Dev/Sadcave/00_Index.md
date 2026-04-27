# Sad Cave — Index

> Quiet emotional Roblox exploration / hangout game.
> Mood, presence, subtle social interaction, peaceful discovery.

---

## 🎯 Current Priority

**Land the repo-strip housekeeping brief, then move into the next XP follow-up.** The XP Progression MVP shipped 2026-04-27 and Tyler did a heavy testing-place cleanup the same day. Vault has been refreshed to match reality. Repo-strip brief is queued for Codex.

Active focus:
- [ ] Hand the repo-strip brief to Codex — `[[06_Codex_Plans/2026-04-27_Repo_Strip_to_Studio_State_v1]]`. Verifies the three new artifacts (`NameTagScript`, `AfkEvent`, `AfkDetector`) are in repo, retires `xp-only.project.json`, freezes or refreshes `docs/live-repo-audit.md`.
- [ ] Walk the post-merge testing-place checks listed in `09_Open_Questions/_Open_Questions` (sitting boost at a real `SeatMarker`, level-up animation, gamepass +22 tick, mobile bar height, second-join migration, DataStore failure).
- [ ] Pick the next XP follow-up to design — Discovery source, Conversation source, AchievementTracker, or jump straight to Title v2. See [[02_Systems/XP_Progression]] follow-up list.

Recently completed:
- ✅ XP Progression MVP merged via PR #1 (2026-04-27).
- ✅ Tyler's heavy testing-place cleanup deleted most legacy systems (2026-04-27).
- ✅ Vault refreshed to match post-cleanup reality (2026-04-27, Cowork session 1).
- ✅ Migration to Cowork — same MCPs wired up, no capability lost.

---

## 🧭 Quick Links

### Vision
- [[01_Vision/Tone_and_Rules]]
- [[01_Vision/Project_Overview]]

### Active Systems
- [[02_Systems/XP_Progression]] — 🟡 Building (MVP shipped, follow-ups pending)
- [[02_Systems/NameTag_Status]] — 🟢 Shipped (rebuilt 2026-04-27, name-only minimal version)
- [[02_Systems/Dialogue_System]] — 🟢 Shipped (early version live; verify scope next session)
- [[02_Systems/Title_System]] — 🔵 Planned (v2 redesign; v1 deleted in cleanup)
- [[02_Systems/Area_Discovery]] — 🔵 Planned (legacy badge script deleted; will be rebuilt as part of XP Discovery source)
- [[02_Systems/Cave_Outside_Lighting]] — 🔵 Planned
- [[02_Systems/Group_Member_Perks]] — ⚪ Idea
- [[02_Systems/Choice_UI_Panel]] — 🟢 Shipped (lives inside dialogue clients)
- [[02_Systems/Cinematic_Subtitle_Panel]] — 🟢 Shipped (lives inside dialogue clients)

### Historical / Superseded
- [[02_Systems/Level_System]] — ⚫ Superseded by XP_Progression (deleted 2026-04-27)
- [[02_Systems/Daily_Rewards]] — ⚫ Removed in 2026-04-27 cleanup
- [[02_Systems/Level_Stat_System]] — Replaced stub, see XP_Progression and Level_System

### Reference / Meta
- [[02_Systems/_Live_Systems_Reference]] — what's currently in Studio (refreshed 2026-04-27)
- [[02_Systems/_UI_Hierarchy]] — `StarterGui` structure (refreshed 2026-04-27)
- [[02_Systems/_Cleanup_Backlog]] — what was cleaned, what's still pending (donations decision)
- [[02_Systems/_No_Touch_Systems]] — must-not-modify list (refreshed 2026-04-27)

### Map
- [[03_Map_Locations/_Map_Overview]]

### NPCs
- [[05_NPCs/QuietKeeper]]

### Workflow & Capture
- **`AGENTS.md`** (at repo root, `C:\Projects\SadCave\AGENTS.md`) — the workflow doc + Codex rules. Read this first on a fresh session.
- [[_Workflow]] — stub pointing at AGENTS.md (kept so the vault still finds it).
- `PLANS.md` (at repo root) — 🧊 historical context only.
- `docs/live-repo-audit.md` (at repo root) — currently stale; the repo-strip brief decides whether to refresh or freeze.
- [[00_Inbox/_Inbox]] — unsorted captures, this session
- [[_Change_Log]] — append-only history of substantive changes

### Plans & Logs
- [[06_Codex_Plans/_Plan_Template]]
- [[06_Codex_Plans/2026-04-25_XP_Progression_MVP_v1]] (shipped)
- [[06_Codex_Plans/2026-04-27_Repo_Strip_to_Studio_State_v1]] (queued for Codex)
- [[07_Sessions/_Session_Template]]
- [[08_Ideas_Parking_Lot/_Parking_Lot]]
- [[09_Open_Questions/_Open_Questions]] — unresolved design decisions
- [[09_Open_Questions/_Known_Bugs]] — active bug tracker

---

## 🛠 Tools

- **Roblox Studio** (place: `Testing cave`) — runtime
- **Rojo repo:** `SadCaveV2` (`C:\Projects\SadCave\`) — source of truth
- **Codex** — implementation
- **Claude (in Cowork)** — planning, design, architecture, review (formerly Claude Opus in chat)
- **Obsidian** — this vault, project memory
- **GitHub MCP** — branch review, PR management
- **Cowork desktop tool** — current host for Claude (migrated 2026-04-27)

---

## 📌 Status Legend

- 🟢 **Shipped** — live and working
- 🟡 **Building** — actively in progress
- 🔵 **Planned** — designed, not started
- ⚪ **Idea** — rough thought, not committed
- 🔴 **Cleanup** — legacy, to be removed
- ⚫ **Superseded** — replaced or deleted; doc kept for history

---

## 📝 Notes

- Always check [[01_Vision/Tone_and_Rules]] before adding a new feature.
- Park stray ideas in [[08_Ideas_Parking_Lot/_Parking_Lot]] instead of expanding scope mid-task.
- Drop in-session captures into [[00_Inbox/_Inbox]] — Opus integrates at session end.
- Log every working session briefly in `07_Sessions/`.
- For **how the whole stack works** (Claude + Codex + vault), see `AGENTS.md` at the repo root.
- **Production caveat:** the testing place was cleaned 2026-04-27. If the live production place still runs the older systems, several pieces of the vault — most notably `_No_Touch_Systems` and `Title_System`'s migration plan — apply differently for production cutover.
