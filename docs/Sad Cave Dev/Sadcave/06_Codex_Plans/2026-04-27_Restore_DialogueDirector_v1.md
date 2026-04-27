# Restore DialogueDirector — Codex Plan

**Date:** 2026-04-27
**Related Systems:** [[../02_Systems/Dialogue_System]], [[../02_Systems/_Live_Systems_Reference]], [[../05_NPCs/QuietKeeper]]
**Branch:** `codex/restore-dialogue-server`
**Spec source of truth:** [[../02_Systems/Dialogue_System]] describes the architecture as it was supposed to be — `DialogueDirector` server script + `DialogueData` + 4 `DialogueRemotes` + two client scripts. The housekeeping export brief on 2026-04-27 confirmed via smoke test that the server-side `DialogueDirector` is **missing** from the testing place. Likely cause: it was deleted during the 2026-04-27 cleanup pass. This brief restores it from a place backup.

---

## 1. Purpose

Bring dialogue back. Right now in the testing place, `RequestCharacterConversation:FireServer("QuietKeeper")` does nothing because there's no server-side script listening. The clients render UI, the data exists, the remotes exist — but no authority drives the conversation. A backup place file from before the cleanup contains the script. This brief locates it, reads its source, and lands it in the repo so Rojo syncs it back into the testing place.

After this brief, talking to QuietKeeper should produce dialogue again.

**Out of scope for this brief:**

- Any redesign of the dialogue system. Restore what existed; don't rewrite. If the restored script has obvious problems, flag them in the inbox for a future redesign.
- Adding new NPCs, new conversations, or new dialogue features.
- Changes to any of the dialogue files just exported via PR #3 (`DialogueData`, `DialogueRemotes`, `NpcDialogueClient`, `PlayerDialogueClient`).
- Restoring anything else that may have been deleted in the 2026-04-27 cleanup. If you find other useful scripts in the backup that aren't in the live testing place, **flag in inbox; do not restore them in this brief.**

## 2. Player Experience

After this lands: walking up to QuietKeeper produces dialogue again — proximity prompt → conversation begins → lines play → choices appear → selection drives the next line. Same behavior as before the cleanup. No new features.

## 3. Technical Structure

### Server responsibilities (restored)

`ServerScriptService.DialogueDirector` (or whatever the script is actually named in the backup — verify):

- Listens to `ReplicatedStorage.DialogueRemotes.RequestCharacterConversation:OnServerEvent`.
- Reads `ReplicatedStorage.DialogueData.Characters.<key>` for the character's conversation tree.
- Drives playback by firing `PlayCharacterDialogue` and `PlayPlayerDialogue` to the requesting player's client.
- Listens to `PlayerDialogueChoiceSelected:OnServerEvent` to advance choice points.

### Client responsibilities

Unchanged. `NpcDialogueClient` and `PlayerDialogueClient` already in repo.

### Remote events / functions

All four remotes already exist in `src/ReplicatedStorage/DialogueRemotes/`:

- `RequestCharacterConversation`
- `PlayCharacterDialogue`
- `PlayPlayerDialogue`
- `PlayerDialogueChoiceSelected`

The restored script should bind to these by name. **Don't rename them** — the clients depend on the existing names.

### DataStore keys touched

Probably none (the original dialogue spec says "no DataStore — session-only"). Verify when reading the restored script. If it does touch DataStore keys, flag with `[C] ?` because that's a wire contract that needs careful review.

## 4. Files / Scripts

### Files to create

- **`src/ServerScriptService/DialogueDirector.server.lua`** — primary deliverable. Source copied byte-exact from the backup place's `ServerScriptService.DialogueDirector` (or whatever the actual script name turns out to be).

If the backup script has child ModuleScripts or is structured as a folder with `init.server.lua`, replicate that structure under `src/ServerScriptService/DialogueDirector/`.

### Files NOT to touch

- All scripts in the kept set per `_No_Touch_Systems.md` (Progression, NoteSystem, Reports, FavoritePromptPersistence, NameTagScript, AfkEvent/AfkDetector, XPBar).
- The four files just exported in PR #3: `src/ReplicatedStorage/DialogueData.lua`, `src/ReplicatedStorage/DialogueRemotes/`, `src/StarterPlayer/StarterPlayerScripts/NpcDialogueClient.client.lua`, `src/StarterPlayer/StarterPlayerScripts/PlayerDialogueClient.client.lua`. These are the dialogue spec's other half — they're correct as-is.
- `default.project.json`, `AGENTS.md`, `PLANS.md`, `README.md`, `place-backups/*.rbxl` (read but never edit).

## 5. Step-by-Step Implementation (for Codex)

### Phase 0 — Setup

1. Re-read `AGENTS.md` (Session Bookends + Codex Rules). Read `02_Systems/Dialogue_System.md` for the architecture you're restoring to.
2. `git checkout main && git pull && git checkout -b codex/restore-dialogue-server`
3. `[C]` log: starting brief.

### Phase 1 — Confirm the gap (sanity check)

4. With Studio MCP set to the testing place, `inspect_instance` on `ServerScriptService` and search for any script that references `RequestCharacterConversation` or `DialogueData`. If a server-side dialogue script exists after all and was simply named something Codex didn't expect previously, **stop and flag with `[C] ?`** — restoration may not be needed; the issue might be different.
5. If confirmed missing, proceed.

### Phase 2 — Locate a backup that has DialogueDirector

6. The user opens one of the `place-backups/*.rbxl` files in a SECOND Studio instance. Order to try (most likely to have the script first):

   - `place-backups/SadCave-2026-04-19.rbxl` — predates the 2026-04-27 cleanup by over a week; very likely contains the server script.
   - `place-backups/Pre-Resync_2026-04-25.rbxl` — predates the cleanup; should also contain it.
   - `place-backups/SadCave-before-rojo.rbxlx` — older but probably has it.
   - `place-backups/Pre-XP-Titles-Restyle_2025-4-25.rbxl` — old, probably has it.

   **Codex cannot open .rbxl files via MCP.** Flag with `[C] ?`: "Please open `<path>` in a separate Studio instance so I can search it for DialogueDirector."

7. After the user opens a backup, run `list_roblox_studios` to see both instances.
8. `set_active_studio` to the backup instance's id.

### Phase 3 — Find the script in the backup

9. From the backup instance, search `ServerScriptService` for likely candidates:
   - `inspect_instance` on `ServerScriptService` and list children.
   - `script_grep` (or equivalent) for `RequestCharacterConversation` across `ServerScriptService` to find any script that listens to it.
   - `script_grep` for `DialogueData` to find any script that requires it.
   - Likely names to look for: `DialogueDirector`, `DialogueServer`, `DialogueHandler`, `DialogueService`, `DialogueRunner`. Also check for misnamed-but-equivalent scripts inside `ServerScriptService.Custom Chat Script`, since dialogue might have been adjacent to chat.

10. When you find it: `script_read` the full source.
11. Note the script's exact name, class (`Script` typically), and any child ModuleScripts (`script_grep` and `inspect_instance` again on the script's children).
12. `[C]` log: `[C] HH:MM — Found dialogue server in <backup file> at ServerScriptService.<exact name> (class <Class>, N lines, M children).`

### Phase 4 — Compatibility check before copying

13. Read the restored script and compare against current testing-place state:
    - **Remote names:** the script must reference `RequestCharacterConversation`, `PlayCharacterDialogue`, `PlayPlayerDialogue`, `PlayerDialogueChoiceSelected` — these already exist as the names in `ReplicatedStorage.DialogueRemotes` per the new export. If the backup script uses different remote names (a renamed older version), that's a real issue. **Flag with `[C] ?`** and don't copy.
    - **`DialogueData` shape:** the script must require `ReplicatedStorage.DialogueData` and read `Characters.<key>`. Verify against the just-exported `src/ReplicatedStorage/DialogueData.lua`. If the script reads a different shape (e.g. older nested structure), flag.
    - **DataStore use:** if the script writes any DataStore key, flag with `[C] ?` — that's a wire contract that needs review.
    - **References to deleted systems:** if the script calls into `LevelLeaderstats`, `TitleService`, `CashLeaderstats`, or anything else from the cleanup-deleted set, flag. The script may need minor edits to drop those calls.

14. If everything checks out, proceed. If anything is flagged, **stop and ask the user.** This brief restores; it doesn't redesign.

### Phase 5 — Export to repo

15. Switch the active Studio back to the testing place: `set_active_studio` to the testing place's id (re-confirm with `list_roblox_studios`). All subsequent edits target the testing place.

16. Write the script source to:

    - `src/ServerScriptService/DialogueDirector.server.lua` if it's a single Script.
    - `src/ServerScriptService/DialogueDirector/init.server.lua` (plus child ModuleScripts as siblings) if it's a script-with-children.

17. Use the exact script name from the backup. If the backup name differs from `DialogueDirector` (e.g. it's actually `DialogueServer`), use the backup's name and document the discrepancy in the inbox so the spec doc gets updated at integration.

18. **Do NOT manually create the script in the testing place via Studio MCP.** Let Rojo sync it from the repo so the repo stays the source of truth.

### Phase 6 — Studio test

19. Rojo serve `default.project.json`. Confirm the new script appears in `ServerScriptService` of the testing place after Rojo connects (verify via `inspect_instance`).
20. Playtest via `start_stop_play`. Walk to `Workspace.QuietKeeperNPC` and trigger the proximity prompt.
21. Confirm:
    - QuietKeeper conversation begins.
    - First line of dialogue plays (per `04_Dialogue/QuietKeeper_Lines.md`, the "First Meeting" intro is `"Oh. Hello." / "You found your way in." / "Stay as long as you'd like."`).
    - Choice buttons appear (3 expected: `"Who are you?"`, `"Where am I?"`, walk-away).
    - Selecting a choice drives the next line (or ends the conversation cleanly).
22. Stop playtest. `[C]` log results: which lines played, did choices work, any console errors.

### Phase 7 — Push and hand back

23. `git push -u origin codex/restore-dialogue-server`
24. Tell the user: which backup file the script came from, the exact name and class, and the playtest result.

## 6. Roblox Services Involved

- `ReplicatedStorage` (reading remotes + DialogueData)
- Whatever else the restored script uses — verify and note.

## 7. Security / DataStore Notes

- ⚠️ Per the dialogue spec, no DataStore use is expected. If the restored script writes DataStore keys, flag and stop.
- ⚠️ The four `DialogueRemotes` are wire contracts — don't rename. Verify the restored script binds to them by their existing names.
- ⚠️ Server-side validation — the script should validate inputs from clients (e.g. character key exists in `DialogueData`, choice index is in range). If the restored script blindly trusts client input, flag in the inbox as a minor concern but don't fix in this brief.

## 8. Boundaries (do NOT touch)

See "Files NOT to touch" above. Specifically: don't edit `DialogueData.lua` or any of the just-exported dialogue files. The restoration is purely additive — adding the missing server piece.

## 9. Studio Test Checklist

- [ ] Pre-check confirmed: no server-side dialogue script in the testing place currently
- [ ] Backup place opened in a second Studio instance; script located
- [ ] Compatibility check passed (remote names match, DialogueData shape matches, no deleted-system dependencies, no surprising DataStore writes)
- [ ] Script exported to `src/ServerScriptService/DialogueDirector*` (use actual name)
- [ ] Rojo serve clean
- [ ] Playtest: QuietKeeper conversation triggers and renders the expected first line
- [ ] Choice buttons appear and selection advances dialogue
- [ ] No new console errors
- [ ] Inbox `[C]` log records: backup file used, exact script name/class, playtest result
- [ ] Branch pushed

## 10. Rollback Notes

If the restored script breaks something: `git checkout main -- src/ServerScriptService/DialogueDirector*` removes the new file. Rojo's next sync removes it from Studio. Dialogue returns to its current broken state — no worse than before.

If the restored script has subtle bugs (works but with errors), keep the branch but iterate: fix in place, push, re-review. Don't merge until playtest is clean.

## 11. Notes for Claude (review)

When Codex pushes:

- Confirm the script's source matches the backup byte-exact (modulo any flagged-and-resolved compatibility edits).
- Spot-check that the four DialogueRemotes binding lines (`OnServerEvent`, `:FireClient` calls) reference the exact existing remote names.
- Run an independent playtest. Dialogue is the riskiest restoration — easy for a subtle remote-shape mismatch to break it. Walk up to QuietKeeper, trigger the prompt, verify the first three lines and a choice selection.
- If Codex flagged compatibility concerns (renamed remotes, deleted-system dependencies), surface those clearly to the user in the verdict so they can decide whether to merge as-is or iterate.
- Verdict format: "Safe to merge — dialogue works again" / "Hold off — <specific issue>" / "Need user's call on <flag>."

After this merges, the dialogue spec doc (`02_Systems/Dialogue_System.md`) should get a small update to confirm the restored architecture matches what's live, plus a change log entry. That's an integration task at end-of-session, not part of this brief.
