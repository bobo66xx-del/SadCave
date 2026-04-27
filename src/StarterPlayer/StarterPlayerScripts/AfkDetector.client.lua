-- Fires AfkEvent on window focus loss/gain so the XP system can apply AFK rate.
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AfkEvent = ReplicatedStorage:WaitForChild("AfkEvent", 10)
if not AfkEvent then return end

UserInputService.WindowFocused:Connect(function()
	AfkEvent:FireServer(false)
end)

UserInputService.WindowFocusReleased:Connect(function()
	AfkEvent:FireServer(true)
end)

