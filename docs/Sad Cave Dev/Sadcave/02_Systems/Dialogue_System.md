# Dialogue System

**Status:** 🟢 Shipped (early version live)

---

## Purpose
Drive emotional, character-driven moments through short conversations with NPCs. Core to Sad Cave's mood — the system through which players feel seen.

## Player Experience
Player approaches an NPC → proximity prompt appears → conversation opens with bubble text and/or cinematic subtitles. Choices presented as buttons. Lines feel intimate, paced, human. No quest-giver energy.

---

## Real Architecture (as built)

### Server
- **`ServerScriptService.DialogueDirector`** — owns conversation flow, line playback, choice resolution
  - Reads from `DialogueData`
  - Drives 4 RemoteEvents

### Shared (ReplicatedStorage)
- **`DialogueData`** (ModuleScript) — single source of truth for all dialogue
  - Top-level keys: `Global` (settings), `Characters` (e.g. `QuietKeeper` with `start` and `return` conversations), `Player` (styling)
  - **This is where new dialogue goes.** No code changes needed to add new lines for existing characters.
- **`DialogueRemotes`** (Folder) — 4 RemoteEvents:
  - `PlayPlayerDialogue`
  - `PlayCharacterDialogue`
  - `PlayerDialogueChoiceSelected`
  - `RequestCharacterConversation`

### Client
- **`StarterPlayerScripts.NpcDialogueClient`** — NPC-side: bubble text, proximity prompts, typing sounds
- **`StarterPlayerScripts.PlayerDialogueClient`** — player-side: subtitle UI + choice buttons

### NPC binding
- NPCs (e.g. `Workspace.QuietKeeperNPC`) have **no scripts/prompts attached directly**
- The client script handles proximity prompts and routes to `DialogueData` by character key
- This means: to add a new NPC, you (a) place the rig in Workspace, (b) add a `Characters.NewNPCKey` entry to `DialogueData`, (c) make sure `NpcDialogueClient` recognizes it

---

## Adding New Dialogue (cheat sheet)
1. Open `ReplicatedStorage.DialogueData`
2. Find or add the character key under `Characters`
3. Add/edit a conversation entry (e.g. `start`, `return`, custom keys)
4. Test in Studio — no code changes required for line edits

## Adding a New NPC (cheat sheet)
1. Place the rig in `Workspace` (use the same rig structure as `QuietKeeperNPC`)
2. Add `Characters.<NewKey>` to `DialogueData` with `start` (and optional `return`) conversations
3. Confirm `NpcDialogueClient` picks up the new NPC by name/tag (verify how it's matched)
4. Tune proximity prompt distance to taste

## Open Questions
- How are flags/branches stored long-term? (Currently: no DataStore — session-only.)
- Do we need persistent dialogue state (e.g. "have they met QuietKeeper before"), and if so, where?
- Subtitle typewriter pacing — is it tunable per-line in `DialogueData`?

## Related
- [[Choice_UI_Panel]]
- [[Cinematic_Subtitle_Panel]]
- [[../05_NPCs/QuietKeeper]]
- [[../04_Dialogue/_Dialogue_Index]]
