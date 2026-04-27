local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local progressionRoot = script.Parent
local progressionFolder = ReplicatedStorage:WaitForChild("Progression")
local SourceConfig = require(progressionFolder:WaitForChild("SourceConfig"))
local ProgressionService = require(progressionRoot:WaitForChild("ProgressionService"))
local PresenceTick = require(progressionRoot:WaitForChild("Sources"):WaitForChild("PresenceTick"))

local seatConnections = {}

local function disconnectSeatConnections(player)
	local connections = seatConnections[player]
	if not connections then
		return
	end

	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end

	seatConnections[player] = nil
end

local function trackSeatConnection(player, connection)
	seatConnections[player] = seatConnections[player] or {}
	table.insert(seatConnections[player], connection)
end

local function isSeatMarkerSeat(seatPart)
	if not seatPart then
		return false
	end

	local seatMarkers = Workspace:FindFirstChild("SeatMarkers")
	if not seatMarkers then
		return false
	end

	return seatPart:IsDescendantOf(seatMarkers)
end

local function hookCharacter(player, character)
	disconnectSeatConnections(player)
	ProgressionService.ClearSittingState(player)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		humanoid = character:WaitForChild("Humanoid", 10)
	end

	if not humanoid then
		warn("[ProgressionDriver] Could not find Humanoid for", player.Name)
		return
	end

	trackSeatConnection(player, humanoid.Seated:Connect(function(isSeated, seatPart)
		if isSeated and isSeatMarkerSeat(seatPart) then
			ProgressionService.RegisterSittingState(player, seatPart, os.time())
		else
			ProgressionService.ClearSittingState(player)
		end
	end))
end

local function hookPlayer(player)
	ProgressionService.LoadPlayer(player)

	player.CharacterAdded:Connect(function(character)
		hookCharacter(player, character)
	end)

	player.CharacterRemoving:Connect(function()
		ProgressionService.ClearSittingState(player)
		disconnectSeatConnections(player)
	end)

	if player.Character then
		hookCharacter(player, player.Character)
	end

	ProgressionService.SendSnapshot(player)
end

local afkEvent = ReplicatedStorage:WaitForChild("AfkEvent", 10)
if afkEvent and afkEvent:IsA("RemoteEvent") then
	afkEvent.OnServerEvent:Connect(function(player, isAFK)
		ProgressionService.RegisterAFKState(player, isAFK)
	end)
else
	warn("[ProgressionDriver] ReplicatedStorage.AfkEvent was not found; AFK XP state will stay active-rate until AFK is available")
end

Players.PlayerAdded:Connect(hookPlayer)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(hookPlayer, player)
end

Players.PlayerRemoving:Connect(function(player)
	ProgressionService.SavePlayer(player)
	ProgressionService.UnloadPlayer(player)
	disconnectSeatConnections(player)
end)

if SourceConfig.ENABLED then
	task.spawn(function()
		while true do
			task.wait(SourceConfig.TICK_INTERVAL_SECONDS)

			for _, player in ipairs(Players:GetPlayers()) do
				task.spawn(function()
					ProgressionService.Tick(player, PresenceTick)
				end)
			end
		end
	end)
end

game:BindToClose(function()
	local remaining = 0

	for _, player in ipairs(Players:GetPlayers()) do
		remaining += 1

		task.spawn(function()
			ProgressionService.SavePlayer(player)
			remaining -= 1
		end)
	end

	local deadline = os.clock() + 25
	while remaining > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end)
