local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")

local NoteSystem = ReplicatedStorage:WaitForChild("NoteSystem")
local SubmitNote = NoteSystem:WaitForChild("SubmitNote")
local NoteUpdated = NoteSystem:WaitForChild("NoteUpdated")
local NoteResult = NoteSystem:WaitForChild("NoteResult")

local COOLDOWN_SECONDS = 60
local DISTANCE_BUFFER = 2
local MAX_NOTE_LENGTH = 120
local MIN_LEVEL_TO_EDIT_NOTE = 5
local EDIT_LEVEL_REQUIRED_MESSAGE = "must be level 5+ to edit note"
local NOTE_STORE_NAME = "NoteSystem"
local NOTE_STORE_KEY = "CurrentNotes"

local noteInteraction = Workspace:WaitForChild("NoteInteraction")
local noteStore = DataStoreService:GetDataStore(NOTE_STORE_NAME)

local notesBySpotId = {}
local lastSubmitByUserId = {}
local submitInFlightByUserId = {}

local function trim(text)
	return text:match("^%s*(.-)%s*$")
end

local function sendResult(player, resultCode, message, spotId)
	NoteResult:FireClient(player, resultCode, message, spotId)
end

local function copyNotesTable()
	local snapshot = {}
	for spotId, noteText in pairs(notesBySpotId) do
		snapshot[spotId] = noteText
	end
	return snapshot
end

local function loadSavedNotes()
	local success, result = pcall(function()
		return noteStore:GetAsync(NOTE_STORE_KEY)
	end)

	if not success then
		warn("[NoteSystem] Failed to load notes:", result)
		return
	end

	if type(result) ~= "table" then
		return
	end

	for spotId, noteText in pairs(result) do
		if type(spotId) == "string" and type(noteText) == "string" then
			notesBySpotId[spotId] = noteText
		end
	end
end

local function saveNotes()
	local success, result = pcall(function()
		return noteStore:SetAsync(NOTE_STORE_KEY, copyNotesTable())
	end)

	if not success then
		warn("[NoteSystem] Failed to save notes:", result)
	end
end

loadSavedNotes()

local function findSpotPart(spotId)
	for _, instance in ipairs(noteInteraction:GetChildren()) do
		if instance:IsA("BasePart") then
			local configuredSpotId = instance:GetAttribute("SpotId")
			if type(configuredSpotId) == "string" and configuredSpotId == spotId then
				local prompt = instance:FindFirstChildWhichIsA("ProximityPrompt")
				if prompt then
					return instance, prompt
				end
			end
		end
	end

	return nil, nil
end

local function isPlayerNearSpot(player, spotPart, prompt)
	local character = player.Character
	if not character then
		return false
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return false
	end

	local maxDistance = prompt.MaxActivationDistance + DISTANCE_BUFFER
	return (rootPart.Position - spotPart.Position).Magnitude <= maxDistance
end

local function filterNoteText(player, text)
	local success, result = pcall(function()
		local filterResult = TextService:FilterStringAsync(text, player.UserId)
		return filterResult:GetNonChatStringForBroadcastAsync()
	end)

	if not success then
		return nil
	end

	return result
end

local function sendCurrentNote(player, spotId)
	NoteUpdated:FireClient(player, spotId, notesBySpotId[spotId] or "")
end

local function getPlayerLevel(player)
	local levelValue = player:FindFirstChild("Level")
	if levelValue and levelValue:IsA("IntValue") then
		return levelValue.Value
	end

	return 0
end

local function hasExistingNote(spotId)
	local noteText = notesBySpotId[spotId]
	return type(noteText) == "string" and noteText ~= ""
end

SubmitNote.OnServerEvent:Connect(function(player, spotId, rawText)
	local userId = player.UserId
	if submitInFlightByUserId[userId] then
		sendResult(player, "cooldown", "Wait before posting again.", spotId)
		return
	end

	submitInFlightByUserId[userId] = true

	if type(spotId) ~= "string" or type(rawText) ~= "string" then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "failed", "That note could not be posted.", nil)
		return
	end

	if hasExistingNote(spotId) and getPlayerLevel(player) < MIN_LEVEL_TO_EDIT_NOTE then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "level_required", EDIT_LEVEL_REQUIRED_MESSAGE, spotId)
		return
	end

	local spotPart, prompt = findSpotPart(spotId)
	if not spotPart or not prompt then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "failed", "That note could not be posted.", spotId)
		return
	end

	if not isPlayerNearSpot(player, spotPart, prompt) then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "too_far", "Too far away.", spotId)
		return
	end

	local lastSubmit = lastSubmitByUserId[userId]
	local now = os.clock()
	if lastSubmit and now - lastSubmit < COOLDOWN_SECONDS then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "cooldown", "Wait before posting again.", spotId)
		return
	end

	local trimmedText = trim(rawText)
	if trimmedText == "" then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "failed", "That note could not be posted.", spotId)
		return
	end

	if #trimmedText > MAX_NOTE_LENGTH then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "too_long", "Note is too long.", spotId)
		return
	end

	local filteredText = filterNoteText(player, trimmedText)
	if type(filteredText) ~= "string" then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "failed", "That note could not be posted.", spotId)
		return
	end

	filteredText = trim(filteredText)
	if filteredText == "" then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "failed", "That note could not be posted.", spotId)
		return
	end

	if #filteredText > MAX_NOTE_LENGTH then
		submitInFlightByUserId[userId] = nil
		sendResult(player, "too_long", "Note is too long.", spotId)
		return
	end

	lastSubmitByUserId[userId] = now
	notesBySpotId[spotId] = filteredText
	saveNotes()
	submitInFlightByUserId[userId] = nil
	NoteUpdated:FireAllClients(spotId, filteredText)
	sendResult(player, "posted", "Posted.", spotId)
end)

local function connectPrompt(notePart)
	if not notePart:IsA("BasePart") then
		return
	end

	local prompt = notePart:FindFirstChildWhichIsA("ProximityPrompt")
	if not prompt then
		return
	end

	prompt.Triggered:Connect(function(player)
		local spotId = notePart:GetAttribute("SpotId")
		if type(spotId) ~= "string" or spotId == "" then
			return
		end

		sendCurrentNote(player, spotId)
	end)
end

for _, instance in ipairs(noteInteraction:GetChildren()) do
	connectPrompt(instance)
end

Players.PlayerRemoving:Connect(function(player)
	lastSubmitByUserId[player.UserId] = nil
	submitInFlightByUserId[player.UserId] = nil
end)
