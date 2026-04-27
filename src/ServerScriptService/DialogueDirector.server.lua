local ServerScriptService = game:GetService("ServerScriptService")
if not script:IsDescendantOf(ServerScriptService) then
	return
end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dialogueData = require(ReplicatedStorage:WaitForChild("DialogueData"))
local globalConfig = dialogueData.Global or {}
local characterConfigs = dialogueData.Characters or {}
local playerConfig = dialogueData.Player or {}

local remotesFolder = ReplicatedStorage:FindFirstChild("DialogueRemotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "DialogueRemotes"
	remotesFolder.Parent = ReplicatedStorage
end

local function getOrCreateRemote(name)
	local remote = remotesFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = remotesFolder
	end
	return remote
end

local playPlayerDialogueRemote = getOrCreateRemote("PlayPlayerDialogue")
local playCharacterDialogueRemote = getOrCreateRemote("PlayCharacterDialogue")
local playerChoiceSelectedRemote = getOrCreateRemote("PlayerDialogueChoiceSelected")
local requestCharacterConversationRemote = getOrCreateRemote("RequestCharacterConversation")

local activeConversationByPlayer = {}
local activeChoiceRequestsByPlayer = {}
local fulfilledChoiceResultsByPlayer = {}
local requestCooldownByPlayer = {}
local choiceCooldownByPlayer = {}
local warnedFlagsByPlayer = {}
local requestCounter = 0

local CONVERSATION_REQUEST_COOLDOWN = 0.2
local CHOICE_SUBMIT_COOLDOWN = 0.1

local function initializePlayerState(player)
	local chosenName = player:GetAttribute("PlayerChosenName")
	if type(chosenName) ~= "string" or chosenName == "" then
		player:SetAttribute("PlayerChosenName", player.DisplayName ~= "" and player.DisplayName or player.Name)
	end
end

local function warnOnce(player, key, ...)
	local warnedFlags = warnedFlagsByPlayer[player]
	if not warnedFlags then
		warnedFlags = {}
		warnedFlagsByPlayer[player] = warnedFlags
	end
	if warnedFlags[key] then
		return
	end
	warnedFlags[key] = true
	warn(...)
end

local function clearChoiceRequests(player)
	activeChoiceRequestsByPlayer[player] = nil
	fulfilledChoiceResultsByPlayer[player] = nil
end

local function clearPlayerState(player)
	activeConversationByPlayer[player] = nil
	clearChoiceRequests(player)
	requestCooldownByPlayer[player] = nil
	choiceCooldownByPlayer[player] = nil
	warnedFlagsByPlayer[player] = nil
end

local function isOnCooldown(bucket, player, cooldown)
	local now = os.clock()
	local last = bucket[player] or 0
	bucket[player] = now
	return now - last < cooldown
end

local function getActiveChoiceRequest(player, requestId)
	local requests = activeChoiceRequestsByPlayer[player]
	if not requests then
		return nil
	end
	return requests[requestId]
end

local function clearActiveChoiceRequest(player, requestId)
	local requests = activeChoiceRequestsByPlayer[player]
	if not requests then
		return
	end
	requests[requestId] = nil
	if next(requests) == nil then
		activeChoiceRequestsByPlayer[player] = nil
	end
end

local function setFulfilledChoiceResult(player, requestId, result)
	local fulfilled = fulfilledChoiceResultsByPlayer[player]
	if not fulfilled then
		fulfilled = {}
		fulfilledChoiceResultsByPlayer[player] = fulfilled
	end
	fulfilled[requestId] = result
end

local function takeFulfilledChoiceResult(player, requestId)
	local fulfilled = fulfilledChoiceResultsByPlayer[player]
	if not fulfilled then
		return nil
	end
	local result = fulfilled[requestId]
	fulfilled[requestId] = nil
	if next(fulfilled) == nil then
		fulfilledChoiceResultsByPlayer[player] = nil
	end
	return result
end

local function findByPath(root, path)
	if not root or type(path) ~= "string" or path == "" then
		return nil
	end

	local current = root
	for segment in string.gmatch(path, "[^%.]+") do
		if not current then
			return nil
		end
		current = current:FindFirstChild(segment)
	end

	return current
end

local function getCharacterConfig(characterId)
	if type(characterId) ~= "string" then
		return nil
	end
	return characterConfigs[characterId]
end

local function getCharacterModel(characterId, config)
	if type(config) ~= "table" then
		return nil
	end
	return workspace:FindFirstChild(config.modelName or characterId)
end

local function isDialoguePoint(instance)
	return instance and (instance:IsA("BasePart") or instance:IsA("Attachment"))
end

local function getCharacterPoint(characterId, config)
	if type(config.dialoguePointWorkspacePath) == "string" then
		local workspacePoint = findByPath(workspace, config.dialoguePointWorkspacePath)
		if isDialoguePoint(workspacePoint) then
			return workspacePoint
		end
	end

	local model = getCharacterModel(characterId, config)
	if not model then
		return nil
	end

	if type(config.dialoguePointPath) == "string" then
		local byPath = findByPath(model, config.dialoguePointPath)
		if isDialoguePoint(byPath) then
			return byPath
		end
	end

	local pointName = config.dialoguePointName or globalConfig.dialoguePointName or "DialoguePoint"
	local namedPoint = model:FindFirstChild(pointName, true)
	if isDialoguePoint(namedPoint) then
		return namedPoint
	end

	return model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("Head")
		or model:FindFirstChildWhichIsA("BasePart")
end

local function getWorldPosition(point)
	if not point then
		return nil
	end
	if point:IsA("Attachment") then
		return point.WorldPosition
	end
	if point:IsA("BasePart") then
		return point.Position
	end
	return nil
end

local function getPlayerRoot(player)
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart")
end

local function isPlayerNearCharacter(player, characterId, maxDistance)
	local config = getCharacterConfig(characterId)
	if not config then
		return false
	end

	local playerRoot = getPlayerRoot(player)
	local point = getCharacterPoint(characterId, config)
	if not playerRoot or not point then
		return false
	end

	local pointPosition = getWorldPosition(point)
	if not pointPosition then
		return false
	end

	return (playerRoot.Position - pointPosition).Magnitude <= maxDistance
end

local function getPlayerLabel(player)
	local chosenName = player:GetAttribute("PlayerChosenName")
	if type(chosenName) == "string" and chosenName ~= "" then
		return chosenName
	end
	if player.DisplayName ~= "" then
		return player.DisplayName
	end
	return player.Name
end

local function resolveLine(player, text)
	if type(text) ~= "string" then
		return ""
	end

	local resolved = text
	resolved = string.gsub(resolved, "{playerName}", getPlayerLabel(player))
	resolved = string.gsub(resolved, "{playerDisplayName}", player.DisplayName ~= "" and player.DisplayName or player.Name)
	return resolved
end

local function resolveLines(player, lines)
	local resolved = {}
	for index, line in ipairs(lines or {}) do
		resolved[index] = resolveLine(player, line)
	end
	return resolved
end

local function cloneResolvedChoices(player, choices)
	local resolvedChoices = {}
	for index, choice in ipairs(choices or {}) do
		resolvedChoices[index] = {
			id = choice.id,
			text = resolveLine(player, choice.text or ("Choice " .. tostring(index))),
		}
	end
	return resolvedChoices
end

local function getEntryLines(entry)
	if type(entry) == "string" then
		return { entry }
	end

	if type(entry) ~= "table" then
		return {}
	end

	if type(entry.text) == "string" then
		return { entry.text }
	end

	local lines = {}
	for _, line in ipairs(entry.lines or {}) do
		table.insert(lines, line)
	end
	return lines
end

local function estimateLinesDuration(lines, typeSpeed, holdDuration, betweenLinesDelay, extraPerLine)
	local total = 0
	for _, line in ipairs(lines or {}) do
		total += (#line * typeSpeed) + holdDuration + betweenLinesDelay + (extraPerLine or 0)
	end
	return total
end

local function isPlayerEntry(entry)
	if type(entry) ~= "table" or entry.kind == "choice" then
		return false
	end

	if entry.channel == "player" then
		return true
	end

	if entry.speaker == "Player" then
		return true
	end

	if entry.mode == "spoken" or entry.mode == "thought" then
		return true
	end

	return false
end

local function resolveTargetCharacterId(entry, fallbackCharacterId)
	if type(entry) == "table" then
		if type(entry.characterId) == "string" and characterConfigs[entry.characterId] then
			return entry.characterId
		end
		if type(entry.speaker) == "string" and characterConfigs[entry.speaker] then
			return entry.speaker
		end
	end
	return fallbackCharacterId
end

local function resolveSpeakerName(entry, targetCharacterId)
	if type(entry) == "table" and type(entry.speakerName) == "string" and entry.speakerName ~= "" then
		return entry.speakerName
	end

	if type(entry) == "table" and type(entry.speaker) == "string" and entry.speaker ~= "Player" then
		local speakerConfig = characterConfigs[entry.speaker]
		if speakerConfig and type(speakerConfig.displayName) == "string" and speakerConfig.displayName ~= "" then
			return speakerConfig.displayName
		end
		return entry.speaker
	end

	local config = characterConfigs[targetCharacterId]
	if config and type(config.displayName) == "string" and config.displayName ~= "" then
		return config.displayName
	end

	return targetCharacterId
end

local function playCharacterLines(player, characterId, entry, lines)
	local characterConfig = characterConfigs[characterId]
	if not characterConfig then
		return
	end

	local resolved = resolveLines(player, lines)
	if #resolved == 0 then
		return
	end

	playCharacterDialogueRemote:FireClient(player, {
		characterId = characterId,
		speaker = resolveSpeakerName(entry, characterId),
		lines = resolved,
	})

	local duration = estimateLinesDuration(
		resolved,
		characterConfig.typeSpeed or 0.03,
		characterConfig.holdDuration or 1.1,
		characterConfig.betweenLinesDelay or 0.1,
		0.1
	)
	task.wait(duration)
end

local function preparePlayerPayload(player, payload)
	local runtimePayload = {
		id = payload.id,
		mode = payload.mode,
		timeout = payload.timeout,
	}

	if payload.prompt then
		runtimePayload.prompt = resolveLine(player, payload.prompt)
	end

	if payload.lines then
		runtimePayload.lines = resolveLines(player, payload.lines)
	end

	if payload.choices then
		runtimePayload.choices = cloneResolvedChoices(player, payload.choices)
	end

	return runtimePayload
end

local function playPlayerPayload(player, payload)
	local runtimePayload = preparePlayerPayload(player, payload)
	playPlayerDialogueRemote:FireClient(player, runtimePayload)

	if runtimePayload.mode == "choice" then
		return runtimePayload
	end

	local duration = estimateLinesDuration(
		runtimePayload.lines or {},
		playerConfig.typeSpeed or 0.03,
		playerConfig.holdDuration or 1,
		playerConfig.betweenLinesDelay or 0.1,
		0.05
	)
	task.wait(duration)
	return runtimePayload
end

local function createChoiceRequest(player, characterId, runtimePayload)
	requestCounter += 1
	local requestId = "choice_" .. tostring(requestCounter)
	local now = os.clock()
	local timeoutSeconds = runtimePayload.timeout or playerConfig.choiceTimeout or 18
	local allowedChoiceIds = {}
	local choiceTextsById = {}

	for _, choice in ipairs(runtimePayload.choices or {}) do
		if type(choice.id) == "string" and choice.id ~= "" then
			allowedChoiceIds[choice.id] = true
			choiceTextsById[choice.id] = choice.text or choice.id
		end
	end

	local requests = activeChoiceRequestsByPlayer[player]
	if not requests then
		requests = {}
		activeChoiceRequestsByPlayer[player] = requests
	end

	requests[requestId] = {
		requestId = requestId,
		characterId = characterId,
		issuedAt = now,
		expiresAt = now + timeoutSeconds,
		allowedChoiceIds = allowedChoiceIds,
		choiceTextsById = choiceTextsById,
		fallbackChoiceId = runtimePayload.choices and runtimePayload.choices[1] and runtimePayload.choices[1].id or nil,
		fallbackChoiceText = runtimePayload.choices and runtimePayload.choices[1] and runtimePayload.choices[1].text or nil,
	}

	return requestId
end

local function awaitChoice(player, requestId)
	while player.Parent do
		local fulfilled = takeFulfilledChoiceResult(player, requestId)
		if fulfilled then
			return fulfilled
		end

		local request = getActiveChoiceRequest(player, requestId)
		if not request then
			return nil
		end

		if os.clock() >= request.expiresAt then
			local fallbackChoiceId = request.fallbackChoiceId
			local fallbackChoiceText = request.fallbackChoiceText
			clearActiveChoiceRequest(player, requestId)
			if type(fallbackChoiceId) == "string" and fallbackChoiceId ~= "" then
				return {
					id = fallbackChoiceId,
					text = fallbackChoiceText,
					timedOut = true,
				}
			end
			return nil
		end

		task.wait(0.05)
	end

	clearActiveChoiceRequest(player, requestId)
	return nil
end

local function playChoice(player, characterId, payload)
	local runtimePayload = preparePlayerPayload(player, {
		mode = "choice",
		prompt = payload.prompt,
		timeout = payload.timeout,
		choices = payload.choices,
	})
	local requestId = createChoiceRequest(player, characterId, runtimePayload)
	runtimePayload.id = requestId
	playPlayerDialogueRemote:FireClient(player, runtimePayload)
	return awaitChoice(player, requestId)
end

local function playConversationEntries(player, fallbackCharacterId, entries, depth)
	if depth > 12 then
		return
	end

	for _, entry in ipairs(entries or {}) do
		if type(entry) == "string" then
			playCharacterLines(player, fallbackCharacterId, { speaker = fallbackCharacterId }, { entry })
		elseif type(entry) == "table" then
			if entry.kind == "choice" then
				local result = playChoice(player, fallbackCharacterId, {
					prompt = entry.prompt or "Choose",
					timeout = entry.timeout or playerConfig.choiceTimeout,
					choices = entry.choices or {},
				})
				local branches = entry.branches or {}
				local branchEntries = branches[result and result.id] or branches.default
				if branchEntries then
					playConversationEntries(player, fallbackCharacterId, branchEntries, depth + 1)
				end
			elseif isPlayerEntry(entry) then
				playPlayerPayload(player, {
					mode = entry.mode or "spoken",
					lines = getEntryLines(entry),
				})
			else
				local targetCharacterId = resolveTargetCharacterId(entry, fallbackCharacterId)
				if targetCharacterId and characterConfigs[targetCharacterId] then
					playCharacterLines(player, targetCharacterId, entry, getEntryLines(entry))
				end
			end
		end
	end
end

local function resolveConversationRequest(characterConfig, conversationId)
	local conversations = characterConfig.conversations
	if type(conversations) ~= "table" then
		return nil, nil
	end

	local defaultConversationId = characterConfig.defaultConversation
	local requestedConversationId = conversationId
	if requestedConversationId == nil then
		requestedConversationId = defaultConversationId
	elseif type(requestedConversationId) ~= "string" or requestedConversationId == "" then
		return nil, nil
	end

	local conversation = conversations[requestedConversationId]
	if type(conversation) ~= "table" then
		return nil, nil
	end

	if conversation.hidden == true or conversation.locked == true then
		return nil, nil
	end

	if requestedConversationId == defaultConversationId then
		return requestedConversationId, conversation
	end

	local allowedConversationIds = characterConfig.allowedConversationIds
	if type(allowedConversationIds) ~= "table" then
		return nil, nil
	end

	for _, allowedConversationId in ipairs(allowedConversationIds) do
		if allowedConversationId == requestedConversationId then
			return requestedConversationId, conversation
		end
	end

	return nil, nil
end

local function startConversationForPlayer(player, characterId, conversationId)
	if activeConversationByPlayer[player] then
		return false
	end

	local characterConfig = getCharacterConfig(characterId)
	if not characterConfig then
		return false
	end

	local resolvedConversationId, conversation = resolveConversationRequest(characterConfig, conversationId)
	if not resolvedConversationId or not conversation then
		warnOnce(player, "invalidConversation", "[DialogueDirector] Ignoring invalid or locked conversation request for", player.Name)
		return false
	end

	local maxDistance = characterConfig.triggerDistance or globalConfig.fallbackTriggerDistance or 12
	if not isPlayerNearCharacter(player, characterId, maxDistance + 1) then
		return false
	end

	clearChoiceRequests(player)
	activeConversationByPlayer[player] = {
		characterId = characterId,
		conversationId = resolvedConversationId,
	}

	task.spawn(function()
		local ok, err = pcall(function()
			playConversationEntries(player, characterId, conversation, 0)
		end)
		if not ok then
			warn("[DialogueDirector] Conversation failed:", err)
		end
		clearChoiceRequests(player)
		if player.Parent then
			activeConversationByPlayer[player] = nil
		end
	end)

	return true
end

playerChoiceSelectedRemote.OnServerEvent:Connect(function(player, requestId, choiceId)
	if isOnCooldown(choiceCooldownByPlayer, player, CHOICE_SUBMIT_COOLDOWN) then
		return
	end

	if type(requestId) ~= "string" or type(choiceId) ~= "string" then
		warnOnce(player, "invalidChoicePayload", "[DialogueDirector] Ignoring malformed dialogue choice payload from", player.Name)
		return
	end

	local request = getActiveChoiceRequest(player, requestId)
	if not request then
		return
	end

	if os.clock() >= request.expiresAt then
		clearActiveChoiceRequest(player, requestId)
		return
	end

	if not request.allowedChoiceIds[choiceId] then
		warnOnce(player, "invalidChoiceSelection", "[DialogueDirector] Ignoring invalid dialogue choice selection from", player.Name)
		return
	end

	local choiceText = request.choiceTextsById[choiceId]
	if type(choiceText) ~= "string" then
		return
	end

	setFulfilledChoiceResult(player, requestId, {
		id = choiceId,
		text = choiceText,
	})
	clearActiveChoiceRequest(player, requestId)
end)

requestCharacterConversationRemote.OnServerEvent:Connect(function(player, characterId, conversationId)
	if isOnCooldown(requestCooldownByPlayer, player, CONVERSATION_REQUEST_COOLDOWN) then
		return
	end

	if type(characterId) ~= "string" then
		warnOnce(player, "invalidConversationPayload", "[DialogueDirector] Ignoring malformed conversation request from", player.Name)
		return
	end
	startConversationForPlayer(player, characterId, conversationId)
end)

Players.PlayerAdded:Connect(initializePlayerState)
for _, player in ipairs(Players:GetPlayers()) do
	initializePlayerState(player)
end

Players.PlayerRemoving:Connect(function(player)
	clearPlayerState(player)
end)