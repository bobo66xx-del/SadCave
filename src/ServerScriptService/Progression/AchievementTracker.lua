local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local TitleConfig = require(ReplicatedStorage:WaitForChild("TitleConfig"))
local DialogueData = require(ReplicatedStorage:WaitForChild("DialogueData"))
local TitleService = require(ServerScriptService:WaitForChild("TitleService"))

local GROUP_ID = 8106647
local SAT_DOWN_SECONDS = 30
local SEAT_COUNT_TARGET = 5
local UP_TOO_LATE_CHECK_SECONDS = 60
local UTC_OFFSET_LIMIT_SECONDS = 18 * 60 * 60
local TITLE_DATA_WAIT_SECONDS = 20
local PROGRESSION_WAIT_SECONDS = 20

local achievementUnlockedBindable = Instance.new("BindableEvent")
achievementUnlockedBindable.Name = "AchievementUnlocked"
achievementUnlockedBindable.Parent = script

local AchievementTracker = {}
AchievementTracker.AchievementUnlocked = achievementUnlockedBindable.Event

local sessionStateByPlayer = {}
local started = false

local function getAchievementRemotes()
	local folder = ReplicatedStorage:FindFirstChild("AchievementRemotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "AchievementRemotes"
		folder.Parent = ReplicatedStorage
	end

	return folder
end

local function getClientLocalTimeRemote()
	local folder = getAchievementRemotes()
	local remote = folder:FindFirstChild("ClientLocalTime")
	if remote and not remote:IsA("RemoteEvent") then
		warn("[AchievementTracker] Replacing non-RemoteEvent AchievementRemotes.ClientLocalTime")
		remote:Destroy()
		remote = nil
	end

	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = "ClientLocalTime"
		remote.Parent = folder
	end

	return remote
end

local function getSessionState(player)
	local state = sessionStateByPlayer[player]
	if state then
		return state
	end

	state = {
		connections = {},
		seatKeys = {},
		seatKeyCount = 0,
		seatToken = 0,
		utcOffsetSeconds = nil,
		upTooLateDone = false,
	}
	sessionStateByPlayer[player] = state
	return state
end

local function trackConnection(player, connection)
	table.insert(getSessionState(player).connections, connection)
end

local function disconnectPlayer(player)
	local state = sessionStateByPlayer[player]
	if not state then
		return
	end

	for _, connection in ipairs(state.connections) do
		connection:Disconnect()
	end

	sessionStateByPlayer[player] = nil
end

local function waitForTitleData(player)
	if not TitleService.WaitForTitleData then
		warn("[AchievementTracker] TitleService.WaitForTitleData is unavailable")
		return nil
	end

	return TitleService.WaitForTitleData(player, TITLE_DATA_WAIT_SECONDS)
end

local function waitForProgressionState(player)
	local deadline = os.clock() + PROGRESSION_WAIT_SECONDS

	while player.Parent and os.clock() < deadline do
		local progressionState = TitleService.GetProgressionState and TitleService.GetProgressionState(player)
		if progressionState then
			return progressionState
		end

		task.wait(0.25)
	end

	return nil
end

local function ensureDictionary(value)
	if typeof(value) == "table" then
		return value
	end

	return {}
end

local function flagAndFire(player, achievementId)
	if typeof(achievementId) ~= "string" or achievementId == "" then
		return false
	end

	local titleData = waitForTitleData(player)
	if not titleData then
		warn("[AchievementTracker] Could not load TitleData before achievement check for", player.UserId, achievementId)
		return false
	end

	titleData.achievements = ensureDictionary(titleData.achievements)
	if titleData.achievements[achievementId] == true then
		return false
	end

	titleData.achievements[achievementId] = true
	if TitleService.SaveTitleData then
		TitleService.SaveTitleData(player)
	end

	achievementUnlockedBindable:Fire(player, achievementId)
	return true
end

local function getNpcKeys()
	local characterKeys = {}

	for characterKey in pairs(DialogueData.Characters or {}) do
		table.insert(characterKeys, characterKey)
	end

	table.sort(characterKeys)
	return characterKeys
end

local function checkHeardThemAll(player)
	local characterKeys = getNpcKeys()
	local minNpcs = TitleConfig.HEARD_THEM_ALL_MIN_NPCS or 3
	if #characterKeys < minNpcs then
		return false
	end

	local titleData = waitForTitleData(player)
	if not titleData then
		return false
	end

	local npcsHeard = ensureDictionary(titleData.npcsHeard)
	for _, characterKey in ipairs(characterKeys) do
		if npcsHeard[characterKey] ~= true then
			return false
		end
	end

	return flagAndFire(player, "heard_them_all")
end

local function markNpcHeard(player, characterKey)
	if typeof(characterKey) ~= "string" or characterKey == "" then
		return
	end

	local titleData = waitForTitleData(player)
	if not titleData then
		return
	end

	titleData.npcsHeard = ensureDictionary(titleData.npcsHeard)
	if titleData.npcsHeard[characterKey] ~= true then
		titleData.npcsHeard[characterKey] = true
		if TitleService.SaveTitleData then
			TitleService.SaveTitleData(player)
		end
	end
end

local function onConversationEnded(player, characterKey)
	if not player or not player:IsA("Player") then
		return
	end

	flagAndFire(player, "said_something")
	markNpcHeard(player, characterKey)
	checkHeardThemAll(player)
end

local function onNoteSubmitted(player)
	if player and player:IsA("Player") then
		flagAndFire(player, "left_a_mark")
	end
end

local function isSeatMarkerSeat(seatPart)
	local seatMarkers = Workspace:FindFirstChild("SeatMarkers")
	return seatPart ~= nil and seatMarkers ~= nil and seatPart:IsDescendantOf(seatMarkers)
end

local function markSeat(player, seatPart)
	local state = getSessionState(player)
	local seatKey = seatPart:GetFullName()

	if state.seatKeys[seatKey] then
		return
	end

	state.seatKeys[seatKey] = true
	state.seatKeyCount += 1

	if state.seatKeyCount >= SEAT_COUNT_TARGET then
		flagAndFire(player, "knows_every_chair")
	end
end

local function hookCharacter(player, character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		humanoid = character:WaitForChild("Humanoid", 10)
	end

	if not humanoid then
		warn("[AchievementTracker] Could not find Humanoid for", player.Name)
		return
	end

	trackConnection(player, humanoid.Seated:Connect(function(isSeated, seatPart)
		local state = getSessionState(player)
		state.seatToken += 1
		local token = state.seatToken

		if not isSeated or not isSeatMarkerSeat(seatPart) then
			return
		end

		markSeat(player, seatPart)

		task.delay(SAT_DOWN_SECONDS, function()
			local latestState = sessionStateByPlayer[player]
			if not latestState or latestState.seatToken ~= token then
				return
			end

			if player.Parent and humanoid.Parent and humanoid.Sit and humanoid.SeatPart == seatPart then
				flagAndFire(player, "sat_down")
			end
		end)
	end))
end

local function checkVisitAchievements(player)
	local progressionState = waitForProgressionState(player)
	if not progressionState then
		warn("[AchievementTracker] Progression state unavailable for revisit achievements for", player.UserId)
		return
	end

	local revisits = tonumber(progressionState.revisits) or 0
	if revisits >= 2 then
		flagAndFire(player, "came_back")
	end
	if revisits >= 10 then
		flagAndFire(player, "keeps_coming_back")
	end
	if revisits >= 50 then
		flagAndFire(player, "part_of_the_walls")
	end
end

local function checkGroupAchievement(player)
	local ok, isInGroup = pcall(function()
		return player:IsInGroup(GROUP_ID)
	end)

	if not ok then
		warn("[AchievementTracker] Group membership check failed for", player.UserId, isInGroup)
		return
	end

	if isInGroup then
		flagAndFire(player, "one_of_us")
	end
end

local function checkDayOne(player)
	local launchWindow = TitleConfig.LAUNCH_WINDOW
	if typeof(launchWindow) ~= "table" then
		return
	end

	local startUnix = tonumber(launchWindow.startUnix)
	local endUnix = tonumber(launchWindow.endUnix)
	if not startUnix or not endUnix then
		return
	end

	local now = os.time()
	if now >= startUnix and now <= endUnix then
		flagAndFire(player, "day_one")
	end
end

local function checkUpTooLate(player)
	local state = sessionStateByPlayer[player]
	if not state or state.upTooLateDone or not state.utcOffsetSeconds then
		return
	end

	local localUnix = os.time() + state.utcOffsetSeconds
	local localTime = os.date("!*t", localUnix)
	local hour = localTime and localTime.hour

	if hour == 3 or hour == 4 then
		state.upTooLateDone = true
		flagAndFire(player, "up_too_late")
	end
end

local function startUpTooLateLoop()
	task.spawn(function()
		while started do
			for _, player in ipairs(Players:GetPlayers()) do
				task.spawn(checkUpTooLate, player)
			end

			task.wait(UP_TOO_LATE_CHECK_SECONDS)
		end
	end)
end

local function onClientLocalTime(player, offsetSeconds)
	local numericOffset = tonumber(offsetSeconds)
	if not numericOffset or math.abs(numericOffset) > UTC_OFFSET_LIMIT_SECONDS then
		warn("[AchievementTracker] Ignoring invalid UTC offset for", player.UserId)
		return
	end

	local state = getSessionState(player)
	state.utcOffsetSeconds = math.floor(numericOffset)
	checkUpTooLate(player)
end

local function connectDialogueSignal()
	local dialogueDirector = ServerScriptService:WaitForChild("DialogueDirector", 20)
	if not dialogueDirector then
		warn("[AchievementTracker] DialogueDirector missing; said_something and heard_them_all will not unlock")
		return
	end

	local conversationEnded = dialogueDirector:WaitForChild("ConversationEnded", 20)
	if not conversationEnded or not conversationEnded:IsA("BindableEvent") then
		warn("[AchievementTracker] DialogueDirector.ConversationEnded missing; said_something and heard_them_all will not unlock")
		return
	end

	conversationEnded.Event:Connect(onConversationEnded)
end

local function connectNoteSignal()
	local noteServer = ServerScriptService:WaitForChild("NoteSystemServer", 20)
	if not noteServer then
		warn("[AchievementTracker] NoteSystemServer missing; left_a_mark will not unlock")
		return
	end

	local noteSubmitted = noteServer:WaitForChild("NoteSubmitted", 20)
	if not noteSubmitted or not noteSubmitted:IsA("BindableEvent") then
		warn("[AchievementTracker] NoteSystemServer.NoteSubmitted missing; left_a_mark will not unlock")
		return
	end

	noteSubmitted.Event:Connect(onNoteSubmitted)
end

local function onPlayerAdded(player)
	getSessionState(player)

	trackConnection(player, player.Idled:Connect(function()
		flagAndFire(player, "fell_asleep_here")
	end))

	trackConnection(player, player.CharacterAdded:Connect(function(character)
		hookCharacter(player, character)
	end))

	if player.Character then
		hookCharacter(player, player.Character)
	end

	task.spawn(function()
		if not waitForTitleData(player) then
			return
		end

		checkVisitAchievements(player)
		checkGroupAchievement(player)
		checkDayOne(player)
		checkHeardThemAll(player)
	end)
end

function AchievementTracker.Start()
	if started then
		return
	end

	started = true

	getClientLocalTimeRemote().OnServerEvent:Connect(onClientLocalTime)
	task.spawn(connectDialogueSignal)
	task.spawn(connectNoteSignal)
	startUpTooLateLoop()

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(disconnectPlayer)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end
end

return AchievementTracker
