local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TitleConfig = require(ReplicatedStorage:WaitForChild("TitleConfig"))

local TITLE_DATASTORE_NAME = "TitleData"
local TITLE_V1_DATASTORE_NAME = "EquippedTitleV1"
local MAX_ATTEMPTS = 3
local RETRY_DELAY_SECONDS = 1
local EQUIP_RATE_LIMIT_SECONDS = 1

local titleStore = DataStoreService:GetDataStore(TITLE_DATASTORE_NAME)
local titleV1Store = DataStoreService:GetDataStore(TITLE_V1_DATASTORE_NAME)

local playerStates = {}
local levelConnections = {}
local titleDataUpdated = nil
local equipTitleRemote = nil
local unequipTitleRemote = nil
local started = false

local TitleService = {}

local function getTitleRemotes()
	local titleRemotes = ReplicatedStorage:FindFirstChild("TitleRemotes")
	if not titleRemotes then
		titleRemotes = Instance.new("Folder")
		titleRemotes.Name = "TitleRemotes"
		titleRemotes.Parent = ReplicatedStorage
	end

	return titleRemotes
end

local function getOrCreateRemote(remoteName)
	local titleRemotes = getTitleRemotes()
	local remote = titleRemotes:FindFirstChild(remoteName)
	if remote and not remote:IsA("RemoteEvent") then
		warn("[TitleService] Replacing non-RemoteEvent TitleRemotes." .. remoteName)
		remote:Destroy()
		remote = nil
	end

	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = remoteName
		remote.Parent = titleRemotes
	end

	return remote
end

local function getTitleDataUpdated()
	if titleDataUpdated then
		return titleDataUpdated
	end

	titleDataUpdated = getOrCreateRemote("TitleDataUpdated")
	return titleDataUpdated
end

local function getEquipTitleRemote()
	if equipTitleRemote then
		return equipTitleRemote
	end

	equipTitleRemote = getOrCreateRemote("EquipTitle")
	return equipTitleRemote
end

local function getUnequipTitleRemote()
	if unequipTitleRemote then
		return unequipTitleRemote
	end

	unequipTitleRemote = getOrCreateRemote("UnequipTitle")
	return unequipTitleRemote
end

local function getStoreKey(player)
	return tostring(player.UserId)
end

local function withRetry(label, callback)
	local lastError = nil

	for attempt = 1, MAX_ATTEMPTS do
		local ok, result = pcall(callback)
		if ok then
			return true, result
		end

		lastError = result
		warn(string.format("[TitleService] %s failed (%d/%d): %s", label, attempt, MAX_ATTEMPTS, tostring(result)))

		if attempt < MAX_ATTEMPTS then
			task.wait(RETRY_DELAY_SECONDS)
		end
	end

	return false, lastError
end

local function copyDictionary(source)
	local result = {}
	if typeof(source) ~= "table" then
		return result
	end

	for key, value in pairs(source) do
		result[key] = value
	end

	return result
end

local function buildOwnedTitleIds(ownedSet)
	local ownedTitleIds = {}

	for titleId, owned in pairs(ownedSet or {}) do
		if owned == true then
			table.insert(ownedTitleIds, titleId)
		end
	end

	table.sort(ownedTitleIds)
	return ownedTitleIds
end

local function findNewlyUnlockedTitleId(previousOwnedSet, nextOwnedSet)
	local newOwnedSet = {}
	local hasNewTitle = false

	for titleId, owned in pairs(nextOwnedSet or {}) do
		if owned == true and not previousOwnedSet[titleId] then
			newOwnedSet[titleId] = true
			hasNewTitle = true
		end
	end

	if not hasNewTitle then
		return nil
	end

	for _, titleId in ipairs(TitleConfig.GetGamepassTitleIds()) do
		if newOwnedSet[titleId] then
			return titleId
		end
	end

	local pickedTitle = nil
	for _, titleId in ipairs(TitleConfig.GetLevelTitleIds()) do
		if newOwnedSet[titleId] then
			pickedTitle = titleId
		end
	end

	return pickedTitle
end

local function migrateFromV1(player, titleData)
	local migratedTitleId = nil
	local ok, result = withRetry("EquippedTitleV1 GetAsync", function()
		return titleV1Store:GetAsync(getStoreKey(player))
	end)

	if ok and typeof(result) == "string" then
		local mappedTitleId = TitleConfig.MIGRATION[result]
		if mappedTitleId and TitleConfig.GetTitle(mappedTitleId) then
			titleData.equippedTitle = mappedTitleId
			migratedTitleId = mappedTitleId
		end
	elseif not ok then
		warn("[TitleService] Could not read EquippedTitleV1 for", player.UserId)
	end

	titleData.equippedManually = false
	titleData.migratedFromV1 = true
	titleData.migratedTitleId = migratedTitleId

	return titleData
end

local function loadTitleData(player)
	local ok, result = withRetry("TitleData GetAsync", function()
		return titleStore:GetAsync(getStoreKey(player))
	end)

	if not ok then
		warn("[TitleService] Falling back to in-memory title data for", player.UserId)
		return {
			equippedTitle = TitleConfig.DEFAULT_TITLE_ID,
			achievements = {},
			equippedManually = false,
			migratedFromV1 = false,
			loadFailed = true,
		}
	end

	if typeof(result) ~= "table" then
		return migrateFromV1(player, {
			equippedTitle = TitleConfig.DEFAULT_TITLE_ID,
			achievements = {},
			equippedManually = false,
			migratedFromV1 = false,
		})
	end

	local equippedTitle = result.equippedTitle
	if typeof(equippedTitle) ~= "string" or not TitleConfig.GetTitle(equippedTitle) then
		equippedTitle = TitleConfig.DEFAULT_TITLE_ID
	end

	local titleData = {
		equippedTitle = equippedTitle,
		achievements = copyDictionary(result.achievements),
		equippedManually = result.equippedManually == true,
		migratedFromV1 = result.migratedFromV1 == true,
	}

	if not titleData.migratedFromV1 and result.equippedTitle == nil then
		return migrateFromV1(player, titleData)
	end

	return titleData
end

local function saveTitleData(player)
	local state = playerStates[player.UserId]
	if not state then
		return false
	end

	local data = {
		equippedTitle = state.equippedTitle or TitleConfig.DEFAULT_TITLE_ID,
		achievements = copyDictionary(state.achievements),
		equippedManually = state.equippedManually == true,
		migratedFromV1 = state.migratedFromV1 == true,
	}

	local ok = withRetry("TitleData SetAsync", function()
		titleStore:SetAsync(getStoreKey(player), data)
	end)

	if not ok then
		warn("[TitleService] Could not persist title data for", player.UserId)
	end

	return ok
end

local function checkGamepass(player)
	local ok, result = withRetry("UserOwnsGamePassAsync", function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, TitleConfig.TITLE_PACK_GAMEPASS_ID)
	end)

	if not ok then
		warn("[TitleService] Assuming title gamepass is unowned for", player.UserId)
		return false
	end

	return result == true
end

local function getLevelValue(player)
	local leaderstats = player:FindFirstChild("leaderstats") or player:WaitForChild("leaderstats", 20)
	if not leaderstats then
		return nil
	end

	local levelValue = leaderstats:FindFirstChild("Level") or leaderstats:WaitForChild("Level", 20)
	if levelValue and levelValue:IsA("IntValue") then
		return levelValue
	end

	return nil
end

local function getCurrentLevel(player)
	local levelValue = getLevelValue(player)
	if not levelValue then
		warn("[TitleService] Level leaderstat missing for", player.UserId, "- defaulting title ownership to level 1")
		return 1
	end

	return math.max(1, levelValue.Value)
end

local function ensureState(player)
	local state = playerStates[player.UserId]
	if state then
		return state
	end

	state = {
		equippedTitle = TitleConfig.DEFAULT_TITLE_ID,
		achievements = {},
		ownedSet = {},
		gamepassOwned = false,
		equippedManually = false,
		migratedFromV1 = false,
		lastEquipTime = 0,
	}
	playerStates[player.UserId] = state
	return state
end

local function resolveOwnership(player)
	local state = ensureState(player)
	local ownedSet = {}
	local level = getCurrentLevel(player)

	for _, titleId in ipairs(TitleConfig.GetLevelTitleIds()) do
		local title = TitleConfig.GetTitle(titleId)
		if title and title.levelRequired and level >= title.levelRequired then
			ownedSet[titleId] = true
		end
	end

	if state.gamepassOwned then
		for _, titleId in ipairs(TitleConfig.GetGamepassTitleIds()) do
			ownedSet[titleId] = true
		end
	end

	ownedSet[TitleConfig.DEFAULT_TITLE_ID] = true
	state.ownedSet = ownedSet

	return ownedSet
end

local function pickAutoEquip(ownedSet)
	for _, titleId in ipairs(TitleConfig.GetGamepassTitleIds()) do
		if ownedSet[titleId] then
			return titleId
		end
	end

	local pickedTitle = TitleConfig.DEFAULT_TITLE_ID
	for _, titleId in ipairs(TitleConfig.GetLevelTitleIds()) do
		if ownedSet[titleId] then
			pickedTitle = titleId
		end
	end

	return pickedTitle
end

local function applyTitlePayloadToBillboard(billboard, payload)
	if not billboard or not billboard:IsA("BillboardGui") then
		return
	end

	billboard:SetAttribute("TitleEffect", payload.equippedEffect or "none")
	billboard:SetAttribute("TitleTintColor", payload.equippedTintColor or Color3.fromRGB(225, 215, 200))
	billboard:SetAttribute("TitleDisplay", payload.equippedDisplay or "")

	local titleLabel = billboard:FindFirstChild("TitleLabel")
	if titleLabel and titleLabel:IsA("TextLabel") then
		titleLabel.Text = payload.equippedDisplay or ""
	end
end

local function updateNameTag(player, payload)
	local character = player.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	local billboard = hrp and hrp:FindFirstChild("NameTag")

	if billboard and billboard:IsA("BillboardGui") then
		applyTitlePayloadToBillboard(billboard, payload)
	end
end

local function getPlayerTitlePayload(player)
	local state = playerStates[player.UserId]
	local titleId = state and state.equippedTitle or TitleConfig.DEFAULT_TITLE_ID
	local payload = TitleConfig.BuildPayload(titleId, false)
	payload.ownedTitleIds = buildOwnedTitleIds(state and state.ownedSet or {})
	payload.equippedManually = state and state.equippedManually == true or false
	return payload
end

local function buildTitlePayload(player, titleId, newlyUnlocked, options)
	local state = ensureState(player)
	local payload = TitleConfig.BuildPayload(titleId, newlyUnlocked)
	payload.ownedTitleIds = buildOwnedTitleIds(state.ownedSet)
	payload.equippedManually = state.equippedManually == true

	if options then
		for key, value in pairs(options) do
			payload[key] = value
		end
	end

	return payload
end

local function fireCurrentTitlePayload(player, newlyUnlocked)
	local state = ensureState(player)
	local payload = buildTitlePayload(player, state.equippedTitle, newlyUnlocked)
	getTitleDataUpdated():FireClient(player, payload)
	updateNameTag(player, payload)
	return payload
end

local function applyEquip(player, titleId, newlyUnlocked)
	local state = ensureState(player)
	local title = TitleConfig.GetTitleOrDefault(titleId)
	state.equippedTitle = title.id

	local payload = fireCurrentTitlePayload(player, newlyUnlocked)
	saveTitleData(player)

	return payload
end

local function refreshAutoEquip(player, newlyUnlocked)
	local state = ensureState(player)
	local previousOwnedSet = copyDictionary(state.ownedSet)
	local ownedSet = resolveOwnership(player)
	local nextTitle = pickAutoEquip(ownedSet)
	local unlockedTitleId = if newlyUnlocked == true then findNewlyUnlockedTitleId(previousOwnedSet, ownedSet) else nil

	if state.equippedManually and not ownedSet[state.equippedTitle] then
		warn("[TitleService] Manually equipped title is no longer owned for", player.UserId, state.equippedTitle)
		state.equippedManually = false
	end

	if not state.equippedManually and state.equippedTitle ~= nextTitle then
		applyEquip(player, nextTitle, unlockedTitleId ~= nil)
		return
	end

	if unlockedTitleId then
		local notificationPayload = buildTitlePayload(player, unlockedTitleId, true, {
			notificationOnly = true,
			currentEquippedTitle = state.equippedTitle,
		})
		getTitleDataUpdated():FireClient(player, notificationPayload)
	end

	if not TitleConfig.GetTitle(state.equippedTitle) then
		state.equippedTitle = nextTitle
		saveTitleData(player)
	end

	fireCurrentTitlePayload(player, false)
end

local function attachLevelWatcher(player)
	if levelConnections[player.UserId] then
		levelConnections[player.UserId]:Disconnect()
		levelConnections[player.UserId] = nil
	end

	local levelValue = getLevelValue(player)
	if not levelValue then
		return
	end

	levelConnections[player.UserId] = levelValue:GetPropertyChangedSignal("Value"):Connect(function()
		refreshAutoEquip(player, true)
	end)
end

local function canUseEquipRemote(player)
	local state = ensureState(player)
	local now = os.clock()
	if now - (state.lastEquipTime or 0) < EQUIP_RATE_LIMIT_SECONDS then
		return false
	end

	state.lastEquipTime = now
	return true
end

local function equipTitle(player, titleId)
	if typeof(titleId) ~= "string" then
		warn("[TitleService] Rejected EquipTitle with non-string titleId for", player.UserId)
		return false
	end

	if not canUseEquipRemote(player) then
		return false
	end

	if not TitleConfig.GetTitle(titleId) then
		warn("[TitleService] Rejected EquipTitle for unknown title", player.UserId, titleId)
		return false
	end

	local state = ensureState(player)
	local ownedSet = resolveOwnership(player)
	if not ownedSet[titleId] then
		warn("[TitleService] Rejected EquipTitle for unowned title", player.UserId, titleId)
		return false
	end

	state.equippedManually = true
	applyEquip(player, titleId, false)
	return true
end

local function unequipTitle(player)
	if not canUseEquipRemote(player) then
		return false
	end

	local state = ensureState(player)
	state.equippedManually = false
	refreshAutoEquip(player, false)
	saveTitleData(player)
	return true
end

local function onPlayerAdded(player)
	local loadedData = loadTitleData(player)
	local state = ensureState(player)
	state.equippedTitle = loadedData.equippedTitle or TitleConfig.DEFAULT_TITLE_ID
	state.achievements = copyDictionary(loadedData.achievements)
	state.equippedManually = loadedData.equippedManually == true
	state.migratedFromV1 = loadedData.migratedFromV1 == true
	state.gamepassOwned = checkGamepass(player)

	attachLevelWatcher(player)
	if loadedData.migratedTitleId then
		resolveOwnership(player)
		fireCurrentTitlePayload(player, false)
		saveTitleData(player)
	else
		refreshAutoEquip(player, false)
		if loadedData.migratedFromV1 and not loadedData.loadFailed then
			saveTitleData(player)
		end
	end

	task.delay(2, function()
		if player.Parent then
			fireCurrentTitlePayload(player, false)
		end
	end)

	player.CharacterAdded:Connect(function()
		attachLevelWatcher(player)
		task.defer(function()
			fireCurrentTitlePayload(player, false)
		end)
	end)
end

local function onPlayerRemoving(player)
	saveTitleData(player)

	local connection = levelConnections[player.UserId]
	if connection then
		connection:Disconnect()
		levelConnections[player.UserId] = nil
	end

	playerStates[player.UserId] = nil
end

local function onGamepassPurchaseFinished(player, gamepassId, wasPurchased)
	if gamepassId ~= TitleConfig.TITLE_PACK_GAMEPASS_ID or not wasPurchased then
		return
	end

	local state = ensureState(player)
	state.gamepassOwned = true
	refreshAutoEquip(player, true)
end

function TitleService.Start()
	if started then
		return
	end

	started = true
	getTitleDataUpdated()
	getEquipTitleRemote().OnServerEvent:Connect(equipTitle)
	getUnequipTitleRemote().OnServerEvent:Connect(unequipTitle)

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(onGamepassPurchaseFinished)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end
end

function TitleService.GetPlayerTitlePayload(player)
	return getPlayerTitlePayload(player)
end

function TitleService.ApplyTitlePayloadToBillboard(billboard, payload)
	applyTitlePayloadToBillboard(billboard, payload)
end

return TitleService
