# Workflow — Sad Cave Dev Stack

> How design, planning, and implementation flow across **You + Opus + Codex + Studio + Vault**.
> Read this at the start of any fresh session to re-orient.

---

## The Stack

| Role              | Who                       | What they do                                              |
| ----------------- | ------------------------- | --------------------------------------------------------- |
| Director          | You                       | Taste, final call, hands-on Studio work for visual/feel   |
| Planner           | Opus (Claude, in chat)    | Design, architecture, vault keeper, spec writer           |
| Builder           | Codex                     | Luau implementation, Studio changes via MCP, Rojo commits |
| Source of intent  | Obsidian vault            | What we're building and why                               |
| Source of reality | Roblox Studio + Rojo repo | What actually exists                                      |

**The core split:** Opus doesn't write code. Codex doesn't design. Both can read and write the vault — it's the shared workspace that lets them stay in sync without you re-explaining context.

---

## The Loop

### 1. Design (with Opus)
- You and Opus talk through a system or change here in chat.
- Opus updates the relevant `02_Systems/` note as the conversation goes.
- Decisions get logged. Open questions get flagged.
- By end of conversation, the system note **is** the spec.

### 2. Handoff brief (Opus → Codex)
- When a system is ready to build, Opus writes a plan in `06_Codex_Plans/` using `_Plan_Template.md`.
- Filename: `YYYY-MM-DD_System_Name_v1.md`.
- The brief is short, declarative, self-contained. Codex reads it directly from the vault — no copy-paste needed.
- Codex follows wikilinks (e.g. to `01_Vision/Tone_and_Rules`, related `02_Systems/` notes) for context.

### 3. Build (with Codex)
- You drive Codex against the brief.
- Codex writes Luau, modifies Studio via MCP, commits through Rojo.
- Codex captures observations to `00_Inbox/_Inbox.md` as it works (prefix `[C]`).
- Codex updates the **Status** field of its plan file (🔵 → 🟡 → 🟢).
- This is where most of the actual building happens.

### 4. Capture (You + Opus + Codex → Inbox)
- While work is happening, observations get dumped into `00_Inbox/_Inbox.md`.
- One line per entry. Timestamped. Prefixed `[U]` (you), `[O]` (Opus), or `[C]` (Codex).
- Use `?` for unresolved items needing your decision.
- No structure. Just capture.

### 5. Codex review (Opus, before integration)
- After Codex finishes a build, Opus reads the resulting scripts via Studio MCP.
- Compares against the handoff brief.
- Flags drift in the inbox: "spec said cooldown 3s, code has 5s — intentional?"
- You decide: accept the drift (update the spec) or fix it (update the code).

### 6. Integrate (Opus, end of session)
- You say "let's integrate" or just "wrap up."
- Opus reads the inbox + relevant system notes and reconciles:
  - Updates `02_Systems/` notes to match what got built
  - Appends substantive changes to `_Change_Log.md`
  - Moves unresolved `?` items to `09_Open_Questions/`
  - Clears the inbox (today's section)
- Opus writes a session recap in `07_Sessions/` using `_Session_Template.md`.

---

## Folder Map

| Folder | Purpose | Lifecycle |
|--------|---------|-----------|
| `00_Inbox/` | Unsorted captures, this session | Empties end of session |
| `01_Vision/` | Tone, rules, north star, project overview | Stable, rarely edited |
| `02_Systems/` | One note per system. The spec. Plus meta-docs (`_Cleanup_Backlog`, `_Live_Systems_Reference`, `_UI_Hierarchy`). | Updated as design evolves |
| `03_Map_Locations/` | Map + locations | Updated as map expands |
| `04_Dialogue/` | Dialogue content | Updated as NPCs grow |
| `05_NPCs/` | NPC notes | Updated as NPCs added |
| `06_Codex_Plans/` | Handoff briefs to Codex (design-driven tasks) | One file per build, archived after ship |
| `07_Sessions/` | Session recaps | Append-only |
| `08_Ideas_Parking_Lot/` | Stray ideas, not committed | Persistent, may never be used |
| `09_Open_Questions/` | Unresolved design questions + `_Known_Bugs` | Persistent until decided |
| `_Change_Log.md` | History of substantive changes | Append-only, permanent |
| `00_Index.md` | Top-level map | Updated when status changes |

## Surfaces Outside the Vault

The vault is the design layer. Two repo-level surfaces sit beside it:

| Surface | Purpose | Who writes |
|---------|---------|-----------|
| `AGENTS.md` (repo root) | Codex's rules — vault access boundaries, build loop, code conventions, no-touch systems, cleanup backlog | Opus, only when workflow itself changes |
| `PLANS.md` (repo root) | Live-reconciliation plans — the running history of repo-vs-Studio export passes since 2026-04-19. Each plan: Goal/Scope/Non-goals/Risks/Steps/Validation/Status | Codex appends Status log entries; Opus reviews at integration |
| `docs/live-repo-audit.md` (repo root) | Authoritative classification of every live object's export status (exact / structurally mapped / tooling blocker / duplicate-name blocker / manual export needed). The queue. | Codex updates as items move between buckets |

**Why two planning surfaces?** `06_Codex_Plans/` is for design-driven tasks where Opus writes a self-contained brief and Codex builds it. `PLANS.md` is for the ongoing infrastructure work that started before the vault existed and has its own format (Goal/Scope/Status log). They don't compete — they cover different kinds of work.

---

## Decisions Locked In

- **Inbox:** All three (you, Opus, Codex) write to it. Prefixes `[U]` / `[O]` / `[C]` distinguish.
- **Codex review:** Opus reads Codex's output before integration and flags drift from spec.
- **Integration cadence:** End of every session by default.
- **Vault role:** Design doc / spec — what we're building and why. Not a code mirror.
- **Codex write boundaries:** Codex writes to `00_Inbox/_Inbox.md` and the `Status` field of its current plan file. Codex does NOT edit `01_Vision/`, `02_Systems/`, `_Change_Log.md`, or any other design surface. Design changes happen with Opus, in chat.

---

## Anti-patterns (things that will break this flow)

- **Inbox never gets integrated** → vault drifts, becomes useless. Mitigation: integration at end of every session by default.
- **System notes get edited mid-build without going through inbox** → Opus and you both editing the same note simultaneously. Mitigation: during active building, observations go to inbox; system notes get updated only at integration.
- **Codex implements without a brief** → vault doesn't reflect what was built. Mitigation: every system going to Codex gets a `06_Codex_Plans/` file first.
- **Codex edits design surfaces** → silent drift, design conversation skipped. Mitigation: convention-only — Codex's instructions tell it to write only to inbox + plan Status. Opus reverts unauthorized edits during integration if it happens.
- **Change log fills up with stray thoughts** → loses signal. Mitigation: only substantive shipped changes go in change log; ideas go to parking lot, questions go to open questions.

---

## Re-orientation checklist (start of fresh session)

When opening a new chat with Opus on this project:
1. Opus reads `00_Index.md` → current priority and active systems
2. Opus reads `00_Inbox/_Inbox.md` → anything pending from last session
3. Opus reads most recent file in `07_Sessions/` → where we left off
4. Opus reads `09_Open_Questions/_Open_Questions.md` → outstanding decisions
5. Opus reads `01_Vision/Tone_and_Rules` → the north star, before any design work
6. Opus reads `AGENTS.md`, `PLANS.md`, and `docs/live-repo-audit.md` (at repo root) — these are the sibling surfaces to the vault and contain Codex's rules + live-reconciliation history + the export-status queue

> **Codex's rules** live in `AGENTS.md` at the repo root (`C:\Projects\SadCave\AGENTS.md`), not in the vault. Opus reads it once at the start of a fresh session for shared context, but does not edit it during normal design work — update it only when the workflow itself changes.
