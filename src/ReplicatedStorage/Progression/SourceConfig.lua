-- Tunable constants for the XP Progression system.
-- All values can be adjusted without touching service logic.

local SourceConfig = {}

-- Master enable flag. Set to false to keep ProgressionService dormant.
-- Used during the cutover from LevelLeaderstats so the new system can
-- be deployed inert and switched on after verification.
-- Flipped to true 2026-04-27 — cutover from LevelLeaderstats complete
-- (legacy script deleted from testing place, repo lean, no risk of conflict).
SourceConfig.ENABLED = true

-- Level curve constants: XP per level N = floor(A + B * N^C)
SourceConfig.CURVE_A = 45
SourceConfig.CURVE_B = 0.55
SourceConfig.CURVE_C = 1.15

-- Presence tick amounts (per 60-second tick)
SourceConfig.PRESENCE_SITTING_XP = 20
SourceConfig.PRESENCE_ACTIVE_XP = 15
SourceConfig.PRESENCE_AFK_XP = 3

-- Sitting threshold: how long a player must be seated at a SeatMarker
-- before the boosted (sitting) tick rate kicks in.
SourceConfig.SITTING_THRESHOLD_SECONDS = 30

-- Tick interval
SourceConfig.TICK_INTERVAL_SECONDS = 60

-- Gamepass multiplier (applied to all XP grants)
SourceConfig.GAMEPASS_ID = 1790063497
SourceConfig.GAMEPASS_MULTIPLIER = 1.5

-- DataStore name
SourceConfig.PROGRESSION_DATASTORE_NAME = "ProgressionData"
SourceConfig.PROGRESSION_DATASTORE_VERSION = "v1"

-- Legacy DataStore names (read-only for migration)
SourceConfig.LEGACY_LEVEL_DATASTORE_NAME = "LevelSave"
SourceConfig.LEGACY_TIME_DATASTORE_NAME = "TotalTimePlayedSave"
SourceConfig.LEGACY_REVISITS_DATASTORE_NAME = "RevisitsSave"

return SourceConfig
