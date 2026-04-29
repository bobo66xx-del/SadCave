local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local DEFAULT_COLOR = Color3.fromRGB(225, 215, 200)
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IS_DESKTOP = not IS_MOBILE

local DESKTOP_BILLBOARD_SIZE = UDim2.new(0, 280, 0, 80)
local DESKTOP_TITLE_SIZE = UDim2.new(1, 0, 0, 22)
local DESKTOP_TITLE_POSITION = UDim2.new(0, 0, 0, 0)
local DESKTOP_NAME_SIZE = UDim2.new(1, 0, 0, 41)
local DESKTOP_NAME_POSITION = UDim2.new(0, 0, 0, 28)
local NAME_TAG_MAX_DISTANCE = 50

local MOVING_SPEED_THRESHOLD = 10
local MOVING_FADE_DELAY = 2
local STILLNESS_RESTORE_DELAY = 0.4
local STILLNESS_FADE_TIME = 0.6
local DISTANCE_FADE_START = 20
local DISTANCE_FADE_SOFT_END = 40
local DISTANCE_SOFT_AMOUNT = 0.85

local controllers = {}

local function blendColor(fromColor, toColor, alpha)
	return Color3.new(
		fromColor.R + (toColor.R - fromColor.R) * alpha,
		fromColor.G + (toColor.G - fromColor.G) * alpha,
		fromColor.B + (toColor.B - fromColor.B) * alpha
	)
end

local function brighten(color, amount)
	return Color3.new(
		math.clamp(color.R + amount, 0, 1),
		math.clamp(color.G + amount, 0, 1),
		math.clamp(color.B + amount, 0, 1)
	)
end

local function disconnectAll(connections)
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
end

local function setIfDifferent(instance, propertyName, value)
	if instance[propertyName] ~= value then
		instance[propertyName] = value
	end
end

local function clearEffectChildren(titleLabel)
	local shimmer = titleLabel:FindFirstChild("TitleShimmerGradient")
	if shimmer then
		shimmer:Destroy()
	end

	local stroke = titleLabel:FindFirstChild("TitleGlowStroke")
	if stroke then
		stroke:Destroy()
	end
end

local function readEffectState(billboard)
	local effect = billboard:GetAttribute("TitleEffect")
	if typeof(effect) ~= "string" then
		effect = "none"
	end

	local tintColor = billboard:GetAttribute("TitleTintColor")
	if typeof(tintColor) ~= "Color3" then
		tintColor = DEFAULT_COLOR
	end

	return effect, tintColor
end

local function applyDesktopSizing(billboard, titleLabel, nameLabel)
	if not IS_DESKTOP then
		return
	end

	setIfDifferent(billboard, "Size", DESKTOP_BILLBOARD_SIZE)
	setIfDifferent(titleLabel, "TextSize", 16)
	setIfDifferent(titleLabel, "Size", DESKTOP_TITLE_SIZE)
	setIfDifferent(titleLabel, "Position", DESKTOP_TITLE_POSITION)
	setIfDifferent(nameLabel, "TextSize", 25)
	setIfDifferent(nameLabel, "Size", DESKTOP_NAME_SIZE)
	setIfDifferent(nameLabel, "Position", DESKTOP_NAME_POSITION)
end

local function applyMaxDistance(billboard)
	setIfDifferent(billboard, "MaxDistance", NAME_TAG_MAX_DISTANCE)
end

local function readBaselineTransparency(billboard, titleLabel)
	local baseline = billboard:GetAttribute("TitleBaselineTransparency")
	if typeof(baseline) ~= "number" then
		baseline = math.clamp(titleLabel.TextTransparency, 0, 1)
		billboard:SetAttribute("TitleBaselineTransparency", baseline)
	end

	return math.clamp(baseline, 0, 1)
end

local function getDistanceFadeAmount(billboard)
	local camera = Workspace.CurrentCamera
	local adornee = billboard.Adornee
	if not camera or not adornee or not adornee:IsA("BasePart") then
		return 0
	end

	local distance = (camera.CFrame.Position - adornee.Position).Magnitude
	if distance <= DISTANCE_FADE_START then
		return 0
	end

	if distance <= DISTANCE_FADE_SOFT_END then
		local alpha = (distance - DISTANCE_FADE_START) / (DISTANCE_FADE_SOFT_END - DISTANCE_FADE_START)
		return math.clamp(alpha * DISTANCE_SOFT_AMOUNT, 0, DISTANCE_SOFT_AMOUNT)
	end

	return 1
end

local function moveToward(current, target, amount)
	if current < target then
		return math.min(current + amount, target)
	end

	if current > target then
		return math.max(current - amount, target)
	end

	return current
end

local function updateTitlePresenceFade(billboard, controller, now, dt)
	local titleLabel = controller.titleLabel
	local adornee = billboard.Adornee
	if not titleLabel or not titleLabel.Parent or not adornee or not adornee:IsA("BasePart") or not adornee.Parent then
		return
	end

	local speed = adornee.AssemblyLinearVelocity.Magnitude
	if speed > MOVING_SPEED_THRESHOLD then
		controller.velocityHighSince = controller.velocityHighSince or now
		controller.velocityLowSince = nil

		if now - controller.velocityHighSince >= MOVING_FADE_DELAY then
			controller.targetStillnessFade = 1
		end
	else
		controller.velocityLowSince = controller.velocityLowSince or now
		controller.velocityHighSince = nil

		if now - controller.velocityLowSince >= STILLNESS_RESTORE_DELAY then
			controller.targetStillnessFade = 0
		end
	end

	local fadeStep = if STILLNESS_FADE_TIME > 0 then dt / STILLNESS_FADE_TIME else 1
	controller.currentStillnessFade = moveToward(
		controller.currentStillnessFade,
		controller.targetStillnessFade,
		math.clamp(fadeStep, 0, 1)
	)

	local distanceFade = getDistanceFadeAmount(billboard)
	local fadeAmount = 1 - (1 - controller.currentStillnessFade) * (1 - distanceFade)
	local appliedTransparency = controller.titleBaselineTransparency
		+ (1 - controller.titleBaselineTransparency) * math.clamp(fadeAmount, 0, 1)

	if math.abs(titleLabel.TextTransparency - appliedTransparency) > 0.001 then
		titleLabel.TextTransparency = appliedTransparency
	end
end

local function applyEffect(billboard, titleLabel, nameLabel)
	local existing = controllers[billboard]
	local currentStillnessFade = if existing then existing.currentStillnessFade else 0
	local targetStillnessFade = if existing then existing.targetStillnessFade else 0
	local velocityHighSince = if existing then existing.velocityHighSince else nil
	local velocityLowSince = if existing then existing.velocityLowSince else nil

	if existing then
		existing.cleanup()
	end

	clearEffectChildren(titleLabel)

	local connections = {}
	local tweens = {}
	local alive = true

	local function cleanup()
		if not alive then
			return
		end

		alive = false
		for _, tween in ipairs(tweens) do
			tween:Cancel()
		end
		disconnectAll(connections)
		clearEffectChildren(titleLabel)
	end

	local controller = {
		cleanup = cleanup,
		titleLabel = titleLabel,
		titleBaselineTransparency = readBaselineTransparency(billboard, titleLabel),
		currentStillnessFade = currentStillnessFade,
		targetStillnessFade = targetStillnessFade,
		velocityHighSince = velocityHighSince,
		velocityLowSince = velocityLowSince,
	}
	controllers[billboard] = controller

	applyDesktopSizing(billboard, titleLabel, nameLabel)
	applyMaxDistance(billboard)

	local effect, tintColor = readEffectState(billboard)

	if effect == "tint" then
		titleLabel.TextColor3 = tintColor
	elseif effect == "shimmer" then
		titleLabel.TextColor3 = DEFAULT_COLOR

		local gradient = Instance.new("UIGradient")
		gradient.Name = "TitleShimmerGradient"
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, blendColor(DEFAULT_COLOR, tintColor, 0.2)),
			ColorSequenceKeypoint.new(0.5, blendColor(DEFAULT_COLOR, tintColor, 0.7)),
			ColorSequenceKeypoint.new(1, blendColor(DEFAULT_COLOR, tintColor, 0.2)),
		})
		gradient.Offset = Vector2.new(-1, 0)
		gradient.Parent = titleLabel

		local tween = TweenService:Create(
			gradient,
			TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false),
			{ Offset = Vector2.new(1, 0) }
		)
		table.insert(tweens, tween)
		tween:Play()
	elseif effect == "pulse" then
		titleLabel.TextColor3 = tintColor

		local tween = TweenService:Create(
			titleLabel,
			TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ TextColor3 = brighten(tintColor, 0.05) }
		)
		table.insert(tweens, tween)
		tween:Play()
	elseif effect == "glow" then
		titleLabel.TextColor3 = tintColor

		local stroke = Instance.new("UIStroke")
		stroke.Name = "TitleGlowStroke"
		stroke.Color = tintColor
		stroke.Thickness = 2
		stroke.Transparency = 0.85
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = titleLabel
	else
		titleLabel.TextColor3 = DEFAULT_COLOR
	end

	table.insert(connections, billboard:GetAttributeChangedSignal("TitleEffect"):Connect(function()
		applyEffect(billboard, titleLabel, nameLabel)
	end))
	table.insert(connections, billboard:GetAttributeChangedSignal("TitleTintColor"):Connect(function()
		applyEffect(billboard, titleLabel, nameLabel)
	end))
	if IS_DESKTOP then
		table.insert(connections, billboard:GetPropertyChangedSignal("Size"):Connect(function()
			applyDesktopSizing(billboard, titleLabel, nameLabel)
		end))
		table.insert(connections, titleLabel:GetPropertyChangedSignal("Size"):Connect(function()
			applyDesktopSizing(billboard, titleLabel, nameLabel)
		end))
		table.insert(connections, titleLabel:GetPropertyChangedSignal("Position"):Connect(function()
			applyDesktopSizing(billboard, titleLabel, nameLabel)
		end))
		table.insert(connections, titleLabel:GetPropertyChangedSignal("TextSize"):Connect(function()
			applyDesktopSizing(billboard, titleLabel, nameLabel)
		end))
		table.insert(connections, nameLabel:GetPropertyChangedSignal("Size"):Connect(function()
			applyDesktopSizing(billboard, titleLabel, nameLabel)
		end))
		table.insert(connections, nameLabel:GetPropertyChangedSignal("Position"):Connect(function()
			applyDesktopSizing(billboard, titleLabel, nameLabel)
		end))
		table.insert(connections, nameLabel:GetPropertyChangedSignal("TextSize"):Connect(function()
			applyDesktopSizing(billboard, titleLabel, nameLabel)
		end))
	end
	table.insert(connections, billboard:GetPropertyChangedSignal("MaxDistance"):Connect(function()
		applyMaxDistance(billboard)
	end))
	table.insert(connections, titleLabel.AncestryChanged:Connect(function(_, parent)
		if not parent then
			cleanup()
			controllers[billboard] = nil
		end
	end))
	table.insert(connections, nameLabel.AncestryChanged:Connect(function(_, parent)
		if not parent then
			cleanup()
			controllers[billboard] = nil
		end
	end))
end

local function tryAttach(billboard)
	if controllers[billboard] or not billboard:IsA("BillboardGui") or billboard.Name ~= "NameTag" then
		return
	end

	local titleLabel = billboard:FindFirstChild("TitleLabel") or billboard:WaitForChild("TitleLabel", 10)
	if not titleLabel or not titleLabel:IsA("TextLabel") then
		return
	end

	local nameLabel = billboard:FindFirstChild("NameLabel") or billboard:WaitForChild("NameLabel", 10)
	if not nameLabel or not nameLabel:IsA("TextLabel") then
		return
	end

	applyEffect(billboard, titleLabel, nameLabel)
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
	if descendant:IsA("BillboardGui") and descendant.Name == "NameTag" then
		task.spawn(tryAttach, descendant)
	end
end

Workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("BillboardGui") and descendant.Name == "NameTag" then
		task.defer(tryAttach, descendant)
	end
end)

RunService.Heartbeat:Connect(function(dt)
	local now = os.clock()

	for billboard, controller in pairs(controllers) do
		if not billboard.Parent then
			controller.cleanup()
			controllers[billboard] = nil
		else
			updateTitlePresenceFade(billboard, controller, now, dt)
		end
	end
end)
