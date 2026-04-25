# Cave Entrance

**Status:** 🟡 Built — has lots of props, lacks formal zone definition

---

## Mood
Threshold. The hush right before stepping inside. Cooler light, soft echo. The first thing every player sees — sets the entire tone.

## What Players Do Here
- Spawn / enter
- Meet [[../05_NPCs/QuietKeeper]]
- Get oriented without being told what to do
- Choose to go deeper or step outside

## NPCs Present
- [[../05_NPCs/QuietKeeper]] (`Workspace.QuietKeeperNPC`)

---

## Built Props (in Workspace, contributing to mood)
The cave area has a strong prop foundation already:
- **Lighting / atmosphere:** `FirePit`, `Fireflies`, `fast Fireflies`, `Specks`, `SunRayParts`, `Lantern`, `ReadabilityLighting`
- **Foliage:** `Pine Tree`, `Pine`, `Tree2`, `Tree3`, multiple `MapleTree` variants, `Vines`, `leafs falling tree`, `GeneratedTrees`
- **Flowers:** `QuantumFlowers`, `PeachFlowers`, `FireFlowers`, `MossFlowers`, `Rose`
- **Water/structure:** `Waterfall`, `Crate`, `Fence`
- **Seating:** `Workspace.Seats` + auto-generated `SeatMarkers`
- **Other:** `NoteInteraction`, `ToolPickups`, `CameraScenes`

This is well-developed visually. The gaps are structural, not aesthetic.

---

## Gaps / TODO
- ❌ Cave entrance is not formally defined as an `InsideZone` (verify) — needed for [[../02_Systems/Area_Discovery]] and [[../02_Systems/Cave_Outside_Lighting]]
- ❌ No clearly designated "first chill spot" near the entrance
- ❌ Tree models are duplicated (`MapleTree`, `MapleTree2`, `MapleTree 3`, `MapleTree.5`) — see [[../02_Systems/_Cleanup_Backlog]]

## Lighting Preset
- Currently uses one of `Lighting.v1 / V2 / final / build` — needs decision (see [[../02_Systems/Cave_Outside_Lighting]])

## Progression Hooks (planned)
- First-entry discovery XP — depends on [[../02_Systems/XP_Progression]]
- QuietKeeper dialogue trigger — already wired via `DialogueData`
- Sitting reward at any of the existing seats — depends on [[../02_Systems/XP_Progression]]

## Notes
- Avoid signage, tutorials, or arrows. Let players feel their way in.
- If anything feels like a "loading area," cut it.
- The prop density is good — don't add more, polish what's there.
