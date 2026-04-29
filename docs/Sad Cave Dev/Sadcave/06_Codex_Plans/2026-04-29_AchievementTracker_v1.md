# AchievementTracker — Codex Plan

**Date:** 2026-04-29
**Status:** 🟡 Building (Codex pushed `codex/achievement-tracker` head `2df4378`, Claude review passed playtest, awaiting Tyler's merge)
*(legend: 🔵 Queued — written, awaiting Codex · 🟡 Building — Codex on branch · 🟢 Shipped — merged, include PR # and date · ⏸ Waiting — written but deliberately on hold · ⚫ Superseded — replaced or invalidated)*
**Branch:** `codex/achievement-tracker` (head `2df4378`, pushed 2026-04-29 ~08:03 UTC, awaiting merge)
**Related Systems:** [[../02_Systems/Title_System]], [[../02_Systems/Dialogue_System]], [[../02_Systems/XP_Progression]], [[../01_Vision/Player_Experience_Arcs]]

**Driving notes:** First slot in the Title category activation sequence (anchored to the felt-shape map in `Player_Experience_Arcs` — Achievement category has the densest concentration of beats falling in the diagnosed-weak days 3–7 of the return arc). Title v2 surface is feature-complete on the player-facing side (PRs #12 / #13 / #14 / #17); only the level + gamepass categories actively check ownership today. This brief activates the achievement category — ~12 of the 60 titles in `TitleConfig` light up. Design decisions made in the 2026-04-29 design pass with Tyler:

- `fell_asleep_here` uses `Player.Idled` (idle detection — physical inactivity), not the focus-based `AfkDetector`.
- `heard_them_all` ships now, future-proofed against new NPCs via the existing `DialogueData.Characters` registry. Min-NPC gate (3) keeps it dormant with the current QuietKeeper-only roster — the title fires automatically when at least 3 NPCs are defined and a player has spoken to all of them.
- `knows_every_chair` is a per-session unique-seat set (resets on rejoin). Once earned, persistent.
- `day_one` ships with the launch window left as `nil` placeholders in `TitleConfig` — Tyler sets the actual launch date when real launch happens. Title is dormant until then.
- `up_too_late` follows the spec already in `Title_System` (client sends UTC offset, server checks 3am–5am local time).
- Single brief — all twelve titles, shared hook plumbing.

---

## 1. Purpose

Activate the Achievement title category in the Title v2 system. Add a new `AchievementTracker` ModuleScript that:

- Tracks per-player achievement flags inside the existing `TitleData` DataStore (no new key — flags live in `TitleData.achievements`, already specced).
- Listens to existing system signals (dialogue completion, note submission, sitting, idle, seat changes, group membership, revisits, time-of-day windows) and sets the corresponding flag the first time a condition fires.
- Fires an `AchievementUnlocked(player, achievementId)` BindableEvent when a flag flips from false to true.
- Cooperates with `TitleService` so newly-earned achievements immediately recompute the player's owned-title set, fire `TitleDataUpdated`, and trigger the existing client-side `new title: <display>` fade.

After this brief ships, twelve achievement titles become earnable. The polished-menu and presence-category briefs are unblocked to follow.

## 2. Player Experience

When a player triggers an achievement condition (e.g. completes their first conversation), they see a short text fade above the XPBar reading `new title: said something`, holding 5 seconds. Same fade pattern that level milestones use. If a level-up and an achievement unlock fire close together, they merge into the existing combined fade (`level N — new title: X`).

The title appears in their owned-tab list inside the placeholder TitleMenu, ready to equip. Auto-equip-highest still applies for first-time players (a low-level player who unlocks `said_something` may auto-equip it if it outranks their current level title; the existing manual-equip-respects-forever rule remains untouched).

The twelve titles activated by this brief and what triggers each:

| ID | Display | Trigger |
|----|---------|---------|
| `said_something` | said something | First completed conversation with any NPC. |
| `sat_down` | sat down | First time seated for ≥30s continuous. |
| `left_a_mark` | left a mark | First successful note submission. |
| `came_back` | came back | Second session (revisits ≥ 2). |
| `keeps_coming_back` | keeps coming back | Tenth session (revisits ≥ 10). |
| `part_of_the_walls` | part of the walls | Fiftieth session (revisits ≥ 50). |
| `heard_them_all` | heard them all | Talked to every NPC currently defined in `DialogueData.Characters`, AND the registry contains at least `HEARD_THEM_ALL_MIN_NPCS` (= 3) entries. Gate keeps it dormant with the current QuietKeeper-only roster. |
| `knows_every_chair` | knows every chair | Sat at five different `SeatMarker` seats in the same session. Set resets on rejoin. |
| `up_too_late` | up too late | Player's local clock is between 03:00 and 05:00 at any point during the session. Local time computed from server-time + client-reported UTC offset. |
| `fell_asleep_here` | fell asleep here | First time `Player.Idled` fires for the player (Roblox default: 20 minutes of mouse/keyboard inactivity — comfortably ≥ the 19-minute spec target). |
| `one_of_us` | one of us | Member of group `8106647` at session start. |
| `day_one` | day one | Joined within the v2 launch window. Window timestamps are `nil` until Tyler sets them — title is dormant on ship. |

## 3. Technical Structure

### Server responsibilities

- **`AchievementTracker` ModuleScript** at `ServerScriptService.Progression.AchievementTracker` — same folder as the rest of the progression layer, but it does not depend on `Progression/Sources/` and is not part of the XP tick. Its role is purely "watch for the trigger conditions of achievement titles and flip the flag the first time."
- **`AchievementTrackerInit` server starter** at `ServerScriptService.Progression.AchievementTrackerInit.server.lua` — mirrors the `TitleServiceInit` pattern from PR #13 (ModuleScript + thin starter). The starter requires the module, calls `AchievementTracker.Start()`, and is the runtime entry point.
- **TitleService integration** — `TitleService.lua` adds achievement-category ownership resolution (right now it only checks level + gamepass) and listens to `AchievementTracker.AchievementUnlocked` so newly-earned achievements immediately recompute owned titles and fire `TitleDataUpdated`.
- **Persistence** — flags live in `TitleData.achievements` (already specced in the Title_System note). No new DataStore key. The `npcsHeard` set (for `heard_them_all`) lives in the same table as a sibling field — `TitleData.npcsHeard = { [characterKey] = true, ... }`. Persistent across sessions.
- **Hooks** — see § 5 for how each achievement is wired.

### Client responsibilities

Mostly nothing new. Two small additions:

- **`AchievementClient` LocalScript** at `StarterPlayer.StarterPlayerScripts.AchievementClient.client.lua` — fires the new `ClientLocalTime` RemoteEvent on character spawn, sending the client's UTC offset (computed from `os.time()` vs `os.date("!*t")` math). Used only by `up_too_late`. Tiny script.
- The existing client-side title-unlock fade (`XPBarController` listening to `TitleDataUpdated` for the combined-fade format) already handles the visual notification. No client UI work.

### Remote events / functions

New under `ReplicatedStorage.AchievementRemotes/`:

- `ClientLocalTime` (RemoteEvent) — client sends its UTC offset (number, seconds) once on spawn. Server uses it for `up_too_late` window checks.

No other new remotes. No new RemoteFunctions.

### DataStore keys touched

Only the existing `TitleData` key (read + write). The flags + `npcsHeard` set live alongside `equippedTitle`, `migratedFromV1`, and the existing achievement flags placeholder.

### BindableEvents

- `AchievementTracker.AchievementUnlocked` — internal server-side BindableEvent. Listened to by `TitleService` only. Payload: `(player: Player, achievementId: string)`.
- `DialogueDirector.ConversationEnded` (NEW or existing — see § 5) — server-side BindableEvent fired when a conversation ends. Payload: `(player: Player, characterKey: string)`. Codex verifies whether a signal of this shape already exists in `DialogueDirector`; if not, adds it as a small additive instrumentation. `AchievementTracker` listens.
- `NoteSystemServer.NoteSubmitted` (NEW — additive) — server-side BindableEvent fired after a note successfully persists. Payload: `(player: Player, spotId: string)`. **Authorization:** `NoteSystemServer` is on the no-touch list; this brief explicitly authorizes adding a small additive BindableEvent there. The change must not modify the existing `SubmitNote` validation, persistence, cooldown, or `NoteResult` paths — only fire the new BindableEvent after the existing successful-save code path completes.

## 4. Files / Scripts

**Create:**

- `src/ServerScriptService/Progression/AchievementTracker.lua` — new ModuleScript. ~200–300 lines including all twelve hook implementations.
- `src/ServerScriptService/Progression/AchievementTrackerInit.server.lua` — thin runtime starter. ~10 lines.
- `src/ReplicatedStorage/AchievementRemotes/init.meta.json` — Folder.
- `src/ReplicatedStorage/AchievementRemotes/ClientLocalTime/init.meta.json` — RemoteEvent.
- `src/StarterPlayer/StarterPlayerScripts/AchievementClient.client.lua` — small client script. ~15 lines.

**Modify:**

- `src/ServerScriptService/TitleService.lua` — add achievement-category ownership resolution; listen to `AchievementTracker.AchievementUnlocked`; on fire, recompute owned titles and re-publish `TitleDataUpdated`. Touch the unlock-detection path that already exists for level/gamepass — extend, don't rewrite.
- `src/ReplicatedStorage/TitleConfig.lua` — confirm achievement entries have `achievementId` set per the table in `Title_System`. Add a `LAUNCH_WINDOW = { startUnix = nil, endUnix = nil }` (or similar, top-level) for `day_one` — both nil placeholders. Add `HEARD_THEM_ALL_MIN_NPCS = 3` constant. Document inline that Tyler sets `LAUNCH_WINDOW` when actual v2 launch happens.
- `src/ServerScriptService/NoteSystemServer.server.lua` — additive: create `NoteSubmitted` BindableEvent at top of file, fire it after the existing successful-save path inside the `SubmitNote.OnServerEvent` handler. **No other changes.** Re-read the file in full before editing — this is a no-touch system being touched under explicit authorization, and the change must be minimal and surgical.
- The existing dialogue server script (verify exact name in Studio: `DialogueDirector` per the Dialogue_System spec, but `_Live_Systems_Reference` notes the exact name should be confirmed) — add a `ConversationEnded` BindableEvent if one doesn't already exist. If a signal of similar shape exists under a different name (e.g. `ConversationFinished`, `DialogueEnded`), use that and document the alternate name in the inbox. **Verify in Studio first via `script_read` or `inspect_instance` before assuming.**

**Do NOT modify:**

- `ProgressionService.lua`, `Progression/Driver.server.lua`, `Progression/Sources/PresenceTick.lua` — all no-touch. AchievementTracker reads `Player.leaderstats.Level.Value` and `ProgressionData` indirectly via TitleService's existing accessor pattern; for `sat_down` it hooks `Humanoid.Seated` directly rather than instrumenting PresenceTick.
- `AfkDetector.client.lua` and `AfkEvent` — unrelated; idle detection uses `Player.Idled` which is server-readable and independent.
- `TitleConfig.MIGRATION` table — read only.
- The placeholder TitleMenu UI, `NameTagEffectController`, `XPBarController` client — unchanged. The existing fade-on-`TitleDataUpdated` path already handles achievement title notifications.
- Any unrelated repo file.

## 5. Step-by-Step Implementation (for Codex)

### Setup

1. **Branch.** `git checkout main && git pull && git checkout -b codex/achievement-tracker`.
2. **Read context.** Open in this order:
   - `02_Systems/Title_System.md` (the Achievements table and the AchievementTracker section).
   - `02_Systems/Dialogue_System.md` (so the conversation hook makes sense).
   - `01_Vision/Tone_and_Rules.md` (every brief).
   - `02_Systems/_No_Touch_Systems.md` (especially the `NoteSystemServer` and `ProgressionService` entries — this brief touches `NoteSystemServer` under explicit authorization).
   - `src/ServerScriptService/TitleService.lua` (especially the ownership-resolution path you'll extend).
   - `src/ReplicatedStorage/TitleConfig.lua` (the achievements entries).
   - `src/ServerScriptService/NoteSystemServer.server.lua` (the existing `SubmitNote` handler — read fully before adding the BindableEvent).
3. **Verify dialogue signal.** In Studio, locate the dialogue server script (per `Dialogue_System.md` it's `DialogueDirector` in `ServerScriptService`). Read it via `script_read`. Look for a "conversation ended" signal — could be a BindableEvent, a function callback, or an explicit `:Fire` somewhere at the end-of-conversation code path. Note in the inbox what you find; spec the hook accordingly.
4. **Verify NPC roster.** Read `ReplicatedStorage.DialogueData` to confirm the shape of `Characters` and how to enumerate keys. Currently expect one key (`QuietKeeper`).

### Build the AchievementTracker module

5. **Skeleton.** Create `AchievementTracker.lua` with:
   - `local AchievementTracker = {}`
   - A `BindableEvent` for `AchievementUnlocked`, exposed as `AchievementTracker.AchievementUnlocked` (the `.Event`).
   - `_sessionState` table keyed by `Player` for per-session data (seat set for `knows_every_chair`, conversation count if needed). Cleaned on `Players.PlayerRemoving`.
   - A `function AchievementTracker.Start()` entry point that hooks `Players.PlayerAdded` / `PlayerRemoving` and any global signals (e.g. `DialogueDirector.ConversationEnded`).
   - A private helper `flagAndFire(player, achievementId)`:
     - Read the player's TitleData (via TitleService — add a small `TitleService.GetTitleData(player)` accessor if not already present).
     - If `titleData.achievements[achievementId]` is already truthy, return — already earned.
     - Set `titleData.achievements[achievementId] = true`, save TitleData (existing TitleService save path), fire `AchievementUnlocked:Fire(player, achievementId)`.
6. **Stub the ModuleScript starter.** Create `AchievementTrackerInit.server.lua` with `require(script.Parent.AchievementTracker).Start()` and a `print("[AchievementTracker] script ready")` log.

### Implement each achievement

Implement these in order. After each, smoke-test in Studio if possible (some are easier than others to trigger).

7. **`came_back` / `keeps_coming_back` / `part_of_the_walls`.** On `PlayerAdded` (after TitleData loads — coordinate ordering with TitleService's existing PlayerAdded handler so achievements check after data is ready), read `ProgressionData.revisits` (via TitleService's existing accessor or a small additive helper). For each threshold (2 / 10 / 50), call `flagAndFire` if reached.
8. **`one_of_us`.** On `PlayerAdded`, `pcall(GroupService.GetGroupsAsync, player.UserId)` (or use `IsInGroup` if simpler). If group `8106647` is in the result, call `flagAndFire(player, "one_of_us")`.
9. **`day_one`.** Read `TitleConfig.LAUNCH_WINDOW`. If both `startUnix` and `endUnix` are non-nil and `os.time()` is in `[startUnix, endUnix]`, call `flagAndFire(player, "day_one")` on `PlayerAdded`. If either is nil, skip.
10. **`said_something`.** On `DialogueDirector.ConversationEnded(player, characterKey)`:
    - `flagAndFire(player, "said_something")`.
    - Add `characterKey` to `titleData.npcsHeard` (set syntax: `npcsHeard[characterKey] = true`). Save.
    - Check `heard_them_all`: enumerate `DialogueData.Characters` keys, count them. If count ≥ `TitleConfig.HEARD_THEM_ALL_MIN_NPCS` AND every key in the registry is in `npcsHeard`, call `flagAndFire(player, "heard_them_all")`.
11. **`left_a_mark`.** On `NoteSystemServer.NoteSubmitted(player, spotId)`, call `flagAndFire(player, "left_a_mark")`.
12. **`sat_down` and `knows_every_chair`.** On `CharacterAdded`, hook `humanoid.Seated:Connect(function(isSeated, seatPart) ... end)`:
    - When `isSeated` becomes true and `seatPart` is set: record start time; record `seatPart.Name` in the per-session set in `_sessionState`. If unique-seat set size ≥ 5, call `flagAndFire(player, "knows_every_chair")`.
    - When `isSeated` is true and the player has been seated ≥ 30s continuously without standing: call `flagAndFire(player, "sat_down")`. Implementation: when seated starts, schedule a `task.delay(30, ...)` that re-checks `humanoid.Sit` is still true at fire time. If the player stood up before 30s elapsed, the delayed check fails and the flag doesn't fire.
    - On respawn (`CharacterAdded` again), don't reset the per-session seat set — Tyler said "per session" meaning per server-session, not per life. The set clears only on `PlayerRemoving`.
13. **`up_too_late`.** Run a once-per-minute server check per active player: compute their local time as `os.time() + utcOffsetSeconds`. Convert to hour-of-day (`os.date("*t", localUnix).hour`). If hour is 3 or 4 (i.e. 03:00–04:59), call `flagAndFire(player, "up_too_late")` and stop checking that player for the rest of the session. If `utcOffsetSeconds` hasn't arrived yet (client hasn't sent), skip the check that minute. Implementation can be a single global `task.spawn` loop with a 60s `wait`, iterating active players.
14. **`fell_asleep_here`.** On `PlayerAdded`, hook `player.Idled:Connect(function() flagAndFire(player, "fell_asleep_here") end)`. Roblox's default Idled fires after 20 minutes of mouse/keyboard inactivity — comfortably ≥ the 19-minute spec target. We accept this as the trigger; no custom timer needed.

### Wire TitleService to AchievementTracker

15. **TitleService extension.** In `TitleService.lua`:
    - Require `AchievementTracker`.
    - Connect to `AchievementTracker.AchievementUnlocked`. On fire, recompute the player's owned-titles list (extend the existing ownership-resolution path to include achievement titles — find each title in `TitleConfig.TITLES` whose `category == "achievement"` and whose `achievementId` matches a flag in `titleData.achievements`).
    - Re-publish `TitleDataUpdated` so the client picks up the new title and the existing `new title: X` fade fires.
    - If the achievement title is the highest-tier owned and the player hasn't manually equipped a title, auto-equip-highest may swap to the new achievement title (use the existing `refreshAutoEquip` path — don't rewrite).
16. **Add `TitleService.GetTitleData(player)`** if a public accessor doesn't already exist (small additive helper for AchievementTracker; ~3 lines).

### Add the client UTC-offset reporter

17. **Create the RemoteEvent.** Add `AchievementRemotes` Folder + `ClientLocalTime` RemoteEvent under `ReplicatedStorage`.
18. **AchievementClient.client.lua.** On `LocalPlayer.CharacterAdded` (or just `script.Parent.LocalPlayer` ready), compute UTC offset: `os.time() - os.time(os.date("!*t"))` (seconds offset from UTC). Fire `AchievementRemotes.ClientLocalTime:FireServer(offsetSeconds)`. AchievementTracker server-side listens on `OnServerEvent` and stores the offset on `_sessionState[player].utcOffsetSeconds`.

### Update TitleConfig

19. **TitleConfig changes.**
    - Confirm every achievement title in `TITLES` has `category = "achievement"` and a non-nil `achievementId` matching the IDs above. If any are missing or wrong, fix them (purely data; trivial).
    - Add `TitleConfig.LAUNCH_WINDOW = { startUnix = nil, endUnix = nil }` near the top, with an inline comment: `-- Set both timestamps to the v2 launch start and start+7days when real launch happens. Leave nil to keep day_one dormant.`
    - Add `TitleConfig.HEARD_THEM_ALL_MIN_NPCS = 3` near the top.
20. **Document the `npcsHeard` field** at the top of TitleService alongside the other TitleData field documentation. Mention it's persistent across sessions.

### NoteSystemServer instrumentation

21. **NoteSystemServer additive change.** Re-read the file in full. Add a `NoteSubmitted` BindableEvent at the top (`local NoteSubmitted = Instance.new("BindableEvent")` and expose via `_G.SadCaveNoteSubmitted = NoteSubmitted` — actually no, prefer the `script:SetAttribute("SignalRef", ...)` pattern is overkill; the cleanest cross-script signal is to put the BindableEvent under `ServerScriptService.NoteSystemServer.NoteSubmitted` as a child Instance and have AchievementTracker `:WaitForChild` it. **Codex picks the cleanest pattern given the existing code shape**; document the choice in the inbox).
    - Fire the BindableEvent inside the existing `SubmitNote.OnServerEvent` handler, **after** the existing successful-save path completes. **Do not change** any existing logic — no validation tweaks, no cooldown changes, no error-path modifications.
    - Re-read the file after the change to confirm the only diff is the BindableEvent declaration + the single `:Fire` call.

### Dialogue ConversationEnded signal

22. **Dialogue server script.** Read the existing dialogue server script (verify name first — `DialogueDirector` per the spec). Look for the conversation-end code path. Add a `ConversationEnded` BindableEvent (parented either to the script itself as a child Instance, or under a known location like `ServerScriptService.DialogueDirector.ConversationEnded` — Codex picks). Fire `(player, characterKey)` at the conversation-end point. AchievementTracker `:WaitForChild`s and listens.
    - If a similar signal already exists, use the existing one and document in the inbox what name it has.

### Test

23. **Studio playtest** via `start_stop_play` + `console_output`. Walk this checklist:
    - `[AchievementTracker] script ready` prints on server start.
    - Spawn into the world. `[AchievementTracker]` doesn't error on PlayerAdded.
    - Talk to QuietKeeper, finish the conversation. Verify `said_something` flag flips, `new title: said something` fade fires above XPBar, `npcsHeard[QuietKeeper] = true` saves. Verify `heard_them_all` does NOT fire (only 1 NPC < 3 minimum).
    - Sit on a `Workspace.SeatMarkers.Seat` for 30+ seconds. Verify `sat_down` flag flips and fade fires.
    - Stand up. Sit at five different SeatMarkers in the same session (if testing place has only one, skip this and document in the inbox; if more exist, verify `knows_every_chair` fires after the fifth).
    - Submit a note. Verify `left_a_mark` flag flips and fade fires.
    - Check `one_of_us` — Tyler is in group `8106647`, so on his join the flag should fire on the first session that has this brief running.
    - Check `came_back` — depends on Tyler's `revisits` count; if ≥ 2, should fire on the first join after this brief lands.
    - Idle test: walk away from the keyboard for 20+ minutes. Verify `fell_asleep_here` fires. (Time-consuming; if Codex's session can't accommodate, document in inbox and leave for Tyler to verify on his own.)
    - `up_too_late` test: hard to fake at noon. Verify the code path at minimum by temporarily forcing `utcOffsetSeconds` to a value that makes "now" 03:30 — confirm the flag fires. Revert the test override before push.
    - `day_one` test: verify the flag does NOT fire on join (LAUNCH_WINDOW is nil). Optional: temporarily set LAUNCH_WINDOW to a window that includes "now," join, verify it fires; revert.
    - Achievement title appears in the placeholder TitleMenu's `owned` tab.
    - No errors in the log.
24. **Capture observations in inbox** as `[C]` lines. Be specific: which achievements were verified end-to-end vs. code-reviewed only. Flag any that couldn't be tested.
25. **Push and hand back for review.** `git push -u origin codex/achievement-tracker`. Standard handoff.

## 6. Roblox Services Involved

- `Players` — for `PlayerAdded`, `PlayerRemoving`, `Player.Idled`.
- `DataStoreService` — indirectly, via TitleService's existing save path.
- `GroupService` — for `one_of_us` (use `pcall` — group lookups can fail).
- `RunService` (or `task.spawn` + `task.wait`) — for the once-per-minute `up_too_late` loop.
- No `MarketplaceService`, no `TweenService`, no `Lighting`, no `HttpService`.

## 7. Security / DataStore Notes

- ⚠️ **Server-authoritative.** Every achievement check happens server-side. Client never claims "I achieved X." The only client-originated data is the UTC offset for `up_too_late`, which is documented as low-risk (worst case: a player fakes their timezone and earns one cosmetic title).
- ⚠️ **Save coalescing.** Each `flagAndFire` triggers a TitleData save. If multiple achievements fire close together (e.g. the player joins for the second time AND happens to be idle 20 min into that session), the saves should not race. Use the existing TitleService save path which already handles this — don't write a parallel save. If TitleService doesn't already coalesce, that's a fix for a different brief; this brief assumes the existing save behavior.
- ⚠️ **Idempotency.** `flagAndFire` is a no-op if the flag is already true — re-running it never double-fires `AchievementUnlocked` and never spams the title fade.
- ⚠️ **Group lookup pcall.** `GroupService:GetGroupsAsync` (or `IsInGroup`) can fail with an HTTP error. Wrap in `pcall`; on failure, log a warning and skip — don't fire `one_of_us` based on a failed lookup, and don't crash the rest of AchievementTracker.
- ⚠️ **Idled is server-readable.** `Player.Idled` is on the server-side `Player` instance. No need for the client to forward anything — server hooks directly. This is what makes idle detection reliable: client-side idle reporting could be spoofed, server-side is authoritative.
- ⚠️ **NPC enumeration.** `DialogueData.Characters` is read every time `said_something` fires — make sure the read is cheap (it's a ModuleScript table; already in memory). Don't `:WaitForChild` it on every fire; require it once at module load.
- ⚠️ **Per-session state cleanup.** Make sure `_sessionState[player]` is cleaned on `PlayerRemoving` to prevent memory leaks across many sessions.
- ⚠️ **`heard_them_all` recheck on join.** If a player previously talked to QuietKeeper (when only 1 NPC existed), and Tyler later adds a second + third NPC, `heard_them_all` should re-check on the player's next session — they already have `npcsHeard[QuietKeeper]`, they just need to talk to the new NPCs. This works automatically because the check happens on every `ConversationEnded`, but make sure it also re-checks on `PlayerAdded` (in case the player joined after Tyler added NPCs but doesn't talk to anyone that session — the title shouldn't fire then, but if the existing `npcsHeard` already covers everyone, it should fire on join).

## 8. Boundaries (do NOT touch)

- `ProgressionService.lua`, `Driver.server.lua`, `PresenceTick.lua` — no-touch. AchievementTracker reads progression data via TitleService's accessor, never directly modifies progression state.
- `AfkDetector.client.lua`, `AfkEvent` — unrelated; idle detection uses `Player.Idled` server-side independently.
- `XPBarController.client.lua` — the fade pipeline already works; AchievementTracker doesn't talk to the client directly. Achievement notifications ride the existing `TitleDataUpdated` path that XPBarController already listens to.
- `NameTagScript.server.lua`, `NameTagEffectController` — unchanged. TitleLabel/effect rendering follows the existing equipped-title path.
- The placeholder TitleMenu UI — unchanged. Achievement titles appear automatically because the TitleMenu reads from TitleData.
- `TitleConfig.MIGRATION` table — read-only, don't touch.
- `ReportHandler`, `report/reportHandler`, ReportRemotes — unrelated.
- `FavoritePromptPersistence`, `PromptFavorite` — unrelated.
- Real player data on production DataStores — we work in the testing place; data is real but isolated from production.
- Anything on `_No_Touch_Systems.md` not explicitly authorized in § 4 above.

## 9. Studio Test Checklist

- [ ] **`[AchievementTracker] script ready`** prints on server start.
- [ ] **`said_something` fires** on first conversation completion. Fade reads `new title: said something`, holds 5s.
- [ ] **`heard_them_all` does NOT fire** with QuietKeeper as the only NPC (gate at min 3 NPCs holds).
- [ ] **`sat_down` fires** after 30s seated on a SeatMarker. Doesn't fire if player stands at 28s.
- [ ] **`left_a_mark` fires** after a successful note submission. Doesn't fire on a note that fails the validation (cooldown/length/level).
- [ ] **`came_back` / `keeps_coming_back` / `part_of_the_walls`** fire correctly based on Tyler's actual `revisits` count on first join under this brief.
- [ ] **`one_of_us` fires** if Tyler is in group `8106647` (verify expected behavior on his account).
- [ ] **`fell_asleep_here` fires** after Roblox's default 20-minute idle. (Time-consuming — Codex may verify the code path and leave the long-form verification for Tyler.)
- [ ] **`up_too_late` fires** when the local-time check passes. Verified at minimum via temporary offset override; reverted before push.
- [ ] **`day_one` does NOT fire** with `LAUNCH_WINDOW` nil. Verify by checking the flag stays false on join.
- [ ] **`knows_every_chair`** fires when 5 unique seats are sat in the same session (if testing place has 5+ seats).
- [ ] **TitleData saves cleanly** after each unlock; persist across leave/rejoin.
- [ ] **TitleMenu owned tab updates** — newly-earned achievement titles appear without a rejoin.
- [ ] **No errors in console.** No double-fires, no save-race warnings, no missing-child errors on the new `ConversationEnded` / `NoteSubmitted` BindableEvents.
- [ ] **NoteSystemServer behavior unchanged** — same cooldown, same length cap, same level gate, same NoteResult codes. Submit a note that's too long and verify the error path still works.

## 10. Rollback Notes

- If AchievementTracker errors out, the `Init` script can be deleted from `ServerScriptService.Progression/` — TitleService falls back to its current behavior (level + gamepass categories only). All twelve achievement titles silently stop being earnable; existing achievement data on TitleData is preserved.
- The `NoteSubmitted` BindableEvent is additive and has zero callers if AchievementTracker is removed — safe to leave in place during rollback.
- The `ConversationEnded` BindableEvent likewise additive.
- The `LAUNCH_WINDOW = { nil, nil }` constant in TitleConfig is a no-op when nil — nothing breaks if Codex never sets it.
- `TitleService.GetTitleData(player)` accessor is additive and safe to leave even if AchievementTracker is rolled back.
- `git revert` of the merge commit cleanly removes everything: AchievementTracker, AchievementRemotes, AchievementClient, TitleConfig constants, TitleService extension, NoteSystemServer + DialogueDirector instrumentation. No DataStore migration is needed for rollback (the achievements field is empty for players who never earned anything, and `npcsHeard` is similarly empty).

## 11. Notes for Tyler / Claude review

- **The min-NPC gate is the future-proof lever for `heard_them_all`.** Today: 1 NPC, gate holds (1 < 3). When Tyler adds a second NPC: 2 < 3, still gated. Third NPC: gate opens, the title becomes earnable for any player whose `npcsHeard` covers all three. Players who already talked to QuietKeeper get partial credit automatically (their persistent `npcsHeard` set carries forward). When Tyler decides the right minimum is 5 instead of 3, change `HEARD_THEM_ALL_MIN_NPCS` in TitleConfig — no other code change needed.
- **`day_one` activation when launch happens:** Tyler edits `TitleConfig.LAUNCH_WINDOW = { startUnix = <launch_unix>, endUnix = <launch_unix + 7 * 86400> }`. That's the entire activation. After 7 days the window closes naturally; `day_one` becomes unearnable for new players. Tyler can choose to wipe the constant later (set both back to nil) or leave the closed-window state — either works.
- **Seat list test depends on testing place geometry.** Per `_Live_Systems_Reference`, `Workspace.SeatMarkers` has at least one Seat (`CustomSitAnimScript`-bearing). If there are fewer than 5 SeatMarkers in the testing place, Codex can't verify `knows_every_chair` fires; flag in inbox for Tyler to verify after adding more seats, or Codex can spawn a few extra seats temporarily for the test (delete before push).
- **Idle test takes 20 minutes wall-clock.** Codex may verify the code path (the `Player.Idled:Connect` line) without actually waiting 20 minutes, and leave the long-form verification for Tyler. If so, flag clearly in the inbox: `[C] HH:MM — fell_asleep_here code path wired but not runtime-tested (would require a 20-minute idle hold). Tyler please verify on a future session.`
- **NoteSystemServer is being touched under explicit authorization.** Codex's edit must be minimal: declare the BindableEvent, fire it at the existing successful-save point, nothing else. Re-read the file after the edit to confirm the diff is clean. If the edit accidentally changes a validation path, halt and flag immediately.
- **Title v2 design dependencies — none new.** This brief depends on what's already shipped (Title v2 MVP-1 + MVP-1 followup + MVP-2 + migration verification). No coordination needed with any other open brief. Polished TitleMenu is parallel-track and unblocked to follow.
- **Resolves the `fell_asleep_here` open question** that's been sitting in `Title_System.md` since the v2 spec was written. Update the Title_System "Open Questions (resolved)" section at integration to note that the focus-vs-idle decision was made in this session and the implementation lives here.
