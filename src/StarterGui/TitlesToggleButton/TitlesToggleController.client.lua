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

local isOpen = false
local hovering = false
local pressing = false
local openRequested = nil
local closeRequested = nil
local dotFadeTween = nil
local dotPulseTween = nil
local dotVisible = false
local previousOwnedSet = {}
local firstPayloadReceived = false

local button = Instance.new("TextButton")
button.Name = "EdgeTab"
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = TAB_RESTING_POSITION
button.Size = TAB_SIZE
button.BackgroundColor3 = TAB_BACKGROUND
button.BackgroundTransparency = 0.25
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
stroke.Transparency = 0.82
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
label.TextTransparency = 0.4
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
		root.Visible = not root.Visible
		isOpen = root.Visible
		if isOpen then
			clearNotifyDot()
		end
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
	end)

	closeRequested.Event:Connect(function()
		isOpen = false
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
	hovering = true
	if pressing and IS_DESKTOP then
		tweenTab(0.05, TAB_HOVER_POSITION)
	else
		tweenTab(0.15, TAB_HOVER_POSITION)
	end
end)

button.MouseLeave:Connect(function()
	hovering = false
	if pressing and IS_DESKTOP then
		tweenTab(0.05, TAB_RESTING_POSITION)
	else
		tweenTab(0.25, TAB_RESTING_POSITION)
	end
end)

button.MouseButton1Down:Connect(function()
	if not IS_DESKTOP then
		return
	end

	pressing = true
	TweenService:Create(button, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.05,
	}):Play()
end)

button.MouseButton1Up:Connect(function()
	if not IS_DESKTOP then
		return
	end

	pressing = false
	TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = if hovering then 0.15 else 0.25,
	}):Play()
end)

UserInputService.InputEnded:Connect(function(input)
	if not IS_DESKTOP or not pressing or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	pressing = false
	TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = if hovering then 0.15 else 0.25,
	}):Play()
end)

button.MouseButton1Click:Connect(function()
	if not openRequested or not closeRequested then
		fallbackDirectToggle()
		return
	end

	if isOpen then
		closeRequested:Fire()
	else
		openRequested:Fire()
	end
end)

task.spawn(connectMenuBindables)
task.spawn(connectTitleUpdates)
