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

2026-04-27 — Workflow sync hardening
- Decision: tighten the vault workflow with three new rules to make sync drift visible and enforceable rather than implicit.
  1. **Opus inbox-first.** Before any vault edit during a session, Opus writes an `[O]` inbox line stating what's about to change and why.
  2. **Start-of-session GitHub sync.** As part of the re-orient routine (now step 5), query `mcp__github__list_pull_requests` and reconcile every PR merged since the last session recap against the change log, plan-file Status, and the index. Codex executions that landed between sessions stop being invisible.
  3. **End-of-session consistency validation.** As part of integration (now step 6), explicit cross-checks: every PR merged this session has a change-log entry; every plan file has Status; every Shipped status names a real PR; index Plans/Active Systems statuses match the underlying files.
- Why: today's session surfaced four sync failures in one stretch — index queueing a brief that already shipped, plan files lacking status, change log out of order with a prepend-bug fusing two entries, and the inbox going silent for `[O]` writes. Root cause was always "manual discipline gap that nothing enforces." These three rules turn each failure mode into a checkable invariant: the inbox-first rule traps Opus drift mid-session, the GitHub sync traps cross-session Codex drift, and the validation step traps emerging drift before it compounds.
- Alternatives considered: (a) automate the checks with a `validate-vault.sh` script — rejected for now because the manual checks are short and adding tooling adds maintenance burden; revisit if the manual checks fail twice. (b) Reduce surfaces by stripping status emojis from the index Plans/Active Systems sections (forcing readers to open plan/system files individually) — rejected because the index's at-a-glance read is high value at start-of-session; the validation step solves the drift without losing read speed. (c) Move plan-status to dataview-style auto-generation from frontmatter — rejected as scope creep; the static convention works once integration enforces it.
- Lives in: `AGENTS.md` (Section 4 Capture, Start-of-Session bookend step 5, End-of-Session bookend step 6); `_Plan_Template.md` (Status field); `_Change_Log.md` (format header).
- Reversibility: trivial. Each rule is a few sentences in `AGENTS.md`; rolling back is a delete.
- Supersedes: none — this is the first formalization of cross-session sync discipline.

2026-04-27 — Change-log format hardening
- Decision: change-log entries use `YYYY-MM-DD HH:MM UTC — [System] — ...` when the timestamp is known (PR merges, hard scheduled events) and `YYYY-MM-DD (<session label>)` otherwise. Sorted newest-on-top **by event time**, not by write time. Examples in the format footer of `_Change_Log.md`.
- Why: the 2026-04-27 block had drift where session 1 entries were sorted above PR #2 (10:13 UTC) even though PR #2 happened earlier. The cause was ambiguous "newest on top" — which can mean event-time or write-time. Forcing UTC timestamps disambiguates and makes ordering audit-trivial. A separate prepend-bug also fused PR #3's entry with leftover text from the Housekeeping brief entry; that's not a format issue per se, but the format clarity makes such bugs more visible the next time they happen.
- Alternatives considered: (a) keep "newest on top" with no timestamp requirement — rejected, that's what got us into this mess. (b) ISO-8601 with seconds (`14:00:00 UTC`) — rejected as overkill for human-readable changelog; minute precision is enough.
- Lives in: `_Change_Log.md` header and format footer; `AGENTS.md` End-of-Session bookend step 2.
- Reversibility: trivial.

2026-04-27 — Plan-file Status convention
- Decision: every file in `06_Codex_Plans/` carries a `**Status:**` line at the top using emoji legend 🔵 Queued / 🟡 Building / 🟢 Shipped / ⏸ Waiting / ⚫ Superseded. Shipped statuses include the PR number and merge timestamp.
- Why: prior to today, plan execution state was tracked in three places — the index Plans section, the inline note in the index Active Focus, and (sometimes) the brief filename — none of which were consistent. Putting Status on the plan file itself makes the brief self-describing and gives integration a single field to validate.
- Alternatives considered: (a) keep status only in the index — rejected, drift between index and plan files was already happening. (b) Use Obsidian frontmatter (`status: shipped`) instead of an inline `**Status:**` line — rejected because Obsidian frontmatter doesn't render in plain markdown previews and the plan files want to be readable as plain text.
- Lives in: every file in `06_Codex_Plans/`; `_Plan_Template.md`; `00_Index.md` Plans & Logs section; `AGENTS.md` End-of-Session bookend step 6.
- Reversibility: trivial — strip the line if the convention isn't earning its keep.

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
