# Open Questions

> Unresolved design questions that need your decision before they can be integrated into a system note. Persistent (unlike `00_Inbox`, this doesn't empty at session end).
>
> **Lifecycle:** moved here from inbox during integration when an item is `?`-flagged and not ready to resolve. Stays here until you decide. Once resolved, the answer is written into the relevant `02_Systems/` note and the question is removed from this file.

---

## Active

<!-- Format: bullet with the question + context + which system it affects -->

- XP_Progression testing-place cutover checks still to exercise: sitting boost, level-up animation, gamepass +22 tick, mobile bar height, second-join migration variants, and DataStore failure simulation. Context: XP MVP branch live test validated XPBar, migration to level 557, leaderstats, active tick, and boundary safety, but these cases still need a formal pass with Opus during the post-merge testing-place walkthrough. **Sitting boost is now unblocked** — `Workspace.SeatMarkers` has a `Seat` child with `CustomSitAnimScript` (verified during the 2026-04-27 audit refresh).
- DiscordLogs Secret Refactor brief is ⏸ Waiting for Tyler to greenlight the secret-handling approach (Branch A: `HttpService:GetSecret`, Branch B: Studio-only sibling ModuleScript, Branch C: script attribute placeholder). Until then, `DiscordLogs` stays Studio-only. Tyler 2026-04-27: revisit some other time, no decision needed yet.

---

## Resolved (recent)

> Keep the last few resolved questions here for context. Older ones can be deleted — `_Change_Log.md` holds permanent history.

- 2026-04-27 — Keep/delete decisions for three drift-found ScreenGuis (`IntroScreen`, `Menu`, `Game Version`). Tyler decided **keep all three as-is** — they stay live and Studio-only, no export, no cleanup. See `_Decisions.md` 2026-04-27 — "Drift-found ScreenGuis: keep all three" and `_UI_Hierarchy.md` updated drift section.
- 2026-04-27 — Manual Export queue from the 2026-04-27 audit refresh (`ReplicatedStorage.Rose`, `Workspace.Avalog`, `Workspace.Leader2`, `Workspace.playerBugReportSystem`, `Workspace.ReportGUI`, `Workspace.Truss`, `Workspace.WelcomeBadge`). Tyler decided **skip** — `Workspace` isn't mapped in any Rojo project file so these don't affect repo sync, and the load-bearing `Avalog` dependency is fine living in Studio while `FavoritePromptPersistence` itself stays no-touch. Audit doc keeps the list as informational. See `_Decisions.md` 2026-04-27 — "Workspace Manual Export queue: skip."
- 2026-04-27 — Pick the next XP follow-up to design. Tyler decided **Title v2** — full v2 spec already exists in `02_Systems/Title_System`, ready for build planning when Tyler kicks off the thread. Discovery / Conversation / AchievementTracker deferred. See `_Decisions.md` 2026-04-27 — "Next XP follow-up: Title v2."
