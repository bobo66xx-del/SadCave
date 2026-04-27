# NameTag / Status System

**Status:** 🟢 Shipped (rebuilt 2026-04-27) — minimal name-only version

---

## Purpose
Show each player's display name above their character via a BillboardGui. The previous title- and level-rendering responsibilities are out for now (the v1 title pipeline was deleted in the 2026-04-27 cleanup; v2 title rendering is a follow-up brief).

## Player Experience
Above each player: a single BillboardGui label with the player's display name. No title row, no level handle. Quiet and minimal — fits while the title/level rendering pipeline is being redesigned.

---

## Real Architecture (as built, post-2026-04-27)

### Server
- **`ServerScriptService.NameTagScript`** (file in repo: `src/ServerScriptService/NameTagScript.server.lua`)
  - Builds the BillboardGui programmatically and adornes it to each character's `HumanoidRootPart`
  - Watches via `AncestryChanged` and re-applies if the tag is destroyed (Avalog-safe — the third-party Avalog package destroys tags parented to the Head)
  - Single label, single TextLabel for the player's display name

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
- ❌ Level / handle row — deferred design choice; XP MVP keeps level visible via leaderstats, no nametag rendering needed for it yet
- ❌ Distance fade (was unverified pre-cleanup, simply absent now)
- ❌ Hide-during-dialogue (was an open question pre-cleanup; still open)
- ❌ Per-player toggle (was the `GUIToggle` ScreenGui; UI was deleted with the legacy menu pass)

These are intentional gaps, not bugs. Each can be reconsidered as part of v2 title rendering or as a small dedicated brief.

---

## Design Notes
- Keep the visual minimal until v2 titles return — don't ship intermediate styling that gets thrown away.
- If a per-player toggle is wanted before v2, treat it as a small dedicated brief; don't extend the current script in-place.
- Avalog watchdog must stay — without it, nametags vanish for any player whose character flow touches Avalog.

## Related
- [[XP_Progression]] (drives the presence-tick AFK state)
- [[Title_System]] (the v2 redesign that will reintroduce title rendering)
- [[../06_Codex_Plans/2026-04-27_Repo_Strip_to_Studio_State_v1]] (verifies the new artifacts are in repo)
