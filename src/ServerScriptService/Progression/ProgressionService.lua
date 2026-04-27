local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local progressionFolder = ReplicatedStorage:WaitForChild("Progression")
local SourceConfig = require(progressionFolder:WaitForChild("SourceConfig"))
local LevelCurve = require(progressionFolder:WaitForChild("LevelCurve"))

local function ensureRemoteEvent(name)
	local remote = progressionFolder:FindFirstChild(name)
	if remote and remote:IsA("RemoteEvent") then
		return remote
	end

	if remote then
		warn("[ProgressionService] Replacing non-RemoteEvent Progression child", name)
		remote:Destroy()
	end

	remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = progressionFolder
	return remote
end

local XPUpdated = ensureRemoteEvent("XPUpdated")
local LevelUp = ensureRemoteEvent("LevelUp")

local progressionStore = DataStoreService:GetDataStore(
	SourceConfig.PROGRESSION_DATASTORE_NAME,
	SourceConfig.PROGRESSION_DATASTORE_VERSION
)
local legacyLevelStore = DataStoreService:GetDataStore(SourceConfig.LEGACY_LEVEL_DATASTORE_NAME)
local legacyTimeStore = DataStoreService:GetDataStore(SourceConfig.LEGACY_TIME_DATASTORE_NAME)
local legacyRevisitsStore = DataStoreService:GetDataStore(SourceConfig.LEGACY_REVISITS_DATASTORE_NAME)

local ProgressionService = {}

local MAX_ATTEMPTS = 2
local RETRY_DELAY_SECONDS = 1
local GAMEPASS_RETRY_DELAY_SECONDS = 5

local states = {}

local function withRetry(actionName, callback)
	local lastError = nil

	for attempt = 1, MAX_ATTEMPTS do
		local ok, result = pcall(callback)
		if ok then
			return true, result
		end

		lastError = result
		warn(("[ProgressionService] %s failed (attempt %d/%d): %s"):format(
			actionName,
			attempt,
			MAX_ATTEMPTS,
			tostring(result)
		))

		if attempt < MAX_ATTEMPTS then
			task.wait(RETRY_DELAY_SECONDS)
		end
	end

	return false, lastError
end

local function readNumber(dataStore, key, label)
	local ok, result = withRetry(label .. " GetAsync", function()
		return dataStore:GetAsync(key)
	end)

	if not ok then
		return 0, false
	end

	if typeof(result) == "number" then
		return math.max(0, math.floor(result)), true
	end

	local asNumber = tonumber(result)
	if asNumber then
		return math.max(0, math.floor(asNumber)), true
	end

	return 0, true
end

local function normalizeDiscoveredZones(value)
	if typeof(value) ~= "table" then
		return {}
	end

	local normalized = {}
	for key, zoneValue in pairs(value) do
		normalized[key] = zoneValue
	end

	return normalized
end

local function normalizeProgressionData(value)
	local data = if typeof(value) == "table" then value else {}

	return {
		totalXP = math.max(0, math.floor(tonumber(data.totalXP) or 0)),
		discoveredZones = normalizeDiscoveredZones(data.discoveredZones),
		totalTimePlayed = math.max(0, math.floor(tonumber(data.totalTimePlayed) or 0)),
		revisits = math.max(0, math.floor(tonumber(data.revisits) or 0)),
	}
end

local function getKey(player)
	return player.UserId
end

local function getLevelValue(player)
	local value = player:FindFirstChild("Level")
	if value and not value:IsA("IntValue") then
		value:Destroy()
		value = nil
	end

	if not value then
		value = Instance.new("IntValue")
		value.Name = "Level"
		value.Parent = player
	end

	return value
end

local function getDirectXPValue(player)
	local value = player:FindFirstChild("XP")
	if value and not value:IsA("IntValue") then
		value:Destroy()
		value = nil
	end

	if not value then
		value = Instance.new("IntValue")
		value.Name = "XP"
		value.Parent = player
	end

	return value
end

local function getLeaderstatsValue(player, name)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and not leaderstats:IsA("Folder") then
		leaderstats:Destroy()
		leaderstats = nil
	end

	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local value = leaderstats:FindFirstChild(name)
	if value and not value:IsA("IntValue") then
		value:Destroy()
		value = nil
	end

	if not value then
		value = Instance.new("IntValue")
		value.Name = name
		value.Parent = leaderstats
	end

	return value
end

local function buildPayload(state)
	local level, xpForCurrentLevel, xpForNextLevel = LevelCurve.GetLevelProgress(state.totalXP)
	state.level = level

	return {
		totalXP = state.totalXP,
		level = level,
		xpForCurrentLevel = xpForCurrentLevel,
		xpForNextLevel = xpForNextLevel,
	}
end

local function syncLeaderstats(player, state)
	if not SourceConfig.ENABLED then
		return
	end

	local payload = buildPayload(state)

	getLevelValue(player).Value = payload.level
	getDirectXPValue(player).Value = payload.totalXP
	getLeaderstatsValue(player, "Level").Value = payload.level
	getLeaderstatsValue(player, "XP").Value = payload.totalXP
	player:SetAttribute("LevelLoaded", true)
end

local function checkGamepass(player)
	local ok, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, SourceConfig.GAMEPASS_ID)
	end)

	if ok then
		return result == true
	end

	warn("[ProgressionService] UserOwnsGamePassAsync failed for", player.UserId, result)
	task.wait(GAMEPASS_RETRY_DELAY_SECONDS)

	local retryOk, retryResult = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, SourceConfig.GAMEPASS_ID)
	end)

	if retryOk then
		return retryResult == true
	end

	warn("[ProgressionService] UserOwnsGamePassAsync retry failed for", player.UserId, retryResult)
	return false
end

local function saveState(player, state)
	if state.loadFailed then
		warn("[ProgressionService] Skipping save for", player.UserId, "because ProgressionData did not load cleanly")
		return false
	end

	local data = {
		totalXP = state.totalXP,
		discoveredZones = state.discoveredZones,
		totalTimePlayed = state.totalTimePlayed,
		revisits = state.revisits,
	}

	local key = getKey(player)
	local ok = withRetry("ProgressionData SetAsync", function()
		progressionStore:SetAsync(key, data)
	end)

	state.lastSaveOk = ok
	return ok
end

local function migratePlayer(player)
	local key = getKey(player)
	local legacyLevel = readNumber(legacyLevelStore, key, "LevelSave")
	local totalTimePlayed = readNumber(legacyTimeStore, key, "TotalTimePlayedSave")
	local revisits = readNumber(legacyRevisitsStore, key, "RevisitsSave")

	return {
		totalXP = LevelCurve.GetXPForLevel(legacyLevel),
		discoveredZones = {},
		totalTimePlayed = totalTimePlayed,
		revisits = revisits,
		migratedFromLegacy = true,
	}
end

function ProgressionService.LoadPlayer(player)
	if states[player] then
		return states[player]
	end

	if SourceConfig.ENABLED then
		player:SetAttribute("LevelLoaded", false)
	end

	local key = getKey(player)
	local ok, storedData = withRetry("ProgressionData GetAsync", function()
		return progressionStore:GetAsync(key)
	end)

	local state
	if ok and storedData ~= nil then
		state = normalizeProgressionData(storedData)
	elseif ok then
		state = migratePlayer(player)
	else
		state = normalizeProgressionData(nil)
		state.loadFailed = true
	end

	state.totalXP = math.max(0, math.floor(state.totalXP or 0))
	state.discoveredZones = normalizeDiscoveredZones(state.discoveredZones)
	state.totalTimePlayed = math.max(0, math.floor(state.totalTimePlayed or 0))
	state.revisits = math.max(0, math.floor(state.revisits or 0)) + 1
	state.gamepassOwned = checkGamepass(player)
	state.isAFK = false
	state.seatedAt = nil
	state.lastSeatedAt = nil
	state.seatPart = nil
	state.level = LevelCurve.GetLevel(state.totalXP)

	states[player] = state

	if ok then
		saveState(player, state)
	end

	syncLeaderstats(player, state)

	return state
end

function ProgressionService.SavePlayer(player)
	local state = states[player]
	if not state then
		return false
	end

	return saveState(player, state)
end

function ProgressionService.UnloadPlayer(player)
	states[player] = nil
end

function ProgressionService.GetState(player)
	return states[player]
end

function ProgressionService.RegisterSittingState(player, seatPart, timestamp)
	local state = states[player]
	if not state then
		return
	end

	state.seatedAt = timestamp or os.time()
	state.lastSeatedAt = state.seatedAt
	state.seatPart = seatPart
end

function ProgressionService.ClearSittingState(player)
	local state = states[player]
	if not state then
		return
	end

	state.lastSeatedAt = state.seatedAt
	state.seatedAt = nil
	state.seatPart = nil
end

function ProgressionService.RegisterAFKState(player, isAFK)
	local state = states[player]
	if not state then
		return
	end

	state.isAFK = isAFK == true
	state.afkChangedAt = os.time()
end

function ProgressionService.SendSnapshot(player)
	if not SourceConfig.ENABLED then
		return
	end

	local state = states[player]
	if not state then
		return
	end

	XPUpdated:FireClient(player, buildPayload(state))
end

function ProgressionService.GrantXP(player, amount, source)
	if not SourceConfig.ENABLED then
		return false, "disabled"
	end

	local state = states[player]
	if not state then
		return false, "missing_state"
	end

	local numericAmount = tonumber(amount)
	if not numericAmount or numericAmount <= 0 then
		return false, "invalid_amount"
	end

	local oldLevel = LevelCurve.GetLevel(state.totalXP)
	local multiplier = if state.gamepassOwned then SourceConfig.GAMEPASS_MULTIPLIER else 1
	local amountToGrant = math.floor(numericAmount * multiplier)

	if amountToGrant <= 0 then
		return false, "zero_amount"
	end

	state.totalXP += amountToGrant
	state.lastGrantSource = source
	state.lastGrantAmount = amountToGrant

	local payload = buildPayload(state)
	syncLeaderstats(player, state)

	if payload.level > oldLevel then
		LevelUp:FireClient(player, {
			newLevel = payload.level,
		})
		saveState(player, state)
	end

	XPUpdated:FireClient(player, payload)

	return true, payload
end

function ProgressionService.Tick(player, presenceTick)
	if not SourceConfig.ENABLED then
		return false, "disabled"
	end

	local state = states[player]
	if not state then
		return false, "missing_state"
	end

	state.totalTimePlayed += SourceConfig.TICK_INTERVAL_SECONDS

	local amount, sourceName = presenceTick.GetTickAmount(player, state, SourceConfig)
	return ProgressionService.GrantXP(player, amount, "presence_" .. sourceName)
end

return ProgressionService
