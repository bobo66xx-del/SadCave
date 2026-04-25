# QuietKeeper

**Status:** 🟢 Built (rig + dialogue entry exist)
**Location:** `Workspace.QuietKeeperNPC` → [[../03_Map_Locations/Cave_Entrance]]
**Dialogue config:** `ReplicatedStorage.DialogueData` → `Characters.QuietKeeper`
**Lines (working draft):** [[../04_Dialogue/QuietKeeper_Lines]]

---

## Real Build

- Full R15 rig in `Workspace.QuietKeeperNPC`
- Outfit: BlackKnight wings, skeletal horns, messy parted light bangs hair
- **No scripts, ProximityPrompts, or attributes attached to the rig**
- All dialogue interaction is handled by `StarterPlayerScripts.NpcDialogueClient`, which:
  - Detects the NPC by character key
  - Adds proximity prompt at runtime
  - Pulls conversation data from `DialogueData.Characters.QuietKeeper`
- Conversation entries already defined: `start` (first meeting), `return` (returning player)

To edit QK dialogue → open `ReplicatedStorage.DialogueData` and edit the `QuietKeeper` entry. No code changes needed.

---

## Who They Are
The quiet presence at the cave entrance. Has been here a long time. Doesn't explain themselves, doesn't ask for anything. Just acknowledges you.

## Personality
- Calm, patient, slightly tired in a peaceful way
- Speaks rarely, but warmly when they do
- Treats the player as a guest, not a player
- Notices when you've been gone or when you're back

## Role in the Game
- First friendly contact
- Sets the emotional tone within the first 30 seconds of play
- Gentle anchor — players will return to talk to them

## What QuietKeeper Does NOT Do
- ❌ Give quests
- ❌ Explain controls or systems
- ❌ Sell anything
- ❌ Lore-dump
- ❌ Cheer the player on

## Visual / Vibe
- Current rig has BlackKnight wings + skeletal horns — **double-check if this still matches the desired tone**
- Wings/horns lean toward a "dark fantasy" silhouette which can read as edgy rather than quiet/melancholy
- Possible adjustment: keep the silhouette grounded, lower-contrast, less "boss-fight," more "lonely figure"
- Should sit or stand still — minimal animation
- Optional faint ambient particle (slow, drifting)

## Open Questions
- Does the current outfit match the QuietKeeper personality, or is it carryover from a different concept?
- Do they have a name? Or is "QuietKeeper" only what we call them internally? (Lean: never named in-game.)
- Voice: text-only, or soft non-verbal sound (single low tone) when they "speak"? Currently the dialogue clients have typing sounds — check tone fit.

## Related
- [[../02_Systems/Dialogue_System]]
- [[../04_Dialogue/QuietKeeper_Lines]]
- [[../03_Map_Locations/Cave_Entrance]]
