local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local screenGui = script.Parent
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local barHeight = 6
local bumpHeight = if isMobile then 10 else 8

local progressionFolder = ReplicatedStorage:WaitForChild("Progression", 5)
if not progressionFolder then
	warn("[XPBar] ReplicatedStorage.Progression was not found")
	return
end

local XPUpdated = progressionFolder:WaitForChild("XPUpdated", 5)
local LevelUp = progressionFolder:WaitForChild("LevelUp", 5)

if not XPUpdated or not LevelUp then
	warn("[XPBar] Progression remotes were not found")
	return
end

local background = Instance.new("Frame")
background.Name = "Background"
background.AnchorPoint = Vector2.new(0, 1)
background.Position = UDim2.new(0, 0, 1, 0)
background.Size = UDim2.new(1, 0, 0, barHeight)
background.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
background.BackgroundTransparency = 0.55
background.BorderSizePixel = 0
background.ZIndex = 1
background.Parent = screenGui

local glow = Instance.new("Frame")
glow.Name = "Glow"
glow.AnchorPoint = Vector2.new(0, 0.5)
glow.Position = UDim2.new(0, 0, 0.5, 0)
glow.Size = UDim2.new(1, 0, 1, 0)
glow.BackgroundColor3 = Color3.fromRGB(225, 200, 160)
glow.BackgroundTransparency = 1
glow.BorderSizePixel = 0
glow.ZIndex = 2
glow.Parent = background

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.AnchorPoint = Vector2.new(0, 0.5)
fill.Position = UDim2.new(0, 0, 0.5, 0)
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(225, 200, 160)
fill.BackgroundTransparency = 0.6
fill.BorderSizePixel = 0
fill.ZIndex = 3
fill.Parent = background

local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "LevelLabel"
levelLabel.AnchorPoint = Vector2.new(0.5, 1)
levelLabel.Position = UDim2.new(0.5, 0, 1, -16)
levelLabel.Size = UDim2.new(0, 240, 0, 20)
levelLabel.BackgroundTransparency = 1
levelLabel.Font = Enum.Font.Gotham
levelLabel.TextSize = 14
levelLabel.TextColor3 = Color3.fromRGB(225, 215, 200)
levelLabel.TextTransparency = 1
levelLabel.Text = ""
levelLabel.ZIndex = 4
levelLabel.Parent = screenGui

local hoverDetector = Instance.new("TextButton")
hoverDetector.Name = "HoverDetector"
hoverDetector.AnchorPoint = Vector2.new(0, 1)
hoverDetector.Position = UDim2.new(0, 0, 1, -(barHeight + 12))
hoverDetector.Size = UDim2.new(1, 0, 0, barHeight + 12)
hoverDetector.BackgroundTransparency = 1
hoverDetector.BorderSizePixel = 0
hoverDetector.AutoButtonColor = false
hoverDetector.Text = ""
hoverDetector.TextTransparency = 1
hoverDetector.ZIndex = 5
hoverDetector.Parent = screenGui

local cachedLevel = 0
local cachedXPInLevel = 0
local cachedXPRequired = 1
local currentFillFraction = 0
local pendingFillFraction = nil
local levelUpAnimating = false
local revealToken = 0

local fillTween = nil
local labelTween = nil

local function playTween(instance, tweenInfo, properties)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

local function tweenFill(fraction, duration)
	currentFillFraction = math.clamp(fraction, 0, 1)

	if fillTween then
		fillTween:Cancel()
	end

	fillTween = playTween(fill, TweenInfo.new(duration or 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(currentFillFraction, 0, 1, 0),
	})
end

local function tweenLabel(transparency, duration)
	if labelTween then
		labelTween:Cancel()
	end

	labelTween = playTween(levelLabel, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		TextTransparency = transparency,
	})
end

local function getPayloadNumber(payload, key, fallback)
	if typeof(payload) == "table" and typeof(payload[key]) == "number" then
		return payload[key]
	end

	return fallback
end

local function updateFromPayload(payload)
	cachedLevel = getPayloadNumber(payload, "level", cachedLevel)
	cachedXPInLevel = getPayloadNumber(payload, "xpForCurrentLevel", cachedXPInLevel)
	cachedXPRequired = math.max(1, getPayloadNumber(payload, "xpForNextLevel", cachedXPRequired))

	local fraction = cachedXPInLevel / cachedXPRequired
	if levelUpAnimating then
		pendingFillFraction = fraction
	else
		tweenFill(fraction, 0.6)
	end
end

local function showProgressText()
	if levelUpAnimating then
		return
	end

	revealToken += 1
	local token = revealToken

	levelLabel.Text = string.format("level %d - %d / %d xp", cachedLevel, cachedXPInLevel, cachedXPRequired)
	tweenLabel(0, 0.4)

	task.delay(2, function()
		if token ~= revealToken or levelUpAnimating then
			return
		end

		tweenLabel(1, 0.6)
	end)
end

local function extractNewLevel(payload)
	if typeof(payload) == "table" and typeof(payload.newLevel) == "number" then
		return payload.newLevel
	end

	if typeof(payload) == "number" then
		return payload
	end

	return cachedLevel
end

local function playLevelUp(payload)
	levelUpAnimating = true
	revealToken += 1

	local newLevel = extractNewLevel(payload)
	levelLabel.Text = "level " .. tostring(newLevel)
	tweenLabel(0, 0.4)
	tweenFill(1, 0.35)

	playTween(fill, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0, bumpHeight),
	})
	playTween(glow, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.75,
		Size = UDim2.new(1, 0, 0, bumpHeight),
	})

	task.wait(0.35)

	playTween(fill, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0),
	})
	playTween(glow, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	})

	task.wait(2)
	tweenLabel(1, 0.6)
	task.wait(0.6)

	levelUpAnimating = false
	tweenFill(pendingFillFraction or currentFillFraction, 0.3)
	pendingFillFraction = nil
end

XPUpdated.OnClientEvent:Connect(updateFromPayload)
LevelUp.OnClientEvent:Connect(function(payload)
	task.spawn(playLevelUp, payload)
end)

hoverDetector.MouseEnter:Connect(showProgressText)
hoverDetector.Activated:Connect(showProgressText)

-- TODO: Listen to TitleRemotes.TitleDataUpdated for new-title fades when TitleService v2 ships.
