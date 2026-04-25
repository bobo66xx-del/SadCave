local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local TOOL_LIBRARY_NAME = "ToolLibrary"
local PICKUP_FOLDER_NAME = "ToolPickups"
local DEFAULT_MAX_ACTIVATION_DISTANCE = 10

local toolLibrary = ServerStorage:WaitForChild(TOOL_LIBRARY_NAME)
local pickupFolder = Workspace:WaitForChild(PICKUP_FOLDER_NAME)

local connectedPrompts = {}

local function getPickupModel(prompt: ProximityPrompt): Model?
	local model = prompt:FindFirstAncestorOfClass("Model")
	if not model or not model:IsDescendantOf(pickupFolder) then
		return nil
	end

	return model
end

local function getToolName(model: Model): string?
	local toolName = model:GetAttribute("ToolName")
	if typeof(toolName) == "string" and toolName ~= "" then
		return toolName
	end

	return nil
end

local function playerHasTool(player: Player, toolName: string): boolean
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack and backpack:FindFirstChild(toolName) then
		return true
	end

	local character = player.Character
	if character and character:FindFirstChild(toolName) then
		return true
	end

	return false
end

local function getBackpack(player: Player): Backpack?
	return player:FindFirstChildOfClass("Backpack") or player:WaitForChild("Backpack", 5)
end

local function applyPostPickupBehavior(model: Model, prompt: ProximityPrompt)
	local behavior = model:GetAttribute("PickupBehavior")
	if behavior == "SingleUse" then
		prompt.Enabled = false
	elseif behavior == "Cooldown" then
		-- Reserved for future cooldown behavior.
	end
end

local function grantTool(player: Player, prompt: ProximityPrompt)
	local model = getPickupModel(prompt)
	if not model then
		return
	end

	local toolName = getToolName(model)
	if not toolName then
		warn(string.format("[ToolPickupService] %s is missing a ToolName attribute.", model:GetFullName()))
		return
	end

	if playerHasTool(player, toolName) then
		return
	end

	local toolTemplate = toolLibrary:FindFirstChild(toolName)
	if not toolTemplate or not toolTemplate:IsA("Tool") then
		warn(string.format("[ToolPickupService] Missing tool template for %s.", toolName))
		return
	end

	local backpack = getBackpack(player)
	if not backpack then
		warn(string.format("[ToolPickupService] Backpack unavailable for %s.", player.Name))
		return
	end

	toolTemplate:Clone().Parent = backpack
	applyPostPickupBehavior(model, prompt)
end

local function configurePrompt(prompt: ProximityPrompt, toolName: string)
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.ActionText = "Pick Up"
	prompt.ObjectText = toolName
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = DEFAULT_MAX_ACTIVATION_DISTANCE
end

local function connectPrompt(prompt: ProximityPrompt)
	if connectedPrompts[prompt] then
		return
	end

	local model = getPickupModel(prompt)
	if not model then
		return
	end

	local toolName = getToolName(model)
	if not toolName then
		warn(string.format("[ToolPickupService] %s is missing a ToolName attribute.", model:GetFullName()))
		return
	end

	configurePrompt(prompt, toolName)
	connectedPrompts[prompt] = prompt.Triggered:Connect(function(player)
		grantTool(player, prompt)
	end)
end

for _, descendant in ipairs(pickupFolder:GetDescendants()) do
	if descendant:IsA("ProximityPrompt") then
		connectPrompt(descendant)
	end
end

pickupFolder.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("ProximityPrompt") then
		connectPrompt(descendant)
	end
end)

-- Temporary pickup placement is stored directly on the models in Workspace.ToolPickups.
-- Move those models in Explorer later if you want different world positions.
