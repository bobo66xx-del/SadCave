# Codex Plan Template

> Copy this file, rename to `YYYY-MM-DD_System_Name_v1.md`, fill in.

---

# [System Name] — Codex Plan

**Date:** YYYY-MM-DD
**Related Systems:** [[../02_Systems/...]]

---

## 1. Purpose
What this change does and why.

## 2. Player Experience
What the player will feel / notice. If nothing is visible, say so.

## 3. Technical Structure
- Server responsibilities:
- Client responsibilities:
- Remote events / functions:
- DataStore keys touched:

## 4. Files / Scripts
List every file Codex will create or modify. **Be specific.**

- `ServerScriptService/...`
- `ReplicatedStorage/...`
- `StarterPlayerScripts/...`
- `StarterGui/...`

## 5. Step-by-Step Implementation (for Codex)
1.
2.
3.

## 6. Roblox Services Involved
e.g. `DataStoreService`, `Players`, `RunService`, `TweenService`, `Lighting`...

## 7. Security / DataStore Notes
- ⚠️ Validation:
- ⚠️ DataStore retry/pcall:
- ⚠️ Rate limits:

## 8. Boundaries (do NOT touch)
List unrelated systems Codex must leave alone for this task.

## 9. Studio Test Checklist
- [ ] Does X happen on join?
- [ ] Does Y persist after leave/rejoin?
- [ ] Does Z fail gracefully on error?

## 10. Rollback Notes
How to undo this if it breaks things in production.
