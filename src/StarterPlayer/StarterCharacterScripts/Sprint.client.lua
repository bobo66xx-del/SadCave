local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local plr = game.Players.LocalPlayer
local char = workspace:WaitForChild(plr.Name)
local humanoid = char:WaitForChild("Humanoid")

local normalSpeed = 16
local runSpeed = plr:WaitForChild("RunValue").Value -- your custom speed

-- RUN WHEN SHIFT PRESSED
uis.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		local info = TweenInfo.new(0.5)
		local tween = tweenService:Create(humanoid, info, {WalkSpeed = runSpeed})
		tween:Play()
	end
end)

-- STOP RUNNING WHEN SHIFT RELEASED
uis.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift then
		local info = TweenInfo.new(0.5)
		local tween = tweenService:Create(humanoid, info, {WalkSpeed = normalSpeed})
		tween:Play()
	end
end)
