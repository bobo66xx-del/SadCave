# Choice UI Panel

**Status:** 🟢 Shipped (as part of `PlayerDialogueClient`)

⚠️ **Note:** Choice rendering is **not** a separate ScreenGui. It lives inside `StarterPlayerScripts.PlayerDialogueClient`, which builds choice buttons dynamically when the dialogue system signals a choice point.

---

## Purpose
Give players agency in dialogue without breaking the calm. Choices feel intimate — not RPG menus.

## Player Experience
Soft buttons appear when a choice point is reached. 2–3 short choices. Hover/select feels gentle. Selection fades, response begins.

---

## Real Architecture (as built)

- **`StarterPlayerScripts.PlayerDialogueClient`** — owns choice rendering AND subtitle rendering
- **Remote:** `DialogueRemotes.PlayerDialogueChoiceSelected` (RemoteEvent) — client → server when player picks a choice
- **Data:** choices defined in `ReplicatedStorage.DialogueData` per character/conversation

There is no standalone "ChoicePanel" ScreenGui. If you want a more polished choice UI in the future, the cleanest path is to refactor `PlayerDialogueClient` to delegate rendering to a dedicated GUI — but it's not necessary right now.

---

## Design Notes
- Max 3 choices visible at once
- Choice text stays short — match dialogue voice in [[../01_Vision/Tone_and_Rules]]
- Never expose stat/skill checks visibly ("[Charisma] ..." breaks mood — see [[../04_Dialogue/_Dialogue_Index]] for voice rules)

## Open Questions
- Is the current button styling premium enough, or does it feel like default UI?
- Are choices animated (fade-in, ease) or instant?

## Related
- [[Dialogue_System]]
- [[Cinematic_Subtitle_Panel]]
