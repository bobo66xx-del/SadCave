# Codex Review Template

The routine Claude follows when Codex pushes a branch and asks for review. Universal — every Codex task gets reviewed; no risk gradient. The user does not script and cannot verify code by reading it; this template exists so the verdict is solid every time.

Referenced from `AGENTS.md`'s "Codex Review Template" section.

---

## When to use

Codex has pushed `codex/<task-name>` and said the task is ready. Don't merge anything before walking this. If the user asks "can I merge?", that's the trigger.

## Inputs

- The branch name (Codex always names it `codex/<task-name>`)
- The plan file in `06_Codex_Plans/` (if a plan-driven task — most are)
- Codex's inbox notes for the session (`[C]` prefixed, dated)

## Steps

### 1. Read the diff

Use the GitHub MCP. Pull the PR if one exists (`mcp__github__list_pull_requests` filtered by `head: codex/<task-name>`), or compare commits if Codex pushed without opening a PR (`mcp__github__list_commits` on the branch).

Read every changed file. Don't skim. Don't trust the diff summary in lieu of reading the actual changes.

### 2. Cross-reference with the plan

Open the relevant `06_Codex_Plans/YYYY-MM-DD_*_v1.md`. For each step in "Step-by-Step Implementation," confirm the diff actually matches. Look for:

- Files the plan said to create — present and reasonable?
- Files the plan said NOT to touch — actually untouched?
- DataStore keys touched — only the ones the plan named?
- Remote names — match the plan? (Renaming a remote breaks live clients.)

If the plan and the diff disagree, that's not automatically wrong — sometimes scope shifted with good reason. But it needs to be explained in Codex's inbox notes. If it isn't, that's a flag for the verdict.

### 3. Read Codex's inbox notes for the session

Find the dated section in `00_Inbox/_Inbox.md`. Read every `[C]` line. Look especially for:

- `[C] ?` flags — Codex was unsure; the user (or Claude) needs to resolve.
- "Could not playtest" — playtest theater is an anti-pattern; if Codex couldn't validate, you must.
- Phase X partial / blocked — incomplete work that Codex flagged honestly.
- Renames or scope drifts — should be explicit in the notes if they happened.

### 4. Decide if an independent playtest is needed

Run a playtest yourself (`start_stop_play` + `console_output`) when:

- Codex flagged "could not playtest" or playtest was thin (no detail beyond "ok").
- Behavior is risky — DataStore changes, remote contract changes, anything player-facing where you wouldn't trust a one-line "playtested: ok."
- The plan specified validation steps Codex didn't explicitly check off.
- Anything related to monetization, moderation, or persistent player data.

Skip the playtest only when Codex's notes are thorough, the change is genuinely tiny (e.g. a single config tweak), and there's no DataStore / remote / player-state surface area touched.

When in doubt: playtest. It costs minutes; missing a bug costs trust.

### 5. Translate the diff to plain English

This is the actual deliverable to the user. The user can't read Luau and shouldn't have to. Write a verdict that covers, in this order:

1. **One-sentence verdict.** "Looks good — here's what changed" or "Wait, something's off — here's what and why."
2. **What changed in player-facing terms.** Not file names. "Players who join now get an XP bar; their level migrated correctly in my test." Not "ProgressionService.lua now reads LevelSave."
3. **What changed under the hood, in normal language.** "I added a new save file for XP and level. The old level save is still there but only gets read once during migration."
4. **What was tested.** "I joined as a player, watched the bar fill for two minutes, confirmed migration worked, no errors in the console."
5. **What wasn't tested or what's flagged.** Be honest. "Sitting boost couldn't be tested because there's no `SeatMarker` placed in the world yet."
6. **Anything Codex flagged that needs the user's call.** List each `[C] ?` with a one-sentence summary and a recommended answer.
7. **Verdict on next step.** "Safe to merge" / "Fix item N first" / "Need user's call on item N before merging."

Avoid file paths, line numbers, and code snippets unless one is genuinely necessary to explain a flag. The user is reading to make a merge decision; the diff lives on GitHub for the curious.

### 6. Hand back to the user

Post the verdict in chat. Wait for the user's call (merge / iterate / abandon). Don't proactively merge — `main` is sacred, only the user merges.

If the user merges, post a one-line confirmation in the inbox: `[O] HH:MM — PR #N merged. Branch `codex/<task-name>` deleted.` This becomes part of the session's wrap-up integration.

If the user asks for iteration, write the iteration scope clearly back to Codex (in chat or as an updated section in the plan file). Same branch, same review cycle.

## Verdict format (template)

```
**Verdict:** <Looks good | Hold off | Needs user call>

**What changed (player-facing):**
- ...

**Under the hood:**
- ...

**Tested:**
- ...

**Not tested / flagged:**
- ...

**Codex `?` flags needing your call:**
- ...

**Recommendation:** <safe to merge | fix item N first | call on item N before merging>
```

## Anti-patterns specific to review

- **Skipping the diff because Codex's inbox notes sound complete.** Notes can be thorough and still miss something the diff reveals. Read both.
- **Reading only the file names, not the contents.** Renaming a script doesn't tell you what changed inside it.
- **Treating "playtest: ok" as validation.** If the note doesn't describe what was observed, treat it as "didn't really playtest" and run your own.
- **Telling the user "trust me, it looks fine."** That's not a verdict; that's an abdication. The user can't independently verify, so the verdict has to be specific enough that they can decide.
