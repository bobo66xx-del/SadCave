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

## 2026-04-28

- [C] 21:58 — [MigrationProbe] START Title v2 migration runtime verification.
- [C] 21:58 — [MigrationProbe] PLANTED userId=999999991 key=_PROBE_TitleV2Migration_999999991 v1Title=regular.
- [C] 21:58 — [MigrationProbe] PLANTED userId=999999992 key=_PROBE_TitleV2Migration_999999992 v1Title=newcomer.
- [C] 21:58 — [MigrationProbe] PLANTED userId=999999993 key=_PROBE_TitleV2Migration_999999993 v1Title=saber_owner.
- [C] 21:58 — [MigrationProbe] PASS userId=999999991 key=_PROBE_TitleV2Migration_999999991 v1Title=regular expected=familiar_face got equippedTitle=familiar_face migratedTitleId=familiar_face migratedFromV1=true.
- [C] 21:58 — [MigrationProbe] PASS userId=999999992 key=_PROBE_TitleV2Migration_999999992 v1Title=newcomer expected=new_here got equippedTitle=new_here migratedTitleId=new_here migratedFromV1=true.
- [C] 21:58 — [MigrationProbe] PASS userId=999999993 key=_PROBE_TitleV2Migration_999999993 v1Title=saber_owner expected=new_here got equippedTitle=new_here migratedTitleId=nil migratedFromV1=true.
- [C] 21:58 — [MigrationProbe] PASS cleanup userId=999999991 key=_PROBE_TitleV2Migration_999999991 EquippedTitleV1=nil TitleData=nil.
- [C] 21:58 — [MigrationProbe] PASS cleanup userId=999999992 key=_PROBE_TitleV2Migration_999999992 EquippedTitleV1=nil TitleData=nil.
- [C] 21:58 — [MigrationProbe] PASS cleanup userId=999999993 key=_PROBE_TitleV2Migration_999999993 EquippedTitleV1=nil TitleData=nil.
- [C] 21:58 — [MigrationProbe] COMPLETE all migration cases passed and cleanup verified.
- [C] 21:58 — Removed the temporary CodexMigrationProbe from repo and Studio after passing verification; kept TitleService.LoadAndMigrateForUserId as the only branch code change.

<!-- New session entries go HERE — add a new dated section above this line, like:
## 2026-04-28
- [C] 09:15 — first observation
-->

<!-- Sessions 7 + 8 (2026-04-28) integrated. Recaps at 07_Sessions/2026-04-28_session_1.md and 2026-04-28_session_2.md. -->

## YYYY-MM-DD (template — do not write here, this is just a format example)

- [O] HH:MM — example: noticed `CashLeaderstats` still referenced in three places, see `_Cleanup_Backlog`
- [U] HH:MM — example: dialogue cooldown felt too short, bumped to 4s
- [U] HH:MM — ? should daily reward streak break on 1 missed day or 2?
