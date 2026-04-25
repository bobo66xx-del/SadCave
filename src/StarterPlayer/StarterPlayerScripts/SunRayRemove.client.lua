local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local insideZonesFolder = Workspace:WaitForChild("InsideZones")
local sunRayPartsFolder = Workspace:WaitForChild("SunRayParts")

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Whitelist
overlapParams.MaxParts = 10

local currentState = nil
local CHECK_DELAY = 0.12

local function isHRPInsideAnyZone(hrp)
	overlapParams.FilterDescendantsInstances = {hrp}

	for _, zone in ipairs(insideZonesFolder:GetChildren()) do
		if zone:IsA("BasePart") then
			local parts = Workspace:GetPartBoundsInBox(zone.CFrame, zone.Size, overlapParams)
			if #parts > 0 then
				return true
			end
		end
	end

	return false
end

local function setSunRayTransparency(value)
	for _, part in ipairs(sunRayPartsFolder:GetChildren()) do
		if part:IsA("BasePart") then
			part.Transparency = value
		end
	end
end

local function updateSunRayTransparency()
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if isHRPInsideAnyZone(hrp) then
		if currentState ~= "Inside" then
			currentState = "Inside"
			setSunRayTransparency(0.8)
		end
	else
		if currentState ~= "Outside" then
			currentState = "Outside"
			setSunRayTransparency(1)
		end
	end
end

player.CharacterAdded:Connect(function(character)
	character:WaitForChild("HumanoidRootPart")
	task.wait(0.2)
	updateSunRayTransparency()
end)

task.spawn(function()
	while true do
		updateSunRayTransparency()
		task.wait(CHECK_DELAY)
	end
end)
