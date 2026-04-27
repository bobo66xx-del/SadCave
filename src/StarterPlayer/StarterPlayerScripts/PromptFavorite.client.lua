--// Variables and Service

local AvatarEditorService = game:GetService("AvatarEditorService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

--// Settings

local YourPlaceID = 5895908271 -- your place id obv
local FavDelay = 600 -- seconds till it prompts after joining
local RemoteWaitTimeout = 10
local EligibilityWaitTimeout = 15
local DataReadyAttribute = "FavoritePromptDataReady"
local EligibleAttribute = "CanShowFavoritePrompt"
local PromptShownRemote = ReplicatedStorage:WaitForChild("FavoritePromptShown", RemoteWaitTimeout)
if not PromptShownRemote then
	warn("[FavoritePrompt] FavoritePromptShown remote missing in ReplicatedStorage; favorite prompt disabled this session")
	return
end

local hasPromptBeenHandled = false

local function canShowPromptThisSession()
	if hasPromptBeenHandled then
		return false
	end

	print("[FavoritePrompt] client checking eligibility start", "DataReady=", LocalPlayer:GetAttribute(DataReadyAttribute), "CanShow=", LocalPlayer:GetAttribute(EligibleAttribute))
	local waitStart = os.clock()
	while LocalPlayer:GetAttribute(DataReadyAttribute) ~= true do
		if os.clock() - waitStart >= EligibilityWaitTimeout then
			print("[FavoritePrompt] client eligibility wait timed out", "DataReady=", LocalPlayer:GetAttribute(DataReadyAttribute), "CanShow=", LocalPlayer:GetAttribute(EligibleAttribute))
			return false
		end

		task.wait(0.25)
	end

	local canShow = LocalPlayer:GetAttribute(EligibleAttribute) == true
	print("[FavoritePrompt] client eligibility resolved", "DataReady=", LocalPlayer:GetAttribute(DataReadyAttribute), "CanShow=", LocalPlayer:GetAttribute(EligibleAttribute), "Result=", canShow)
	return canShow
end

local function tryPromptFavorite()
	print("[FavoritePrompt] delayed prompt started", "FavDelay=", FavDelay)
	task.wait(FavDelay)

	if not canShowPromptThisSession() then
		return
	end

	hasPromptBeenHandled = true
	print("[FavoritePrompt] client sent remote")
	PromptShownRemote:FireServer()

	local success, result = pcall(function()
		AvatarEditorService:PromptSetFavorite(YourPlaceID, Enum.AvatarItemType.Asset, true)
	end)

	if not success then
		warn(result)
	end
end

--// Code

LocalPlayer.CharacterAdded:Connect(function()
	task.spawn(tryPromptFavorite)
end)

if LocalPlayer.Character then
	task.spawn(tryPromptFavorite)
end
