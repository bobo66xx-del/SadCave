local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local screenGui = script.Parent
screenGui.DisplayOrder = math.max(screenGui.DisplayOrder, 21)

local TAB_RESTING_POSITION = UDim2.new(1, 0, 0.5, 0)
local TAB_HOVER_POSITION = UDim2.new(1, 4, 0.5, 0)
local TAB_BACKGROUND = Color3.fromRGB(20, 18, 22)
local WARM_GREY = Color3.fromRGB(225, 215, 200)

local isOpen = false
local openRequested = nil
local closeRequested = nil

local button = Instance.new("TextButton")
button.Name = "EdgeTab"
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = TAB_RESTING_POSITION
button.Size = UDim2.new(0, 18, 0, 90)
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
label.Size = UDim2.new(1, 0, 0, 60)
label.BackgroundTransparency = 1
label.Font = Enum.Font.Gotham
label.Text = "titles"
label.TextSize = 10
label.TextColor3 = WARM_GREY
label.TextTransparency = 0.4
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
label.Rotation = -90
label.ZIndex = 31
label.Parent = button

local function tweenTab(backgroundTransparency, position)
	TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = backgroundTransparency,
		Position = position,
	}):Play()
end

local function fallbackDirectToggle()
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	local titleMenu = playerGui and playerGui:FindFirstChild("TitleMenu")
	local root = titleMenu and titleMenu:FindFirstChild("Root")

	if root and root:IsA("GuiObject") then
		root.Visible = not root.Visible
		isOpen = root.Visible
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
	end)

	closeRequested.Event:Connect(function()
		isOpen = false
	end)
end

button.MouseEnter:Connect(function()
	tweenTab(0.15, TAB_HOVER_POSITION)
end)

button.MouseLeave:Connect(function()
	tweenTab(0.25, TAB_RESTING_POSITION)
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
