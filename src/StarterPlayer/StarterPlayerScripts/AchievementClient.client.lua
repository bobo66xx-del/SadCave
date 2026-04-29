local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local achievementRemotes = ReplicatedStorage:WaitForChild("AchievementRemotes")
local clientLocalTime = achievementRemotes:WaitForChild("ClientLocalTime")

local function getUtcOffsetSeconds()
	local now = os.time()
	return os.difftime(now, os.time(os.date("!*t", now)))
end

local function sendUtcOffset()
	clientLocalTime:FireServer(getUtcOffsetSeconds())
end

localPlayer.CharacterAdded:Connect(sendUtcOffset)
if localPlayer.Character then
	sendUtcOffset()
end
