local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function fixCamera(char)
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Custom
	local humanoid = char:WaitForChild("Humanoid")
	cam.CameraSubject = humanoid
end

player.CharacterAdded:Connect(fixCamera)
if player.Character then fixCamera(player.Character) end
