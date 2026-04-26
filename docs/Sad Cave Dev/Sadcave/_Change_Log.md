# Change Log

> Append-only history of substantive changes to Sad Cave. Newest entries on top.
> Written by Opus during end-of-session integration. One line per change. Date + system + what changed + why.
>
> **What belongs here:** shipped features, design pivots, removed systems, renamed concepts, broken assumptions corrected.
> **What does NOT belong here:** stray ideas (→ `08_Ideas_Parking_Lot`), open questions (→ `09_Open_Questions`), session recaps (→ `07_Sessions`), small in-progress tweaks (→ `00_Inbox` until they ship).

---

## 2026

### April

<!-- New entries go directly below this line -->

2026-04-25 — Live Reconciliation — Exported `Theme.server.lua` and `OverheadTagsToggleServer.server.lua` to repo (structurally mapped, 9/9 and 35/35 lines). Both hit the numbered-conversational-output connector blocker, so not byte-exact. `fridge-ui` classified as tooling blocker (AnchorPoint null on centered nodes). Audit updated; highest-priority queue cleared.
2026-04-25 — NameTag_Status — Confirmed `OverheadTagsToggleServer` is a no-op server handler. Overhead tag visibility is client-side only. Server remote kept for backward compatibility. Updated `_Live_Systems_Reference` to reflect this — was previously listed as an unverified assumption.

2026-04-25 — Workflow — Frozen `PLANS.md` as historical-only; consolidated all planning to `06_Codex_Plans/` in the vault. Two surfaces was unnecessary friction; PLANS.md predated the vault and was never the intended go-forward.
2026-04-25 — Workflow — Vault committed to git for the first time. Backed up to `origin/main` after a near-deletion incident. Future drift cannot wipe the vault silently.
2026-04-25 — Workflow — Migrated `docs/project-overview.md`, `docs/game-systems.md`, `docs/ui-hierarchy.md`, `docs/known-bugs.md` into the vault. Single source of truth for text documentation. Originals left as stub pointers.
2026-04-25 — AGENTS.md — Removed `CashLeaderstats` from the no-touch DataStore list. It's slated for removal in cleanup, not a system to preserve. Frozen-not-extended is the correct stance.
2026-04-25 — AGENTS.md — Restored `PLANS.md` and `docs/live-repo-audit.md` references after audit revealed they were the active record of months of live-only reconciliation work. Repo wasn't "stale" — it was a curated subset with documented blockers.
2026-04-25 — AGENTS.md — Fixed file extension convention from `.luau`/`.client.luau`/`.server.luau` to `.lua`/`.client.lua`/`.server.lua` to match what the repo actually uses. Language is still Luau; extension is `.lua` for Rojo tooling reasons.
2026-04-25 — 06_Codex_Plans — Wrote, then superseded, `2026-04-25_Repo_Resync_v1.md`. Brief was based on a wrong premise (treating repo as stale). Replaced with `2026-04-25_Live_Reconciliation_Continuation_v1.md` targeting the audit's actual top priorities: `fridge-ui`, `Theme`, `OverheadTagsToggleServer`. Lesson preserved in the superseded brief's frontmatter.
2026-04-25 — Vault — Migrated Codex instructions from `_Codex_Instructions.md` (vault) into `AGENTS.md` (repo root) per session 1's plan. Codex's rules now live next to the code Codex edits.

---

## Format

`YYYY-MM-DD — [System] — Change. Reason.`

Example:
`2026-04-25 — Dialogue_System — Bumped default cooldown 3s → 4s. Felt rushed in playtest.`
`2026-04-25 — Cleanup_Backlog — Removed legacy saber shop. Off-tone, replaced by nothing (intentional).`
