# Inbox

> Unsorted captures from the current session. Empties at end of session.
> **You**, **Opus**, and **Codex** all write here. One line per entry, timestamped.
>
> **Prefixes:**
> - `[U]` — written by you
> - `[O]` — written by Opus
> - `[C]` — written by Codex
> - `?` — unresolved, needs your decision before integration
>
> **Lifecycle:** items get triaged into `02_Systems/`, `_Change_Log.md`, `_Decisions.md`, `_Known_Bugs.md`, or `09_Open_Questions/` at end of session, then cleared from here. Anything still unresolved stays with a `?` prefix and rolls to next session.
>
> **Opus rule (per AGENTS.md Section 4):** before any vault edit during a session, write an `[O]` line first stating what you're about to change and why.

---

## 2026-04-27 (session 3 — Cowork)

- [O] 21:26 — Re-orient walked clean. AGENTS.md, index, prior recap, GitHub PR list, open questions, known bugs, Tone_and_Rules all read. All six 2026-04-27 PRs (#1–#6) reconciled in change-log + plan files; no backfill needed. Inbox was empty going in.
- [O] 21:28 — Tyler decision: keep `IntroScreen`, `Menu`, `Game Version` ScreenGuis as-is. They stay live; no export, no cleanup. Will resolve the corresponding entry in `_Open_Questions` and update the `_UI_Hierarchy` drift section at end-of-session integration.
- [O] 21:28 — Tyler decision: drop the Manual Export queue follow-up. `Workspace.Avalog` / `Leader2` / `playerBugReportSystem` / `ReportGUI` / `Truss` / `WelcomeBadge` / `ReplicatedStorage.Rose` stay Studio-only — `Workspace` is not mapped in `default.project.json` or `xp-only.project.json` so they don't affect Rojo sync. The audit doc still tracks them as Manual export needed for visibility; we just won't act on it. Will resolve the corresponding entry in `_Open_Questions` at integration.
- [O] 21:29 — Tyler decision: DiscordLogs Secret Refactor stays ⏸ Waiting; revisit later. No vault change needed beyond noting the deferral persists.
- [O] 21:29 — Tyler decision: next XP follow-up to design will be **Title v2** (skipping Discovery / Conversation / AchievementTracker for now). Will close the corresponding `_Open_Questions` item and reflect this in the index Current Priority block at integration. Note for future me: don't auto-design Title v2 yet — wait for Tyler to start that thread.
- [O] 21:30 — About to write `06_Codex_Plans/2026-04-27_PromptFavorite_Bugs_Cleanup_v1.md` (🔵 Queued). Brief covers two of the three bugs in `_Known_Bugs.md`: (a) `FavoritePromptShown` infinite yield in `PromptFavorite.client.lua` line 15 (no-timeout `WaitForChild`; remote not in audit's ReplicatedStorage list), (b) duplicate `PromptFavorite` Script in StarterPlayerScripts (audit tooling blocker; the existing `.client.lua` LocalScript matches the repo Exact, the duplicate `Script` class instance is what produced the original "class mismatch" repro). Excluding `FavoritePromptPersistence` line-4 bug from the brief — it's no-touch, suspected tied to deferred Avalog dependency, would just dead-end Codex on read-only access; staying tracked in `_Known_Bugs.md`. Index Plans & Logs update to follow at integration.
- [O] 21:30 — Note: brief tells Codex to read (not modify) `FavoritePromptPersistence.server.lua` to understand the remote contract for `FavoritePromptShown`. Reading no-touch systems for context is fine; modifying them isn't. If the right fix would require touching `FavoritePromptPersistence`, Codex flags back via inbox `[C] ?` instead of proceeding.
- [C] (session 3) — Codex started the plan, hit the "byte-equal or stop" guard. Duplicate `Script` and canonical `LocalScript` source differ only by one trailing newline (Script 2190 chars, LocalScript 2189). Per brief, Codex stopped — did not delete, did not keep the client timeout patch, did not push a branch. Reported `FavoritePromptPersistence` does create `FavoritePromptShown` at runtime via `Instance.new` and listens with `OnServerEvent` (confirms the race-with-server theory for the infinite-yield warning).
- [O] 21:42 — Brief was over-cautious. Trailing-whitespace deltas are not meaningful source differences in Lua/Luau (one trailing `\n` has zero behavioral impact). Updating step 2 + step 10 of `2026-04-27_PromptFavorite_Bugs_Cleanup_v1.md` to allow deletion when duplicate differs from canonical only by trailing whitespace / line endings; real source diffs still stop-and-flag. Tyler wants Codex to fix the bug, not admire it.
- [O] 21:42 — Folding the runtime-creation finding into the brief's reviewer notes so future readers know `FavoritePromptShown` is server-published, not Rojo-static, and the fix path is timeout-on-the-client (already in the brief, now with the contract confirmed).
- [C] 21:41 — ? PromptFavorite cleanup guard fired: Studio has both `StarterPlayerScripts.PromptFavorite` instances (`Script` and `LocalScript`), but the duplicate `Script` source is not byte-equal to the canonical `LocalScript`; the only observed difference is one final trailing newline (`Script` source length 2190, `LocalScript` source length 2189). Per brief, stopped before deleting the duplicate or pushing the client timeout patch.
- [C] 21:48 — Duplicate `StarterPlayerScripts.PromptFavorite` Script full source before deletion (JSON-escaped string; final trailing `\n` included): "--// Variables and Service\n\nlocal AvatarEditorService = game:GetService(\"AvatarEditorService\")\nlocal Players = game:GetService(\"Players\")\nlocal ReplicatedStorage = game:GetService(\"ReplicatedStorage\")\nlocal LocalPlayer = Players.LocalPlayer\n\n--// Settings\n\nlocal YourPlaceID = 5895908271 -- your place id obv\nlocal FavDelay = 600 -- seconds till it prompts after joining\nlocal EligibilityWaitTimeout = 15\nlocal DataReadyAttribute = \"FavoritePromptDataReady\"\nlocal EligibleAttribute = \"CanShowFavoritePrompt\"\nlocal PromptShownRemote = ReplicatedStorage:WaitForChild(\"FavoritePromptShown\")\n\nlocal hasPromptBeenHandled = false\n\nlocal function canShowPromptThisSession()\n\tif hasPromptBeenHandled then\n\t\treturn false\n\tend\n\n\tprint(\"[FavoritePrompt] client checking eligibility start\", \"DataReady=\", LocalPlayer:GetAttribute(DataReadyAttribute), \"CanShow=\", LocalPlayer:GetAttribute(EligibleAttribute))\n\tlocal waitStart = os.clock()\n\twhile LocalPlayer:GetAttribute(DataReadyAttribute) ~= true do\n\t\tif os.clock() - waitStart >= EligibilityWaitTimeout then\n\t\t\tprint(\"[FavoritePrompt] client eligibility wait timed out\", \"DataReady=\", LocalPlayer:GetAttribute(DataReadyAttribute), \"CanShow=\", LocalPlayer:GetAttribute(EligibleAttribute))\n\t\t\treturn false\n\t\tend\n\n\t\ttask.wait(0.25)\n\tend\n\n\tlocal canShow = LocalPlayer:GetAttribute(EligibleAttribute) == true\n\tprint(\"[FavoritePrompt] client eligibility resolved\", \"DataReady=\", LocalPlayer:GetAttribute(DataReadyAttribute), \"CanShow=\", LocalPlayer:GetAttribute(EligibleAttribute), \"Result=\", canShow)\n\treturn canShow\nend\n\nlocal function tryPromptFavorite()\n\tprint(\"[FavoritePrompt] delayed prompt started\", \"FavDelay=\", FavDelay)\n\ttask.wait(FavDelay)\n\n\tif not canShowPromptThisSession() then\n\t\treturn\n\tend\n\n\thasPromptBeenHandled = true\n\tprint(\"[FavoritePrompt] client sent remote\")\n\tPromptShownRemote:FireServer()\n\n\tlocal success, result = pcall(function()\n\t\tAvatarEditorService:PromptSetFavorite(YourPlaceID, Enum.AvatarItemType.Asset, true)\n\tend)\n\n\tif not success then\n\t\twarn(result)\n\tend\nend\n\n--// Code\n\nLocalPlayer.CharacterAdded:Connect(function()\n\ttask.spawn(tryPromptFavorite)\nend)\n\nif LocalPlayer.Character then\n\ttask.spawn(tryPromptFavorite)\nend\n"

<!-- New session entries go HERE — add a new dated section above this line, like:
## 2026-04-28
- [C] 09:15 — first observation
-->

## YYYY-MM-DD (template — do not write here, this is just a format example)

- [O] HH:MM — example: noticed `CashLeaderstats` still referenced in three places, see `_Cleanup_Backlog`
- [U] HH:MM — example: dialogue cooldown felt too short, bumped to 4s
- [U] HH:MM — ? should daily reward streak break on 1 missed day or 2?
