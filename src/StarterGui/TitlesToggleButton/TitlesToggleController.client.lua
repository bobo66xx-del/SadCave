local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local screenGui = script.Parent
screenGui.DisplayOrder = math.max(screenGui.DisplayOrder, 21)

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local IS_DESKTOP = not IS_MOBILE

local TAB_RESTING_POSITION = UDim2.new(1, 0, 0.5, 0)
local TAB_HOVER_POSITION = UDim2.new(1, 4, 0.5, 0)
local TAB_SIZE = if IS_DESKTOP then UDim2.new(0, 24, 0, 120) else UDim2.new(0, 18, 0, 90)
local LABEL_SIZE = if IS_DESKTOP then UDim2.new(1, 0, 0.67, 0) else UDim2.new(1, 0, 0, 60)
local LABEL_TEXT_SIZE = if IS_DESKTOP then 13 else 10
local TAB_BACKGROUND = Color3.fromRGB(20, 18, 22)
local WARM_GREY = Color3.fromRGB(225, 215, 200)
local TAB_RESTING_BACKGROUND_TRANSPARENCY = 0.25
local TAB_HOVER_BACKGROUND_TRANSPARENCY = 0.15
local TAB_PRESS_BACKGROUND_TRANSPARENCY = 0.05
local TAB_LABEL_TRANSPARENCY = 0.4
local TAB_LABEL_HOVER_TRANSPARENCY = 0.2
local TAB_STROKE_TRANSPARENCY = 0.82
local RECESS_SIZE = if IS_DESKTOP then UDim2.new(0, 2, 0, 130) else UDim2.new(0, 2, 0, 100)
local RECESS_BACKGROUND = Color3.fromRGB(15, 15, 17)
local RECESS_BACKGROUND_TRANSPARENCY = 0.25

local isOpen = false
local hovering = false
local pressing = false
local openRequested = nil
local closeRequested = nil
local tabVisibilityTweens = {}
local labelHoverTween = nil
local dotFadeTween = nil
local dotPulseTween = nil
local dotVisible = false
local previousOwnedSet = {}
local firstPayloadReceived = false

local edgeRecess = Instance.new("Frame")
edgeRecess.Name = "EdgeRecess"
edgeRecess.AnchorPoint = Vector2.new(1, 0.5)
edgeRecess.Position = TAB_RESTING_POSITION
edgeRecess.Size = RECESS_SIZE
edgeRecess.BackgroundColor3 = RECESS_BACKGROUND
edgeRecess.BackgroundTransparency = RECESS_BACKGROUND_TRANSPARENCY
edgeRecess.BorderSizePixel = 0
edgeRecess.ZIndex = 29
edgeRecess.Parent = screenGui

local button = Instance.new("TextButton")
button.Name = "EdgeTab"
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = TAB_RESTING_POSITION
button.Size = TAB_SIZE
button.BackgroundColor3 = TAB_BACKGROUND
button.BackgroundTransparency = TAB_RESTING_BACKGROUND_TRANSPARENCY
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Text = ""
button.ZIndex = 30
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 4)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = WARM_GREY
stroke.Transparency = TAB_STROKE_TRANSPARENCY
stroke.Thickness = 1
stroke.Parent = button

local label = Instance.new("TextLabel")
label.Name = "Label"
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.new(0.5, 0, 0.5, 0)
label.Size = LABEL_SIZE
label.BackgroundTransparency = 1
label.Font = Enum.Font.Gotham
label.Text = "titles"
label.TextSize = LABEL_TEXT_SIZE
label.TextColor3 = WARM_GREY
label.TextTransparency = TAB_LABEL_TRANSPARENCY
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
label.Rotation = -90
label.ZIndex = 31
label.Parent = button

local notifyDot = Instance.new("Frame")
notifyDot.Name = "NotifyDot"
notifyDot.AnchorPoint = Vector2.new(0.5, 1)
notifyDot.Position = UDim2.new(0.5, 0, 1, -8)
notifyDot.Size = UDim2.new(0, 6, 0, 6)
notifyDot.BackgroundColor3 = WARM_GREY
notifyDot.BackgroundTransparency = 1
notifyDot.BorderSizePixel = 0
notifyDot.ZIndex = 32
notifyDot.Parent = button

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = notifyDot

local function tweenTab(backgroundTransparency, position)
	TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = backgroundTransparency,
		Position = position,
	}):Play()
end

local function cancelLabelHoverTween()
	if labelHoverTween then
		labelHoverTween:Cancel()
		labelHoverTween = nil
	end
end

local function tweenLabelTransparency(textTransparency, duration)
	cancelLabelHoverTween()

	local tween = TweenService:Create(label, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		TextTransparency = textTransparency,
	})
	labelHoverTween = tween
	tween.Completed:Connect(function()
		if labelHoverTween == tween then
			labelHoverTween = nil
		end
	end)
	tween:Play()
end

local function cancelDotTweens()
	if dotFadeTween then
		dotFadeTween:Cancel()
		dotFadeTween = nil
	end

	if dotPulseTween then
		dotPulseTween:Cancel()
		dotPulseTween = nil
	end
end

local function startDotPulse()
	if not dotVisible then
		return
	end

	if dotPulseTween then
		dotPulseTween:Cancel()
	end

	notifyDot.BackgroundTransparency = 0.6
	dotPulseTween = TweenService:Create(
		notifyDot,
		TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ BackgroundTransparency = 0.2 }
	)
	dotPulseTween:Play()
end

local function showNotifyDot()
	dotVisible = true
	cancelDotTweens()

	if isOpen then
		notifyDot.BackgroundTransparency = 1
		return
	end

	local tween = TweenService:Create(
		notifyDot,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.4 }
	)
	dotFadeTween = tween
	tween.Completed:Connect(function(playbackState)
		if dotFadeTween ~= tween then
			return
		end

		dotFadeTween = nil
		if playbackState == Enum.PlaybackState.Completed then
			startDotPulse()
		end
	end)
	tween:Play()
end

local function cancelTabVisibilityTweens()
	for _, tween in ipairs(tabVisibilityTweens) do
		tween:Cancel()
	end

	table.clear(tabVisibilityTweens)
end

local function addTabVisibilityTween(instance, tweenInfo, goal)
	local tween = TweenService:Create(instance, tweenInfo, goal)
	table.insert(tabVisibilityTweens, tween)
	tween:Play()
end

local function setTabVisible(visible)
	cancelTabVisibilityTweens()
	cancelLabelHoverTween()

	if visible then
		button.Active = true
		addTabVisibilityTween(edgeRecess, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = RECESS_BACKGROUND_TRANSPARENCY,
		})
		addTabVisibilityTween(button, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = TAB_RESTING_BACKGROUND_TRANSPARENCY,
		})
		addTabVisibilityTween(label, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			TextTransparency = TAB_LABEL_TRANSPARENCY,
		})
		addTabVisibilityTween(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Transparency = TAB_STROKE_TRANSPARENCY,
		})

		if dotVisible then
			startDotPulse()
		else
			addTabVisibilityTween(notifyDot, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
			})
		end
	else
		hovering = false
		pressing = false
		button.Active = false
		addTabVisibilityTween(edgeRecess, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
		addTabVisibilityTween(button, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
		addTabVisibilityTween(label, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			TextTransparency = 1,
		})
		addTabVisibilityTween(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Transparency = 1,
		})
		addTabVisibilityTween(notifyDot, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
		})
	end
end

local function clearNotifyDot()
	if not dotVisible and notifyDot.BackgroundTransparency >= 1 then
		return
	end

	dotVisible = false
	cancelDotTweens()

	local tween = TweenService:Create(
		notifyDot,
		TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)
	dotFadeTween = tween
	tween.Completed:Connect(function()
		if dotFadeTween ~= tween then
			return
		end

		dotFadeTween = nil
	end)
	tween:Play()
end

local function normalizeOwnedTitleIds(titleIds)
	local ownedSet = {}
	if typeof(titleIds) ~= "table" then
		return ownedSet
	end

	for key, value in pairs(titleIds) do
		if typeof(value) == "string" then
			ownedSet[value] = true
		elseif value == true and typeof(key) == "string" then
			ownedSet[key] = true
		end
	end

	return ownedSet
end

local function hasNewOwnedTitle(nextOwnedSet)
	for titleId in pairs(nextOwnedSet) do
		if not previousOwnedSet[titleId] then
			return true
		end
	end

	return false
end

local function fallbackDirectToggle()
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	local titleMenu = playerGui and playerGui:FindFirstChild("TitleMenu")
	local root = titleMenu and titleMenu:FindFirstChild("Root")

	if root and root:IsA("GuiObject") then
		if isOpen then
			return
		end

		root.Visible = true
		isOpen = true
		clearNotifyDot()
		setTabVisible(false)
	else
		warn("[TitlesToggle] TitleMenu bindables and fallback Root were not ready")
	end
end

local function connectMenuBindables()
	local playerGui = player:WaitForChild("PlayerGui")
	local titleMenu = playerGui:WaitForChild("TitleMenu", 10)
	if not titleMenu then
		warn("[TitlesToggle] TitleMenu was not ready")
		return
	end

	openRequested = titleMenu:WaitForChild("OpenRequested", 5)
	closeRequested = titleMenu:WaitForChild("CloseRequested", 5)

	if not openRequested or not openRequested:IsA("BindableEvent") or not closeRequested or not closeRequested:IsA("BindableEvent") then
		warn("[TitlesToggle] TitleMenu bindables were not ready; falling back to direct Root toggle")
		openRequested = nil
		closeRequested = nil
		return
	end

	openRequested.Event:Connect(function()
		isOpen = true
		clearNotifyDot()
		setTabVisible(false)
	end)

	closeRequested.Event:Connect(function()
		isOpen = false
		setTabVisible(true)
	end)
end

local function connectTitleUpdates()
	local titleRemotes = ReplicatedStorage:WaitForChild("TitleRemotes", 10)
	if not titleRemotes then
		warn("[TitlesToggle] TitleRemotes were not ready")
		return
	end

	local titleDataUpdated = titleRemotes:WaitForChild("TitleDataUpdated", 10)
	if not titleDataUpdated then
		warn("[TitlesToggle] TitleDataUpdated was not ready")
		return
	end

	titleDataUpdated.OnClientEvent:Connect(function(payload)
		if typeof(payload) ~= "table" then
			return
		end

		local ownedTitleIds = payload.ownedTitleIds or payload.OwnedTitleIds
		if not ownedTitleIds then
			return
		end

		local nextOwnedSet = normalizeOwnedTitleIds(ownedTitleIds)

		if not firstPayloadReceived then
			previousOwnedSet = nextOwnedSet
			firstPayloadReceived = true
			return
		end

		if hasNewOwnedTitle(nextOwnedSet) then
			showNotifyDot()
		end

		previousOwnedSet = nextOwnedSet
	end)
end

button.MouseEnter:Connect(function()
	if isOpen then
		return
	end

	hovering = true
	if IS_DESKTOP then
		tweenLabelTransparency(TAB_LABEL_HOVER_TRANSPARENCY, 0.15)
	end

	if pressing and IS_DESKTOP then
		tweenTab(TAB_PRESS_BACKGROUND_TRANSPARENCY, TAB_HOVER_POSITION)
	else
		tweenTab(TAB_HOVER_BACKGROUND_TRANSPARENCY, TAB_HOVER_POSITION)
	end
end)

button.MouseLeave:Connect(function()
	if isOpen then
		return
	end

	hovering = false
	if IS_DESKTOP then
		tweenLabelTransparency(TAB_LABEL_TRANSPARENCY, 0.2)
	end

	if pressing and IS_DESKTOP then
		tweenTab(TAB_PRESS_BACKGROUND_TRANSPARENCY, TAB_RESTING_POSITION)
	else
		tweenTab(TAB_RESTING_BACKGROUND_TRANSPARENCY, TAB_RESTING_POSITION)
	end
end)

button.MouseButton1Down:Connect(function()
	if isOpen or not IS_DESKTOP then
		return
	end

	pressing = true
	TweenService:Create(button, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = TAB_PRESS_BACKGROUND_TRANSPARENCY,
	}):Play()
end)

button.MouseButton1Up:Connect(function()
	if isOpen or not IS_DESKTOP then
		return
	end

	pressing = false
	TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = if hovering then TAB_HOVER_BACKGROUND_TRANSPARENCY else TAB_RESTING_BACKGROUND_TRANSPARENCY,
	}):Play()
end)

UserInputService.InputEnded:Connect(function(input)
	if isOpen or not IS_DESKTOP or not pressing or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	pressing = false
	TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = if hovering then TAB_HOVER_BACKGROUND_TRANSPARENCY else TAB_RESTING_BACKGROUND_TRANSPARENCY,
	}):Play()
end)

button.MouseButton1Click:Connect(function()
	if isOpen then
		return
	end

	if not openRequested or not closeRequested then
		fallbackDirectToggle()
		return
	end

	openRequested:Fire()
end)

task.spawn(connectMenuBindables)
task.spawn(connectTitleUpdates)
