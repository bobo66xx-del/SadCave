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

<!-- New session entries go HERE — add a new dated section above this line, like:
## 2026-04-28
- [C] 09:15 — first observation
-->

## 2026-04-27 (Cowork session 4)

- [O] — About to run the Reality Check: walk Studio via MCP and spot-check the kept-list surfaces in `_Live_Systems_Reference.md`. Why: protocol calls for it on any session that will touch a system, and Tyler asked for it. Will update the doc inline if drift, or log "no drift" in `_Change_Log.md` either way.
- [O] — About to edit `AGENTS.md` to retire the "Opus (Claude, in chat)" wording. Why: I now run in Cowork, not chat; the carryover has been deferred since Cowork session 1 and Tyler greenlit fixing it now. Strictly cosmetic — no workflow rules change.
- [O] — Reality Check drift found: `NameTagScript.server.lua` (live + repo, byte-equal) builds a BillboardGui with BOTH `NameLabel` and `LevelLabel`; the LevelLabel renders the leaderstats `Level` value as `"level N"` above every player. Vault disagrees — `NameTag_Status.md` says "Single label, single TextLabel for the player's display name" and lists `❌ Level / handle row — deferred design choice`, and `_Live_Systems_Reference.md` says "name-only BillboardGui." Repo and Studio agree with each other, so the spec is what's wrong, not the build. About to update both vault docs to describe reality, and flag a `?` for Tyler to decide whether to keep the level row (it doubles up with the XPBar's level display, which may be louder than intended for the tone).
- [O] — Reality Check side-finding: `search_game_tree` reports 9 instances at depth 1 in `StarterPlayer.StarterPlayerScripts`, but the audit (PR #6 + PR #8 dedup) lists 8 expected (`AfkDetector`, `MobileLightingCompensation`, `NpcDialogueClient`, `PlayerDialogueClient`, `PromptFavorite` LocalScript, `PromptGroup`, `SunRayRemove`, `environment change ` Folder). Cowork's MCP wrapper is summarizing instance results to counts only (same shape bug the dashboard hit), so I can't enumerate names to find the 9th. `script_search "PromptFavorite"` returns `count:1` confirming PR #8's dedup stuck. Could be a benign tool-counting quirk (parent counted, etc.) or a real 9th item. Flagging as `?` for the next session that has working enumerate.
- [O] — ? Tyler — `NameTagScript` renders level row above every player, doubling up with XPBar. Was that intentional, or should the level row be removed (script becomes truly name-only)? This is a tone/UX call, not a spec-correction call.
- [U] — Decided: remove the level row from the nametag, leave only the player's name. Reason: the level already lives in the XPBar, doubling it on the nametag was louder than the tone called for.
- [O] — About to write a Codex brief at `06_Codex_Plans/2026-04-27_NameTag_Strip_Level_Row_v1.md` to strip the `LevelLabel` and the leaderstats hooking from `NameTagScript.server.lua`, branch `codex/nametag-strip-level-row`. Why: implementing Tyler's decision; small surgical change. Safety check: the XPBar consumes the `XPUpdated` remote directly (not leaderstats), so removing the nametag's leaderstats hook does not affect the XPBar; `ProgressionService` still writes leaderstats `Level` for `NoteSystem`'s level gate. `NameTagScript` itself is not on the no-touch list (verified `_No_Touch_Systems.md`).
- [O] — About to log the keep/remove decision to `_Decisions.md` and update `NameTag_Status.md` + `00_Index.md` to point at the new brief.
- [C] 18:08 — Stripped `LevelLabel`, `updateLevel`, and leaderstats hooks from `NameTagScript.server.lua`; kept the Avalog `AncestryChanged` watchdog and confirmed Studio has the synced name-only script.
- [C] 18:14 — Playtested clean Studio run in `Testing cave`: console showed `[NameTag] script ready`; runtime `HumanoidRootPart.NameTag` had exactly one `NameLabel` (`vesbus`), no `LevelLabel`, size `{0, 200}, {0, 30}`; after reset/respawn the new character again had one `NameLabel` and no `LevelLabel`; XPBar still existed with live fill and leaderstats `Level=557`, `XP=230685`.
- [C] 18:14 — Console output from clean run: `[NameTag] script ready` / `checkRemoteAgainstAllowList: a remote was added to a protected container with non-allowlisted name 'ExpChatFeatureValueChanged' and has been disabled (see go/lua-apps-remotes)` / `[FavoritePrompt] player added 1132193781` / `[FavoritePrompt] setting FavoritePromptDataReady for 1132193781 to false` / `[FavoritePrompt] setting CanShowFavoritePrompt for 1132193781 to false` / `[FavoritePrompt] PlayerDataStore.Loaded fired 1132193781 SessionLoaded= false FavoritePromptShown= false` / `[FavoritePrompt] profile observe 1132193781 old= false new= false SessionLoaded= false` / `[FavoritePrompt] setting FavoritePromptDataReady for 1132193781 to false` / `[FavoritePrompt] setting CanShowFavoritePrompt for 1132193781 to false` / `[FavoritePrompt] profile observe 1132193781 old= false new= true SessionLoaded= true` / `[FavoritePrompt] profile initial await completed 1132193781 FavoritePromptShown= true` / `[FavoritePrompt] profile evaluated post-await 1132193781 SessionLoaded= true FavoritePromptShown= true alreadyPrompted= true` / `[FavoritePrompt] setting FavoritePromptDataReady for 1132193781 to true` / `[FavoritePrompt] setting CanShowFavoritePrompt for 1132193781 to false` / `[FavoritePrompt] final eligibility post-await 1132193781 CanShowFavoritePrompt= false` / `[FavoritePrompt] delayed prompt started FavDelay= 600` / `passed` / `passed2` / `[FavoritePrompt] delayed prompt started FavDelay= 600` / `[FavoritePrompt] profile observe 1132193781 old= true new= true SessionLoaded= true`.
- [C] 18:14 — Limit: did not force a real ProgressionService level-up because `GrantXP` saves on level-up; XPBar/leaderstats presence was verified, and no NameTag/LevelLabel/updateLevel errors appeared. Avalog forced-destroy watchdog was not server-probed because Studio `execute_luau` is client-context during Play; respawn re-create was verified instead.

## YYYY-MM-DD (template — do not write here, this is just a format example)

- [O] HH:MM — example: noticed `CashLeaderstats` still referenced in three places, see `_Cleanup_Backlog`
- [U] HH:MM — example: dialogue cooldown felt too short, bumped to 4s
- [U] HH:MM — ? should daily reward streak break on 1 missed day or 2?
