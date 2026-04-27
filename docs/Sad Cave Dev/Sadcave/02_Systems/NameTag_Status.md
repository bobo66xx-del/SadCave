# NameTag / Status System

**Status:** 🟡 Building — name-only target, build pending via [[../06_Codex_Plans/2026-04-27_NameTag_Strip_Level_Row_v1]]. **Decision 2026-04-27 (Cowork session 4):** Tyler decided to remove the level row from the nametag — the level already lives in the XPBar and the doubled surface was louder than the tone allows. The brief was queued and is waiting on Codex; until it ships, the live build still renders name + level (sections below describe both the current build and the post-brief target).

---

## Purpose
Show each player's display name and current level above their character via a BillboardGui. The previous title-rendering responsibility is out for now — the v1 title pipeline was deleted in the 2026-04-27 cleanup; v2 title rendering is a follow-up brief.

## Player Experience

**Target (post-brief, name-only):** Above each player floats a single TextLabel — the player's display name, no level row, no title row. Quiet and minimal. The XPBar at the bottom of the screen carries level visibility; the nametag does not duplicate it.

**Current build (until the brief ships):** Above each player floats a BillboardGui with two stacked rows — display name on top (60% of the bounds), `"level N"` underneath (40%, smaller and dimmer). The level value mirrors the leaderstats `Level` populated by `ProgressionService` and updates live as the player levels up. The level row is the surface being removed by [[../06_Codex_Plans/2026-04-27_NameTag_Strip_Level_Row_v1]].

---

## Real Architecture (as built, post-2026-04-27)

### Server
- **`ServerScriptService.NameTagScript`** (file in repo: `src/ServerScriptService/NameTagScript.server.lua`)
  - Builds the BillboardGui programmatically and adornes it to each character's `HumanoidRootPart`
  - BillboardGui: `Size UDim2.new(0, 200, 0, 50)`, `StudsOffset Vector3.new(0, 3, 0)`, `MaxDistance = 100`, `AlwaysOnTop = true`
  - Two TextLabels stacked vertically:
    - `NameLabel` (top 60%): `Gotham 16`, color `(225, 215, 200)`, stroke `(0, 0, 0)` at transparency 0.6, text = `player.DisplayName`
    - `LevelLabel` (bottom 40%): `Gotham 12`, color `(180, 170, 155)`, stroke `(0, 0, 0)` at transparency 0.7, text = `"level " .. leaderstats.Level.Value`
  - Disables Roblox's default `Humanoid.DisplayDistanceType` so it doesn't compete with the BillboardGui
  - Watches via `AncestryChanged` and re-applies the BillboardGui if it's destroyed (Avalog-safe — the third-party Avalog package destroys tags parented to the Head); the watchdog also re-runs on every re-create
  - Hooks `leaderstats.Level:GetPropertyChangedSignal("Value")` to update the LevelLabel live; also handles the late-leaderstats case via `player.ChildAdded`

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
- ✅ Level row — present (`LevelLabel` rendered live from leaderstats `Level`); see Player Experience for the "duplicated with XPBar" question
- ❌ Distance fade (was unverified pre-cleanup, simply absent now)
- ❌ Hide-during-dialogue (was an open question pre-cleanup; still open)
- ❌ Per-player toggle (was the `GUIToggle` ScreenGui; UI was deleted with the legacy menu pass)

The remaining ❌ items are intentional gaps, not bugs. Each can be reconsidered as part of v2 title rendering or as a small dedicated brief. The level row's keep/remove decision is the open inbox question.

---

## Design Notes
- Keep the visual minimal until v2 titles return — don't ship intermediate styling that gets thrown away.
- If a per-player toggle is wanted before v2, treat it as a small dedicated brief; don't extend the current script in-place.
- Avalog watchdog must stay — without it, nametags vanish for any player whose character flow touches Avalog.
- The level row was originally written into the script during the 2026-04-27 rebuild but the spec was authored describing the cleaner name-only target; the spec was reality-checked back into agreement during Cowork session 4. Decide the keep/remove call before the next nametag-touching brief so the spec doesn't drift again.

## Related
- [[XP_Progression]] (drives the presence-tick AFK state)
- [[Title_System]] (the v2 redesign that will reintroduce title rendering)
- [[../06_Codex_Plans/2026-04-27_Repo_Strip_to_Studio_State_v1]] (verifies the new artifacts are in repo)
