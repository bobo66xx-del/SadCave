# NameTag / Status System

**Status:** 🟢 Shipped — name-only build live as of PR #9 (merged 2026-04-27 23:20 UTC, branch `codex/nametag-strip-level-row`). The previous "🟡 Building — name-only target" status reflected the gap between the 2026-04-27 (Cowork session 4) decision and the brief landing on `main`; that gap closed at 23:20 UTC.

---

## Purpose
Show each player's display name above their character via a BillboardGui. Title rendering is out for now — the v1 title pipeline was deleted in the 2026-04-27 cleanup; v2 title rendering is a follow-up brief. Level visibility lives on the XPBar (bottom of screen), not on the nametag.

## Player Experience

Above each player floats a single TextLabel — the player's display name, in soft warm-grey, no level row, no title row. Quiet and minimal. Spawning, respawning, and level-ups all leave the nametag unchanged (it doesn't react to leaderstats anymore — that surface lives entirely in the XPBar).

---

## Real Architecture (as built, post-PR #9)

### Server
- **`ServerScriptService.NameTagScript`** (file in repo: `src/ServerScriptService/NameTagScript.server.lua`)
  - Builds the BillboardGui programmatically and adornes it to each character's `HumanoidRootPart`
  - BillboardGui: `Size UDim2.new(0, 200, 0, 30)`, `StudsOffset Vector3.new(0, 3, 0)`, `MaxDistance = 100`, `AlwaysOnTop = true`
  - One TextLabel filling the full BillboardGui:
    - `NameLabel` (`Size UDim2.new(1, 0, 1, 0)`): `Gotham 16`, color `(225, 215, 200)`, stroke `(0, 0, 0)` at transparency 0.6, text = `player.DisplayName`
  - Disables Roblox's default `Humanoid.DisplayDistanceType` so it doesn't compete with the BillboardGui
  - Watches via `AncestryChanged` and re-applies the BillboardGui if it's destroyed (Avalog-safe — the third-party Avalog package destroys tags parented to the Head); the watchdog re-runs on every re-create
  - **No leaderstats hook.** The script does not read or react to `leaderstats.Level` after PR #9; level changes are entirely handled by the XPBar via `ReplicatedStorage.Progression.XPUpdated`.

### Linked AFK plumbing
- **`ReplicatedStorage.AfkEvent`** (RemoteEvent, repo: `src/ReplicatedStorage/AfkEvent/init.meta.json`) — fired by client when window focus changes
- **`StarterPlayerScripts.AfkDetector`** (LocalScript, repo: `src/StarterPlayer/StarterPlayerScripts/AfkDetector.client.lua`) — fires `AfkEvent:FireServer(true/false)` on `WindowFocused` / `WindowFocusReleased`
- The XP Progression `Driver` listens to `AfkEvent.OnServerEvent` to flip the player's AFK state for the presence tick. NameTagScript itself does **not** show AFK status visually right now — that's a follow-up if/when wanted.

### Retired (deleted in 2026-04-27 cleanup)
- `ServerScriptService.NameTagScript Owner` (the old title-rendering nametag)
- `ServerScriptService.OverheadTagsToggleServer` (no-op server handler tied to a client-only preference)
- `ServerScriptService.AFK` (replaced by `AfkEvent` + `AfkDetector` plus the XP Driver's listener)
- `StarterPlayer.StarterPlayerScripts.AFKLS` (replaced by `AfkDetector`)
- `Workspace.NameTags` folder (was scaffolding for the old pipeline)
- `ReplicatedStorage.RebuildOverheadTags`, `ReplicatedStorage.OverheadTagsEnabled`, `ReplicatedStorage.OverheadTagsToggle` (companion remotes/values for the old pipeline)

---

## What's Missing vs Pre-Cleanup

- ❌ Title row — will return when [[Title_System]] v2 ships
- ❌ Level row — removed by PR #9 (2026-04-27); the XPBar is the level surface
- ❌ Distance fade (was unverified pre-cleanup, simply absent now)
- ❌ Hide-during-dialogue (was an open question pre-cleanup; still open)
- ❌ Per-player toggle (was the `GUIToggle` ScreenGui; UI was deleted with the legacy menu pass)

The remaining ❌ items are intentional gaps, not bugs. Each can be reconsidered as part of v2 title rendering or as a small dedicated brief.

---

## Design Notes
- Keep the visual minimal until v2 titles return — don't ship intermediate styling that gets thrown away.
- If a per-player toggle is wanted before v2, treat it as a small dedicated brief; don't extend the current script in-place.
- Avalog watchdog must stay — without it, nametags vanish for any player whose character flow touches Avalog. PR #9 verified the watchdog was preserved through the strip.
- The level row was originally written into the script during the 2026-04-27 rebuild even though the spec described "name-only" — that mismatch was caught during Cowork session 4's Reality Check, the keep/remove call was made (remove), and PR #9 closed the gap so build and spec agree. If a future brief wants to surface anything beyond the name on the nametag (titles, tags, status icons), update this spec first and let the brief follow.

## Related
- [[XP_Progression]] (drives the presence-tick AFK state)
- [[Title_System]] (the v2 redesign that will reintroduce title rendering)
- [[../06_Codex_Plans/2026-04-27_Repo_Strip_to_Studio_State_v1]] (verifies the new artifacts are in repo)
