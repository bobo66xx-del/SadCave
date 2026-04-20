# AGENTS.md

## Project guidance
This repo is for Sad Cave / Roblox game work. Make the smallest safe change that solves the task and preserve existing behavior unless the user asks for a refactor.

## Real project structure
- Repo files are mostly docs, but the live game structure is active in Roblox Studio.
- Main live areas:
  - `StarterGui/` actual UI systems such as `ShopMenu`, `currencyui`, `settingui`, `tipui`, `NoteUI`, `SadCaveMusicGui`, `notificationUI`, `fridge-ui`
    - `TitleMenu` is now locally managed through Rojo from `src/StarterGui/TitleMenu`
  - `ReplicatedStorage/` shared config, remotes, templates, and tools
    - important: `TitleConfig`, `ShopCatalog`, `TipProductConfig`, `TitleRemotes`, `ShopRemotes`, `NoteSystem`, `ReportRemotes`, `Remotes`, `NameTag`
  - `ServerScriptService/` main server authority
    - important: `CashLeaderstats`, `LevelLeaderstats`, `TitleService`, `ShopService`, `NoteSystemServer`, `DailyRewardsServer`, `NameTagScript Owner`, `TextChatServiceHandler`, `AdminServerManager`, `ReportHandler`, `FavoritePromptPersistence`
  - `StarterPlayer/` client and character scripts
    - important: `PromptFavorite`, `RainScript`, `Theme`, `camera`, `AFKLS`, `AutomaticPrompt`, `Sprint`

## Working rules
- Read only the relevant live scripts/docs first, then expand if needed.
- For `TitleMenu`, check the local Rojo source in `src/StarterGui/TitleMenu` first; the shared title pipeline still lives in Studio.
- `TitleMenu` no longer depends on `ShopMenu` row metrics; its row sizing and compact mobile filter fitting are now local to the `TitleMenu` slice.
- Keep UI naming and theme consistent with the existing live UI.
- Avoid unrelated cleanup during fixes.
- Preserve live remote names/contracts unless explicitly asked to change them.

## Critical no-touch systems
- DataStores / saved player data:
  - `CashLeaderstats`, `LevelLeaderstats`, `ShopService`, `TitleService`, `DailyRewardsServer`, `FavoritePromptPersistence`, `NoteSystemServer`
- Monetization / entitlement:
  - `TipProductConfig`, tip purchase UI/scripts, gamepass checks in `TitleService`, `LevelLeaderstats`, admin-related purchase/access scripts
- Admin / moderation / reports:
  - `AdminServerManager`, `ReportHandler`, `ReplicatedStorage.Admin`, `ReplicatedStorage.ReportRemotes`
- Live networking contracts:
  - `TitleRemotes`, `ShopRemotes`, `NoteSystem`, `ReportRemotes`, `ReplicatedStorage.Remotes`, daily reward remotes
- Title / overhead tag pipeline:
  - `TitleConfig`, `TitleService`, `NameTagScript Owner`
  - note: this no-touch warning is about the shared title pipeline, not the locally managed `StarterGui.TitleMenu` UI

## Validation
- No automated install/build/test commands are confirmed in this repo. Say that clearly if no automated checks were run.
- Use manual Roblox Studio validation.
- Preferred workflow:
  - inspect the affected live objects/scripts in Studio first
  - make the smallest change
  - run a Studio playtest focused on the changed system
  - if UI changed, verify the exact screen(s) involved
  - if remotes/data/title/shop/admin behavior changed, test the full client-server flow and call out any untested edge cases
- In your final note, state:
  - where the change was made
  - how it was tested in Studio
  - what result was observed
  - any limits or untested cases

## Done when
- Requested behavior works.
- Relevant checks were run, or missing checks were stated clearly.
- No unrelated systems were changed.
- Risks, follow-ups, or limits are stated clearly.

## Planning
For larger, riskier, or multi-step work, create or update `PLANS.md` before coding and keep it current during implementation.
