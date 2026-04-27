# DiscordLogs Secret Refactor — Codex Plan

**Date:** 2026-04-27
**Status:** ⏸ Waiting — Planned, on hold per Tyler. The Discord webhook export is intentionally deferred until the secret-handling approach (Branch A vs B vs C below) is greenlit. Do not execute until Tyler confirms.
**Related Systems:** [[../02_Systems/_No_Touch_Systems]], [[../02_Systems/_Live_Systems_Reference]]
**Branch:** `codex/discordlogs-secret-refactor`
**Spec source of truth:** the housekeeping export brief (`2026-04-27_Housekeeping_Utility_Export_v1.md`) flagged DiscordLogs as un-exportable because its `LogsSettings` child contains a Discord webhook URL marked DO NOT SHARE. Pushing it to a public GitHub repo would leak the credential. This brief refactors DiscordLogs so the webhook URL stays out of source.

---

## 1. Purpose

Get `ServerScriptService.DiscordLogs` into the Rojo source tree without ever putting the Discord webhook URL into a checked-in file. After this lands, DiscordLogs is committed in the repo, the webhook URL lives only in Studio (or Roblox's secrets store), and the export of the kept set is complete.

**Out of scope for this brief:**

- Any change to *what* DiscordLogs logs (events, formatting). Just the secret-handling pattern changes.
- Other secrets-handling reviews. If DiscordLogs has the project's only webhook, that's everything; if there are other Discord/HTTP credentials elsewhere (verify), they need their own briefs.
- Any restructure of the logging surface (no new log levels, no rate-limit changes, etc.).

## 2. Player Experience

None. Logging is a server-internal observability feature.

## 3. Technical Structure

### Three approaches — pick the cleanest one Studio supports

In order of preference:

**Branch A — `HttpService:GetSecret` (preferred).** Roblox added a Secrets API (Game Settings → Security → Secrets) that lets a place store named secrets which scripts read at runtime via `HttpService:GetSecret("WebhookName")`. The secret never appears in source. `HttpService:PostAsync` accepts the returned `Secret` userdata directly. This is the modern correct pattern.

**Branch B — Studio-only sibling ModuleScript (fallback).** Keep `ServerScriptService.DiscordLogs.LogsSettings` as a Studio-only ModuleScript that's NOT mapped by Rojo. The exported parent `DiscordLogs.server.lua` does `require(script:WaitForChild("LogsSettings")).WEBHOOK_URL`. Rojo's `$ignoreUnknownInstances: true` flag in `default.project.json` already preserves Studio-only children, so this works. Downside: the secret still lives in Studio's saved place file, which is fine for a private dev game but conceptually less clean than the Secrets API.

**Branch C — placeholder + per-environment override (last resort).** Export `DiscordLogs` with a `WEBHOOK_URL = ""` placeholder. Set the real URL via a script attribute (`script:SetAttribute("WebhookUrl", "...")`) in Studio that the script reads on init: `local url = script:GetAttribute("WebhookUrl") or ""`. Rojo doesn't sync attributes by default, so the attribute stays Studio-side. Downside: easy to accidentally commit the attribute if `init.meta.json.properties.Attributes` ever gets added.

**Default to Branch A** unless Codex confirms `HttpService:GetSecret` isn't available or the secret can't be set in the place's Game Settings. Document the choice in the inbox with reasoning.

### Server responsibilities

Same as today: the script wakes up, listens to whatever events trigger logging, posts to Discord. Only the source of the URL changes.

### Client responsibilities

None. DiscordLogs is server-only.

### Remote events / functions

None changed.

### DataStore keys touched

None.

## 4. Files / Scripts

### Files to create / modify

- **`src/ServerScriptService/DiscordLogs.server.lua`** — exported from Studio with the secret-source line refactored per the chosen branch.
- **`src/ServerScriptService/DiscordLogs/`** *(only if Studio's live `DiscordLogs` is a folder/script-with-children, not a single Script)* — preserve the live folder structure but exclude `LogsSettings` from Rojo source. Use the `init.server.lua` + sibling pattern if needed.

### Files NOT to commit, ever

- The Discord webhook URL, in any form, in any file under `src/`, `docs/`, `place-backups/`, or anywhere else in the repo.
- A `LogsSettings.lua` file containing the URL.
- An `init.meta.json` `properties.Attributes` block that includes the URL.
- A comment in any committed file that includes the URL.

If during the export you notice the URL anywhere in your staged changes, **abort the commit**, redact, and re-stage. Flag with `[C] ?`.

### Files NOT to touch

Per `_No_Touch_Systems.md`:

- Anything in `src/ServerScriptService/Progression/`, `src/ReplicatedStorage/Progression/`, `src/StarterGui/XPBar/`.
- `src/ServerScriptService/NoteSystemServer.server.lua`, `src/ReplicatedStorage/NoteSystem/`, `src/ServerScriptService/ReportHandler.server.lua`, `src/ServerScriptService/report/`, `src/ReplicatedStorage/ReportRemotes/`.
- `src/ServerScriptService/FavoritePromptPersistence.server.lua`, `src/ReplicatedStorage/AfkEvent/`, `src/ServerScriptService/NameTagScript.server.lua`, `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua`.
- All scripts and remotes just exported in `codex/housekeeping-utility-export` (`DialogueData`, `DialogueRemotes`, `RemoveFF`, `Reset`, `SoftShutdown`, `PromptGroup`, `PromptFavorite`, `NpcDialogueClient`, `PlayerDialogueClient`).
- `default.project.json`, `AGENTS.md`, `PLANS.md`, `README.md`.

## 5. Step-by-Step Implementation (for Codex)

### Phase 0 — Setup

1. Re-read `AGENTS.md` (Session Bookends + Codex Rules) and `_No_Touch_Systems.md`.
2. `git checkout main && git pull && git checkout -b codex/discordlogs-secret-refactor`
3. `[C]` log: starting brief.

### Phase 1 — Inspect live DiscordLogs

4. Use Studio MCP `inspect_instance` on `ServerScriptService.DiscordLogs` to see the class and child structure.
5. Use `script_read` to read both `DiscordLogs` and `DiscordLogs.LogsSettings` (or whichever child holds the URL). Note exactly where the URL is referenced in `DiscordLogs`'s source — that's the line you'll refactor.
6. **Important:** do NOT log the webhook URL anywhere — not in inbox notes, not in commit messages, not in chat. If you need to refer to it, call it `<webhook url>`.
7. `[C]` log a redacted summary: `[C] HH:MM — DiscordLogs is a <Script|ModuleScript> at ServerScriptService.<path>. URL is sourced from <ChildName>.<FieldName> on line N.`

### Phase 2 — Pick the secret approach

8. Check whether `HttpService:GetSecret` is callable in this place. Quick test: from Studio command bar, run:

   ```lua
   local ok, err = pcall(function() return game:GetService("HttpService"):GetSecret("test_nonexistent") end)
   print(ok, err)
   ```

   If the error is "Secret 'test_nonexistent' not found" or similar, the API is available — go with **Branch A**. If the error is `GetSecret is not a valid member of HttpService` or similar, the API isn't available in this place — go with **Branch B**.

9. `[C]` log the choice and reason.

### Phase 3a — Branch A: HttpService:GetSecret

10. In the Studio Game Settings → Security → Secrets, **the user adds a new secret** named (suggested) `DiscordLogsWebhook` with the current webhook URL as its value. Codex cannot do this step via MCP — flag with `[C] ?` and ask the user to do it before continuing.
11. After the user confirms the secret is set, refactor the live `DiscordLogs` source so it reads:

    ```lua
    local HttpService = game:GetService("HttpService")
    local webhookSecret = HttpService:GetSecret("DiscordLogsWebhook")  -- returns Secret userdata
    ```

    Replace whichever `require(...).WEBHOOK_URL` (or equivalent) line is in the source today. Pass the Secret userdata directly to `HttpService:PostAsync(webhookSecret, body, ...)` — `PostAsync` accepts Secrets natively.

12. `script_read` the refactored DiscordLogs in Studio to verify the live source is correct.
13. Export the script to `src/ServerScriptService/DiscordLogs.server.lua`. **Verify zero occurrences of the actual webhook URL in the file** (`grep` for `discord.com/api/webhooks/` and similar; if any match, abort).

### Phase 3b — Branch B: Studio-only sibling ModuleScript

14. Confirm that `default.project.json` uses `$ignoreUnknownInstances: true` for `ServerScriptService` (it does; verify before relying on it).
15. Live `DiscordLogs` already requires a child `LogsSettings`. Refactor as needed so the require line is robust to a missing child:

    ```lua
    local settings = script:FindFirstChild("LogsSettings")
    local webhookUrl = settings and require(settings).WEBHOOK_URL or ""
    if webhookUrl == "" then
        warn("[DiscordLogs] No webhook URL configured; logging disabled.")
        return
    end
    ```

16. **Do not export** `LogsSettings`. It stays Studio-only.
17. Export only the parent `DiscordLogs` to `src/ServerScriptService/DiscordLogs.server.lua` (or `src/ServerScriptService/DiscordLogs/init.server.lua` if it's a script-with-children — Rojo will preserve the child via `$ignoreUnknownInstances`).
18. **Verify zero occurrences of the actual webhook URL in the exported file.**

### Phase 4 — Studio test

19. Rojo serve `default.project.json`. Confirm clean serve (no errors).
20. Playtest via Studio MCP `start_stop_play`. Watch console for:
    - DiscordLogs startup log/print indicating it loaded.
    - Trigger whatever event normally produces a Discord log (e.g. join the server in solo Play mode and check that the configured event fires).
    - Check that no `Secret` or webhook URL appears in console output.
21. **The user will need to verify a real Discord message arrived** — Codex can't see Discord. Flag with `[C] ?`: "Confirm a Discord message arrived in the configured channel after playtest."
22. `[C]` log result.

### Phase 5 — Push and hand back

23. Final pre-push check: `git diff main..HEAD` and grep for `discord.com/api/webhooks/`, `webhooks/`, and any partial fragments of the URL. If anything matches, **stop, fix, re-check before pushing.**
24. `git push -u origin codex/discordlogs-secret-refactor`
25. Tell the user: which branch was chosen (A or B), what action they need to take (set the secret in Game Settings if Branch A, no action if Branch B), and what the playtest produced.

## 6. Roblox Services Involved

- `HttpService` — for `GetSecret` (Branch A) and `PostAsync`.
- Whatever services DiscordLogs already uses for its trigger events (verify; don't change them).

## 7. Security / DataStore Notes

- ⚠️ **The webhook URL is a secret.** Never log it, never commit it, never paste it in chat or inbox.
- ⚠️ Use `HttpService:GetSecret` if available — that's the Roblox-blessed pattern for exactly this situation.
- ⚠️ `HttpService:PostAsync` accepts `Secret` userdata directly; pass the secret object, don't convert it to a string first (which would defeat the point).
- ⚠️ If Branch B is chosen, the URL still lives in the place's saved file. That's not in the repo, but it's still in the place. Treat the place file itself as containing a secret.

## 8. Boundaries (do NOT touch)

See "Files NOT to touch" above. Plus: don't touch any other ServerScriptService script as part of this brief, even if you notice an issue. Flag in inbox if so.

## 9. Studio Test Checklist

- [ ] Live DiscordLogs source no longer contains the webhook URL literal — secret comes from `HttpService:GetSecret` (Branch A) or Studio-only sibling (Branch B)
- [ ] `src/ServerScriptService/DiscordLogs.server.lua` exists and contains zero webhook-URL fragments (verified by `grep` before push)
- [ ] Rojo serves `default.project.json` cleanly
- [ ] Playtest startup log shows DiscordLogs loaded (not erroring on missing secret)
- [ ] User-verified: a real Discord message arrived in the configured channel after playtest
- [ ] Inbox `[C]` log records the branch chosen and the user-action required (if any)
- [ ] Branch pushed

## 10. Rollback Notes

If anything breaks: `git checkout main -- src/ServerScriptService/DiscordLogs.server.lua` removes the new file. The live Studio script still works as long as its dependency (LogsSettings child or HttpService secret) is intact.

If Branch A is chosen and the secret is later removed from Game Settings: DiscordLogs will start failing at the `GetSecret` call. Add a `pcall` wrapper in the refactored source so the script logs a warning and stays alive instead of crashing.

## 11. Notes for Claude (review)

When Codex pushes:

- **The single most important review check:** `grep -r "discord.com/api/webhooks" src/ docs/` and confirm zero matches. Same for any 4-5 character fragment of the actual URL. If anything matches, the secret leaked — block the merge and have Codex force-push a clean version.
- Confirm the choice (Branch A vs B) is reasonable for the place's setup and that user actions (setting the secret) are clearly flagged in the inbox.
- Spot-check the exported file's source against Studio: should match modulo the secret-source line refactor.
- Verdict: "Safe to merge after user confirms the secret is set in Game Settings (Branch A) / no user action needed (Branch B)."
