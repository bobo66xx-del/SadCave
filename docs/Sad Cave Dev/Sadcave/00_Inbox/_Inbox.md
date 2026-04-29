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

## 2026-04-29 (Cowork session 14 — desktop refinement design pass)

- [O] design call landed during Tyler review of polished pass live: desktop nametag + edge tab read too small (verified via 5 Studio screenshots — both close-up and distance, also one mobile-feel shot). Mobile sizing stays as-is. Plan: bump nametag sizes (BillboardGui 200x50 -> 240x64, title 11pt -> 14pt, name 16pt -> 22pt) and edge tab (18x90 -> 24x120, label 10pt -> 13pt) on desktop only.
- [O] additional refinement pass agreed during the same call. Tyler initially asked for "all 11" of my critique items; pushed back and split into two bundles. Brief A (this session): size bumps + stillness fade on title (velocity-based), distance fade on title (camera-distance-based), notification dot on tab on title unlock, tactile press feedback on tab click. Brief B (deferred, to ship right after A): background-aware stroke tuning on title, breath between rows, hover affordance on tab, edge anchor recess, drawer-dim while menu open. Two items held entirely (tracking on title row pending feel-test at new size; first-time tab pulse pending real discoverability data from playtests).
- [O] architecture note caught during code reading: nametag layout is set server-side in NameTagScript.server.lua, but desktop-vs-mobile is a per-client property. Each viewer should see nametags sized for their own device, not the viewed player's. So new sizing has to live client-side and re-apply when server re-creates a tag on respawn. Same logic for stillness/distance fades — each client computes per viewed character. Server script stays unchanged in this brief.
- [O] correcting an earlier statement to Tyler: I told him "the menu does compact-filter fitting on small screens" implying the menu has platform detection. Grep shows no TouchEnabled/MouseEnabled in TitleMenuController.client.lua. The AGENTS.md line "row sizing and compact mobile filter fitting are local to the TitleMenu slice" is an architectural-ownership statement (about where such code WOULD live), not an existence claim — re-read after the grep, the doc isn't wrong, I misread it. Canonical platform-check pattern actually lives in XPBarController.client.lua + MobileLightingCompensation.client.lua (`UserInputService.TouchEnabled and not UserInputService.MouseEnabled`). Brief reuses that pattern. No AGENTS.md edit needed.
- [O] about to update: 02_Systems/Title_System.md (new "Desktop Refinement Pass" subsection), 02_Systems/NameTag_Status.md (mirrored desktop-specific layout + stillness/distance fade behaviors), 06_Codex_Plans/2026-04-29_Title_Tag_Tab_Desktop_Refinement_v1.md (new brief, 🔵 Queued), 00_Index.md (Plans & Logs entry + Active Focus update), _Decisions.md (4 entries: desktop-only sizing, stillness-fade-as-thesis, split-into-A+B, client-side-sizing). No code changes this session — design + brief only.
- [O] Tyler kicked off Codex against `06_Codex_Plans/2026-04-29_Title_Tag_Tab_Desktop_Refinement_v1.md`. Status flipping 🔵 Queued -> 🟡 Building across brief file, Title_System spec Desktop Refinement Pass section, NameTag_Status spec section, and 00_Index.md (Active Focus + Plans & Logs entries). Branch expected: `codex/title-tag-tab-desktop-refinement`. Standing by for push, then Codex Review Template runs.
- [O] Codex pushed `codex/title-tag-tab-desktop-refinement` at commit `4aef1de`. Static review against the brief: clean — every value matches, no out-of-scope edits, no server changes, no remote contract changes. Live Studio probe via MCP confirmed: BillboardGui 240x64 applied, title 14pt, name 22pt, edge tab 24x120, NotifyDot present + hidden, TitleBaselineTransparency=0.25 captured. Stillness fade verified by walking the humanoid: title TextTransparency went to 0.999 at sustained speed >10 stud/s, hysteresis preserved fade across brief stops. Codex's `?` blocker (Rojo not synced) had resolved by review time. Distance fade + dot trigger + tactile press code reads correct but couldn't end-to-end test (camera follow override + can't FireClient from command bar + can't simulate clicks via MCP). Verdict: looks good — safe to merge.
- [O] Tyler reviewed live state and asked for adjustments before merge (same-branch iteration). Confirmed values: (1) tab fades out as drawer slides in, fades back on close — drops re-click-tab close path, three close paths remain (outside-click, ESC, internal x); (2) stillness fade sustained-high threshold 1.0s -> 2.0s (running needs to be longer-sustained before fade fires); (3) Option A on size — proportional bump: title 14pt -> 16pt, name 22pt -> 25pt, BillboardGui 240x64 -> 280x80; (4) distance fade thresholds halved AND MaxDistance halved — DISTANCE_FADE_START 40 -> 20, DISTANCE_FADE_SOFT_END 80 -> 40, MaxDistance 100 -> 50 (client-side override to keep server file untouched, applies on both platforms not just desktop); (5) per-row notification dots in TitleMenu mirror the tab-dot pattern with Option A clear-on-close (dots stay visible while menu is open so player actually sees them, clear when menu closes after being open with the dot visible).
- [O] about to update: 06_Codex_Plans/2026-04-29_Title_Tag_Tab_Desktop_Refinement_v1.md (add Iteration 1 section + update inline values), 02_Systems/Title_System.md § Desktop Refinement Pass (new sizing table, new fade thresholds, new behaviors), 02_Systems/NameTag_Status.md § Desktop Refinement Pass (mirrored), _Decisions.md (one consolidated entry covering the iteration deltas + reasoning). New file added to brief's scope: TitleMenuController.client.lua (per-row dot rendering). No status change in 00_Index.md — brief stays 🟡 Building, branch stays codex/title-tag-tab-desktop-refinement.

- [C] 07:28 — Read the desktop refinement brief, Title_System, NameTag_Status, Tone_and_Rules, and _No_Touch_Systems. Implementing only the two allowed client controllers on branch `codex/title-tag-tab-desktop-refinement`; server title/data/remotes stay untouched.
- [C] 07:35 — Implemented Brief A in `NameTagEffectController.client.lua` and `TitlesToggleController.client.lua`: desktop-only size bumps, multiplicative stillness+distance title fade, unlock dot from `ownedTitleIds`, clear-on-open, and desktop press dim. Name row stays unchanged.
- [C] 07:35 — ? Studio validation blocked: `Testing cave` is connected, but Studio still has old sources for both edited LocalScripts (`DISTANCE_FADE_START` / `NotifyDot` not present) even though a `rojo serve` process is running. Static `git diff --check` passed and `rojo build default.project.json` succeeded; playtest still needs a Rojo sync/retry before review.
- [C] 08:41 — Iteration 1 implemented on the same branch: nametag desktop bump now 280x80 / title 16 / name 25, sustained-run fade threshold is 2.0s, distance fade is 20-40 with client MaxDistance 50, tab fades out while drawer is open and no longer closes on re-click, and TitleMenu owned rows can show 4x4 pulsing `RowNotifyDot`s for titles unlocked this session.
- [C] 08:41 — Playtested via Studio after mirroring exact repo sources into the three LocalScripts over localhost because Rojo served updated files but the plugin had not applied them. Runtime probe confirmed NameTag Size 280x80, TitleLabel 16pt/22px, NameLabel 25pt/41px, MaxDistance 50, TitleBaselineTransparency 0.25, EdgeTab 24x120, NotifyDot present, and tab open/close fade state (open: tab/label/dot transparency 1 + Active=false; close: background 0.25, label 0.4 + Active=true). Could not end-to-end fire `TitleDataUpdated` from command context (`FireClient can only be called from the server`), so row-dot trigger remains source/build validated.

## YYYY-MM-DD (template — do not write here, this is just a format example)

- [O] HH:MM — example: noticed `CashLeaderstats` still referenced in three places, see `_Cleanup_Backlog`
- [U] HH:MM — example: dialogue cooldown felt too short, bumped to 4s
- [U] HH:MM — ? should daily reward streak break on 1 missed day or 2?
