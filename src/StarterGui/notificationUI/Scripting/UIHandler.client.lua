-- // Variables

local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local notificationsModule = require(script.Parent:WaitForChild("NotificationsHandler"))
local notificationEvent = ReplicatedStorage:WaitForChild("Global_Events"):WaitForChild("Notification_Event")

local debounce = false

-- // Main

notificationEvent.OnClientEvent:Connect(function(Title, Time, Color)
	if not debounce then
		debounce = true
		notificationsModule.new(Title, Time, Color)
		task.wait(1)
		debounce = false
	end
end)
