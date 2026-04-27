# Open Questions

> Unresolved design questions that need your decision before they can be integrated into a system note. Persistent (unlike `00_Inbox`, this doesn't empty at session end).
>
> **Lifecycle:** moved here from inbox during integration when an item is `?`-flagged and not ready to resolve. Stays here until you decide. Once resolved, the answer is written into the relevant `02_Systems/` note and the question is removed from this file.

---

## Active

<!-- Format: bullet with the question + context + which system it affects -->

- XP_Progression testing-place cutover checks still to exercise: sitting boost, level-up animation, gamepass +22 tick, mobile bar height, second-join migration variants, and DataStore failure simulation. Context: XP MVP branch live test validated XPBar, migration to level 557, leaderstats, active tick, and boundary safety, but these cases still need a formal pass with Opus during the post-merge testing-place walkthrough. **Sitting boost is now unblocked** — `Workspace.SeatMarkers` has a `Seat` child with `CustomSitAnimScript` (verified during the 2026-04-27 audit refresh).
- Keep/delete decisions for three drift-found ScreenGuis from the 2026-04-27 audit refresh: (a) `IntroScreen` — cleanup pass listed it deleted but it's still live, MCP inspector can't faithfully export it (tooling blocker), (b) `Menu` — same situation, but it has source content (1-line `LocalScript` + 30-line `MainScript`) that could be exported if kept, (c) `Game Version` — undocumented, contains a 1-line `ShowGameVersion` LocalScript. Tyler decision needed for each before any export/cleanup. Tracked in `docs/live-repo-audit.md` Manual Export queue and `_UI_Hierarchy.md` drift section.
- Manual Export queue from the 2026-04-27 audit refresh — items live but not in `src/`, needing decision: `ReplicatedStorage.Rose` (Tool asset), `Workspace.Avalog` (453-script dependency of `FavoritePromptPersistence` — load-bearing, this is the priority one), `Workspace.Leader2` (20-script Model), `Workspace.playerBugReportSystem` (8-script package), `Workspace.ReportGUI` (Model with `READ ME` + `ReportHandler` scripts), `Workspace.Truss` (TrussPart with `ReportGUI.READ ME` Script), `Workspace.WelcomeBadge` (top-level Workspace Script). May want a follow-up brief grouped by system, especially the Avalog dependency.
- DiscordLogs Secret Refactor brief is ⏸ Waiting for Tyler to greenlight the secret-handling approach (Branch A: `HttpService:GetSecret`, Branch B: Studio-only sibling ModuleScript, Branch C: script attribute placeholder). Until then, `DiscordLogs` stays Studio-only.
- Pick the next XP follow-up to design — Discovery source, Conversation source, AchievementTracker, or jump straight to Title v2. Tyler's call. See `[[02_Systems/XP_Progression]]` follow-up list.

---

## Resolved (recent)

> Keep the last few resolved questions here for context. Older ones can be deleted — `_Change_Log.md` holds permanent history.

- _(none yet)_
