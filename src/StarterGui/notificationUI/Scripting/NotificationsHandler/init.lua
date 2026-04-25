-- // Variables

local Notifications_Frame = script.Parent.Parent:WaitForChild("Interface").Notifications
local notifications = {}

-- // Main

notifications.new = function(Title, Time, Color)
	local Notification = script.NotificationFrame:Clone()
	Notification.Title.Text = Title
	Notification.Color.BackgroundColor3 = Color3.fromHex(Color)
	Notification.Parent = Notifications_Frame

	Notification:TweenSize(UDim2.new(0, 200,0, 35), "Out", "Linear", 0.3, true)
	task.wait(Time)
	Notification:TweenSize(UDim2.new(0, 200,0, 0), "In", "Linear", 0.3, true)
	task.wait(0.4)
	Notification:Destroy()

	return Notification
end

return notifications
