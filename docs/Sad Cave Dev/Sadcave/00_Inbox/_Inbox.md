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
> **Lifecycle:** items get triaged into `02_Systems/`, `_Change_Log.md`, or `09_Open_Questions/` at end of session, then cleared from here. Anything still unresolved stays with a `?` prefix and rolls to next session.

---

<!-- New session entries go HERE — add a new dated section above this line, like:
## 2026-04-26
- [C] 09:15 — first observation
-->

## 2026-04-26

- [O] — Fixed Rojo project parse error blocking `rojo serve`. Removed redundant `"className": "Script"` from 4 `init.meta.json` files in `ServerScriptService` (`AntiExploit`, `Custom Chat Script`, `Shop`, `TextChatServiceHandler`). Each conflicted with its sibling `init.server.lua` (newer Rojo rejects the redundant declaration). No behavior change — config hygiene only. Unblocked the first XP session.
- [O] — Fixed second wave of Rojo errors. Triple-bracket UDim2 bug (`[[[a, b]], [[c, d]]]` instead of `[[a, b], [c, d]]`) in 25 init.meta.json files across `SadCaveMusicGui` (13 files) and `ShopMenu` (12 files). Caused by an older Studio exporter; newer one used by `TitleMenu` is fine. Also emptied `notificationUI/Scripting/NotificationsHandler/init.meta.json` (contained only `className: ModuleScript` which conflicted with sibling `init.lua`). All cosmetic/structural — no logic changes.
- [O] — Third wave: removed redundant `"className": "LocalScript"` from 4 init.meta.json files in `StarterPlayer/StarterPlayerScripts` (`ChatBubbleDarkTheme`, `OldChatBubbleTheme`, `RainScript`, `Theme`). Same pattern as the ServerScriptService fix — each had an `init.client.lua` already determining the class. ReplicatedStorage scanned, no className conflicts there.

## YYYY-MM-DD (template — do not write here, this is just a format example)

- [O] HH:MM — example: noticed `CashLeaderstats` still referenced in three places, see `_Cleanup_Backlog`
- [U] HH:MM — example: dialogue cooldown felt too short, bumped to 4s
- [U] HH:MM — ? should daily reward streak break on 1 missed day or 2?
