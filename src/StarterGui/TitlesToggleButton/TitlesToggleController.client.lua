local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local screenGui = script.Parent
local player = Players.LocalPlayer

local button = Instance.new("TextButton")
button.Name = "Button"
button.AnchorPoint = Vector2.new(1, 0)
button.Position = UDim2.new(1, -60, 0, 24)
button.Size = UDim2.new(0, 80, 0, 24)
button.BackgroundColor3 = Color3.fromRGB(20, 18, 22)
button.BackgroundTransparency = 0.25
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Font = Enum.Font.Gotham
button.Text = "titles"
button.TextSize = 13
button.TextColor3 = Color3.fromRGB(225, 215, 200)
button.TextTransparency = 0.05
button.ZIndex = 10
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(225, 215, 200)
stroke.Transparency = 0.82
stroke.Thickness = 1
stroke.Parent = button

local function tweenButton(backgroundTransparency, strokeTransparency)
	TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = backgroundTransparency,
	}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = strokeTransparency,
	}):Play()
end

button.MouseEnter:Connect(function()
	tweenButton(0.15, 0.65)
end)

button.MouseLeave:Connect(function()
	tweenButton(0.25, 0.82)
end)

button.MouseButton1Click:Connect(function()
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	local titleMenu = playerGui and playerGui:FindFirstChild("TitleMenu")
	local root = titleMenu and titleMenu:FindFirstChild("Root")

	if root and root:IsA("GuiObject") then
		root.Visible = not root.Visible
	else
		warn("[TitlesToggle] TitleMenu.Root was not ready")
	end
end)
