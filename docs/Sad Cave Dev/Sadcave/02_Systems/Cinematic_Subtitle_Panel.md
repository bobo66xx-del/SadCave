# Cinematic Subtitle Panel

**Status:** 🟢 Shipped (as part of dialogue clients)

⚠️ **Note:** Subtitle rendering is **not** a standalone ScreenGui. It lives inside the dialogue client scripts, which create and animate subtitle UI dynamically.

---

## Purpose
Lower-screen cinematic subtitle bar that displays NPC and player dialogue. The visual signature of Sad Cave's emotional moments.

## Player Experience
Soft band fades in across lower portion of screen. Text typewriters in slowly. Reads like a film, not an RPG textbox.

---

## Real Architecture (as built)

Subtitle rendering is split across the two dialogue clients:
- **`StarterPlayerScripts.NpcDialogueClient`** — bubble text + subtitle for NPC lines, includes typing sounds and proximity prompt logic
- **`StarterPlayerScripts.PlayerDialogueClient`** — subtitle + choice rendering for player-driven dialogue

Pacing, styling, and animation are all driven from these scripts (and may consume styling from `DialogueData.Player` / `DialogueData.Global`).

---

## Design Notes
- Background: dark, semi-transparent — never fully black
- Type: clean sans, slight letter spacing
- Pacing: typewriter effect (already implemented; check `NpcDialogueClient` for current speed)
- Allow line-skip on click, but never instant — fade-then-skip
- Hide nametags and other UI during subtitle moments (see [[NameTag_Status]] open question)

## Open Questions
- Are NPC subtitles and player subtitles visually consistent, or do they differ? (Worth auditing for tone consistency.)
- Is the typewriter speed tunable per-line via `DialogueData`, or hardcoded?
- Does the subtitle hide automatically, or only on next-line trigger?

## Related
- [[Dialogue_System]]
- [[Choice_UI_Panel]]
