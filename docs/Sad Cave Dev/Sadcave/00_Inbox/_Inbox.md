# Inbox

> Unsorted captures from the current session. Empties at end of session.
> **You**, **Claude**, and **Codex** all write here. One line per entry, timestamped.
>
> **Prefixes:**
> - `[U]` — written by you
> - `[O]` — written by Claude (the letter is legacy short for "Opus" and is preserved so older inbox/change-log entries still read cleanly)
> - `[C]` — written by Codex
> - `?` — unresolved, needs your decision before integration
>
> **Lifecycle:** items get triaged into `02_Systems/`, `_Change_Log.md`, `_Decisions.md`, `_Known_Bugs.md`, or `09_Open_Questions/` at end of session, then cleared from here. Anything still unresolved stays with a `?` prefix and rolls to next session.
>
> **Claude rule (per AGENTS.md Section 4):** before any vault edit during a session, write an `[O]` line first stating what you're about to change and why.

---

<!-- New session entries go below this line. Add a new dated section like:
## 2026-04-28
- [C] 09:15 — first observation
-->

<!-- Sessions 7 + 8 (2026-04-28) integrated. Recaps at 07_Sessions/2026-04-28_session_1.md and 2026-04-28_session_2.md. -->
<!-- Session 9 (2026-04-28 session_3, PR #17 migration verification) integrated. Recap at 07_Sessions/2026-04-28_session_3.md. -->
<!-- Session 10 (2026-04-28 session_4, Player Experience Arcs vision doc + QuietKeeper_Memory spec + Title category activation sequence) integrated. Recap at 07_Sessions/2026-04-28_session_4.md. -->
<!-- Session 11 (2026-04-29 session_1, AchievementTracker brief + Codex review) integrated; PR #20 merge backfill pending in session_2. Recap at 07_Sessions/2026-04-29_session_1.md. -->
<!-- Session 12 (2026-04-29 session_2, PR #20 backfill + polished-menu+nametag design pass + Codex brief) integrated. Recap at 07_Sessions/2026-04-29_session_2.md. -->
<!-- Session 13 (2026-04-29 session_3, polish-pass review + PR #23 merge + integration) integrated. Recap at 07_Sessions/2026-04-29_session_3.md. -->
<!-- Note: codex/title-polish-pass branch carried forward stale [O]/[C] entries from sessions 1 + 13 because the branch base was pre-PR-#22 in Codex's worktree. Those entries described work that is fully integrated as of session 3 (PRs #20 + #23). Cleared together with this wrap. -->
<!-- Session 14 (2026-04-29 session_4, Desktop Refinement Pass design + Brief A two-iteration loop + PR #25 merge + integration) integrated. Recap at 07_Sessions/2026-04-29_session_4.md. PR #25 merged 14:01:58 UTC carries Codex's [C] entries from both iterations + my mid-session [O] entries directly into main; this wrap clears the inbox section, flips the brief / Title_System / NameTag_Status / index status to 🟢 Shipped, appends a 14:01 UTC change-log entry, captures the same-branch two-iteration design call in _Decisions.md (already added during session), backfills the two stale 🔵 Queued statuses on Title_v2_MVP1 + MVP1_Followup plan files, and updates Active Focus to reflect the new "sit with state, then decide on Brief B" stance. -->
<!-- Session 15 (2026-04-29 session_5, Brief B authoring + kickoff + review + merge + Nametag Aura Pass design + brief authoring + integration) integrated. Recap at 07_Sessions/2026-04-29_session_5.md. PR #27 merged 2026-04-30 04:38:32 UTC carries Codex's `[C]` entries directly into main; this wrap clears the inbox section, flips Brief B to 🟢 Shipped across plan + spec + index + change-log, captures the Direction-A-chosen + Brief-B-item-5-dropped decisions in _Decisions.md, files the up_too_late bug in _Known_Bugs.md as new active, adds the Aura Pass Active Focus + Plans & Logs entries with the canonical design landing in NameTag_Status. Two non-blocking carry-forwards parked in the PR #27 change-log + NameTag_Status § Brief B entry: stroke shipped at 0.5 unconditionally (moot once Aura Pass cushion lands), recess fades preemptively (one-line revert in any future polish touch). The Codex `?` validation-limit flags from Brief B (hover tween + mobile gap couldn't be exercised via MCP) were addressed implicitly by Tyler's normal-play merge — he saw the build live before merging. Inbox-first rule was bent once for the Brief B plan write pre-pull, documented in this session's `[O]` lines and rationalized in the recap's "Notes" section. -->

## YYYY-MM-DD (template — do not write here, this is just a format example)

- [O] HH:MM — example: noticed `CashLeaderstats` still referenced in three places, see `_Cleanup_Backlog`
- [U] HH:MM — example: dialogue cooldown felt too short, bumped to 4s
- [U] HH:MM — ? should daily reward streak break on 1 missed day or 2?
