-- LocalScript: CoreGuiBackpackDisabler
-- Single source of truth for suppressing Roblox's default backpack/hotbar.
--
-- Why this exists:
-- Tools are granted to Backpack/StarterGear at times that do not line up with spawn-only
-- timers (for example ServerScriptService.DelayedStarterTools gives tools 12 seconds after
-- spawn). If Backpack CoreGui is not continuously owned by one client controller, Roblox can
-- briefly restore the default hotbar over the custom one.

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local DEBUG = true
local WATCHDOG_INTERVAL = 1
local BURST_REAPPLY_COUNT = 15
local BURST_REAPPLY_INTERVAL = 0.1

local player = Players.LocalPlayer
if not player then
	return
end

local backpackConnections = {}
local characterConnections = {}
local playerGuiConnections = {}
local burstToken = 0
local avalogObserverScope = nil

local function debugLog(message: string)
	if DEBUG then
		print("[BackpackCoreGuiController] " .. message)
	end
end

local function warnLog(message: string)
	warn("[BackpackCoreGuiController] " .. message)
end

local function disconnectConnections(connections)
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)
end

local function getBackpackEnabled(): boolean?
	local ok, enabled = pcall(function()
		return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
	end)

	if ok then
		return enabled
	end

	return nil
end

local function disableBackpack(reason: string, shouldLog: boolean?)
	local enabledBefore = getBackpackEnabled()
	if enabledBefore == true then
		warnLog(string.format("Detected Backpack CoreGui enabled unexpectedly; forcing off (%s)", reason))
	end

	local ok, err = pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)

	if not ok then
		warnLog(string.format("Failed to disable Backpack CoreGui (%s): %s", reason, tostring(err)))
		return
	end

	if shouldLog then
		debugLog(string.format("Backpack CoreGui disabled (%s)", reason))
	end
end

local function startDisableBurst(reason: string, count: number?)
	burstToken += 1
	local currentToken = burstToken
	local totalCount = count or BURST_REAPPLY_COUNT

	debugLog(string.format("Starting backpack suppression burst (%s)", reason))

	task.spawn(function()
		for _ = 1, totalCount do
			if currentToken ~= burstToken then
				return
			end

			disableBackpack(reason, false)
			task.wait(BURST_REAPPLY_INTERVAL)
		end
	end)
end

local function onToolEvent(containerName: string, action: string, tool: Instance)
	debugLog(string.format("Tool %s in %s: %s", action, containerName, tool.Name))
	disableBackpack(string.format("%s %s %s", containerName, action, tool.Name), true)
	startDisableBurst(string.format("%s %s %s", containerName, action, tool.Name))
end

local function hookBackpack(backpack: Backpack)
	disconnectConnections(backpackConnections)
	debugLog("Hooked Backpack listeners")

	table.insert(backpackConnections, backpack.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			onToolEvent("Backpack", "added", child)
		end
	end))

	table.insert(backpackConnections, backpack.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			onToolEvent("Backpack", "removed", child)
		end
	end))
end

local function hookCharacter(character: Model)
	disconnectConnections(characterConnections)
	debugLog(string.format("Character respawned: %s", character.Name))
	disableBackpack("CharacterAdded", true)
	startDisableBurst("CharacterAdded")

	table.insert(characterConnections, character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			onToolEvent("Character", "added", child)
		end
	end))

	table.insert(characterConnections, character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			onToolEvent("Character", "removed", child)
		end
	end))

	local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
	if backpack then
		hookBackpack(backpack)
	end
end

local function hookPlayerGui(playerGui: PlayerGui)
	disconnectConnections(playerGuiConnections)
	debugLog("Hooked PlayerGui listeners")

	local function onGuiChanged(action: string, child: Instance)
		if child:IsA("LayerCollector") then
			debugLog(string.format("PlayerGui %s: %s", action, child.Name))
			disableBackpack(string.format("PlayerGui %s %s", action, child.Name), true)
			task.defer(function()
				disableBackpack(string.format("PlayerGui deferred %s %s", action, child.Name), false)
			end)
			startDisableBurst(string.format("PlayerGui %s %s", action, child.Name), 8)
		end
	end

	table.insert(playerGuiConnections, playerGui.ChildAdded:Connect(function(child)
		onGuiChanged("added", child)
	end))

	table.insert(playerGuiConnections, playerGui.ChildRemoved:Connect(function(child)
		onGuiChanged("removed", child)
	end))
end

local function hookAvalog()
	local ok, Fusion, States = pcall(function()
		local avalogFolder = Workspace:WaitForChild("Avalog", 5)
		local avalogModule = avalogFolder and avalogFolder:WaitForChild("Avalog", 5)
		local avalogPackage = avalogModule and avalogModule:WaitForChild("Packages", 5):WaitForChild("Avalog", 5)
		local fusionModule = avalogPackage and avalogPackage.Parent:WaitForChild("Fusion", 5)
		local statesModule = avalogPackage and avalogPackage.SourceCode.Client.UI:WaitForChild("States", 5)
		return require(fusionModule), require(statesModule)
	end)

	if not ok or not Fusion or not States or not States.Open then
		warnLog("Avalog state hook unavailable; backpack suppression will rely on general listeners")
		return
	end

	avalogObserverScope = Fusion.scoped(Fusion)
	avalogObserverScope:Observer(States.Open):onChange(function()
		local isOpen = Fusion.peek(States.Open)
		debugLog(isOpen and "Avalog opened" or "Avalog closed")
		disableBackpack(isOpen and "Avalog opened" or "Avalog closed", true)
		startDisableBurst(isOpen and "Avalog opened" or "Avalog closed")
	end)

	debugLog("Avalog observer connected")
	disableBackpack("Avalog observer connected", true)
end

disableBackpack("Initial join", true)
startDisableBurst("Initial join")

local backpack = player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
if backpack then
	hookBackpack(backpack)
end

local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 5)
if playerGui then
	hookPlayerGui(playerGui)
end

if player.Character then
	hookCharacter(player.Character)
end

player.CharacterAdded:Connect(hookCharacter)
player.CharacterRemoving:Connect(function(character)
	debugLog(string.format("Character removing: %s", character.Name))
	disableBackpack("CharacterRemoving", true)
	startDisableBurst("CharacterRemoving", 6)
end)

player.ChildAdded:Connect(function(child)
	if child:IsA("Backpack") then
		debugLog("Player received Backpack instance")
		hookBackpack(child)
		disableBackpack("Backpack instance added", true)
		startDisableBurst("Backpack instance added")
	elseif child:IsA("PlayerGui") then
		debugLog("PlayerGui rebuilt")
		hookPlayerGui(child)
		disableBackpack("PlayerGui rebuilt", true)
		startDisableBurst("PlayerGui rebuilt")
	end
end)

hookAvalog()

task.spawn(function()
	while true do
		task.wait(WATCHDOG_INTERVAL)
		local enabled = getBackpackEnabled()
		if enabled == true then
			warnLog("Watchdog detected Backpack CoreGui enabled without controller approval")
			disableBackpack("Watchdog recovery", true)
			startDisableBurst("Watchdog recovery", 10)
		end
	end
end)
