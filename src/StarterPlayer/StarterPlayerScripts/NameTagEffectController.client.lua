local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local DEFAULT_COLOR = Color3.fromRGB(225, 215, 200)
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

local function applyEffect(billboard, titleLabel)
	local existing = controllers[billboard]
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

	controllers[billboard] = {
		cleanup = cleanup,
	}

	local effect, tintColor = readEffectState(billboard)

	if effect == "tint" then
		titleLabel.TextColor3 = tintColor
	elseif effect == "shimmer" then
		titleLabel.TextColor3 = DEFAULT_COLOR

		local gradient = Instance.new("UIGradient")
		gradient.Name = "TitleShimmerGradient"
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, blendColor(DEFAULT_COLOR, tintColor, 0.25)),
			ColorSequenceKeypoint.new(0.5, blendColor(DEFAULT_COLOR, tintColor, 0.9)),
			ColorSequenceKeypoint.new(1, blendColor(DEFAULT_COLOR, tintColor, 0.25)),
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
			{ TextColor3 = brighten(tintColor, 0.08) }
		)
		table.insert(tweens, tween)
		tween:Play()
	elseif effect == "glow" then
		titleLabel.TextColor3 = tintColor

		local stroke = Instance.new("UIStroke")
		stroke.Name = "TitleGlowStroke"
		stroke.Color = tintColor
		stroke.Thickness = 1
		stroke.Transparency = 0.55
		stroke.Parent = titleLabel
	else
		titleLabel.TextColor3 = DEFAULT_COLOR
	end

	table.insert(connections, billboard:GetAttributeChangedSignal("TitleEffect"):Connect(function()
		applyEffect(billboard, titleLabel)
	end))
	table.insert(connections, billboard:GetAttributeChangedSignal("TitleTintColor"):Connect(function()
		applyEffect(billboard, titleLabel)
	end))
	table.insert(connections, titleLabel.AncestryChanged:Connect(function(_, parent)
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

	applyEffect(billboard, titleLabel)
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

RunService.Heartbeat:Connect(function()
	for billboard, controller in pairs(controllers) do
		if not billboard.Parent then
			controller.cleanup()
			controllers[billboard] = nil
		end
	end
end)
