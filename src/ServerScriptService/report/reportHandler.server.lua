-- // Variables

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Guis = ServerStorage:WaitForChild("Guis")
local Settings = require(ReplicatedStorage:WaitForChild("report"):WaitForChild("Settings"))
local notificationEvent = ReplicatedStorage:WaitForChild("Global_Events"):WaitForChild("Notification_Event")

local debounces = {
	playerReport = false,
	bugReport = false
}

-- // Main Logic

-- / Defined Functions

local function handleCooldown(debounceKey, cooldownTime)
	task.wait(cooldownTime * 60)
	debounces[debounceKey] = false
end

local function triggerUI(player, uiName, debounceKey, cooldown, cooldownTime)
	if not debounces[debounceKey] then
		Guis:WaitForChild(uiName):Clone().Parent = player.PlayerGui
		debounces[debounceKey] = true

		if cooldown then
			task.spawn(handleCooldown, debounceKey, cooldownTime)
		else
			debounces[debounceKey] = false
		end
	else
		notificationEvent:FireClient(player, "Active cooldown", 3, "#ff0000")
	end
end

local function checkCommands(player, message, commands, uiName, debounceKey, cooldown, cooldownTime)
	for _, command in pairs(commands) do
		if string.lower(message) == string.lower(command) and not player.PlayerGui:FindFirstChild(uiName) then
			triggerUI(player, uiName, debounceKey, cooldown, cooldownTime)
			break
		end
	end
end

-- /

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		checkCommands(player, message, Settings.playerReport_Config.commands, "playerReportUI", "playerReport", Settings.playerReport_Config.cooldown, Settings.playerReport_Config.cooldownTime)
		checkCommands(player, message, Settings.bugReport_Config.commands, "bugReportUI", "bugReport", Settings.bugReport_Config.cooldown, Settings.bugReport_Config.cooldownTime)
	end)
end)
