# Decisions

> Forward-looking design-decision register. Append-only. Newest entries on top.
>
> **What belongs here:** choices made with reasoning that will outlive the moment they were made. Not "we shipped X" — that goes in `_Change_Log.md`. This is the *why*: why X over Y, what was considered, what was rejected.
>
> **What does NOT belong here:** stray ideas (→ `08_Ideas_Parking_Lot/`), open questions (→ `09_Open_Questions/`), shipped change records (→ `_Change_Log.md`), session recaps (→ `07_Sessions/`).
>
> **Lifecycle:** entries are written by Claude during end-of-session integration when a session involved a decision. They never get edited or deleted — if a decision is later reversed, append a new decision that supersedes the old one.
>
> **Why this file exists separately from the change log:** the change log records *what changed*; this file records *what choice was made*. Sometimes both apply (a decision shipped); sometimes only the decision exists (we picked an approach for a future build). Future-Claude needs both records, but for different reasons.

---

## Format

```
YYYY-MM-DD — <Topic>
- Decision: <one-sentence summary>
- Why: <reasoning, including what was rejected>
- Alternatives considered: <list>
- Lives in: <where the decision shows up — system spec, AGENTS.md, code path, etc.>
- Reversibility: <how hard it is to undo, if it matters>
- Supersedes: <prior decision date if this one replaces it; otherwise omit>
```

---

## 2026

### April

<!-- New entries go directly below this line -->

2026-04-27 — Decisions register starts here
- Decision: introduce `_Decisions.md` as a forward-looking design-decision register, separate from `_Change_Log.md` (which tracks shipped changes) and `09_Open_Questions/` (which tracks unresolved decisions).
- Why: the change log mixes "we shipped X" with "we picked approach A over B" entries. Searching for *why we chose what we chose* is harder than it needs to be. A separate file with one consistent shape makes the design-history searchable as its own thing without bloating the change log.
- Alternatives considered: (a) keep everything in change log with tighter formatting — rejected because the two genres really do answer different questions; (b) embed decisions inline in system specs only — rejected because cross-cutting decisions (workflow, environments, conventions) don't have a single system spec home; (c) backfill the existing change log into a decisions file — rejected as scope creep, not worth retroactive reclassification.
- Lives in: this file; pointer added to `AGENTS.md` "End of session — Wrap-up" routine, step 3.
- Reversibility: trivial — collapse back into change log if the file isn't earning its keep after a few months.

2026-04-27 — Cowork as Claude's host
- Decision: migrate Claude's host environment from claude.ai chat to the Cowork desktop tool. All MCP integrations preserved (Roblox Studio, GitHub, sadcave-repo filesystem, Obsidian); gained shell, structured task tracking, and persistent artifacts.
- Why: same capability surface plus extras, no capability lost. Persistent artifacts in particular open the door to a live "Sad Cave dev tracker" page that wasn't possible in chat.
- Alternatives considered: stay in claude.ai chat — rejected, no upside; partial migration (chat for design, Cowork for review) — rejected as needless context-splitting.
- Lives in: `00_Index.md` Tools section; this file; inbox 2026-04-27 Cowork session 1.
- Reversibility: trivial — the workflow doesn't depend on Cowork specifically; same MCPs work in chat.

2026-04-27 — Vault meta-doc structure: keep stale specs as Historical / Superseded
- Decision: when a system gets deleted (e.g. `LevelLeaderstats`, `DailyRewardsServer`), keep its `02_Systems/` spec in place with a Superseded or Removed banner instead of deleting the file.
- Why: the change log, sister specs, and other meta-docs reference these systems by their doc names (e.g. `[[Level_System]]` from `XP_Progression`). Deleting the file would break wikilinks and lose the audit trail. A short "this is historical" banner at the top makes the staleness obvious without breaking the link graph.
- Alternatives considered: delete the file outright — rejected (breaks links); move to a `_archived/` folder — rejected (still breaks `[[Wikilink]]` resolution unless every reference also updates).
- Lives in: `Level_System.md`, `Daily_Rewards.md`, `Level_Stat_System.md` (stub), and reflected in `00_Index.md`'s "Historical / Superseded" section.
- Reversibility: trivial — delete the file later if the audit-trail value fades.

2026-04-27 — Bookend routines formalized in AGENTS.md
- Decision: replace the informal "Re-orientation" section in `AGENTS.md` with explicit Start-of-Session, Reality Check, and End-of-Session bookend routines.
- Why: previously the re-orient was an ad-hoc 6-step list with no matching wrap-up; the wrap-up lived only inside The Loop step 6 prose. Vault drift between sessions (most visibly the 2026-04-25 → 2026-04-27 gap) is the failure mode this fixes. Making the bookends symmetric and explicit means each session starts with a known floor and ends with a known ceiling.
- Alternatives considered: leave as-is and rely on Claude's judgment — rejected, judgment fails when the session is rushed; build automation (Cowork scheduled task) for reality check — deferred as a follow-up, not rejected.
- Lives in: `AGENTS.md` "Session Bookends" section.
- Reversibility: easy — collapse the three sub-sections back into a single re-orient checklist if it feels heavy in practice.
