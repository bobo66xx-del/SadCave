local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Avalog = game.Workspace.Avalog.Avalog.Packages.Avalog
local PlayerDataStore = require(Avalog.SourceCode.Server.PlayerDataStorage.PlayerDataStore)

local REMOTE_NAME = "FavoritePromptShown"
local DATA_READY_ATTRIBUTE = "FavoritePromptDataReady"
local ELIGIBLE_ATTRIBUTE = "CanShowFavoritePrompt"

local remote = ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = REMOTE_NAME
	remote.Parent = ReplicatedStorage
end

local sessionPrompted = {}

local function setPromptState(player: Player, isReady: boolean, canShow: boolean)
	print("[FavoritePrompt] setting", DATA_READY_ATTRIBUTE, "for", player.UserId, "to", isReady)
	player:SetAttribute(DATA_READY_ATTRIBUTE, isReady)
	print("[FavoritePrompt] setting", ELIGIBLE_ATTRIBUTE, "for", player.UserId, "to", canShow)
	player:SetAttribute(ELIGIBLE_ATTRIBUTE, canShow)
end

local function markLoadedProfile(player: Player, profile, source)
	local data = profile.Data:Get()
	local alreadyPrompted = data.FavoritePromptShown == true

	print("[FavoritePrompt] profile evaluated", source, player.UserId, "SessionLoaded=", profile.Session:loaded(), "FavoritePromptShown=", data.FavoritePromptShown, "alreadyPrompted=", alreadyPrompted)

	if alreadyPrompted then
		sessionPrompted[player] = true
	end

	setPromptState(player, true, not alreadyPrompted)
	print("[FavoritePrompt] final eligibility", source, player.UserId, "CanShowFavoritePrompt=", not alreadyPrompted)
end

Players.PlayerAdded:Connect(function(player)
	print("[FavoritePrompt] player added", player.UserId)
	setPromptState(player, false, false)
end)

Players.PlayerRemoving:Connect(function(player)
	sessionPrompted[player] = nil
end)

PlayerDataStore.Loaded:Connect(function(player, profile)
	print("[FavoritePrompt] PlayerDataStore.Loaded fired", player.UserId, "SessionLoaded=", profile.Session:loaded(), "FavoritePromptShown=", profile.Data:Get().FavoritePromptShown)
	profile.Data:Observe(function(oldData, newData)
		print("[FavoritePrompt] profile observe", player.UserId, "old=", oldData and oldData.FavoritePromptShown, "new=", newData and newData.FavoritePromptShown, "SessionLoaded=", profile.Session:loaded())
	end)
	setPromptState(player, false, false)
	task.spawn(function()
		profile.Session:await()
		print("[FavoritePrompt] profile initial await completed", player.UserId, "FavoritePromptShown=", profile.Data:Get().FavoritePromptShown)
		markLoadedProfile(player, profile, "post-await")
	end)
end)

for player, profile in pairs(PlayerDataStore.Profiles) do
	print("[FavoritePrompt] existing profile found", player.UserId, "SessionLoaded=", profile.Session:loaded(), "FavoritePromptShown=", profile.Data:Get().FavoritePromptShown)
	setPromptState(player, false, false)
	task.spawn(function()
		profile.Session:await()
		print("[FavoritePrompt] existing profile await completed", player.UserId, "FavoritePromptShown=", profile.Data:Get().FavoritePromptShown)
		markLoadedProfile(player, profile, "existing-post-await")
	end)
end

remote.OnServerEvent:Connect(function(player)
	print("[FavoritePrompt] server received remote", player.UserId)

	if sessionPrompted[player] then
		print("[FavoritePrompt] session already prompted", player.UserId)
		setPromptState(player, true, false)
		return
	end

	local profile = PlayerDataStore:Get(player)
	print("[FavoritePrompt] profile lookup", player.UserId, "found=", profile ~= nil)
	if profile == nil then
		warn("[FavoritePrompt] missing profile while patching", player.UserId)
		return
	end

	print("[FavoritePrompt] before patch", player.UserId, "FavoritePromptShown=", profile.Data:Get().FavoritePromptShown, "SessionLoaded=", profile.Session:loaded())
	sessionPrompted[player] = true
	setPromptState(player, true, false)
	profile.Session:patch(PlayerDataStore.Actions.SetFavoritePromptShown)
	print("[FavoritePrompt] after patch", player.UserId, "FavoritePromptShown=", profile.Data:Get().FavoritePromptShown)
end)
