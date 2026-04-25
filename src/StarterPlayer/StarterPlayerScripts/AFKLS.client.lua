local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AfkEvent = ReplicatedStorage:WaitForChild("AfkEvent")

local function focusGained()
	-- Player is back, remove AFK from name
	AfkEvent:FireServer(false)
end

local function focusReleased()
	-- Player is AFK, add AFK to name
	AfkEvent:FireServer(true)
end

UserInputService.WindowFocused:Connect(focusGained)
UserInputService.WindowFocusReleased:Connect(focusReleased)
