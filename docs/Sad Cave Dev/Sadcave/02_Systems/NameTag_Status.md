# NameTag / Status System

**Status:** 🟢 Shipped

---

## Purpose
Show player presence subtly above each character — name, title, level — without breaking immersion.

## Player Experience
Above each player: BillboardGui showing name (top), title (middle), level/handle info (bottom). Title comes from [[Title_System]]. Level comes from [[Level_System]].

---

## Real Architecture (as built)

### Server
- **`ServerScriptService.NameTagScript Owner`**
  - Manages nametag creation, positioning, text updates, cleanup
  - Reads `TitleConfig` to render equipped title with effects
  - Listens to `RebuildOverheadTags` and `OverheadTagsEnabled` (BindableEvents/Values in ReplicatedStorage)
  - Uses `TweenService` for animations
  - Integrates with `TextChatService`

### Template
- **`ReplicatedStorage.NameTag`** — BillboardGui with three TextLabels:
  - `UpperText` — player name
  - `LowerText` — title
  - `HandleTag` — level info

### UI Toggle
- `StarterGui.GUIToggle` — handles user toggling of nametags on/off
- `ServerScriptService.OverheadTagsToggleServer` — server-side toggle handling

### Legacy
- `Workspace.NameTags` folder — referenced by `GUIToggle`, may be legacy

---

## Design Notes
- Tag should fade with distance (verify if implemented)
- Hide entirely during dialogue cinematics (verify if implemented)
- Title display already supports per-title visual effects (driven by `TitleConfig.GetEffect`)

## Open Questions
- Is the `Workspace.NameTags` folder legacy? Can it be removed?
- Does the nametag respect dialogue state (hide during cinematics)?
- Are title visual effects on high-tier titles too flashy? (See [[Title_System]] tone notes.)

## Related
- [[Title_System]]
- [[Level_System]]
- [[XP_Progression]]
