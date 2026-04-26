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

**The core split:** Opus doesn't write code. Codex doesn't design. Both *read* the vault freely — it's the shared workspace that lets them stay in sync without you re-explaining context. *Writes* are scoped: Opus owns design surfaces, Codex writes only to `00_Inbox/_Inbox.md` and the `Status` field of its current plan. Full write rules are in `AGENTS.md`.

---

## The Loop

### 1. Design (with Opus)
- You and Opus talk through a system or change here in chat.
- Opus updates the relevant `02_Systems/` note as the conversation goes.
- Decisions get logged. Open questions get flagged.
- Opus may use `execute_luau` (Studio MCP) to query live state during design — current values, instance properties, quick calculations — without breaking conversation flow.
- By end of conversation, the system note **is** the spec.

### 2. Handoff brief (Opus → Codex)
- When a system is ready to build, Opus writes a plan in `06_Codex_Plans/` using `_Plan_Template.md`.
- Filename: `YYYY-MM-DD_System_Name_v1.md`.
- The brief is short, declarative, self-contained. Codex reads it directly from the vault — no copy-paste needed.
- Codex follows wikilinks (e.g. to `01_Vision/Tone_and_Rules`, related `02_Systems/` notes) for context.

### 3. Build (with Codex)
- You drive Codex against the brief.
- Codex writes Luau in the Rojo source tree (Rojo syncs files to Studio), uses Studio MCP for Studio-only changes (instances/properties not in the Rojo tree), and commits via git.
- Codex captures observations to `00_Inbox/_Inbox.md` as it works (prefix `[C]`).
- Before marking 🟢, Codex playtests via `start_stop_play` + `console_output` (Studio MCP) and notes the result in the inbox: errors, expected behavior confirmed, anything weird.
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
- Reads Codex's playtest notes from the inbox. Spot-checks with `start_stop_play` + `console_output` if the system is high-risk or Codex's notes are thin.
- Flags drift in the inbox: "spec said cooldown 3s, code has 5s — intentional?"
- You decide: accept the drift (update the spec) or fix it (update the code).

### 6. Integrate (Opus, end of session)
- You say "let's integrate" or just "wrap up."
- Opus reads the inbox + relevant system notes and reconciles:
  - Updates `02_Systems/` notes to match what got built
  - Appends substantive changes to `_Change_Log.md`
  - Moves unresolved `?` items to `09_Open_Questions/`
  - Logs any Codex-generated placeholder assets in `02_Systems/_Cleanup_Backlog.md` so they don't accumulate untracked
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
| `PLANS.md` (repo root) | **Historical context only.** Running history of repo-vs-Studio export passes from 2026-04-19 to 2026-04-20, written before the vault existed. Read for prior decisions; never appended to. | Nobody. Frozen. |
| `docs/live-repo-audit.md` (repo root) | Authoritative classification of every live object's export status (exact / structurally mapped / tooling blocker / duplicate-name blocker / manual export needed). The queue. | Codex updates as items move between buckets |

**One planning surface, going forward.** All new plans — design-driven *and* live-reconciliation — live in `06_Codex_Plans/`. `PLANS.md` is sealed for context, not extended.

**`AGENTS.md` is the Codex-facing mirror of `_Workflow.md`.** When workflow rules change that affect Codex (build loop, validation, write boundaries, conventions), update `AGENTS.md` in the same edit pass. The two documents are paired — drift between them creates silent disagreements about how the loop works.

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
- **Codex playtests but writes perfunctory observations** → playtest theater, no real validation. Mitigation: format expectation in step 3 ("errors, expected behavior confirmed, anything weird"). If a playtest note is just `[C] Playtested: ok`, treat it as unverified — Opus spot-checks during review.
- **Generated placeholder assets accumulate untracked** → asset bloat over time, no one remembers what's placeholder vs final. Mitigation: integration logs Codex-generated placeholders to `_Cleanup_Backlog.md`; when real art ships, the placeholder swap gets flagged in the inbox so the entry can be retired.

---

## Re-orientation checklist (start of fresh session)

When opening a new chat with Opus on this project:
1. Opus reads `00_Index.md` → current priority and active systems
2. Opus reads `00_Inbox/_Inbox.md` → anything pending from last session
3. Opus reads most recent file in `07_Sessions/` → where we left off
4. Opus reads `09_Open_Questions/_Open_Questions.md` → outstanding decisions
5. Opus reads `01_Vision/Tone_and_Rules` → the north star, before any design work
6. Opus reads `AGENTS.md` and `docs/live-repo-audit.md` (at repo root) — Codex's rules and the export-status queue. (`PLANS.md` is also at repo root but is historical-only; read it only when you need context on prior reconciliation decisions.)

> **Codex's rules** live in `AGENTS.md` at the repo root (`C:\Projects\SadCave\AGENTS.md`), not in the vault. Opus reads it once at the start of a fresh session for shared context, but does not edit it during normal design work — update it only when the workflow itself changes.
