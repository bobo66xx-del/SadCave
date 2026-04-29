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

## 2026-04-29

- [O] — About to create `06_Codex_Plans/2026-04-29_AchievementTracker_v1.md`. Activates the Achievement title category per the Title_System Category Activation Sequence (first slot) — ~12 titles, hooks into existing dialogue / sitting / note / idle / group / revisits / time-window paths, fires `AchievementUnlocked` BindableEvent that TitleService listens to. Tyler-decided design calls this session: `fell_asleep_here` uses `Player.Idled` (idle, not focus); `heard_them_all` ships now with min-NPC gate (3) so it stays dormant with current QuietKeeper-only roster; `knows_every_chair` per-session set, resets on rejoin; `day_one` ships with launch window placeholder timestamps (nil) — Tyler sets the date when real launch happens; `up_too_late` per existing Title_System spec (client UTC offset). Single brief, all 10 titles + the 2 future-proofed ones.

- [C] 02:48 — Started `codex/achievement-tracker`; preserving existing dirty vault/Obsidian edits already present on `main`.
- [C] 02:48 — Verified live `ServerScriptService.DialogueDirector` has no existing conversation-ended BindableEvent; adding a small `ConversationEnded` child signal in the repo script.
- [C] 02:48 — Verified live `ReplicatedStorage.DialogueData.Characters` currently has one key: `QuietKeeper`; `heard_them_all` should stay gated by min NPC count 3.
- [C] 02:48 — Verified live `Workspace.SeatMarkers` has one Seat (`Workspace.SeatMarkers.Seat`); `knows_every_chair` code can be wired but five-seat runtime verification is blocked unless temporary test seats are added and removed.
- [C] 03:02 — Built AchievementTracker repo slice: new server tracker + starter, `AchievementRemotes.ClientLocalTime`, client UTC-offset reporter, achievement ownership in `TitleService`, `TitleConfig` launch/min-NPC constants, and additive `ConversationEnded` / `NoteSubmitted` BindableEvents.
- [C] 03:02 — Validation: `git diff --check` passed and `rojo build default.project.json --output .codex-export/achievement-tracker.rbxlx` succeeded; built rbxlx contains `AchievementTracker`, `ClientLocalTime`, `ConversationEnded`, `NoteSubmitted`, and `HEARD_THEM_ALL_MIN_NPCS`.
- [C] 03:02 — ? Studio playtest blocked: Studio MCP is attached to `Testing cave`, but Rojo plugin logged "Couldn't connect to the Rojo server"; after starting local `rojo serve`, the plugin did not reconnect and new live script instances still have empty `Source`. Runtime checks (`[AchievementTracker] script ready`, dialogue/note/sit unlocks, idle/time/day-one) need a Rojo reconnect/manual playtest.

## YYYY-MM-DD (template — do not write here, this is just a format example)

- [O] HH:MM — example: noticed `CashLeaderstats` still referenced in three places, see `_Cleanup_Backlog`
- [U] HH:MM — example: dialogue cooldown felt too short, bumped to 4s
- [U] HH:MM — ? should daily reward streak break on 1 missed day or 2?
