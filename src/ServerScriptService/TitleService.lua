local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TitleConfig = require(ReplicatedStorage:WaitForChild("TitleConfig"))

local TITLE_DATASTORE_NAME = "TitleData"
local MAX_ATTEMPTS = 3
local RETRY_DELAY_SECONDS = 1

local titleStore = DataStoreService:GetDataStore(TITLE_DATASTORE_NAME)

local playerStates = {}
local levelConnections = {}
local titleDataUpdated = nil
local started = false

local TitleService = {}

local function getTitleDataUpdated()
	if titleDataUpdated then
		return titleDataUpdated
	end

	local titleRemotes = ReplicatedStorage:FindFirstChild("TitleRemotes")
	if not titleRemotes then
		titleRemotes = Instance.new("Folder")
		titleRemotes.Name = "TitleRemotes"
		titleRemotes.Parent = ReplicatedStorage
	end

	titleDataUpdated = titleRemotes:FindFirstChild("TitleDataUpdated")
	if not titleDataUpdated then
		titleDataUpdated = Instance.new("RemoteEvent")
		titleDataUpdated.Name = "TitleDataUpdated"
		titleDataUpdated.Parent = titleRemotes
	end

	return titleDataUpdated
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

local function loadTitleData(player)
	local ok, result = withRetry("TitleData GetAsync", function()
		return titleStore:GetAsync(getStoreKey(player))
	end)

	if not ok then
		warn("[TitleService] Falling back to in-memory title data for", player.UserId)
		return {
			equippedTitle = TitleConfig.DEFAULT_TITLE_ID,
			achievements = {},
			loadFailed = true,
		}
	end

	if typeof(result) ~= "table" then
		return {
			equippedTitle = TitleConfig.DEFAULT_TITLE_ID,
			achievements = {},
		}
	end

	local equippedTitle = result.equippedTitle
	if typeof(equippedTitle) ~= "string" or not TitleConfig.GetTitle(equippedTitle) then
		equippedTitle = TitleConfig.DEFAULT_TITLE_ID
	end

	return {
		equippedTitle = equippedTitle,
		achievements = copyDictionary(result.achievements),
	}
end

local function saveTitleData(player)
	local state = playerStates[player.UserId]
	if not state then
		return false
	end

	local data = {
		equippedTitle = state.equippedTitle or TitleConfig.DEFAULT_TITLE_ID,
		achievements = copyDictionary(state.achievements),
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
	return TitleConfig.BuildPayload(titleId, false)
end

local function applyEquip(player, titleId, newlyUnlocked)
	local state = ensureState(player)
	local title = TitleConfig.GetTitleOrDefault(titleId)
	state.equippedTitle = title.id

	local payload = TitleConfig.BuildPayload(title.id, newlyUnlocked)
	getTitleDataUpdated():FireClient(player, payload)
	updateNameTag(player, payload)
	saveTitleData(player)

	return payload
end

local function refreshAutoEquip(player, newlyUnlocked)
	local state = ensureState(player)
	local ownedSet = resolveOwnership(player)
	local nextTitle = pickAutoEquip(ownedSet)

	if state.equippedTitle ~= nextTitle then
		applyEquip(player, nextTitle, newlyUnlocked)
	else
		updateNameTag(player, TitleConfig.BuildPayload(nextTitle, false))
	end
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

local function onPlayerAdded(player)
	local loadedData = loadTitleData(player)
	local state = ensureState(player)
	state.equippedTitle = loadedData.equippedTitle or TitleConfig.DEFAULT_TITLE_ID
	state.achievements = copyDictionary(loadedData.achievements)
	state.gamepassOwned = checkGamepass(player)

	attachLevelWatcher(player)
	refreshAutoEquip(player, false)

	player.CharacterAdded:Connect(function()
		attachLevelWatcher(player)
		task.defer(function()
			updateNameTag(player, getPlayerTitlePayload(player))
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
