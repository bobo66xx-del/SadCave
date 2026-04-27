# Environments

> Sad Cave runs in two distinct Roblox places. Decisions about builds, cleanup, and migration usually need to know which one is in scope. This doc names them and what's different about each.

---

## Testing place — `Testing cave`

The experimental sandbox. Every Codex brief, every playtest, every cleanup pass happens here first.

- **Studio name:** `Testing cave`
- **Studio MCP id:** `b2f076e7-1056-4618-9ac5-3e41f079a2e4` (verify in `list_roblox_studios` if it changes)
- **Active players:** none. This is dev-only.
- **State as of 2026-04-27:** post-cleanup. Most legacy systems deleted; XP Progression MVP live; minimal `NameTagScript`; no titles, no shop, no daily rewards, no admin tools, no cash currency. See `02_Systems/_Live_Systems_Reference.md` for the full kept set.
- **DataStores:** real Roblox DataStores. Anything the testing place writes to a DataStore lands in the real cloud, not a mock. Be careful with destructive writes during dev — they affect the actual stored values.

## Production place

The live game with active players.

- **Studio name / id:** TBD — fill in here when production work first happens. (Tyler may not have opened it through MCP yet; do that and update this doc.)
- **Active players:** yes. Decisions affecting wire contracts, player save data, monetization, or moderation matter here in a way they don't in testing.
- **State as of 2026-04-27:** **assumed unchanged from pre-cleanup.** The 2026-04-27 testing-place cleanup did not touch production. If production has been pulled forward in any way, update this doc immediately.
- **DataStores:** the real cloud DataStores with real player histories. Migration plans need to be conservative and reversible.

## What's the same

- The repo (`SadCaveV2` at `C:\Projects\SadCave\`) — both places sync from it via Rojo.
- The vault — both environments share design intent.
- The workflow — Director → Planner → Builder → review → merge applies in both.
- Tone & Rules — universal. Production isn't allowed to drift on tone any more than testing is.

## What's different

| Concern | Testing place | Production |
|---------|---------------|------------|
| Players in session | Tyler only (and invited devs) | Public |
| Wire contracts | Free to rename — no live clients | Frozen — renaming a live remote breaks active players mid-session |
| Player DataStore writes | Affect Tyler's own save (already migrated to v2 XP) | Affect every active player — irreversible without a migration plan |
| Legacy systems | Most deleted 2026-04-27 | Still running until cutover |
| Risk profile | Low | High — every change wants a soak period in testing first |
| Studio cleanup latitude | Tyler can delete things at will | Coordinated cutover only |
| `_No_Touch_Systems.md` | Reflects testing reality (small list) | Effectively broader — all the v1 systems still count as no-touch in production |

## Production cutover protocol

When testing-place work is ready to land in production, **don't promote it ad-hoc**. Each cutover gets its own treatment:

1. A dedicated brief in `06_Codex_Plans/`, separate from the testing-place build brief, that covers the production-specific concerns: migration of existing player data, backward-compatible remote contracts during the transition, rollback procedure, monitoring during the soak.
2. Conservative defaults — keep legacy DataStores readable for at least one full week after cutover. Don't delete the old scripts immediately; disable them first. The XP MVP brief modeled this: shipped with `ENABLED=false`, live cutover flips the flag, rollback is one boolean.
3. Universal Claude review applies. Production diffs always get a verdict — no "small change" exception.
4. Tyler decides timing. Don't merge production cutover branches without an explicit "okay, push to prod" signal.

## When this doc gets read

Per the Session Bookends in `AGENTS.md`, this file is read at session start when production cutover is in scope. Otherwise it's reference material — not part of the every-session re-orient.

## Open Questions

- What's production's Studio id and current state? Confirm next time the production place is opened.
- Is production currently expected to migrate to post-2026-04-27 testing state, or is testing diverging on purpose? (Lean: testing is divergent during active redesign; production catches up via deliberate cutover briefs.)
- Where do players' v1 title equipment / shard balances go during production cutover? See `Title_System.md` migration table — that plan still applies for production.
