local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = ReplicatedStorage.Remotes.Theme

event.OnServerEvent:Connect(function(player,hsv,newcolor)
	if player.UserId == 1132193781 or player.UserId == 1 then
		game.Lighting.AfterPulseColor.Value = newcolor
	end

end)
