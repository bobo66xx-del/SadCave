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

2026-04-27 — XPBar visibility: small height bump to 6px desktop
- Decision: change `XPBarController.client.lua`'s desktop `barHeight` from 4 to 6 (mobile is already 6, so the if/else effectively unifies). Keep `Background.BackgroundTransparency=0.85`, `Fill.BackgroundTransparency=0.6`, `bumpHeight=8` desktop, warm-tint Fill color — all unchanged. Only the resting bar height changes.
- Why: the bar IS rendering correctly (Codex confirmed via probe and screenshot during the 2026-04-27 Cowork session 5 walkthrough) but Tyler couldn't see it during a full Studio session. At 4px with `Background.BackgroundTransparency=0.85`, the strip is the same color as the dark cave at the bottom of the screen and visually disappears against the environment. The Fill at 0.6 with the warm tint is the only thing that registers, and at 4px it barely qualifies as visible. Going to 6px adds a perceptible vertical presence without crossing into "loud UI" — still half the level-up bumpHeight, still much smaller than any other on-screen element, still in line with Sad Cave's "subtle, premium" UI principles.
- Alternatives considered: (a) drop `Background.BackgroundTransparency` from 0.85 to 0.7 instead of changing height — rejected, height is the more impactful axis here because the issue is the bar disappearing into background, not transparency per se; could revisit later if 6px still doesn't read; (b) bump both height and opacity — rejected as compounding for a first pass, prefer one axis at a time; (c) leave as-is and treat the bar as "lookup-on-demand level info via hover" — rejected because the LevelLabel reveal-on-hover is a separate affordance and the bar should also work as live ambient feedback; (d) bump to 8px or higher — rejected as risking "loud" tone for a 60-second tick interval where progress is gradual.
- Lives in: `06_Codex_Plans/2026-04-27_XP_Testing_Place_Bug_Sweep_v1.md` Decisions block; eventual `_Change_Log.md` entry once the PR ships; reflected in `02_Systems/XP_Progression.md` after build.
- Reversibility: trivial — one constant in one file, swap back if the heavier strip feels wrong in real play.

2026-04-27 — XP system: seated SeatMarker overrides AFK
- Decision: change `PresenceTick.GetTickAmount` so that when `state.seatedAt` is set and elapsed ≥ `SITTING_THRESHOLD_SECONDS`, the function returns `PRESENCE_SITTING_XP` ("sitting" source) regardless of `state.isAFK`. Player must still cross the 30-second threshold; player without a seat still falls through to the `isAFK` → AFK rate path. Net effect: a player physically seated at a SeatMarker keeps earning sitting rate even if their Roblox window doesn't have focus.
- Why: Sad Cave's design intent is that progression rewards presence, and the most explicit presence signal the game has is "the player chose to sit at a meditation seat." Window focus is a weak proxy for engagement — a player at a seat with Discord in the foreground is more "present" than a player wandering with Studio focused but their attention elsewhere. The 2026-04-27 Cowork session 5 walkthrough caught the existing logic granting AFK rate (3) to a seated player whose Studio window had merely lost focus to Cowork — a tone-violating misfire that would essentially make sitting-boost useless during normal play (everyone alt-tabs constantly). Reading the seated state first matches the design intent and is a one-line conditional reorder.
- Alternatives considered: (a) Branch B — tighten AFK detection with an idle-time gate in `AfkDetector.client.lua` (only fire AFK after focus-loss AND no input for N seconds). Rejected for now: adds state and surface area for marginal benefit; doesn't solve the philosophical question (what counts as "input" for someone meditating?); could be a follow-up if non-seated AFK detection ever needs tightening. (b) Branch C — leave AFK-overrides-sitting as intentional design. Rejected: makes sitting-boost nonfunctional in real play given how often players alt-tab during a session — the boost would only work for players who Studio-focus their entire session, which isn't realistic. (c) Read seated state ALWAYS first regardless of threshold (i.e. drop the 30-second sitting threshold). Rejected: the threshold is a deliberate "must commit to sitting" gate; instant boost on sit-down would weaken the presence signal. Threshold stays.
- Lives in: `06_Codex_Plans/2026-04-27_XP_Testing_Place_Bug_Sweep_v1.md` Decisions block; eventual `_Change_Log.md` entry once the PR ships; reflected in `02_Systems/XP_Progression.md` Real Architecture section after build.
- Reversibility: trivial — one conditional reorder in `PresenceTick.GetTickAmount`. If players abuse it or the tone shifts, swap order back or move to Branch B.

2026-04-27 — NameTag level row: remove
- Decision: strip the `LevelLabel` and its leaderstats hooking from `NameTagScript.server.lua`. Final form is name-only: a single TextLabel showing the player's display name, no level row, no title row.
- Why: the level value already renders in the XPBar at the bottom of the screen; doubling it on the overhead nametag put the same number on screen twice and felt louder than the tone allows. The Reality Check this session caught the spec-vs-build mismatch — the spec had always described "name-only" while the live script always had the level row — so this decision both resolves the open inbox `?` and makes the build match the long-stated intent.
- Alternatives considered: (a) keep the level row as-is, accept the doubled surface for visibility — rejected because the XPBar already covers visibility and the tone is the higher-priority constraint; (b) keep both but make the nametag level only appear when the XPBar is hidden — rejected as overengineering, the simplest fix is removal; (c) remove the XPBar level instead — rejected because the XPBar IS the level surface, that's its whole purpose.
- Lives in: `02_Systems/NameTag_Status.md` (updated to "name-only, post-decision build pending"), brief `06_Codex_Plans/2026-04-27_NameTag_Strip_Level_Row_v1.md`, eventual change-log entry once the PR ships.
- Reversibility: trivial — the deleted code is in git history; if the team later wants the level back, it's a re-add, not a rebuild.

2026-04-27 — Brief equality rule: whitespace-tolerant
- Decision: when a Codex brief asks Codex to compare two source files for "equality" before destructive action (e.g. deleting a duplicate), the rule is "byte-equal **or differs only by trailing whitespace / line-ending characters**" — not "byte-equal or stop." Real non-whitespace diffs (different code, comments, identifiers, constants) still stop-and-flag for Opus review. Captured in `2026-04-27_PromptFavorite_Bugs_Cleanup_v1.md` step 2 + reviewer notes.
- Why: the original strict "byte-equal" version of the rule fired on a one-trailing-newline diff during PR #8 work (Script source 2190 chars, LocalScript 2189). Codex correctly stopped per the brief, but the stop was over-cautious — Lua/Luau treat trailing whitespace as semantically inert, and Studio copy-paste introduces these deltas trivially. Stricter-feeling defaults aren't always safer when they make Codex stop on something that was never going to break.
- Alternatives considered: (a) keep strict byte-equal and have Codex flag every whitespace diff for Opus to relax case-by-case — rejected, that's what just happened and it was friction with no upside; (b) compare with Lua's lexer / AST instead of byte-level — rejected, overkill for a one-off comparison and not available without extra tooling; (c) hash both sources after stripping trailing whitespace — equivalent to the chosen rule, just stated differently; chose plain-English version for brief readability.
- Lives in: `2026-04-27_PromptFavorite_Bugs_Cleanup_v1.md` step 2 and reviewer notes; pattern available for future briefs that need a similar rule.
- Reversibility: trivial — change one paragraph in any future brief.

2026-04-27 — Drift-found ScreenGuis: keep all three
- Decision: `IntroScreen`, `Menu`, and `Game Version` ScreenGuis — caught by the 2026-04-27 audit refresh as drift between `_UI_Hierarchy.md` (which said deleted) and live Studio (where they still exist) — are kept as-is. No export to `src/`, no cleanup, no further investigation.
- Why: Tyler made the call. The cost-benefit on each is "leave it alone." `IntroScreen` is a tooling blocker for faithful export (current MCP inspector can't expose enough UI fidelity); `Menu` could be exported but its 30-line MainScript would need analysis effort; `Game Version` is one tiny LocalScript. None of them are causing problems and none are blocking other work. Deleting them risks breaking something nobody currently understands.
- Alternatives considered: (a) export each to `src/` to bring under Rojo — rejected, fidelity tooling blocker on `IntroScreen` + non-trivial effort for low-value UI surfaces; (b) delete to match the original cleanup intent — rejected, no current pain and unclear consequences; (c) decide per-ScreenGui (some keep, some delete) — collapsed into the simpler "keep all" call after Tyler's read.
- Lives in: `_UI_Hierarchy.md` drift section (status: "kept by Tyler 2026-04-27"); `09_Open_Questions/_Open_Questions.md` Resolved.
- Reversibility: cheap — re-open the question and either delete in Studio or write an export brief if priorities change.

2026-04-27 — Workspace Manual Export queue: skip
- Decision: the seven Manual-Export-needed Workspace items from the 2026-04-27 audit (`Workspace.Avalog`, `Leader2`, `playerBugReportSystem`, `ReportGUI`, `Truss`, `WelcomeBadge`, plus `ReplicatedStorage.Rose`) are not pursued. They stay live and Studio-only. The audit doc still tracks them as Manual-export-needed for visibility, but no follow-up brief gets written.
- Why: Tyler's read — `Workspace` is not mapped in `default.project.json` or `xp-only.project.json`, so these items don't affect Rojo sync. They're invisible to the repo and that's fine. The one priority concern was `Workspace.Avalog` (453-script load-bearing dependency of the no-touch `FavoritePromptPersistence`), but pulling it into the repo would be high-effort and high-risk for unclear benefit while `FavoritePromptPersistence` itself is no-touch. `ReplicatedStorage.Rose` is the only non-Workspace item in the queue and is a single Tool asset; same calculus.
- Alternatives considered: (a) write a follow-up brief to bundle the Workspace queue into one export pass — rejected, low-value high-effort; (b) bring `Workspace.Avalog` in alone since it's load-bearing — rejected, the dependency is fine living in Studio while we don't touch `FavoritePromptPersistence`; (c) document each item's "Studio-only intentional" rationale individually — partly rejected, partly happening (`_Live_Systems_Reference.md` already notes the load-bearing nature of Avalog).
- Lives in: `09_Open_Questions/_Open_Questions.md` Resolved; `docs/live-repo-audit.md` Manual Export queue keeps the list as informational.
- Reversibility: cheap — re-open and write a per-item brief if the dependency story ever changes.

2026-04-27 — Next XP follow-up: Title v2
- Decision: when the next XP follow-up gets designed, it will be **Title v2** — not Discovery source, Conversation source, or AchievementTracker.
- Why: Tyler's call on sequencing. Title v2 has a full v2 spec already written (`02_Systems/Title_System` — ~60 titles across 6 categories with per-title `tintColor`, five effect tiers, combined `TitleData` DataStore, simplified `owned`/`locked` filter tabs); the spec stage is done, ready for build planning when the time is right. Discovery / Conversation / AchievementTracker still need design conversations before they're ready for briefs. Title v2 is also more visible to players than the back-end XP sources — a good "next ship" candidate.
- Alternatives considered: (a) Discovery source first to build out the XP source variety — deferred until after Title v2; (b) AchievementTracker first because Title v2's `category-keyed unlock conditions` partly depend on achievement signals — Tyler accepted that Title v2 can ship with level-only categories first and achievement-gated titles get filled in once AchievementTracker exists; (c) Conversation source — same defer-until-after rationale.
- Lives in: `00_Index.md` Active Focus + Current Priority block; `02_Systems/Title_System.md`; `09_Open_Questions/_Open_Questions.md` Resolved.
- Reversibility: trivial — until a Title v2 build brief exists, just redirect the next follow-up.
- Note for execution: Claude doesn't auto-design Title v2. Wait for Tyler to start the thread.

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
